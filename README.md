![Oak](Resources/logo.png)

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Swift Version 3.1](https://img.shields.io/badge/Swift-3.1--dev-orange.svg)](https://swift.org/download/#swift-31-development)
[![License: MPL 2.0](https://img.shields.io/badge/license-MPL%202.0-orange.svg)](https://www.mozilla.org/en-US/MPL/2.0/)

The hackable, extensible, pure Swift instruction set simulator for Unix (assembly included).

Designed for ARM initially, currently supports RISC-V.

# Requirements
Swift 3.1-dev (Jan 28th Snapshot or later). Supported on both macOS and Linux.

# Usage
Well, more like development environment setup at the moment really...

## Unix
To build and test:

```bash
    swift build
    .build/debug/OakSim [your-file-here]
```

### macOS (Xcode)
Open your terminal, type:

```bash
    swift package generate-xcodeproj
```

...and use the generated Xcode project file. It's gitignored though, as Xcode projects are not as flexible as the Swift Package Manager.


#To-do
* Disassembly. Currently, the disassembler function does nothing, which makes it a bit difficult.
* Core Abstraction. Make Core into a class rather than a protocol. Unlike Oak.js, the Assembler in Oak is extremely customizable, and the simulator should be similar, currently it's a part of the user program and not a customizable part of Oak.
* Documentation. Documentation is sparse, and while it is easy to use, Oak's codebase can be quite intimidating still because of the size.
* Access Control. It is unclear what should be public and what should be private.
* Makefile?

# License
Mozilla Public License 2.0. Check LICENSE.