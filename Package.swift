import PackageDescription

let package = Package(
    name: "SwiftLevelDBApp",
    dependencies: [
        .Package(url: "https://github.com/amraboelela/SwiftLevelDB", majorVersion: 1)
    ]
)
