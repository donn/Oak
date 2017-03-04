import Foundation
import Colors

public enum Keyword
{
    case directive
    case comment
    case label
    case stringMarker
    case charMarker
    case register
    case blockCommentBegin
    case blockCommentEnd

    //Only send as keywordRegexes
    case string
    case char
    case data
}

public enum Directive
{
    case text
    case data
    case string
    case cString //Null terminated

    //Ints and chars
    case _8bit
    case _16bit
    case _32bit
    case _64bit

    //Fixed point decimals
    case fixedPoint
    case floatingPoint
}

public class Assembler
{
    private var instructionSet: InstructionSet
    private var keywordRegexes: [Keyword: String]
    private var directives: [String: Directive]
    private var endianness: Endianness?

   
    /*
        Argument processor

        Processes Arguments

        (wow)
    */
    public func process(_ text: String, address: UInt, type: Parameter, bits: Int, labels: [String: UInt]) -> (errorMessage: String?, value: UInt)
    {
        let array = Array(text.characters) //Character View
        var errorMessage: String?
        var value: UInt = 0

        switch (type)
        {
            case .register:
                if let index = instructionSet.abiNames.index(where: {$0 == text})
                {
                    value = UInt(index)
                    return (errorMessage, value)
                }
                guard let regex = keywordRegexes[.register], let registerExtract = Regex(regex)!.captures(in: text), let registerNo = UInt( registerExtract[1])
                else
                {
                    errorMessage = "Register \(text) does not exist."
                    return (errorMessage, value)
                }

                if (registerNo & (~UInt(0) << UInt(bits))) == 0
                {
                    value = registerNo
                    return (errorMessage, value)
                }
                else
                {
                    errorMessage = "Register \(text) does not exist."
                    return (errorMessage, value)
                }
                
                
            case .immediate:
                var int: UInt?
                if let target = labels[text]
                {
                    int = target
                }
                else if let regex = keywordRegexes[.char], let charExtract = Regex(regex)!.captures(in: text)
                {
                    var characters = Array(charExtract[1].characters)

                    switch (characters[0])
                    {
                        case "n":
                            characters[1] = "\n"
                        case "0":
                            characters[1] = "\0"
                        case "'":
                            characters[1] = "\'"
                        case "t":
                            characters[1] = "\t"
                        default:
                            break                                               
                    }
                    //TO-DO: finish characters
                    int = 0
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
                    value = unwrap
                    return (errorMessage, value)
                }
                errorMessage = "The value of '\(text)' is out of range."
                return (errorMessage, value)
                
                
            case .offset:
                var int: UInt?
                if let target = labels[text]
                {
                    int = target &- address
                }
                else
                {
                    var radix = 10
                    var splice = false
                    
                    if array[0] == "0"
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
                    value = unwrap
                    return (errorMessage, value)
                }
                errorMessage = "The value of '\(text)' is out of range."
                return (errorMessage, value)
            default:
                return (errorMessage, value)
        }
    }

    /*
     Lexer

     In a way, the first pass of the assembler. It detects syntactic errors and isolates labels and comments.
    */
    public func lex(_ file: String) -> (errorMessages: [String], labels: [String: UInt], lines: [String])
    {
        var errorMessages = [String]()
        var labels = [String: UInt]()
        var lines = [String]()
        
        var address: UInt = 0 
        var text = true
        let list = file.components(separatedBy: "\n")
        
        for (i, line) in list.enumerated()
        {
            var lineMutable = line
            
            //Comments
            if let separator = keywordRegexes[.comment]
            {
                if let captures = Regex(separator)!.captures(in: lineMutable)
                {
                    lineMutable = captures[1]
                }
            }
            
            //Labels
            if let separator = keywordRegexes[.label]
            {
                if let captures = Regex(separator)!.captures(in: lineMutable)
                {
                    labels[captures[2]] = address
                    lineMutable = captures[3]
                }
            }
            
            //Check for Directives
            //If your ISA's standard has the directive anywhere other than the beginning of the string, please raise an issue.
            guard let words = Regex("[^\\s]+")!.matches(in: lineMutable)
            else
            {
                continue
            }

            var directiveString: String?
            var directiveData: String?
            if let separator = keywordRegexes[.directive]
            {
                if let captures = Regex(separator)!.captures(in: lineMutable)
                {
                    directiveString = captures[1]
                    directiveData = captures[2]
                }
                
            }
            
            //Calculate size in bytes
            if (text)
            {
                if let str = directiveString, let directive = directives[str]
                {
                    switch (directive)
                    {
                        case .data:
                            text = false
                            if (words.count > 1)
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): This directive does not take any parameters."
                                errorMessages.append(message)
                                continue
                            }
                        case .text:
                            if (words.count > 1)
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): This directive does not take any parameters."
                                errorMessages.append(message)
                                continue
                            }
                        default:
                            //TODO - Allow user-defined directives
                            let message = "\("Assembler Error:".red.bold) Line \(i): This directive is unsupported in the text section."
                            errorMessages.append(message)
                            continue
                    }
                }
                else
                {
                    guard let instruction = instructionSet.instruction(prefixing: lineMutable)
                    else
                    {
                        let message = "\("Assembler Error:".red.bold) Line \(i): Instruction \(words[0]) not found."
                        errorMessages.append(message)
                        continue
                    }
                
                    address += UInt(instruction.bytes)
                }
            }
            else
            {
                if let str = directiveString, let directive = directives[str]
                {
                    switch (directive)
                    {
                        case .data:
                            if (words.count > 1)
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): This directive does not take any parameters."
                                errorMessages.append(message)
                                continue
                            }
                        case .text:
                            text = true
                            if (words.count > 1)
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): This directive does not take any parameters."
                                errorMessages.append(message)
                                continue
                            }
                        case .cString:                            
                            address += 1
                            fallthrough
                        case .string:
                            guard let regex = keywordRegexes[.string], let captures = Regex(regex)!.captures(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): Malformed string."
                                errorMessages.append(message)
                                continue
                            }
                            let array = Array(captures[1].characters)
                            for character in array
                            {
                                if (character == "\\")
                                {
                                    address -= 1
                                }
                                address += 1
                            }
                        //Ints and chars
                        case ._8bit:
                            guard let regex = keywordRegexes[.data], let matches = Regex(regex)!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No 8-bit values found."
                                errorMessages.append(message)
                                continue
                            }
                            address += UInt(matches.count)
                        case ._16bit:
                            guard let regex = keywordRegexes[.data], let matches = Regex(regex)!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No 16-bit values found."
                                errorMessages.append(message)
                                continue
                            }
                            address += UInt(matches.count << 1)
                        case ._32bit:
                            guard let regex = keywordRegexes[.data], let matches = Regex(regex)!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No 32-bit values found."
                                errorMessages.append(message)
                                continue
                            }
                            address += UInt(matches.count << 2)
                        case ._64bit:
                            guard let regex = keywordRegexes[.data], let matches = Regex(regex)!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No 64-bit values found."
                                errorMessages.append(message)
                                continue
                            }
                            address +=  UInt(matches.count << 3)
                        //Fixed point decimals
                        case .fixedPoint:
                            let message = "\("Oak Error:".blue.bold) Line \(i): Fixed point decimals not yet supported."
                            errorMessages = [message]
                            return (errorMessages, labels, lines)
                        case .floatingPoint:
                            guard let matches = Regex("[-+]?[0-9]*\\.?[0-9]+")!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No floating point values found."
                                errorMessages.append(message)
                                continue
                            }
                            guard let width = instructionSet.floatingPointLengths[str]
                            else
                            {
                                let message = "\("Instruction Set Error:".blue.bold) Line \(i): Floating point directive \(str) has a missing octet length."
                                errorMessages = [message]
                                return (errorMessages, labels, lines)
                            }
                            address +=  UInt(matches.count * width)
                        default:
                            //TODO - Allow user-defined directives
                            let message = "\("Assembler Error:".red.bold) Line \(i): This directive is unsupported in the data section."
                            errorMessages.append(message)
                            continue
                    }
                }
                else
                {
                    if let _ = instructionSet.instruction(prefixing: lineMutable)
                    {
                        let message = "\("Assembler Error:".red.bold) Line \(i): Instruction \(words[0]) is in the data section."
                        errorMessages.append(message)
                        continue
                    }

                    let message = "\("Assembler Error:".red.bold) Line \(i): Unrecognized keyword \(words[0])."
                    errorMessages.append(message)
                    continue
                }
            }
            lines.append(lineMutable)
        }
        
        return (errorMessages, labels, lines)
    }

    public func assemble(_ lines: [String], labels: [String: UInt]) -> (errorMessages: [String], machineCode: [UInt8])
    {
        var errorMessages = [String]()
        var machineCode = [UInt8]()
        var address: UInt = 0

        var text = true

        var skipLine = false
        assembling: for (i, line) in lines.enumerated()
        {
            skipLine = false

            guard let words = Regex("[^\\s]+")!.matches(in: line)
            else
            {
                continue
            }

            var directiveString: String?
            var directiveData: String?
            if let separator = keywordRegexes[.directive]
            {
                if let captures = Regex(separator)!.captures(in: line)
                {
                    directiveString = captures[1]
                    directiveData = captures[2]
                }
            }
            
            //Calculate lengths
            if (text)
            {
                if let str = directiveString, let directive = directives[str]
                {
                    switch (directive)
                    {
                        case .data:
                            text = false
                            if words.count > 1
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): This directive does not take any parameters."
                                errorMessages.append(message)
                                continue
                            }
                        case .text:
                            if words.count > 1
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): This directive does not take any parameters."
                                errorMessages.append(message)
                                continue
                            }
                        default:
                            //TODO - Allow user-defined directives
                            let message = "\("Assembler Error:".red.bold) Line \(i): This directive is unsupported in the text section."
                            errorMessages.append(message)
                            continue
                    }
                }
                else
                {
                    guard let instruction = self.instructionSet.instruction(prefixing: line)
                    else
                    {
                        let message = "\("Assembler Error:".red.bold) Line \(i): Instruction \(words[0]) not found."
                        errorMessages.append(message)
                        continue
                    }
                    
                    let format = instruction.format
                    let bitRanges = format.ranges
                    let regex = format.regex
                    var code = instruction.template
                    
                    guard var captures = regex.captures(in: line)
                    else
                    {
                        let message = "\("Assembler Error:".red.bold) Line \(i): Argument format for \(words[0]) violated."
                        errorMessages.append(message)
                        continue
                    }
                    captures.removeFirst()
                    
                    

                    for (i, range) in bitRanges.enumerated()
                    {
                        if let parameter = range.parameter
                        {    
                            var startBit = 0
                            var endBit: Int?
                            var bits = range.bits
                            var field = range.field

                            let limits = Regex("([A-za-z]+)\\s*\\[\\s*(\\d+)\\s*:\\s*(\\d+)\\s*\\]")!.captures(in: range.field)

                            if let limited = limits 
                            {
                                field = limited[1]
                                bits = range.totalBits!
                            }                
                            
                            var register: UInt = 0
                            
                            if range.parameterType == .special
                            {
                                guard let specialProcess = instruction.format.processSpecialParameter[field]
                                else
                                {
                                    let message = "\("Instruction Set Error:".blue.bold) Line \(i): Special parameter '\(field)' missing parameter processor."
                                    errorMessages = [message]
                                    return (errorMessages, machineCode)
                                }
                                let processed = specialProcess(captures[parameter], address, bits, labels)
                                if let error = processed.errorMessage
                                {
                                    let message = "\("Assembler Error:".red.bold) Line \(i): \(error)"
                                    errorMessages.append(message)
                                    skipLine = true
                                    continue
                                }
                                register = processed.value
                            }
                            else
                            {
                                guard let type = range.parameterType
                                else
                                {
                                    let message = "\("Instruction Set Error:".blue.bold) Line \(i): Parameter '\(field)' missing parameter type."
                                    errorMessages = [message]
                                    return (errorMessages, machineCode)
                                }
                                let processed = process(captures[parameter], address: address, type: type, bits: bits, labels: labels)
                                if let error = processed.errorMessage
                                {
                                    let message = "\("Assembler Error:".red.bold) Line \(i): \(error)"
                                    errorMessages.append(message)
                                    skipLine = true
                                    continue
                                }
                                register = processed.value
                            }
                            
                            if let limited = limits
                            {
                                startBit = Int(limited[3])!
                                endBit = Int(limited[2])!
                                
                                register = register >> UInt(startBit)
                                register = register & ((1 << (UInt(endBit!) - UInt(startBit) + 1)) - 1)
                            }
                            
                            code = code | register << UInt(range.start)
                            
                        }
                    }
                    if skipLine
                    {
                        continue
                    }
                    
                    if endianness == .big
                    {
                        //TO-DO
                    }
                    else //Default to little endian.
                    {
                        for _ in 0..<instruction.bytes
                        {
                            machineCode.append(UInt8(code & 255))
                            code = code >> 8
                        }
                    }

                    address += UInt(instruction.bytes)
                }
            }
            else
            {
                if let str = directiveString, let directive = directives[str]
                {
                    switch (directive)
                    {
                        case .data:
                            if words.count > 1
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): This directive does not take any parameters."
                                errorMessages.append(message)
                                continue
                            }
                        case .text:
                            text = true
                            if words.count > 1
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): This directive does not take any parameters."
                                errorMessages.append(message)
                                continue
                            }
                        case .cString:                            
                            address += 1
                            fallthrough
                        case .string:
                            guard let regex = keywordRegexes[.string], let captures = Regex(regex)!.captures(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): Malformed string."
                                errorMessages.append(message)
                                continue
                            }
                            var characters = Array(captures[1].characters)
                            var j = 0
                            while (j < characters.count)
                            {
                                if characters[j] == "\\"
                                {
                                    if (j + 1 < characters.count)
                                    {
                                        switch (characters[j + 1])
                                        {
                                            case "n":
                                                characters[j + 1] = "\n"
                                            case "0":
                                                characters[j + 1] = "\0"
                                            case "'":
                                                characters[j + 1] = "\'"
                                            case "t":
                                                characters[j + 1] = "\t"
                                            default:
                                                break                                               
                                        }
                                        characters.remove(at: j)
                                        j -= 1
                                    }
                                }
                                j += 1
                            }
                            let utfArray = Array(String(characters).utf8)
                            machineCode.append(contentsOf: utfArray)
                            address += UInt(utfArray.count)
                            if directive == .cString
                            {
                                machineCode.append(0)
                            }
                        //Ints and chars
                        //To-do: make this more optimized because this is mostly identical code
                        case ._8bit:
                            guard let regex = keywordRegexes[.data], let matches = Regex(regex)!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No values found."
                                errorMessages.append(message)
                                continue
                            }
                            for (j, match) in matches.enumerated()
                            {
                                let processed = process(match, address: address, type: .immediate, bits: 8, labels: labels)
                                if let error = processed.errorMessage
                                {
                                    let message = "\("Assembler Error:".red.bold) Line \(i): Value \(j): \(error)."
                                    errorMessages.append(message)
                                    continue
                                }
                                machineCode.append(UInt8(processed.value))
                            }
                            address += UInt(matches.count)
                        case ._16bit:
                            guard let regex = keywordRegexes[.data], let matches = Regex(regex)!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No values found."
                                errorMessages.append(message)
                                continue
                            }
                            for (j, match) in matches.enumerated()
                            {
                                let processed = process(match, address: address, type: .immediate, bits: 16, labels: labels)
                                if let error = processed.errorMessage
                                {
                                    let message = "\("Assembler Error:".red.bold) Line \(i): Value \(j): \(error)."
                                    errorMessages.append(message)
                                    continue
                                }
                                machineCode.append(UInt8(processed.value & 255))
                                machineCode.append(UInt8((processed.value >> 8) & 255))
                            }
                            address += UInt(matches.count << 1)
                        case ._32bit:
                            guard let regex = keywordRegexes[.data], let matches = Regex(regex)!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No 32-bit values found."
                                errorMessages.append(message)
                                continue
                            }
                            for (j, match) in matches.enumerated()
                            {
                                let processed = process(match, address: address, type: .immediate, bits: 32, labels: labels)
                                if let error = processed.errorMessage
                                {
                                    let message = "\("Assembler Error:".red.bold) Line \(i): Value \(j): \(error)."
                                    errorMessages.append(message)
                                    continue
                                }
                                machineCode.append(UInt8(processed.value & 255))
                                machineCode.append(UInt8((processed.value >> 8) & 255))
                                machineCode.append(UInt8((processed.value >> 16) & 255))
                                machineCode.append(UInt8((processed.value >> 24) & 255))
                            }
                            address += UInt(matches.count << 2)
                        case ._64bit:
                            guard let regex = keywordRegexes[.data], let matches = Regex(regex)!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No values found."
                                errorMessages.append(message)
                                continue
                            }
                            for (j, match) in matches.enumerated()
                            {
                                let processed = process(match, address: address, type: .immediate, bits: 64, labels: labels)
                                if let error = processed.errorMessage
                                {
                                    let message = "\("Assembler Error:".red.bold) Line \(i): Value \(j): \(error)."
                                    errorMessages.append(message)
                                    continue
                                }
                                machineCode.append(UInt8(processed.value & 255))
                                machineCode.append(UInt8((processed.value >> 8) & 255))
                                machineCode.append(UInt8((processed.value >> 16) & 255))
                                machineCode.append(UInt8((processed.value >> 24) & 255))
                                machineCode.append(UInt8((processed.value >> 32) & 255))
                                machineCode.append(UInt8((processed.value >> 40) & 255))
                                machineCode.append(UInt8((processed.value >> 48) & 255))
                                machineCode.append(UInt8((processed.value >> 56) & 255))
                            }
                            address +=  UInt(matches.count << 3)
                        //Fixed point decimals
                        case .fixedPoint:
                            let message = "\("Oak Error:".blue.bold) Line \(i): Fixed point decimals not yet supported."
                            errorMessages = [message]
                            return (errorMessages, machineCode)
                        case .floatingPoint:
                            guard let matches = Regex("[-+]?[0-9]*\\.?[0-9]+")!.matches(in: directiveData!)
                            else
                            {
                                let message = "\("Assembler Error:".red.bold) Line \(i): No floating point values found."
                                errorMessages.append(message)
                                continue
                            }
                            guard let width = instructionSet.floatingPointLengths[str]
                            else
                            {
                                let message = "\("Instruction Set Error:".blue.bold) Line \(i): Floating point directive \(str) has a missing octet length.\nConsider submitting a bug report."
                                errorMessages = [message]
                                return (errorMessages, machineCode)
                            }
                            for (j, match) in matches.enumerated()
                            {
                                let message = "\("Oak Error:".blue.bold) Line \(i): Floating point decimal support is not yet finished."
                                errorMessages = [message]
                                return (errorMessages, machineCode)
                            }
                            address +=  UInt(matches.count * width)
                        default:
                            //TODO - Allow user-defined directives
                            let message = "\("Assembler Error:".red.bold) Line \(i): This directive is unsupported in the data section."
                            errorMessages.append(message)
                            continue
                    }
                }
                else
                {
                    let message = "\("Assembler Error:".red.bold) Line \(i): Only directives are accepted in the data section."
                    errorMessages.append(message)
                    continue
                }
            }
        }
        
        return (errorMessages, machineCode)
    }

    static func options(from list: [String]) -> String?
    {
        if list.count == 0
        {
            return nil
        }

        var options: String = ""
        for keyword in list
        {
            if keyword == "\\"
            {
                print("\("Instruction Set Error:".blue.bold) Escape character \\ cannot be used as a keyword.")
            }
            if options.isEmpty
            {
                options = "(?:"
            }
            else
            {
                options += "|"
            }
            options += keyword
        }

        return options + ")";
    }

    /*
        Initializer

        You can either send a keyword list (properly regex-escaped) and let Oak construct its default regexes, or send regexes directly (faster). You need at least one of these. If both are sent, it will default to the regex list. If neither are sent, your ISA will not support anything but plain ol' instructions.
    */
    public init(for instructionSet: InstructionSet, endianness: Endianness? = nil)
    {
        if let regexes = instructionSet.keywordRegexes 
        {
            self.keywordRegexes = regexes
        }
        else if let words = instructionSet.keywords
        {
            self.keywordRegexes = [:]
            
            if let list = words[.directive]
            {
                if let options = Assembler.options(from: list)
                {
                    self.keywordRegexes[.directive] = "\(options)([^\\s]+)\\s*(.+)*"
                }
            }
                    
            if let list = words[.stringMarker]
            {
                if let options = Assembler.options(from: list)
                {
                    self.keywordRegexes[.string] = "\(options)(.*?)\(options)"
                }
            }

            if let list = words[.comment]
            {
                if let options = Assembler.options(from: list)
                {
                    self.keywordRegexes[.comment] = "(.*?)(\(options).*)"
                }
            }

            if let list = words[.label]
            {
                if let options = Assembler.options(from: list)
                {
                    self.keywordRegexes[.label] = "(([A-Za-z_][A-Za-z0-9_]*)\(options))?\\s*(.*)?"
                }
            }
            
            if let list = words[.register]
            {
                if let options = Assembler.options(from: list)
                {
                    self.keywordRegexes[.register] = "\(options)([0-9]+)"
                }
            }

            self.keywordRegexes[.data] = "((?:0[bodx])?[A-F0-9]+)|([_A-Za-z][_A-Za-z0-9]+)"
            if let list = words[.charMarker]
            {
                if let options = Assembler.options(from: list)
                {
                    self.keywordRegexes[.data] = "(\(options)..?\(options))|((?:0[bodx])?[A-F0-9]+)|([_A-Za-z][_A-Za-z0-9]+)"
                    self.keywordRegexes[.char] = "\(options)(..?)\(options)"
                }

            }

            if let list0 = words[.blockCommentBegin]
            {
                if let options0 = Assembler.options(from: list0)
                {
                    if let list1 = words[.blockCommentEnd]
                    {
                        if let options1 = Assembler.options(from: list1)
                        {
                            print("\("Oak Warning:".yellow.bold) Oak does not support block comments just yet, so please do not use them in your code.")
                        }
                    }
                }
            }
        }
        else
        {
            self.keywordRegexes = [:]
            print("\("Instruction Set Warning:".yellow.bold) This instruction set doesn't define any keywords.\nTo suppress this warning, pass an empty [:] to \"keywords\".")
        }
        self.directives = instructionSet.directives
        self.endianness = endianness ?? instructionSet.endianness
        self.instructionSet = instructionSet
    }    
}
