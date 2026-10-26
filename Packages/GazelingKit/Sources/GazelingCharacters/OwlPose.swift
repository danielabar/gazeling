import Foundation

/// Everything that can move on the owl, as plain numbers so poses can be blended for animation.
public struct OwlPose: Equatable, Sendable {
    /// Where the pupils look: -1 (far left / up) to 1 (far right / down).
    public var gazeX = 0.0
    public var gazeY = 0.0
    /// 0 open, 1 fully closed.
    public var eyelid = 0.0
    /// 0 round eyes, 1 happy crescent eyes (lower lids pushed up).
    public var smile = 0.0
    /// -1 furrowed, 0 neutral, 1 raised.
    public var brow = 0.0
    /// Head tilt in degrees, positive is clockwise.
    public var headTilt = 0.0
    /// How far each wing is lifted away from the body, in degrees. Left and right are the owl's own sides as the viewer sees them.
    public var leftWing = 0.0
    public var rightWing = 0.0
    /// 0 wings at the sides, 1 both wings cupped over the eyes.
    public var wingCover = 0.0

    /// Whole-figure lift in points (walking bounce).
    public var bounce = 0.0
    /// How far each foot is lifted, in points.
    public var leftFoot = 0.0
    public var rightFoot = 0.0
    /// 0 to 1, the chest swelling slightly as the owl breathes.
    public var breathe = 0.0

    public init() {}

    private static var fields: [WritableKeyPath<OwlPose, Double>] {
        [
            \.gazeX, \.gazeY, \.eyelid, \.smile, \.brow, \.headTilt, \.leftWing, \.rightWing, \.wingCover,
            \.bounce, \.leftFoot, \.rightFoot, \.breathe,
        ]
    }

    /// Moves from this pose toward `other`: 0 gives this pose, 1 gives `other`.
    public func blended(with other: OwlPose, _ amount: Double) -> OwlPose {
        var result = self
        for field in Self.fields {
            result[keyPath: field] = self[keyPath: field] + (other[keyPath: field] - self[keyPath: field]) * amount
        }
        return result
    }

    public static let neutral = OwlPose()

    public static var happy: OwlPose {
        var p = OwlPose()
        p.smile = 1
        p.brow = 0.6
        return p
    }

    public static var concentrating: OwlPose {
        var p = OwlPose()
        p.brow = -0.45
        p.eyelid = 0.12
        p.headTilt = -4
        return p
    }

    public static var eyesClosed: OwlPose {
        var p = OwlPose()
        p.eyelid = 1
        p.brow = 0.2
        return p
    }

    public static var palming: OwlPose {
        var p = OwlPose()
        p.wingCover = 1
        p.eyelid = 1
        return p
    }

    public static var wave: OwlPose {
        var p = OwlPose()
        p.smile = 1
        p.brow = 0.6
        p.rightWing = 125
        p.headTilt = 5
        return p
    }

    public static var lookLeft: OwlPose {
        var p = OwlPose()
        p.gazeX = -1
        return p
    }

    public static var lookUpRight: OwlPose {
        var p = OwlPose()
        p.gazeX = 1
        p.gazeY = -1
        return p
    }
}
