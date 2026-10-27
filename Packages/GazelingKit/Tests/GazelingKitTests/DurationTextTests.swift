import Foundation
import Testing

@testable import GazelingKit

private let english = Locale(identifier: "en_US")

@Test func durationsReadAsPlainEnglish() {
    #expect(DurationText.format(20, locale: english) == "20 seconds")
    #expect(DurationText.format(60, locale: english) == "1 minute")
    #expect(DurationText.format(300, locale: english) == "5 minutes")
    #expect(DurationText.format(3600, locale: english) == "1 hour")
    #expect(DurationText.format(5400, locale: english) == "1 hour, 30 minutes")
}
