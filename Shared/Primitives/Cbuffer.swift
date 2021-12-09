enum CBufferMode { case fifo, putOnlyRing }

class Cbuffer<T>: RandomAccessCollection {
    func index(after i: Int) -> Int { (i + 1) % cElements }

    subscript(position: Int) -> T {
        get { return self.elements[position]! }
        set { fatalError() }
    }

    var startIndex: Int { nextPushOffset }
    var endIndex: Int { startIndex }

    typealias Index = Int

    private(set) var cElements: Int
    private(set) var elements: [T?]
    private var firstPass = true
    let mode: CBufferMode
    private var nextPopOffset: Int = 0
    private var nextPushOffset: Int = 0
    private var wrappedPop = false

    func average() -> Double {
        var subtotal: Double = 0.0

        elements.forEach {
            guard let i = $0 as? Double else { fatalError() }
            subtotal += i
        }

        return subtotal / Double(count)
    }

    var count: Int {
        if mode == .putOnlyRing            { return elements.count }
        if nextPushOffset == nextPopOffset { return wrappedPop ? cElements : 0 }
        if nextPushOffset > nextPopOffset  { return nextPushOffset - nextPopOffset }
        else                               { return nextPushOffset - nextPopOffset + cElements }
    }

    // swiftlint:disable empty_count
    var isEmpty: Bool { count == 0 }
    // swiftlint:enable empty_count

    var isFull: Bool {
        assert(mode == .putOnlyRing)
        return elements.count == cElements
    }

    init(cElements: Int, mode: CBufferMode = .fifo) {
        self.cElements = cElements
        self.mode = mode

        elements = []
        elements.reserveCapacity(cElements)
    }

    @discardableResult
    func popFront() -> T {
        assert(mode == .fifo)
        assert(nextPopOffset != nextPushOffset || wrappedPop == true, "Underflow in FIFO")

        defer {
            elements[nextPopOffset] = nil
            nextPopOffset = (nextPopOffset + 1) % cElements
            wrappedPop = false
        }

        return elements[nextPopOffset]!
    }

    func pushBack(_ element: T) {
        assert(mode == .fifo)
        assert(nextPopOffset != nextPushOffset || wrappedPop == false, "Overflow in FIFO")

        defer {
            nextPushOffset = (nextPushOffset + 1) % cElements

            // Rememeber that the push pointer has caught the pop pointer,
            // meaning that we've wrapped all the way around to it
            wrappedPop = (nextPushOffset == nextPopOffset)
            firstPass = false
        }

        put_(element)
    }

    private func put_(_ element: T) {
        if elements.count < cElements {
            elements.append(element)
            return
        }

        elements[nextPushOffset] = element
    }

    func put(_ element: T) {
        assert(mode == .putOnlyRing)
        put_(element)

        nextPushOffset = (nextPushOffset + 1) % cElements
    }
}
