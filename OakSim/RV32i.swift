//The RISC-V RV32i Instruction Set, Version 2.1
import Oak

extension InstructionSet
{
    public static func Oak_gen_RV32i() -> InstructionSet?
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
                    BitRange("funct7", at: 25, bits: 7),
                    BitRange("rs2", at: 20, bits: 5, parameter: 2, parameterType: .register),
                    BitRange("rs1", at: 15, bits: 5, parameter: 1, parameterType: .register),
                    BitRange("funct3", at: 12, bits: 3),
                    BitRange("rd", at: 7, bits: 5, parameter: 0, parameterType: .register),
                    BitRange("opcode", at: 0, bits: 7)
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
            constants: ["opcode": 0b0110011, "funct3": 0b000, "funct7": 0b0000000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) &+ Int32(bitPattern: core.registerFile[Int(core.arguments[2])]))
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SUB",
            format: rType,
            constants: ["opcode": 0b0110011, "funct3": 0b000, "funct7": 0b0100000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) &- Int32(bitPattern: core.registerFile[Int(core.arguments[2])]))
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SLL",
            format: rType,
            constants: ["opcode": 0b0110011, "funct3": 0b001, "funct7": 0b0000000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] << core.registerFile[Int(core.arguments[2])]
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SLT",
            format: rType,
            constants: ["opcode": 0b0110011, "funct3": 0b010, "funct7": 0b0000000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = (Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) < Int32(bitPattern: core.registerFile[Int(core.arguments[2])])) ? 1 : 0
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SLTU",
            format: rType,
            constants: ["opcode": 0b0110011, "funct3": 0b0110011, "funct7": 0b0110011],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = (core.registerFile[Int(core.arguments[1])] < core.registerFile[Int(core.arguments[2])]) ? 1 : 0
                core.programCounter += 4
                
            },
            available: false
        ))
       
        instructions.append(Instruction(
            "XOR",
            format: rType,
            constants: ["opcode": 0b0110011, "funct3": 0b100, "funct7": 0b0000000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] ^ core.registerFile[Int(core.arguments[2])]
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SRL",
            format: rType,
            constants: ["opcode": 0b0110011, "funct3": 0b101, "funct7": 0b0000000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] >> core.registerFile[Int(core.arguments[2])]
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SRA",
            format: rType,
            constants: ["opcode": 0b0110011, "funct3": 0b101, "funct7": 0b0100000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) >> Int32(bitPattern: core.registerFile[Int(core.arguments[2])]))
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "OR",
            format: rType,
            constants: ["opcode": 0b0110011, "funct3": 0b110, "funct7": 0b0000000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] | core.registerFile[Int(core.arguments[2])]
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "AND",
            format: rType,
            constants: ["opcode": 0b0110011, "funct3": 0b111, "funct7": 0b0000000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] & core.registerFile[Int(core.arguments[2])]
                core.programCounter += 4
                
            }
        ))
       
        //I-Type
        formats.append(
            Format(
                ranges:
                [
                    BitRange("imm", at: 20, bits: 12, parameter: 2, parameterType: .immediate, signExtended: true),
                    BitRange("rs1", at: 15, bits: 5, parameter: 1, parameterType: .register),
                    BitRange("funct3", at: 12, bits: 3),
                    BitRange("rd", at: 7, bits: 5, parameter: 0, parameterType: .register),
                    BitRange("opcode", at: 0, bits: 7)
                ],
                regex: Regex("[a-zA-Z]+\\s*([A-Za-z0-9]+)\\s*,\\s*([A-Za-z0-9]+),\\s*(-?[a-zA-Z0-9_]+)")!,
                disassembly: "@mnem @arg0, @arg1, @arg2"
            )
        )
       
        guard let iType = formats.last
        else
        {
            return nil
        }
       
        instructions.append(Instruction(
            "JALR",
            format: iType,
            constants: ["opcode": 0b1100111, "funct3": 0b000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = UInt32(core.programCounter) + 4
                core.programCounter = UInt32(bitPattern: Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) + Int32(truncatingBitPattern: core.arguments[2]))
                
            }
        ))
       
        instructions.append(Instruction(
            "ADDI",
            format: iType,
            constants: ["opcode": 0b0010011, "funct3": 0b000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(core.registerFile[Int(core.arguments[1])]) &+ Int32(truncatingBitPattern: core.arguments[2]))
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SLTI",
            format: iType,
            constants: ["opcode": 0b0010011, "funct3": 0b010],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = (Int32(bitPattern: core.registerFile[Int(core.arguments[1])]) < Int32(truncatingBitPattern: core.arguments[2])) ? 1 : 0
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "XORI",
            format: iType,
            constants: ["opcode": 0b0010011, "funct3": 0b100],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] ^ UInt32(core.arguments[2])
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "ORI",
            format: iType,
            constants: ["opcode": 0b0010011, "funct3": 0b110],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] | UInt32(core.arguments[2])
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "ANDI",
            format: iType,
            constants: ["opcode": 0b0010011, "funct3": 0b111],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] & UInt32(core.arguments[2])
                core.programCounter += 4
                
            }
        ))

        //IU Subtype
        formats.append(
            Format(
                ranges:
                [
                    BitRange("imm", at: 20, bits: 12, parameter: 2, parameterType: .immediate, signExtended: false),
                    BitRange("rs1", at: 15, bits: 5, parameter: 1, parameterType: .register),
                    BitRange("funct3", at: 12, bits: 3),
                    BitRange("rd", at: 7, bits: 5, parameter: 0, parameterType: .register),
                    BitRange("opcode", at: 0, bits: 7)
                ],
                regex: Regex("[a-zA-Z]+\\s*([A-Za-z0-9]+)\\s*,\\s*([A-Za-z0-9]+),\\s*(-?[a-zA-Z0-9_]+)")!,
                disassembly: "@mnem @arg0, @arg1, @arg2"
            )
        )

        guard let iuSubtype = formats.last
        else
        {
            return nil
        }

        instructions.append(Instruction(
            "SLTIU",    
            format: iuSubtype,
            constants: ["opcode": 0b0010011, "funct3": 0b011],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = (core.registerFile[Int(core.arguments[1])] < UInt32(core.arguments[2]) ? 1 : 0)
                core.programCounter += 4
                
            }
        ))
       
        //IL Subtype
        formats.append(
            Format(
                ranges:
                [
                    BitRange("imm", at: 20, bits: 12, parameter: 1, parameterType: .immediate),
                    BitRange("rs1", at: 15, bits: 5, parameter: 2, parameterType: .register),
                    BitRange("funct3", at: 12, bits: 3),
                    BitRange("rd", at: 7, bits: 5, parameter: 0, parameterType: .register),
                    BitRange("opcode", at: 0, bits: 7)
                ],
                regex: Regex("[a-zA-Z]+\\s*([A-Za-z0-9]+)\\s*,\\s*(-?0?[boxd]?[0-9A-F]+)\\s*\\(\\s*([A-Za-z0-9]+)\\s*\\)")!,
                disassembly: "@mnem @arg0, @arg1(@arg2)"
            )
        )
       
        guard let ilSubtype = formats.last
        else
        {
            return nil
        }
       
        instructions.append(Instruction(
            "LB",
            format: ilSubtype,
            constants: ["opcode": 0b0000011, "funct3": 0b000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                do
                {
                    let bytes = try core.memory.copy(UInt(bitPattern: Int(Int32(core.registerFile[Int(core.arguments[2])]) + Int32(truncatingBitPattern: core.arguments[1]))), count: 1)
                    core.registerFile[Int(core.arguments[0])] = UInt32(truncatingBitPattern: Utils.signExt(UInt(bytes[0]), bits: 8))
                    core.programCounter += 4    
                }
                catch
                {
                    print("Error")
                    throw error
                }
            }
        ))
       
        instructions.append(Instruction(
            "LH",
            format: ilSubtype,
            constants: ["opcode": 0b0000011, "funct3": 0b001],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                do
                {
                    let bytes = try core.memory.copy(UInt(bitPattern: Int(Int32(core.registerFile[Int(core.arguments[2])]) + Int32(truncatingBitPattern: core.arguments[1]))), count: 2)
                    core.registerFile[Int(core.arguments[0])] = UInt32(Utils.concatenate(bytes: bytes))
                    core.programCounter += 4                    
                    
                }
                catch 
                {
                    throw error
                }
            }
        ))
       
        instructions.append(Instruction(
            "LW",
            format: ilSubtype,
            constants: ["opcode": 0b0000011, "funct3": 0b010],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                do
                {
                    let bytes = try core.memory.copy(UInt(bitPattern: Int(Int32(core.registerFile[Int(core.arguments[2])]) + Int32(truncatingBitPattern: core.arguments[1]))), count: 4)
                    core.registerFile[Int(core.arguments[0])] = UInt32(Utils.concatenate(bytes: bytes))
                    core.programCounter += 4
                    
                }
                catch 
                {
                    throw error
                }
        }
        ))
       
        instructions.append(Instruction(
            "LBU",
            format: ilSubtype,
            constants: ["opcode": 0b0000011, "funct3": 0b100],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                do
                {
                    let bytes = try core.memory.copy(UInt(bitPattern: Int(Int32(core.registerFile[Int(core.arguments[2])]) + Int32(truncatingBitPattern: core.arguments[1]))), count: 1)
                    core.registerFile[Int(core.arguments[0])] = UInt32(bytes[0])
                    core.programCounter += 4
                    
                }
                catch
                {
                    throw error
                }
                
            }
        ))
       
        instructions.append(Instruction(
            "LHU",
            format: ilSubtype,
            constants: ["opcode": 0b0000011, "funct3": 0b101],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                do
                {
                    let bytes = try core.memory.copy(UInt(bitPattern: Int(Int32(core.registerFile[Int(core.arguments[2])]) + Int32(truncatingBitPattern: core.arguments[1]))), count: 2)
                    core.registerFile[Int(core.arguments[0])] = UInt32(Utils.concatenate(bytes: bytes))
                    core.programCounter += 4
                    
                }
                catch
                {
                    throw error
                }
                
            }
        ))
       
        //IS Subtype
        formats.append(
            Format(
                ranges:
                [
                    BitRange("funct7", at: 25, bits: 7),
                    BitRange("shamt", at: 20, bits: 5, parameter: 2, parameterType: .immediate, signExtended: false),
                    BitRange("rs1", at: 15, bits: 5, parameter: 1, parameterType: .register),
                    BitRange("funct3", at: 12, bits: 3),
                    BitRange("rd", at: 7, bits: 5, parameter: 0, parameterType: .register),
                    BitRange("opcode", at: 0, bits: 7)
                ],
                regex: Regex("[a-zA-Z]+\\s*([A-Za-z0-9]+)\\s*,\\s*([A-Za-z0-9]+),\\s*(-?0?[boxd]?[0-9A-F]+)")!,
                disassembly: "@mnem @arg0, @arg1, @arg2"
            )
        )
       
        guard let isSubtype = formats.last
        else
        {
            return nil
        }
       
        instructions.append(Instruction(
            "SLLI",
            format: isSubtype,
            constants: ["opcode": 0b0010011, "funct3": 0b001, "funct7": 0b0000000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] << UInt32(core.arguments[2])
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SRLI",
            format: isSubtype,
            constants: ["opcode": 0b0010011, "funct3": 0b101, "funct7": 0b0000000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.registerFile[Int(core.arguments[1])] >> UInt32(core.arguments[2])
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SRAI",
            format: isSubtype,
            constants: ["opcode": 0b0010011, "funct3": 0b101, "funct7": 0b0100000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = UInt32(bitPattern: Int32(core.registerFile[Int(core.arguments[1])]) >> Int32(bitPattern: UInt32(core.arguments[2])))
                core.programCounter += 4
                
            }
        ))
       
       
        //S-Type
        formats.append(
            Format(
                ranges:
                [
                    BitRange("imm", at: 25, bits: 7, totalBits: 12, limitStart: 5, limitEnd: 11, parameter: 1, parameterType: .immediate),
                    BitRange("rs2", at: 20, bits: 5, parameter: 0, parameterType: .register),
                    BitRange("rs1", at: 15, bits: 5, parameter: 2, parameterType: .register),
                    BitRange("funct3", at: 12, bits: 3),
                    BitRange("imm", at: 7, bits: 5, totalBits: 12, limitStart: 0, limitEnd: 4, parameter: 1, parameterType: .immediate),
                    BitRange("opcode", at: 0, bits: 7)
                ],
                regex: Regex("[a-zA-Z]+\\s*([A-Za-z0-9]+)\\s*,\\s*(-?0?[boxd]?[0-9A-F]+)\\(\\s*([A-Za-z0-9]+)\\s*\\)")!,
                disassembly: "@mnem @arg0, @arg1(@arg2)"
            )
        )
       
        guard let sType = formats.last
        else
        {
            return nil
        }
       
        instructions.append(Instruction(
            "SB",
            format: sType,
            constants: ["opcode": 0b0100011, "funct3": 0b000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                var bytes = [UInt8]()
                bytes.append(UInt8(core.registerFile[Int(core.arguments[0])] & 255))
                do
                {
                    try core.memory.set(UInt(core.registerFile[Int(core.arguments[2])]) + core.arguments[1], bytes: bytes)
                }                
                catch 
                {
                    throw error
                }
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SH",
            format: sType,
            constants: ["opcode": 0b0100011, "funct3": 0b001],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                var bytes = [UInt8]()
                var value = core.registerFile[Int(core.arguments[0])]
                bytes.append(UInt8(value & 255))
                value = value >> 8
                bytes.append(UInt8(value & 255))
                do
                {
                    try core.memory.set(UInt(core.registerFile[Int(core.arguments[2])]) + core.arguments[1], bytes: bytes)
                }
                catch 
                {
                    throw error
                }
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "SW",
            format: sType,
            constants: ["opcode": 0b0100011, "funct3": 0b010],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                var bytes = [UInt8]()
                var value = core.registerFile[Int(core.arguments[0])]
                bytes.append(UInt8(value & 255))
                value = value >> 8
                bytes.append(UInt8(value & 255))
                value = value >> 8
                bytes.append(UInt8(value & 255))
                value = value >> 8
                bytes.append(UInt8(value & 255))
                do
                {
                    try core.memory.set(UInt(core.registerFile[Int(core.arguments[2])]) + core.arguments[1], bytes: bytes)
                }
                catch 
                {
                    throw error
                }
                core.programCounter += 4
                
            }
        ))
       
       
       
        //U-Type
        formats.append(
            Format(
                ranges:
                [
                    BitRange("imm", at: 12, bits: 20, parameter: 1, parameterType: .register),
                    BitRange("rd", at: 7, bits: 5, parameter: 0, parameterType: .register),
                    BitRange("opcode", at: 0, bits: 7)
                ],
                regex: Regex("[a-zA-Z]+\\s*([A-Za-z0-9]+)\\s*,\\s*([a-zA-Z0-9_]+)")!,
                disassembly: "@mnem @arg0, @arg1"
            )
        )
       
        guard let uType = formats.last
        else
        {
            return nil
        }
       
        instructions.append(Instruction(
            "LUI",
            format: uType,
            constants: ["opcode": 0b0110111],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = UInt32(core.arguments[1] << 12)
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "AUIPC",
            format: uType,
            constants: ["opcode": 0b0010111],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = UInt32(core.arguments[1] << 12) + (core.programCounter)
                core.programCounter += 4
                
            }
        ))
       
        //SB-Type
        formats.append(
            Format(
                ranges: [
                    BitRange("imm", at: 25, bits: 7, totalBits: 13, limitStart: 5, limitEnd: 11, parameter: 2, parameterType: .special),
                    BitRange("rs2", at: 20, bits: 5, parameter: 1, parameterType: .register),
                    BitRange("rs1", at: 15, bits: 5, parameter: 0, parameterType: .register),
                    BitRange("funct3", at: 12, bits: 3),
                    BitRange("imm", at: 7, bits: 5, totalBits: 13, limitStart: 0, limitEnd: 4, parameter: 2, parameterType: .special),
                    BitRange("opcode", at: 0, bits: 7)
                ],
                regex: Regex("[a-zA-Z]+\\s*([A-Za-z0-9]+)\\s*,\\s*([A-Za-z0-9]+)\\s*,\\s*([a-zA-Z0-9_]+)")!,
                specialParameterProcessors: ["imm":
                {
                    (text: String, address: UInt, bits: Int, labels: [String: UInt]) -> (errorMessage: String?, value: UInt) in
                    let array = Array(text.characters) //Character View
                    var errorMessage: String?
                    var value: UInt = 0
                    var int: UInt?
                    if let target = labels[text]
                    {
                        int = target - address
                    }
                    else
                    {
                        var radix = 10
                        var splice = false
                        
                        if array[0] == "0" && array.count > 1
                        {
                            if array[1] == "b"
                            {
                                radix = 2
                                splice = true
                            }
                            if array[1] == "o"
                            {
                                radix = 8
                                splice = true
                            }
                            if array[1] == "d"
                            {
                                radix = 10
                                splice = true
                            }
                            if array[1] == "x"
                            {
                                radix = 16
                                splice = true
                            }
                        }
                        
                        var interpretable = text
                        
                        if splice
                        {
                            let index = text.index(text.startIndex, offsetBy: 3)
                            interpretable = text.substring(from: index)
                        }
                        
                        int = UInt(interpretable, radix: radix)

                        if let signed = Int(interpretable, radix: radix), int == nil
                        {
                            int = UInt(bitPattern: signed)
                        }
                    }
                    
                    guard let unwrap = int
                    else
                    {
                        errorMessage = "Immediate '\(text)' is not a recognized label, literal or character."
                        return (errorMessage, value)
                    }

                    if Utils.rangeCheck(unwrap, bits: bits)
                    {
                        var mangle = unwrap & 2046 //mangle[10:1] = int[10:1]
                        mangle = mangle | ((unwrap >> 11) & 1) //mangle[0] = int[11]
                        mangle = mangle | ((unwrap >> 12) & 1) << 11 //mangle[11] = int[12]
                        value = mangle
                        return (errorMessage, value)
                    }

                    errorMessage = "The value of '\(text)' is out of range."
                    return (errorMessage, value)
                }],
                specialParameterDisassemblers: ["imm":
                {
                    (value: UInt) in
                    var unmangle = value & 2046 //value[10:1] = mangle[10:1]
                    unmangle = unmangle | (value & 1) << 11  //value[11] = mangle[0]
                    unmangle = unmangle | ((value >> 11) & 1) << 12 //value[12] = mangle[11]
                    return unmangle
                   
                }],
                disassembly: "@mnem @arg0, @arg1, @arg2"
            )
        )
       
       
        guard let sbType = formats.last
        else
        {
            return nil
        }
               
        instructions.append(Instruction(
            "BEQ",
            format: sbType,
            constants: ["opcode": 0b1100011, "funct3": 0b000],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                if core.registerFile[Int(core.arguments[0])] == core.registerFile[Int(core.arguments[1])]
                {
                    core.programCounter = UInt32(bitPattern: Int32(bitPattern: core.programCounter) + Int32(truncatingBitPattern: core.arguments[2]))
                    return
                }
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "BNE",
            format: sbType,
            constants: ["opcode": 0b1100011, "funct3": 0b001],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                if core.registerFile[Int(core.arguments[0])] != core.registerFile[Int(core.arguments[1])]
                {
                    core.programCounter = UInt32(bitPattern: Int32(bitPattern: core.programCounter) + Int32(truncatingBitPattern: core.arguments[2]))
                    return
                }
                core.programCounter += 4
            }
        ))
       
        instructions.append(Instruction(
            "BLT",
            format: sbType,
            constants: ["opcode": 0b1100011, "funct3": 0b100],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                if Int32(bitPattern: core.registerFile[Int(core.arguments[0])]) < Int32(bitPattern: core.registerFile[Int(core.arguments[1])])
                {
                    core.programCounter += UInt32(core.arguments[2])
                    return
                }
                core.programCounter += 4
                return
            }
        ))
       
        instructions.append(Instruction(
            "BGE",
            format: sbType,
            constants: ["opcode": 0b1100011, "funct3": 0b101],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                if Int32(bitPattern: core.registerFile[Int(core.arguments[0])]) >= Int32(bitPattern: core.registerFile[Int(core.arguments[1])])
                {
                    core.programCounter += UInt32(core.arguments[2])
                    return
                }
                core.programCounter += 4
            }
        ))
       
        instructions.append(Instruction(
            "BLTU",
            format: sbType,
            constants: ["opcode": 0b1100011, "funct3": 0b110],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                if core.registerFile[Int(core.arguments[0])] < core.registerFile[Int(core.arguments[1])]
                {
                    core.programCounter += UInt32(core.arguments[2])
                    return
                }
                core.programCounter += 4
                
            }
        ))
       
        instructions.append(Instruction(
            "BGEU",
            format: sbType,
            constants: ["opcode": 0b1100011, "funct3": 0b111],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                if core.registerFile[Int(core.arguments[0])] >= core.registerFile[Int(core.arguments[1])]
                {
                    core.programCounter += UInt32(core.arguments[2])
                    return
                }
                core.programCounter += 4
                
            }
        ))
       
        //UJ-Type
        formats.append(
            Format(
                ranges: [
                    BitRange("imm", at: 12, bits: 20, parameter: 1, parameterType: .special),
                    BitRange("rd", at: 7, bits: 5,  parameter: 0, parameterType: .register),
                    BitRange("opcode", at: 0, bits: 7)
                ],
                regex: Regex("[a-zA-Z]+\\s*([A-Za-z0-9]+)\\s*,\\s*([a-zA-Z0-9_]+)")!,
                specialParameterProcessors: ["imm":
                {
                    (text: String, address: UInt, bits: Int, labels: [String: UInt]) -> (errorMessage: String?, value: UInt) in
                    let array = Array(text.characters) //Character View
                    var errorMessage: String?
                    var value: UInt = 0                   
                    var int: UInt?

                    if let target = labels[text]
                    {
                        int = target &- address
                    }
                    else
                    {
                        var radix = 10
                        var splice = false
                        
                        if array[0] == "0" && array.count > 1
                        {
                            if array[1] == "b"
                            {
                                radix = 2
                                splice = true
                            }
                            if array[1] == "o"
                            {
                                radix = 8
                                splice = true
                            }
                            if array[1] == "d"
                            {
                                radix = 10
                                splice = true
                            }
                            if array[1] == "x"
                            {
                                radix = 16
                                splice = true
                            }
                        }
                        
                        var interpretable = text
                        
                        if splice
                        {
                            let index = text.index(text.startIndex, offsetBy: 3)
                            interpretable = text.substring(from: index)
                        }
                        
                        int = UInt(interpretable, radix: radix)

                        if let signed = Int(interpretable, radix: radix), int == nil
                        {
                            int = UInt(bitPattern: signed)
                        }
                    }

                    guard let unwrap = int
                    else
                    {
                        errorMessage = "Immediate '\(text)' is not a recognized label, literal or character."
                        return (errorMessage, value)
                    }
                    if Utils.rangeCheck(unwrap, bits: 21)
                    {
                        var mangle = ((unwrap >> 12) & 255) //mangle[7:0] = int[19:12]
                        mangle = mangle | (((unwrap >> 11) & 1) << 8) //mangle[8] = int[11]
                        mangle = mangle | (((unwrap >> 1) & 1023) << 9) //mangle[18:9] = int[10:1]
                        mangle = mangle | (((unwrap >> 20) & 1) << 19 ) //mangle[19] = int[20]
                        value = mangle
                        return (errorMessage, value)
                    }
                    errorMessage = "The value of '\(text)' is out of range."
                    return (errorMessage, value)
                }],
                specialParameterDisassemblers: ["imm":
                {
                    (value: UInt) in
                    var unmangle = ((value >> 8) & 1) << 11 //unmangle[11] = value[8]
                    unmangle = unmangle | (((value >> 19) & 1) << 20) //unmangle[20] = value[19]
                    unmangle = unmangle | (((value >> 0) & 255) << 12) //unmangle[19:12] = value[7:0]
                    unmangle = unmangle | (((value >> 9) & 1023) << 1) //unmangle[10:1] = value[18:9]
                    return unmangle
                   
                }],
                disassembly: "@mnem @arg0, @arg1"
            )
        )
       
        guard let ujType = formats.last
        else
        {
            return nil
        }
       
        instructions.append(Instruction(
            "JAL",
            format: ujType,
            constants: ["opcode": 0b1101111],
            executor:
            {
                (rv32i: Core) in
                let core = rv32i as! RV32iCore
                core.registerFile[Int(core.arguments[0])] = core.programCounter + 4
                core.programCounter = UInt32(bitPattern: Int32(bitPattern: core.programCounter) + Int32(truncatingBitPattern: core.arguments[1]))
                
            }
        ))
       
        //System Type
        //All-Const Type
        formats.append(
            Format(
                ranges: [
                    BitRange("const", at: 0, bits: 32)
                ],
                regex: Regex("[a-zA-Z]+")!,
                disassembly: "@mnem"
            )
        )
       
        guard let allConstSubtype = formats.last
        else
        {
            return nil
        }
       
        instructions.append(Instruction(
                "ECALL",
                format: allConstSubtype,
                constants: ["const": 0b00000000000000000000000001110011],
                executor:
                {
                    (rv32i: Core) in
                    let core = rv32i as! RV32iCore
                    core.state = .environmentCall
                    core.programCounter += 4
                    
                }
               
            )
        )
        
        let abiNames = ["zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2", "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"]

        let keywords: [Keyword: [String]] = [
            .directive: ["\\."],
            .comment: ["#"],
            .label: ["\\:"],
            .stringMarker: ["\\\""],
            .charMarker: ["\\\'"],
            .register: ["x"]
        ]

        let directives: [String: Directive] = [
            "text": .text,
            "data": .data,
            "string": .cString,
            "byte": ._8bit,
            "half": ._16bit,
            "word": ._32bit
        ]
       
        return InstructionSet(bits: 32, formats: formats, instructions: instructions, abiNames: abiNames, keywords: keywords, directives: directives, incrementOnFetch: false)

    }
    
    static let RV32i = Oak_gen_RV32i()
}

public class RV32iRegisterFile
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
        self[2] = UInt32(self.memorySize)
    }

    init(memorySize: Int)
    {
        self.file = [UInt32](repeating: 0, count: 31)
        self.memorySize = memorySize
        self[2] = UInt32(memorySize) //stack pointer
    }
}

public class RV32iCore: Core
{    
    //Endiantiy
    public var endianness = Endianness.little

    //Instruction Set
    public var instructionSet: InstructionSet

    //Registers
    public var registerFile: RV32iRegisterFile

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

    public init?(memorySize: Int = 8192)
    {
        guard let RV32i = InstructionSet.RV32i
        else
        {
            return nil
        }
        self.programCounter = 0
        self.instructionSet = RV32i
        self.registerFile = RV32iRegisterFile(memorySize: memorySize)
        self.memory = SimpleMemory(memorySize)
        self.fetched = 0
        self.state = .idle
    }
}

