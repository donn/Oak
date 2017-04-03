//Errors
public enum MemoryError: Error
{
    case illegalMemoryAccess
}

public protocol Memory
{
    var size: Int { get }
    func copy(_ address: UInt, count: Int) throws -> [UInt8]
    func set(_ address: UInt, bytes: [UInt8]) throws
    init(_ size: Int)
}

protocol RegisterFile
{
    associatedtype Storage: UnsignedInteger
    subscript(index: Int) -> Storage { get }
}

public enum MemoryBehavior
{
    case direct
    case allocated
    case cached
}

//Main Memory
//Memory that only allocates what it needs regardless of specified size, to help save memory.
//It's a low priority at the moment so it's not implemented just yet.
public class MainMemory
{
    var size: Int //In bytes
    var blockSize: Int
    var allocated: [[UInt8]]
    var allocationDictionary: [Int: Int]
 
    init(size: Int, blockSize: Int = 4096)
    {
        self.size = size
        self.blockSize = blockSize
        self.allocated = [[UInt8]]()
        self.allocationDictionary = [Int: Int]()
    }

}

//Simple Memory
//Directly and indiscriminately allocated.
//I realize this is about as useful as an array with embedded error reporting but. Well. That's what it is.
public class SimpleMemory: Memory
{
    private var storage: [UInt8]

    public var size: Int
    {
        return storage.count
    }
    
    public func set(_ unsignedAddress: UInt, bytes: [UInt8]) throws
    {
        let address = Int(unsignedAddress)
        
        if address < 0 || address + bytes.count > storage.count
        {
            throw MemoryError.illegalMemoryAccess
        }

        for (i, byte) in bytes.enumerated()
        {
            storage[address + i] = byte
        }
    }

    public func copy(_ unsignedAddress: UInt, count: Int) throws -> [UInt8]
    {
        let address = Int(unsignedAddress)
        
        if address < 0 || address + count > storage.count
        {
            throw MemoryError.illegalMemoryAccess
        }
        
        var result = [UInt8]()
        
        for i in 0..<count
        {
            result.append(storage[address + i])
        }
        
        return result
    }

    public required init(_ size: Int)
    {
        storage = [UInt8](repeating: 0, count: size)
    }
}
