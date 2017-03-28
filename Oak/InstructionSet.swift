public enum Parameter
{
    case immediate
    case fpImmediate
    case register
    case condition
    case offset
    case special
}

public enum AssemblyError: Error
{
    case wrongSection
    case unrecognizedDirective
    case unrecognizedLabel
    case unrecognizedInstruction
    case unavailableInstruction
    case unhandledSpecial
    case unhandledOptional
}

public class BitRange
{
    public var field: String
    public var condition: ((UInt) -> (Bool))?
    public var start: Int
    public var bits: Int

    public var totalBits: Int?
    public var limitStart: Int?
    public var limitEnd: Int?

    public var parameter: Int?
    public var parameterDefaultValue: UInt? //If the parameter is optional, it will default to this value
    public var parameterType: Parameter?
    public var signExtended: Bool

    public var end: Int
    {
        return start + bits - 1
    }
  
    public init(_ field: String, condition: ((UInt) -> (Bool))? = nil, at start: Int, bits: Int, totalBits: Int? = nil, limitStart: Int? = nil, limitEnd: Int? = nil, parameter: Int? = nil, parameterType: Parameter? = nil, parameterDefaultValue: UInt? = nil, signExtended: Bool = true)
    {
        self.field = field
        self.condition = condition
        self.start = start
        self.bits = bits
        self.totalBits = totalBits
        self.limitStart = limitStart
        self.limitEnd = limitEnd
        self.parameter = parameter
        self.parameterType = parameterType
        self.parameterDefaultValue = parameterDefaultValue
        self.signExtended = signExtended
    }
}

public class Format
{   
    public var ranges: [BitRange]
    public var regex: Regex
    public var disassembly: String
    
    //(address: UInt, text: String, bits: Int, labels: [String: UInt])
    public var processSpecialParameter: [String: ((String, UInt, Int, [String: UInt]) -> (errorMessage: String?, value: UInt))]
    public var disassembleSpecialParameter: [String: (UInt) -> (UInt)]

    public init(ranges: [BitRange],regex: Regex, specialParameterProcessors processSpecialParameter: [String: ((String, UInt, Int, [String: UInt]) -> (errorMessage: String?, value: UInt))] = [:], specialParameterDisassemblers disassembleSpecialParameter: [String: (UInt) -> (UInt)] = [:], disassembly: String)
    {
        self.ranges = ranges
        self.regex = regex
        self.disassembly = disassembly
        self.processSpecialParameter = processSpecialParameter
        self.disassembleSpecialParameter = disassembleSpecialParameter
    }        
}

public class Instruction
{
    public var mnemonic: String
    public var format: Format        
    public var constants: [String: UInt]
    public var available: Bool
    public var execute: (Core) throws -> ()
    
    /*
     Mask
     
     It's basically the bits of each format, but with Xs replacing parts that aren't constant in every instruction.
     Example, if this 8-bit ISA defines 5 bits for the register and 3 bits for the opcode, and the opcode for ADD is 101
     then the ADD instruction's mask is XXXXX101.
    */
    //TO-DO: This is broken for MIPS, as the BitRanges are not in order. Replace with more flexible algorithm (rip performance).
    var computedMask: String? //Used in a dynamic programming-y way. You can also precompute it if you're sure of the ISA's final design to skip the computation.
    var mask: String
    {
        if let computed = computedMask
        {
            return computed
        }
        
        var string = ""
        for range in self.format.ranges
        {
            if let constant = self.constants[range.field]
            {
                string += Utils.pad(constant, digits: range.bits, radix: 2)
            }
            else
            {
                for _ in 0..<range.bits
                {
                    string += "X"
                }
            }
        
        }
        self.computedMask = string
        return computedMask!
    }
    
    
    /*
     Template
     
     Like mask, except it's a 0 instead of a X, also an actual number and not a string of characters.
     The reason is simple: To allow the use of the | operator for easy assembly.
    */
    var computedTemplate: UInt? //See comment on precomputed mask above
    var template: UInt
    {
        if let computed = computedTemplate
        {
            return computed
        }
        
        var code: UInt = 0
        for range in self.format.ranges
        {
            if let constant = self.constants[range.field]
            {
                code =  code | (constant << UInt(bitPattern: range.start))
            }
            
        }
        
        self.computedTemplate = code
        return computedTemplate!
    }

    /*
     Bit Count
     
     If your ISA is some frankenstein that has the bit length for the same instruction vary, implement the closure. Also raise an issue so we can make the Assembler handle it.
     This is not used at all in fixed-length ISAs.
    */
    var calculateBits: ((String) -> (Int))? //line: String, bitLength: Int
    var computedBits: Int? //See precomputedMask
    var bits: Int
    {
        if let precomputedBits = computedBits
        {
            return precomputedBits
        }

        var count = 0
        for range in format.ranges
        {
            count += range.bits
        }

        computedBits = count
        return computedBits!
    }

    var bytes: Int
    {
        return (bits / 8) + (((bits % 8) > 0) ? 1 : 0)
    }
    
    func matches(_ machineCode: UInt) -> Bool
    {
        var machineCodeMutable = machineCode
        
        let characters = self.mask.characters.reversed() 
        
        for character in characters
        {
            if (String(character) != "X" && UInt(String(character)) != (machineCodeMutable & 1))
            {
                return false
            }
            machineCodeMutable = machineCodeMutable >> 1
        }

        return true
    }

    /*
     Instruction
     
     mnemonic: Assembly mnemonic for the ISA. Must be in all caps.
     format: Format for this instruction.
     constants: Opcodes and other such instruction-specified constants.
     executor: A closure that simulates what this function actually does.
     available: Optional. Set to false if you want this function to be unavailable during assembly and simulation.
     mask: Optional. See "computedMask".
     template: Optional. See "computedTemplate".
    */

    public init(_ mnemonic: String, format: Format, constants: [String: UInt], executor execute: @escaping (Core) throws -> (), available: Bool = true, mask precomputedMask: String? = nil, template precomputedTemplate: UInt? = nil)
    {
        self.mnemonic = mnemonic
        self.format = format
        self.constants = constants
        self.available = available
        self.computedMask = precomputedMask
        self.computedTemplate = precomputedTemplate
        self.execute = execute
    }
    
}

//TODO - Proper Psuedoinstructions
public class PseudoInstruction
{

}

public class InstructionSet
{
    private var formats: [Format]
    
    private var instructions: [Instruction]

    //Number of bits. Nil means variable length, and you'll need clever-er disassembly.
    internal var bits: Int8?
        
    //Length of Fixed-Length Decimals (Octets)
    public var fixedDecimalLength: Int?
    
    //Dictionary of Data Directives to Floating Point Length
    public var floatingPointLengths: [String: Int]

    //Array of abiNames
    public var abiNames: [String]

    //Endianness
    public var endianness: Endianness

    //Syntax
    public var keywordRegexes: [Keyword: String]?
    public var keywords: [Keyword: [String]]?
    public var directives: [String: Directive]

    //Assembly Conventions
    public var incrementOnFetch: Bool

    //Instruction Fetcher Functions
    public func instruction(matching: UInt) -> Instruction?
    {
        for instruction in instructions
        {
            if instruction.matches(matching)
            {
                return instruction
            }
        }
        
        return nil
    }
    
    public func instruction(for mnemonic: String) -> Instruction?
    {
        for instruction in instructions
        {
            if instruction.mnemonic == mnemonic.uppercased()
            {
                return instruction
            }
        }
        
        return nil
    }

    public func instruction(prefixing line: String) -> Instruction?
    {
        for instruction in instructions
        {
            if line.uppercased().hasPrefix(instruction.mnemonic)
            {
                return instruction
            }
        }
        
        return nil
    }
    
    
    public func disassemble(_ instruction: Instruction, arguments: [UInt]) -> String
    {
        var output = instruction.format.disassembly
        output = output.replacingOccurrences(of: "@mnem", with: instruction.mnemonic)
        for range in instruction.format.ranges
        {
            if let parameter = range.parameter
            {
                output = output.replacingOccurrences(of: "@arg\(parameter)", with: (range.parameterType == .register) ? abiNames[Int(arguments[parameter])] : "\(Int(bitPattern: arguments[parameter]))")
            }      
        }
        return output
    }
    
    /*
     InstructionSet initializer
     
     Either bits or a getBits closure has to be passed to the initializer or else it fails.
    */
    public init?
    (
        bits: Int8? = nil,
        formats: [Format],
        instructions: [Instruction],
        abiNames: [String],
        floatingPointLengths: [String: Int] = ["float": 4, "double": 8, "single": 4],
        endianness: Endianness = .little,
        keywordRegexes: [Keyword: String]? = nil,
        keywords: [Keyword: [String]]? = nil, 
        directives: [String: Directive] = [:],
        incrementOnFetch: Bool = true
    )
    {
        self.bits = bits
        self.formats = formats
        self.instructions = instructions.sorted(by: {$0.mnemonic.characters.count > $1.mnemonic.characters.count})
        self.abiNames = abiNames
        self.floatingPointLengths = floatingPointLengths
        self.endianness = endianness
        self.keywordRegexes = keywordRegexes
        self.keywords = keywords
        self.directives = directives
        self.incrementOnFetch = incrementOnFetch
    }

      
}
