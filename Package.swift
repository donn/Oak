import PackageDescription

let package = Package (
    name: "Oak",
    targets: [
        Target(name: "OakSim", dependencies: ["Oak"]),
        Target(name: "Oak")
    ],
    dependencies:
    [
        .Package(url: "https://github.com/Skyus/Colors.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/oarrabi/Guaka.git", majorVersion: 0)
    ],
    exclude: ["Resources", "Documentation", "Samples"]
)
