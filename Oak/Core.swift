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
    var instructionSet: InstructionSet { get }
    var state: CoreState { get set }
    var service: Int { get }
        
    func fetch() throws
    func decode() throws -> String
    func execute() throws -> String?
    func loadProgram(machineCode: [UInt8]) throws    
}