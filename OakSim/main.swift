import Foundation
import Oak
import Guaka
import Colors

extension Array
{
    public func print()
    {
        for (i, element) in self.enumerated()
        {
            Swift.print(element)
        }
    }
}

class ExecutionTimer
{
    var printIPS = false
    var elapsed: Double?
    var adjust: Double = 0.0
    var wait: Double = 0.0
    var counter: Int = 0

    func reset()
    {
        adjust = Date().timeIntervalSince1970
        counter = 0
        wait = 0
        elapsed = nil
    }

    func pause()
    {
        wait = Date().timeIntervalSince1970
    }

    func resume()
    {
        elapsed = nil
        adjust += (Date().timeIntervalSince1970 - wait)
        wait = 0
    }

    func stop()
    {
        elapsed = Date().timeIntervalSince1970 - adjust
    }

    func print()
    {
        let time = elapsed ?? (Date().timeIntervalSince1970 - adjust)
        Swift.print("")        
        NSLog("Time taken: %.02f seconds.", time)
        if printIPS
        {
            NSLog("IPS: %.02f.", Double(counter) / time)
        }
        Swift.print("")
    }

    init(printIPS: Bool = false)
    {
        self.printIPS = printIPS
    }

}

var timer = ExecutionTimer(printIPS: true)

signal(SIGINT)
{
    (s: Int32) in
    if 2...6 ~= s
    {
        print("")
        timer.stop()
        timer.print()
        exit(9)
    }
}

let command = Command(
    usage: "oak",
    flags:
    [
        Flag(shortName: "o", longName: "output", type: String.self, description: "Assemble only, specify file path for binary dump."),
        Flag(shortName: "v", longName: "version", value: false, description: "Prints the current version."),
        Flag(shortName: "a", longName: "arch", value: "rv32i", description: "Picks the instruction set architecture."),
        Flag(shortName: "s", longName: "simulate", value: false, description: "Simulate only. The arguments will be treated as binary files."),
        Flag(shortName: "d", longName: "disassemble", value: false, description: "Disassemble while simulating."),
        Flag(shortName: "i", longName: "interactive", value: false, description: "Interactive debugging mode.")
        
    ]
)
{
    (flags, arguments) in
    if flags.getBool(name: "version") ?? false
    {
        print("Oak · Alpha 0.2")
        print("All rights reserved.")
        print("You should have obtained a copy of the Mozilla Public License with your app.")
        print("If you did not, a verbatim copy should be available at https://www.mozilla.org/en-US/MPL/2.0/.")
        return
    }

    var disassemble = flags.getBool(name: "disassemble") ?? false
    var isaChoice: String = "rv32i"
    if let arch = flags.getString(name: "arch"), !arch.isEmpty
    {
        isaChoice = arch
    }

    var assembleOnly = false
    var outputPath: String?
    if let output = flags.getString(name: "output"), !output.isEmpty
    {
        assembleOnly = true
        outputPath = output
    }

    var simulateOnly = flags.getBool(name: "simulate") ?? false
    if assembleOnly && simulateOnly
    {
        print("Error: --simulate and --output are mutually exclusive.")
        exit(64)
    }

    var interactive = flags.getBool(name: "interactive") ?? false

    var coreChoice: Core?

    switch(isaChoice.lowercased())
    {
        case "riscv":
            fallthrough
        case "rv32i":
            coreChoice = RV32iCore()
        case "armv7":
            print("ARMv7 not yet implemented.")
            exit(64)
        case "mips":
            coreChoice = MIPSCore()
        default:
            //Not possible.
            return
    }

    var core = coreChoice!
    var machineCode: [UInt8]
    if arguments.count != 1
    {
        print("Error: Oak needs at least/at most one file.")
        exit(64)
    }

    guard let defile = Defile(arguments[0], mode: .read)
    else
    {
        print("Error: Opening file \(arguments[0]) failed.")
        exit(66)
    }

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
            exit(0xBAD)
        }

        let assembled = assembler.assemble(lexed.lines, labels: lexed.labels)

        if assembled.errorMessages.count != 0
        {
            assembled.errorMessages.print()
            exit(0xBAD)
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
            exit(73)
        }

        do
        {
            try defile.write(bytes:machineCode)
        } catch {
            print("\(error)")
            exit(73)
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
            exit(65)
        }

        timer.reset()
        while true
        {
            while core.state == .running
            {
                do
                {
                    if (interactive)
                    {
                        var exit = false;
                        while (!exit)
                        {
                            print("Program Counter: 0x\(Utils.pad(core.pc, digits: 8, radix: 16)) > ", terminator: "")
                            let input = readLine()
                            if (input == "r")
                            {
                                print(core.registerDump())
                            }
                            if (input == "")
                            {
                                exit = true
                            }
                        }
                    }
                    try core.fetch()
                    let disassembly = try core.decode()
                    if disassemble
                    {
                        print(core.pc, disassembly)
                        //print((core as! RV32iCore).registerDump())
                    }
                    timer.counter += 1

                    if timer.counter == (1 << 14)
                    {
                        print("\("Oak Warning".green.bold): This program has taken over \(1 << 10) instructions and may be an infinite loop. You may want to interrupt the program.")
                    }
                    try core.execute()
                }
                catch
                {
                    print("Error: \(error).")
                    timer.stop()
                    timer.print()
                    exit(0xBAD)
                } 
            }

            if core.state == .environmentCall
            {
                timer.pause()
                let service = core.service
                switch (service[0])
                {
                    case 1:
                        print(">", service[1])
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
                        timer.stop()
                        timer.print()
                        return
                    default:
                        print("\("Warning".yellow.bold): Ignored unknown environment call service number \(core.service[0]).")
                }
                core.state = .running
                timer.resume()
            }
        }
    }
}

command.execute()