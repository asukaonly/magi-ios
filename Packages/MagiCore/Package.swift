// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MagiCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "MagiCore", targets: ["MagiCore"])],
    targets: [
        .target(name: "MagiCore", resources: [.process("Resources")]),
        .testTarget(name: "MagiCoreTests", dependencies: ["MagiCore"]),
    ]
)
