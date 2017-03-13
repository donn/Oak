//These are errors with the emulation. They are not an implementation of exceptions.
public enum CoreError: Error
{
    case unavailableInstruction
    case unrecognizedInstruction
    case isaError
    case unknownError
}

public enum Endianness
{
    case little
    case big
    case bi
}

public enum CoreState
{
    case idle
    case running
    case error
    case environmentCall
    case environmentBreak
}

public enum EnvironmentCalls
{
    case terminate
}

//Core Protocols
public protocol Core
{
    var memory: Memory { get set }
    var instructionSet: InstructionSet { get }
    var state: CoreState { get set }
    var service: [UInt] { get }
    var registers:  [(abiName: String, value: UInt)] { get }
    var pc: UInt { get }

    var fetched: UInt { get set }    
    var decoded: Instruction? { get set }
    var rawValues: [UInt] { get set }
    var arguments: [UInt] { get set }
    var fields: [Int: String] { get set }
        
    func fetch() throws
    func loadProgram(machineCode: [UInt8]) throws
    func registerDump() -> String
}

extension Core
{
    mutating public func decode() throws -> String
    {
        self.decoded = nil
        self.arguments = [UInt](repeating: 0, count: 16)
        self.rawValues = [UInt](repeating: 0, count: 16)
        self.fields = [:]

        guard let instruction = instructionSet.instruction(matching: self.fetched)
        else
        {
            state = .error
            throw CoreError.unrecognizedInstruction
        }
        
        if !instruction.available
        {
            state = .error
            throw CoreError.unavailableInstruction
        }
        
        self.decoded = instruction
        
        let format = instruction.format
        let bitRanges = format.ranges;
        
        for range in bitRanges
        {
            if let parameter = range.parameter
            {
                var limit = 0
                
                fields[parameter] = range.field
                
                if let limits = Regex("([A-za-z]+)\\s*\\[\\s*(\\d+)\\s*:\\s*(\\d+)\\s*\\]")!.captures(in: range.field)
                {
                    fields[parameter] = limits[1]
                    limit = Int(limits[3])!
                }

                rawValues[parameter] |= ((self.fetched >> UInt(range.start)) & ((1 << UInt(range.bits)) - 1)) << UInt(limit)
            }
        }
        for range in bitRanges
        {
            if let parameter = range.parameter
            {    
                var value: UInt = rawValues[parameter]

                if (range.parameterType == .special)
                {
                    guard let disassembleSpecialParameter = instruction.format.disassembleSpecialParameter[fields[parameter]!]
                    else
                    {
                        state = .error
                        print("\("Instruction Set Error:".blue.bold) Special parameter disassembler not found for field \(fields[parameter]!).")
                        throw CoreError.isaError
                    }
                    value = disassembleSpecialParameter(rawValues[parameter]) //Unmangle...
                }
                
                arguments[parameter] = value

                if (range.signExtended && range.parameterType != Parameter.register)
                {
                    arguments[parameter] = Utils.signExt(value, bits: range.totalBits ?? range.bits)
                }
            }
        }

        return instructionSet.disassemble(instruction, arguments: arguments)
    }

    mutating public func execute() throws
    {
        do
        {
            try decoded!.execute(self)
        }
        catch
        {
            throw error
        }
    }
}