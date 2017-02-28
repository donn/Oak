![Oak](Resources/logo.png)

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Swift Version 3.1](https://img.shields.io/badge/Swift-3.1--dev-orange.svg)](https://swift.org/download/#swift-31-development)
[![License: MPL 2.0](https://img.shields.io/badge/license-MPL%202.0-orange.svg)](https://www.mozilla.org/en-US/MPL/2.0/)

The hackable, extensible, pure Swift instruction set simulator for Unix (assembly included).

The ultimate aim for this project is to have a terminal and later GUI app to practice and create various instruction set architectures that is easy to both use *and* modify.

While designed for ARM initially, as one of [Oak.js](https://github.com/skyus/Oak.js) requirements was RISC-V, Oak's backport currently supports RISC-V, but ARM should be coming soon enough.

# Requirements
Swift 3.1-dev (Jan 28th Snapshot or later). Supported on both macOS and Linux.

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