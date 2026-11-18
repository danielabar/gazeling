import AppKit
import GazelingCharacters
import SwiftUI

// Usage: PoseSheet sheet <out.png>   the owl's poses and sizes
//        PoseSheet strips <out.png>  frames of every exercise animation
//        PoseSheet scene <out.png>   the owl and window scene at break-screen size
//        PoseSheet icons <AppIcon.appiconset> <MenuBarIcon.imageset>   the app and menu bar icons
//        PoseSheet screenshot <out.png>   a break on a 1280 x 800 screen, for the README
@MainActor
func render<V: View>(_ view: V, scale: CGFloat, to path: String) {
    let renderer = ImageRenderer(content: view)
    renderer.scale = scale
    guard let cgImage = renderer.cgImage,
        let data = NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:]),
        (try? data.write(to: URL(fileURLWithPath: path))) != nil
    else {
        print("render failed")
        exit(1)
    }
    print("wrote \(path)")
}

let args = CommandLine.arguments
guard args.count >= 3 else {
    print("usage: PoseSheet sheet|strips <out.png>")
    exit(2)
}
MainActor.assumeIsolated {
    switch args[1] {
    case "sheet": render(PoseSheetView(), scale: 1.5, to: args[2])
    case "strips": render(AnimationStripsView(), scale: 1.5, to: args[2])
    case "scene": render(ScenePreviewView(), scale: 1.5, to: args[2])
    case "screenshot": render(ScreenshotView(), scale: 2, to: args[2])
    case "icons" where args.count >= 4: renderIcons(appIconSet: args[2], menuBarIconSet: args[3])
    default:
        print("unknown mode \(args[1])")
        exit(2)
    }
}
