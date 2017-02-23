import Foundation

public class Regex
{
    var regex: NSRegularExpression
    
    public init?(_ pattern: String)
    {
        //Notice: Error handling does not work on Linux. So you better be sure they're right.
        do
        {
            self.regex = try NSRegularExpression(pattern: pattern, options: [])
        }
        catch
        {
            print("Instruction Set Error: Regular expression is invalid.")
            return nil
        }
    }
    
    public func matches(in string: String) -> [String]?
    {
        let attempt = regex.matches(in: string, options: [], range: NSMakeRange(0, string.utf16.count))
        
        if (attempt.count == 0)
        {
            return nil
        }
        
        var matches = [String]()
        
        for match in attempt
        {
            #if os(macOS)
                let range = match.rangeAt(0)
            #else
                let range = match.range(at: 0)
            #endif
            
            let start = String.UTF16Index(range.location)
            let end = String.UTF16Index(range.location + range.length)
            if start > string.utf16.endIndex || end > string.utf16.endIndex
            {
                matches.append("")
                continue
            }
            if let match = String(string.utf16[start..<end])
            {
                matches.append(match)
            }
            
        }
        
        return matches
        
    }
    
    public func captures(in string: String) -> [String]?
    {
        let attempt = regex.matches(in: string, options: [], range: NSMakeRange(0, string.utf16.count))
        
        if (attempt.count == 0)
        {
            return nil
        }
        
        var captures = [String]()
        let match = attempt[0]
        let ranges = match.numberOfRanges
        for i in 0..<ranges
        {
            #if os(macOS)
                let range = match.rangeAt(i)
            #else
                let range = match.range(at: i)
            #endif
            
            let start = String.UTF16Index(range.location)
            let end = String.UTF16Index(range.location + range.length)
            
            if start > string.utf16.endIndex || end > string.utf16.endIndex
            {
                captures.append("")
                continue
            }
            if let capture = String(string.utf16[start..<end])
            {
                captures.append(capture)
            }
        }
        
        return captures
    }
    
    /*
     Returns a 2D array with matches and captures.
     */
    public func array(in string: String) -> [[String]]?
    {
        let attempt = regex.matches(in: string, options: [], range: NSMakeRange(0, string.utf16.count))
        
        if (attempt.count == 0)
        {
            return nil
        }
        
        var array = [[String]]()
        for match in attempt
        {
            var captures = [String]()
            let ranges = match.numberOfRanges
            for i in 0..<ranges
            {
                #if os(macOS)
                    let range = match.rangeAt(i)
                #else
                    let range = match.range(at: i)
                #endif
                
                let start = String.UTF16Index(range.location)
                let end = String.UTF16Index(range.location + range.length)
                
                if start > string.utf16.endIndex || end > string.utf16.endIndex
                {
                    captures.append("")
                    continue
                }
                if let capture = String(string.utf16[start..<end])
                {
                    captures.append(capture)
                }
            }
            
            array.append(captures)
        }
        
        return array
    }
}