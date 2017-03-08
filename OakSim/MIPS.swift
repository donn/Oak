//The MIPS Instruction Set, Version 2.1
//🐰
import Oak

extension InstructionSet
{
    public static func Oak_gen_MIPS() -> InstructionSet?
    {
        //Formats and Instructions
        var formats: [Format] = []
        var instructions: [Instruction] = []
        var pseudoInstructions: [PseudoInstruction] = []
       
        //R-Type
        formats.append(
            Format(
                ranges:
                [
                    BitRange("opcode", at: 26, bits: 6),
                    BitRange("rt", at: 16, bits: 5, parameter: 1, parameterType: .register),
                    BitRange("rd", at: 11, bits: 5, parameter: 0, parameterType: .register),
                    BitRange("funct", at: 0, bits: 6),
                    BitRange("rs", condition: { 0...7 ~= ($0 & 63) }, at: 21, bits: 5, parameter: 2, parameterType: .register),
                    BitRange("shamt", condition: { !(0...7 ~= ($0 & 63)) }, at: 6, bits: 5, parameter: 0, parameterType: .immediate)
                ],
                regex: Regex("[a-zA-Z]+\\s*([A-Za-z0-9]+)\\s*,\\s*([A-Za-z0-9]+)\\s*,\\s*([A-Za-z0-9]+)")!,
                disassembly: "@mnem @arg0, @arg1, @arg2"
            )
        )
       
        guard let rType = formats.last
        else
        {
            return nil
        }
       
        instructions.append(Instruction(
            "ADD",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x20],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) + Int32(bitPattern: core.registerFile[Int(core.arguments[2])]))
                
                
            }
        ))

        instructions.append(Instruction(
            "ADDU",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x21],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) &+ Int32(bitPattern: core.registerFile[Int(core.arguments[2])]))
                
                
            }
        ))

        instructions.append(Instruction(
            "SUB",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x22],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) - Int32(bitPattern: core.registerFile[Int(core.arguments[2])]))
                
                
            }
        ))
       
        instructions.append(Instruction(
            "SUBU",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x23],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) &- Int32(bitPattern: core.registerFile[Int(core.arguments[2])]))
                
                
            }
        ))
       
        instructions.append(Instruction(
            "AND",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x24],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] & core.registerFile[Int(core.arguments[2])]
                
                
            }
        ))
       
        instructions.append(Instruction(
            "OR",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x25],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] | core.registerFile[Int(core.arguments[2])]
                
                
            }
        ))

        instructions.append(Instruction(
            "XOR",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x26],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] ^ core.registerFile[Int(core.arguments[2])]
                
                
            }
        ))

        instructions.append(Instruction(
            "NOR",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x27],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = ~(core.registerFile[Int(core.arguments[1])] | core.registerFile[Int(core.arguments[2])])
                
                
            }
        ))
       
        instructions.append(Instruction(
            "SLT",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x2A],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = (Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) < Int32(bitPattern: core.registerFile[Int(core.arguments[2])])) ? 1 : 0
                
                
            }
        ))
       
        instructions.append(Instruction(
            "SLTU",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x2B],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = (core.registerFile[Int(core.arguments[1])] < core.registerFile[Int(core.arguments[2])]) ? 1 : 0
                
                
            },
            available: false
        ))
       
        instructions.append(Instruction(
            "JR",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x08],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] >> core.registerFile[Int(core.arguments[2])]
                
                
            }
        ))

        instructions.append(Instruction(
            "SLL",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x00],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] << UInt32(core.arguments[2])
                
                
            }
        ))

        instructions.append(Instruction(
            "SRL",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x02],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] >> UInt32(core.arguments[2])
                
                
            }
        ))
       
        instructions.append(Instruction(
            "SRA",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x03],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(core.registerFile[Int(core.arguments[1])]) >> Int32(bitPattern: UInt32(core.arguments[2])))
                
                
            }
        ))

        instructions.append(Instruction(
            "SLLV",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x04],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] << core.registerFile[Int(core.arguments[2])]
                
                
            }
        ))        

        instructions.append(Instruction(
            "SRLV",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x06],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] >> core.registerFile[Int(core.arguments[2])]
                
                
            }
        ))
       
        instructions.append(Instruction(
            "SRAV",
            format: rType,
            constants: ["opcode": 0x0, "funct": 0x07],
            executor:
            {
                (mips: Core) in
                let core = mips as! MIPSCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) >> Int32(bitPattern: core.registerFile[Int(core.arguments[2])]))
                
                
            }
        ))
        
        let abiNames = ["$zero", "$at", "$v0", "$v1", "$a0", "$a1", "$a2", "$a3", "$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7", "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7", "$t8", "$t9", "$k0", "$k1", "$gp", "$fp", "$ra"]

        let keywords: [Keyword: [String]] = [
            .directive: ["\\."],
            .comment: ["#"],
            .label: ["\\:"],
            .stringMarker: ["\\\""],
            .charMarker: ["\\\'"],
            .register: ["$"]
        ]

        let directives: [String: Directive] = [
            "text": .text,
            "data": .data,
            "ascii": .string,
            "asciiz": .cString,
            "byte": ._8bit,
            "half": ._16bit,
            "word": ._32bit
        ]
       
        return InstructionSet(bits: 32, formats: formats, instructions: instructions, abiNames: abiNames, keywords: keywords, directives: directives)

    }
    
    static let MIPS = Oak_gen_MIPS()
}

public class MIPSRegisterFile
{
    private var memorySize: Int
    private var file: [UInt32]

    public var count: Int = 32

    subscript(index: Int) -> UInt32
    {
        get
        {
            if index == 0 || index > 31
            {
                return 0
            }
            return file[index - 1]
        }
        set {
            if index == 0 || index > 31
            {
                return
            }
            file[index - 1] = newValue
        }
    }

    func reset()
    {
        for i in 0...30
        {
           file[i] = 0
        }
        self[29] = UInt32(self.memorySize)
    }

    init(memorySize: Int)
    {
        self.file = [UInt32](repeating: 0, count: 31)
        self.memorySize = memorySize
        self[2] = UInt32(memorySize) //stack pointer
    }
}

public class MIPSCore: Core
{    
    //Endiantiy
    public var endianness = Endianness.little

    //Instruction Set
    public var instructionSet: InstructionSet

    //Registers
    public var registerFile: MIPSRegisterFile

    //Memory
    public var memory: Memory
    
    //Program Counter
    public var programCounter: UInt32

    //Fetched
    public var state: CoreState

    public func reset()
    {
        self.programCounter = 0
        self.registerFile.reset()
    }
    
    //Fetch...
    public var fetched: UInt
    public func fetch() throws
    {
        do
        {
            var bytes = try self.memory.copy(UInt(programCounter), count: 1)
            if (bytes[0] & 3) == 3
            {
                bytes += try self.memory.copy(UInt(programCounter + 1), count: 3)
            }
            self.fetched = Utils.concatenate(bytes: bytes)
        }
        catch
        {
            state = .error
            throw error
        }
    }
    
    //Decode...
    public var decoded: Instruction?
    public var rawValues = [UInt]()
    public var arguments = [UInt]()
    public var fields = [Int: String]()
    

    public func loadProgram(machineCode: [UInt8]) throws
    {
        if machineCode.count < memory.size
        {
            do
            {
                try memory.set(0, bytes: machineCode)
            }
            catch
            {
                throw error
            }
            state = .running
            return
        }
        throw MemoryError.illegalMemoryAccess
    }

    public func registerDump() -> String
    {
        var dump = ""
        for i in 0..<registerFile.count
        {
            dump += "x\(i) \(instructionSet.abiNames[i]) \(registerFile[i])\n"
        }
        return dump
    }

    public var service: [UInt]
    {
        return [UInt(registerFile[17]), UInt(registerFile[10]), UInt(registerFile[11]), UInt(registerFile[12]), UInt(registerFile[13]), UInt(registerFile[14]), UInt(registerFile[15]), UInt(registerFile[16])]
    }

    public var registers: [(abiName: String, value: UInt)]
    {
        var array = [(abiName: String, value: UInt)]()
        for i in 0...31
        {
            array.append((abiName: instructionSet.abiNames[i], value: UInt(registerFile[i])))
        }
        return array
    }

    public var pc: UInt
    {
        return UInt(programCounter)
    }

    public init?(memorySize: Int = 4096)
    {
        guard let MIPS = InstructionSet.MIPS
        else
        {
            return nil
        }
        self.programCounter = 0
        self.instructionSet = MIPS
        self.registerFile = MIPSRegisterFile(memorySize: memorySize)
        self.memory = SimpleMemory(memorySize)
        self.fetched = 0
        self.state = .idle
    }
}

