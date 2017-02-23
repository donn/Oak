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

        if lexed.errorMessages.count != 0 {
            lexed.errorMessages.print()
        }

        let assembled = assembler.assemble(lexed.lines, labels: lexed.labels)

        if assembled.errorMessages.count != 0 {
            assembled.errorMessages.print()
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
        }

        while true
        {
            while core.state == .running
            {
                do
                {
                    let fetch = try core.fetch()
                    let decode = try core.decode()
                    let excute = try core.execute()
                }
                catch
                {
                    print("Error: \(error).")
                } 
            }

            if core.state == .error
            {
                return
            }

            if core.state == .environmentBreak
            {
                core.state = .running
            }

            if core.state == .environmentCall
            {
                switch (core.service)
                {
                    case 10:
                        return
                    default:
                        print("Ignored unknown environment call service number \(core.service).")
                }
                core.state = .running
            }
        }
    }
}

command.execute()