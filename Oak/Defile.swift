import Foundation

public enum DefileModes
{
    case read
    case write
    case append
}

public enum DefileError: Error
{
    case modeMismatch
    case writeFailure
    case null
}

extension String
{
    public func replacing(_ extensions: [String], with replacement: String) -> String
    {
        var components = self.components(separatedBy: ".")
        let last = components.count - 1
        if extensions.contains(components[last])
        {
            components.remove(at: last)
        }
        components.append(replacement)
        return components.joined(separator: ".")
    }
}

public class Defile
{
    private var file: UnsafeMutablePointer<FILE>
    private var mode: DefileModes
    var endOfFile: Bool
    {
       return feof(file) == 0
    }

    /*
     Initializes file.
     
     path: The give path (or filename) to open the file in.
     
     mode: .read, .write or .append.
        *.read opens file for reading. If the file does not exist, the initializer fails.
        *.write opens file for writing. If the file does not exist, it will be created.
        *.append opens the file for appending more information to the end of the file. If the file does not exist, it will be created.
     
     bufferSize: If you are going to be streaming particularly long strings (i.e. >1024 UTF8 characters), you might want to increase this value. Otherwise, the string will be truncated to a maximum length of 1024.
    */
    public init?(_ path: String, mode: DefileModes)
    {
        var modeStr: String
        
        switch(mode)
        {
            case .read:
                modeStr = "r"
            case .write:
                modeStr = "w"
            case .append:
                modeStr = "a"
        }
        
        guard let file = fopen(path, modeStr)
        else
        {
            return nil
        }

        self.file = file        
        self.mode = mode
    }

    deinit
    {
        fclose(file)
    }
    
    /*
     Loads the rest of the file into a string. Proceeds to remove entire file from stream.
     */
    public func dumpString() throws -> String
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var string = ""
            
        var character = fgetc(file)
        
        while character != EOF
        {
            string += "\(UnicodeScalar(UInt32(character))!)"
            character = fgetc(file)
        }        
        
        return string        
    }
    
    /*
     Reads one line from file, removes it from stream.
     */
    public func readLine() throws -> String? 
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var string = ""
        
        var character = fgetc(file)
        
        while character != EOF &&  UInt8(character) != UInt8(ascii:"\n") 
        {
            (UInt8(character) != UInt8(ascii:"\r")) ? string += "\(UnicodeScalar(UInt32(character))!)" : ()
            character = fgetc(file)
        }
        
        if (string == "")
        {
            return nil
        }
        
        return string
    }
    
    /*
     Reads one string from file, removes it (and any preceding whitespace) from stream.
     */
    public func readString() throws -> String?
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var string = ""
        
        var character = fgetc(file)

        while UInt8(character) == UInt8(ascii:"\n") || UInt8(character) == UInt8(ascii:"\r") || UInt8(character) == UInt8(ascii:" ") || UInt8(character) == UInt8(ascii:"\t")
        {
            character = fgetc(file)
        }
        
        while character != EOF && UInt8(character) != UInt8(ascii:"\n") && UInt8(character) != UInt8(ascii:"\r") && UInt8(character) != UInt8(ascii:" ")
        {
            string += "\(UnicodeScalar(UInt32(character))!)"
            character = fgetc(file)
        }
        
        if (string == "")
        {
            return nil
        }
        
        return string
    }

    /*
     Loads the rest of the file into a string. Proceeds to remove entire file from stream.
     */
    public func dumpBytes() throws -> [UInt8]
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var bytes = [UInt8]()
            
        var character = fgetc(file)
        
        while character != EOF
        {
            bytes.append(UInt8(character))
            character = fgetc(file)
        }

        return bytes        
    }

    /*
     Reads binary data from file, removes it from stream.
     */
    public func readBytes(count: Int) throws -> [UInt8]?
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var bytes = [UInt8]()
        var character: Int32 = 0
        for _ in 0..<count
        {
            fread(&character, 1, 1, file);
            if character == EOF
            {
                return nil
            }
            bytes.append(UInt8(character & 0xFF))
        }

        return bytes
    }
    
    /*
     Writes binary data to file.
    */
    public func write(bytes: [UInt8]) throws
    {
        if mode != .write
        {
            throw DefileError.modeMismatch
        }

        for byte in bytes
        {
            if (fputc(Int32(byte), file) == EOF)
            {
                throw DefileError.writeFailure
            }
        }
    }

    /*
     Appends binary data to file.
    */
    public func append(bytes: [UInt8]) throws
    {
        if mode != .append
        {
            throw DefileError.modeMismatch
        }

        for byte in bytes
        {
            if (fputc(Int32(byte), file) == EOF)
            {
                throw DefileError.writeFailure
            }
        }
    }
}
