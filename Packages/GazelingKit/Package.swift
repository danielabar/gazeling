// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GazelingKit",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "GazelingKit", targets: ["GazelingKit"])
    ],
    targets: [
        .target(name: "GazelingKit"),
        .testTarget(name: "GazelingKitTests", dependencies: ["GazelingKit"]),
    ]
)
