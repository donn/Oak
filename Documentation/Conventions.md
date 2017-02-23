# Conventions

I'm using [Ray Wenderlich's Swift style guide](https://github.com/raywenderlich/swift-style-guide), except with Allman-style identation and 4 spaces per indent. Also I use self.variable in initializers to avoid renaming parameters.

I will yield if people prefer K&R-style identation, however, I will yield.

## Integer Typing

* Bytes are octets, and are always UInt8 in Swift. If your ISA has 7-bit bytes, you can treat them as octets and & them with 127 every time.
* Machine code, parts or addresses, regardless of actual length, is always UInt when being passed around. Storage is whatever is deemed appropriate by the ISA.
* Anything Swift will have to deal with (i.e. lengths) should just be an Int.

It is indeed a bit of a waste of space, but reduces the code complexity and typecasting lot. And in an age where memory is abundant but computing power is not, I think it's for the best.