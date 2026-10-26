// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GazelingKit",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "GazelingKit", targets: ["GazelingKit"]),
        .library(name: "GazelingCharacters", targets: ["GazelingCharacters"]),
    ],
    targets: [
        .target(name: "GazelingKit", resources: [.process("Resources")]),
        // Character drawing (SwiftUI). Separate from GazelingKit, which imports Foundation only.
        .target(name: "GazelingCharacters"),
        // Command-line tool: renders the owl pose sheet to a PNG (`make pose-sheet`).
        .executableTarget(name: "PoseSheet", dependencies: ["GazelingCharacters"]),
        .testTarget(name: "GazelingKitTests", dependencies: ["GazelingKit", "GazelingCharacters"]),
    ]
)
