import Foundation

public class Utils
{
    public static func pad(_ number: UInt, digits: Int, radix: Int) -> String
    {
        var padded = String(number, radix: radix)
        let length = padded.characters.count
        if digits > length {
        for _ in 0..<(digits - length)
        {
            padded = "0" + padded
        }
        }
        return padded
    }

    /*
        Concatenates bytes to form UInt.
     
        Use a truncating constructor to get the bits back.
    */
    public static func concatenate(bytes: [UInt8], littleEndian: Bool = true) -> UInt
    {
        var element: UInt = 0

        if littleEndian
        {
            for (i, byte) in bytes.enumerated()
            {
                element = element | (UInt(byte) << UInt(8 * i))
            }
        }
        else
        {
            let order = bytes.count - 1
            for (i, byte) in bytes.enumerated()
            {
                element = element | (UInt(byte) << UInt(8 * (order - i)))
            }
        }

        return element
    }

    /*
        Sign-extends a value.
     
        Most revolutionary sign extension. Super elegant.
    */
    public static func signExt(_ value: UInt, bits: Int) -> UInt
    {
        var mutableValue = value
        let uBits = UInt(bits)
        if (mutableValue & (1 << (uBits - 1))) != 0
        {
            mutableValue = ((~(0) >> uBits) << uBits) | value
        }

        return mutableValue
    }

    //Only works up to n bits on an n-bit computer. Send unsigned numbers as Int(bitPattern:)
    public static func rangeCheck(_ value: UInt, bits: Int) -> Bool
    {
        if bits == (MemoryLayout<Int>.size << 3)
        {
            return true
        }
        
        let min = -(1 << bits - 1)
        let max = (1 << bits - 1) - 1
        let valueExtended = signExt(value, bits: bits)
        return (Int(bitPattern: valueExtended) <= max) && (Int(bitPattern: valueExtended) >= min)
    }

}
