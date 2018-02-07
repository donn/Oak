## Note: Oak is no longer under active development. If you would like to continue using Oak, you may fork this project or try [Oak.js](https://github.com/skyus/Oak.js).

![Oak](Resources/logo.png)

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Swift Version 3.1](https://img.shields.io/badge/Swift-3.1-orange.svg)](https://swift.org/download/#swift-31-development)
[![License: MPL 2.0](https://img.shields.io/badge/license-MPL%202.0-orange.svg)](https://www.mozilla.org/en-US/MPL/2.0/)

The hackable, extensible, pure Swift instruction set simulator for Unix (assembly included).

Supports a limited subset of MIPS and RISC-V.

# Requirements
Swift 3.1 on either macOS or Linux.

# Usage
## Unix
To build and test:

```bash
    make
    make install
    oak <your-file-here>
```

### macOS (Xcode)
Open your terminal, type:

```bash
    swift package generate-xcodeproj
```

...and use the generated Xcode project file. It's gitignored though, as Xcode projects are not as flexible as the Swift Package Manager.

# License
Mozilla Public License 2.0. Check LICENSE.
