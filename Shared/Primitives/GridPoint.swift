import CoreGraphics

struct GridPoint: Overload2D, Numeric, Hashable {
    typealias IntegerLiteralType = Int
    typealias Magnitude = CGFloat

    // swiftlint:disable unused_setter_value
    var aa: CGFloat { get { CGFloat(x) } set { } }
    var bb: CGFloat { get { CGFloat(y) } set { } }
    // swiftlint:enable unused_setter_value

    init?<T>(exactly source: T) where T : BinaryInteger { x = 0; y = 0 }
    init(integerLiteral value: Int) { x = value; y = value }

    func asPoint() -> CGPoint { return CGPoint(x: x, y: y) }

    func asSize() -> CGSize { return CGSize(width: x, height: y) }

    func asVector() -> CGVector { return CGVector(dx: x, dy: y) }

    static func makeTuple(_ xx: CGFloat, _ yy: CGFloat) -> GridPoint { GridPoint(xx, yy) }

    var magnitude: CGFloat { sqrt(CGFloat(x * x + y * y)) }

    let x: Int; let y: Int

    init(_ point: GridPoint) { x = point.x; y = point.y }
    init(x: Int, y: Int) { self.x = x; self.y = y }
    init(_ x: CGFloat, _ y: CGFloat) { self.x = Int(x); self.y = Int(y) }

    static let zero = GridPoint(x: 0, y: 0)

    func distance(to otherPoint: GridPoint) -> CGFloat {
        return (otherPoint - self).hypotenuse
    }

    static func random(_ xRange: Range<Int>, _ yRange: Range<Int>) -> GridPoint {
        let xx = Int.random(in: xRange), yy = Int.random(in: yRange)
        return GridPoint(x: xx, y: yy)
    }

    static func + (_ lhs: GridPoint, _ rhs: GridPoint) -> GridPoint {
        return GridPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func += (_ L: inout GridPoint, _ R: GridPoint) { L = L + R }

    static func - (_ lhs: GridPoint, _ rhs: GridPoint) -> GridPoint {
        return GridPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func -= (_ L: inout GridPoint, _ R: GridPoint) { L = L - R }

    static func * (_ lhs: GridPoint, _ rhs: Int) -> GridPoint {
        return GridPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func *= (_ L: inout GridPoint, _ R: GridPoint) { L = L * R }
}

#if DEBUG
extension GridPoint: CustomDebugStringConvertible {
    var debugDescription: String { String(format: "(%+d, %+d)", x, y) }
}
#endif

struct GridSize: Overload2D, Hashable {
    // swiftlint:disable unused_setter_value
    var aa: CGFloat { get { CGFloat(width) } set { } }
    var bb: CGFloat { get { CGFloat(height) } set { } }
    // swiftlint:enable unused_setter_value

    func area() -> Int { return width * height }

    func asPoint() -> CGPoint { return CGPoint(x: width, y: height) }

    func asSize() -> CGSize { return CGSize(width: width, height: height) }

    func asVector() -> CGVector { return CGVector(dx: width, dy: height) }

    static func makeTuple(_ ww: CGFloat, _ hh: CGFloat) -> GridSize { GridSize(ww, hh) }

    let width: Int; let height: Int

    init(_ size: GridSize) { width = size.width; height = size.height }
    init(width: Int, height: Int) { self.width = width; self.height = height }
    init(_ ww: CGFloat, _ hh: CGFloat) { self.width = Int(ww); self.height = Int(hh) }

    static let zero = GridSize(width: 0, height: 0)

    static func + (_ lhs: GridSize, _ rhs: GridSize) -> GridSize {
        return GridSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func - (_ lhs: GridSize, _ rhs: GridSize) -> GridSize {
        return GridSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func * (_ lhs: GridSize, _ rhs: Int) -> GridSize {
        return GridSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}
