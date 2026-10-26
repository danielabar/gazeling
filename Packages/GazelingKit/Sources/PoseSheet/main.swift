import AppKit
import GazelingCharacters
import SwiftUI

// Usage: PoseSheet <output.png>. Renders the owl pose sheet for review.
let path = CommandLine.arguments.dropFirst().first ?? "pose-sheet.png"

MainActor.assumeIsolated {
    let renderer = ImageRenderer(content: PoseSheetView())
    renderer.scale = 1.5
    guard let cgImage = renderer.cgImage,
        let data = NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:]),
        (try? data.write(to: URL(fileURLWithPath: path))) != nil
    else {
        print("render failed")
        exit(1)
    }
    print("wrote \(path)")
}
