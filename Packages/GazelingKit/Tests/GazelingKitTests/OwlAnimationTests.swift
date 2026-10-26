import Foundation
import Testing

@testable import GazelingCharacters
@testable import GazelingKit

private func pose(_ script: String, _ t: Double, duration: Double = 20) -> OwlPose {
    OwlAnimation.pose(script: script, at: t, duration: duration)
}

@Test func everyExerciseInTheCatalogHasAnAnimation() throws {
    for exercise in try ExerciseCatalog.bundled().exercises {
        #expect(OwlAnimation.scriptIDs.contains(exercise.animationScript), "\(exercise.id)")
    }
}

@Test func stepsStartAndEndNearNeutral() {
    for id in OwlAnimation.scriptIDs {
        for t in [0.0, 20.0] {
            let p = pose(id, t)
            #expect(abs(p.gazeX) < 0.05 && abs(p.gazeY) < 0.05 && p.wingCover < 0.05, "\(id) at \(t)")
        }
    }
}

@Test func sideToSideReachesBothSides() {
    let xs = stride(from: 0.0, to: 5, by: 0.05).map { pose("side-to-side", $0).gazeX }
    #expect(xs.min()! < -0.95 && xs.max()! > 0.95)
    #expect(stride(from: 0.0, to: 5, by: 0.05).allSatisfy { abs(pose("side-to-side", $0).gazeY) < 0.01 })
}

@Test func upDownReachesTopAndBottom() {
    let ys = stride(from: 0.0, to: 5, by: 0.05).map { pose("up-down", $0).gazeY }
    #expect(ys.min()! < -0.95 && ys.max()! > 0.95)
}

@Test func circlesKeepTheirRadiusAndGoTheRightWay() {
    for id in ["circle-left", "circle-right"] {
        for t in stride(from: 1.0, to: 8, by: 0.25) {
            let p = pose(id, t)
            #expect(abs((p.gazeX * p.gazeX + p.gazeY * p.gazeY).squareRoot() - 1) < 0.01)
        }
    }
    // A quarter lap in (t = 1 s) counter-clockwise is at the left, clockwise at the right.
    #expect(pose("circle-left", 1).gazeX < -0.95)
    #expect(pose("circle-right", 1).gazeX > 0.95)
}

@Test func blinkingClosesFullyAndReopens() {
    let lids = stride(from: 1.0, to: 19, by: 0.02).map { pose("blink", $0).eyelid }
    #expect(lids.max()! > 0.99)
    #expect(lids.min()! < 0.01)
}

@Test func palmingCoversTheEyesInTheMiddleAndLetsGoAtTheEnd() {
    let mid = pose("palming", 10)
    #expect(mid.wingCover > 0.99 && mid.eyelid > 0.99)
    #expect(pose("palming", 19.9).wingCover < 0.1)
}

@Test func walkingAlternatesFeet() {
    let p1 = pose("walk", 1.25)
    let p2 = pose("walk", 1.75)
    #expect(p1.leftFoot > 1 && p1.rightFoot == 0)
    #expect(p2.rightFoot > 1 && p2.leftFoot == 0)
}

@Test func idleBlinksHappenOnTheNonBlinkScripts() {
    let lids = stride(from: 1.0, to: 19, by: 0.02).map { pose("look-far", $0).eyelid }
    #expect(lids.max()! > 0.9)
}

@Test func goodbyeWavesTheRightWing() {
    let wings = stride(from: 0.0, to: 2.2, by: 0.05).map { OwlAnimation.goodbyePose(at: $0).rightWing }
    #expect(wings.min()! > 80 && wings.max()! - wings.min()! > 20)
}

@Test func poseBlendingMovesBetweenPoses() {
    var a = OwlPose()
    a.gazeX = -1
    var b = OwlPose()
    b.gazeX = 1
    #expect(a.blended(with: b, 0.5).gazeX == 0)
    #expect(a.blended(with: b, 0) == a && a.blended(with: b, 1) == b)
}
