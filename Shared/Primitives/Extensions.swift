// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

extension CGAffineTransform: CustomDebugStringConvertible {
    public var debugDescription: String {
        "p\((CGPoint.zero << self).compact())"
        + " s\((CGSize(radius: 1) << self).compact())"
    }
}

extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}

extension CGSize {
    func compact() -> String {
        "(\(Double(width).asString(decimals: 3, fixedWidth: 8))"
        + ", \(Double(height).asString(decimals: 3, fixedWidth: 8)))"
    }
}

extension CGPoint {
    func compact() -> String {
        "(\(Double(x).asString(decimals: 3, fixedWidth: 8))"
        + ", \(Double(y).asString(decimals: 3, fixedWidth: 8)))"
    }
}

extension String {
    func substr(_ range: Range<Int>) -> Substring {
        let i = self.startIndex
        let j = self.index(i, offsetBy: range.lowerBound)
        let k = self.index(i, offsetBy: range.upperBound)
        return self[j..<k]
    }
}

// 🙏 https://www.hackingwithswift.com/example-code/language/how-to-find-the-difference-between-two-arrays
extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

// swiftlint:disable shorthand_operator
extension CGAffineTransform {
    static func * (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
        lhs.concatenating(rhs)
    }

    static func *= (lhs: inout CGAffineTransform, rhs: CGAffineTransform) {
        lhs = lhs * rhs
    }

    static func / (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
        return lhs.concatenating(rhs.inverted())
    }

    static func /= (lhs: inout CGAffineTransform, rhs: CGAffineTransform) {
        lhs = lhs / rhs
    }
}
// swiftlint:enable shorthand_operator

infix operator <<
infix operator <<=

extension CGPoint {
    static func << (lhs: CGPoint, rhs: CGAffineTransform) -> CGPoint {
        lhs.applying(rhs)
    }

    static func <<= (lhs: inout CGPoint, rhs: CGAffineTransform) {
        lhs = lhs << rhs
    }
}

extension CGSize {
    static func << (lhs: CGSize, rhs: CGAffineTransform) -> CGSize {
        lhs.applying(rhs)
    }

    static func <<= (lhs: inout CGSize, rhs: CGAffineTransform) {
        lhs = lhs << rhs
    }
}

extension CGPoint {
    func asTransform() -> CGAffineTransform {
        CGAffineTransform(translationX: radius, y: 0)
    }

    var radius: Double { x }
}

extension CGSize {
    init(square: Double) {
        self.init(width: square, height: square)
    }

    func asTransform() -> CGAffineTransform {
        CGAffineTransform(scaleX: radius, y: radius)
    }

    var radius: Double {
        get { width / 2.0 }
        set { width = newValue * 2.0; height = newValue * 2.0 }
    }
}

extension SKSpriteNode {
    var radius: Double {
        get { size.width / 2.0 }
        set { size = CGSize(square: newValue * 2.0) }
    }
}

extension CGFloat {
    static let tau = CGFloat.pi * 2

    func asString(decimals: Int) -> String {
        Double(self).asString(decimals: decimals)
    }
}

extension Double {
    static let tau = Double.pi * 2

    func asString(decimals: Int, fixedWidth: Int? = nil) -> String {
        let fw = (fixedWidth == nil) ? "" : "\(fixedWidth!)"
        let format = String(format: "%%\(fw).\(decimals)f")
        let result = String(format: format, self)
        return result
    }
}

// 🙏
// https://gist.github.com/backslash-f/487f2b046b1e94b2f6291ca7c7cd9064
extension ClosedRange {
    func clamp(_ value: Bound) -> Bound {
        return lowerBound > value ? self.lowerBound
            : upperBound < value ? self.upperBound
            : value
    }
}

extension CGPoint {
    static let anchorAtCenter = CGPoint(x: 0.5, y: 0.5)
    static let anchorDueWest = CGPoint(x: 0.0, y: 0.5)

    enum CompactType { case xy, rθ }

    func getCompact(_ type: CompactType = CompactType.xy) -> String {
        switch type {
        case .xy:
            let xx = Double(self.x).asString(decimals: 2)
            let yy = Double(self.y).asString(decimals: 2)
            return "(x: \(xx), y: \(yy))"

        case .rθ:
            let rr = Double(self.hypotenuse / 2).asString(decimals: 2)
            let θθ = Double(self.theta).asString(decimals: 2)
            return "(r: \(rr), θ: \(θθ))"
        }
    }
}
