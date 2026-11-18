import AppKit
import SwiftUI

/// The About window: name, version, tagline, why eye breaks help (modest claims), sources and
/// credits. Links use Markdown, which `Text` renders.
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                section("Why take eye breaks") {
                    Text(
                        "Long stretches of close screen work often leave eyes feeling tired or dry. While concentrating, people tend to blink less often and less fully."
                    )
                    Text("Gazeling reminds you to look away, blink fully and move.")
                    Text("Benefits last only as long as the habit does, so Gazeling is meant to run every day.")
                    Text("Gazeling is not a medical device.")
                }
                section("Sources") {
                    Text(
                        "Singh et al. (2022), review of 45 trials on digital eye strain treatments. [Ophthalmology](https://doi.org/10.1016/j.ophtha.2022.05.009)"
                    )
                    Text(
                        "Wolffsohn et al. (2025), blinking exercises trial. [Contact Lens and Anterior Eye](https://doi.org/10.1016/j.clae.2025.102453)"
                    )
                    Text(
                        "Arita et al. (2025), blinking exercises trial. [The Ocular Surface](https://doi.org/10.1016/j.jtos.2025.02.003)"
                    )
                }
                section("Credits") {
                    Text(
                        "Free and open source under the MIT licence. [Source code on GitHub](https://github.com/danielabar/gazeling)"
                    )
                    Text(
                        "Voice: [Kokoro](https://huggingface.co/hexgrad/Kokoro-82M) (Apache 2.0 licence), run with [kokoro-onnx](https://github.com/thewh1teagle/kokoro-onnx) (MIT licence)."
                    )
                    Text("The owl and the chimes were made for Gazeling.")
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(28)
        }
        .frame(width: 480, height: 600)
    }

    private var header: some View {
        HStack(spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: "Gazeling").font(.largeTitle.bold())
                Text("Version \(Self.version)").foregroundStyle(.secondary)
                Text("Short eye breaks for people who live at their screens.")
            }
        }
    }

    private func section<Content: View>(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content)
        -> some View
    {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
        }
    }

    /// "0.1.0 (12)": the version from `project.yml` and the build number.
    private static var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }
}
