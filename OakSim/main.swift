import Foundation
import Oak
import Guaka

extension Array
{
    public func print()
    {
        for element in self
        {
            Swift.print(element)
        }
    }
}


let command = Command(
    usage: "oak",
    flags:
    [
        Flag(shortName: "o", longName: "output", type: String.self, description: "Assemble only, specify file path for binary dump."),
        Flag(shortName: "v", longName: "version", value: false, description: "Prints the current version."),
        Flag(shortName: "a", longName: "arch", value: "rv32i", description: "Picks the instruction set architecture."),
        Flag(shortName: "s", longName: "simulate", type: String.self, description: "Simulate only. The arguments will be treated as binary files.")
    ]
)
{
    (flags, arguments) in

    if flags.getBool(name: "version") ?? false
    {
        print("Oak CLI - Alpha 0.1")
        return
    }

    var isaChoice: String = "rv32i"
    if let arch = flags.getString(name: "arch"), !arch.isEmpty
    {
        isaChoice = arch
    }

    var assembleOnly: Bool = false
    var outputPath: String?
    if let output = flags.getString(name: "output"), !output.isEmpty
    {
        assembleOnly = true
        outputPath = output
    }

    var simulateOnly: Bool = false    
    if let input = flags.getString(name: "simulate"), !input.isEmpty
    {
        if assembleOnly
        {
            print("Error: --simulate and --output are mutually exclusive.")
            return
        }
        simulateOnly = true
    }

    var coreChoice: Core?

    switch(isaChoice)
    {
        case "rv32i":
            coreChoice = RV32iCore()
        case "armv7":
            print("ARMv7 not yet implemented.")
            return
        default:
            return
    }

    var core = coreChoice!

    if arguments.count != 1
    {
        print("Error: Oak needs at least/at most one file.")
        return
    }

    guard let defile = Defile(arguments[0], mode: .read)
    else
    {
        print("Error: Opening file \(arguments[0]) failed.")
        return
    }

    var machineCode: [UInt8]
    if simulateOnly
    {
        machineCode = try! defile.dumpBytes()
    }
    else
    {
        let assembler = Assembler(for: core.instructionSet)

        let file = try! defile.dumpString()
        
        let lexed = assembler.lex(file)

        if lexed.errorMessages.count != 0
        {
            lexed.errorMessages.print()
            return
        }

        let assembled = assembler.assemble(lexed.lines, labels: lexed.labels)

        if assembled.errorMessages.count != 0
        {
            assembled.errorMessages.print()
            return
        }

        machineCode = assembled.machineCode
    }

    if assembleOnly
    {
        let binPath = outputPath ?? arguments[0].replacing([".S", ".s", ".asm"], with: ".bin")
        guard let defile = Defile(binPath, mode: .write)
        else
        {
            print("Error: Opening file \(binPath) for writing failed.")
            return
        }
    }
    else
    {
        do
        {
            try core.loadProgram(machineCode: machineCode)
        }
        catch
        {
            print("Error while loading program: \(error).")
            return
        }

        var counter = 0
        var starttime = Date().timeIntervalSince1970

        while true
        {
            while core.state == .running
            {

                do
                {
                    try core.fetch()
                    try core.decode()
                    try core.execute()
                    counter += 1

                    if counter > (1 << 15)
                    {
                        print("Possible infinite loop.")
                        var finishtime = Date().timeIntervalSince1970
                        print("IPS: \(Double(counter) / (finishtime - starttime))")
                        return
                    }
                }
                catch
                {
                    print("Error: \(error).")
                    var finishtime = Date().timeIntervalSince1970
                    print("IPS: \(Double(counter) / (finishtime - starttime))")
                    return
                } 
            }

            if core.state == .error
            {
                var finishtime = Date().timeIntervalSince1970
                print("IPS: \(Double(counter) / (finishtime - starttime))")
                return
            }

            if core.state == .environmentBreak
            {
                core.state = .running
            }

            if core.state == .environmentCall
            {
                let service = core.service
                switch (service[0])
                {
                    case 4:
                        var cString = [UInt8]()
                        var offset: UInt = 0
                        var byte = try! core.memory.copy(service[1] + offset, count: 1)[0]
                        while byte != 0
                        {
                            cString.append(byte)
                            offset += 1              
                            byte = try! core.memory.copy(service[1] + offset, count: 1)[0]    
                        }
                        cString.append(0)
                        if let string = String(bytes: cString, encoding: String.Encoding.utf8)
                        {
                            print(">", string)
                        }
                    case 10:
                        print("Execution complete.")
                        var finishtime = Date().timeIntervalSince1970
                        print("IPS: \(Double(counter) / (finishtime - starttime))")
                        return
                    default:
                        print("Ignored unknown environment call service number \(core.service[0]).")
                }
                core.state = .running
            }
        }
    }
}

command.execute()