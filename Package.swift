import PackageDescription

let package = Package(
    name: "SwiftLevelDBApp",
    dependencies: [
        .Package(url: "../../rengo/SwiftLevelDB", majorVersion: 1)
    ]
)
