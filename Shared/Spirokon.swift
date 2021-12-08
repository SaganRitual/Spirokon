// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

protocol Spirokonable: AnyObject {
    var position: CGPoint { get set }
    var rollMode: Spirokon.RollMode { get }
    var rotation: Double { get set }
    var size: CGSize { get set }
    var spirokonChildren: [Spirokonable] { get set }
    var spirokonParent: Spirokonable? { get set }
    var skNode: SKNode { get }
}

extension Spirokonable {
    var rollMode: Spirokon.RollMode { .normal }
}

class Spirokon {
    enum RollMode { case compensate, doesNotRoll, fullStop, normal }

    private let ancestorOfAll: Spirokonable
    private var all = [Spirokonable]()
    private let appModel: AppModel

    var scene: NarniaScene { (ancestorOfAll as? NarniaScene)! }

    init(appModel: AppModel, ancestorOfAll: Spirokonable) {
        self.appModel = appModel
        self.ancestorOfAll = ancestorOfAll
    }

    func addChild(_ child: Spirokonable, to parent: Spirokonable) {
        precondition(child.spirokonParent == nil, "Child already has a parent")
        parent.spirokonChildren.append(child)
        child.spirokonParent = parent
    }

    func dropDots(currentTime: Double, deltaTime: Double) {
        for tumblerIx in 0..<appModel.tumblers.count {
            guard appModel.tumblers[tumblerIx].draw.value == true else { continue }
            let pixie = scene.pixies[tumblerIx]

            scene.dotter.dropDot(at: pixie.pen.sprite.position, deltaTime: deltaTime)
        }
    }

    func rollPixie(_ pixie: Spirokonable, rotateBy radians: Double) {
        precondition(radians.isFinite)

        pixie.rotation -= radians

//        print(pixie.rollMode == .doesNotRoll ? " " : "*", terminator: "")
//        print("Roll by \(radians.asString(decimals: 4, fixedWidth: 10))", terminator: "")

        let parent = pixie.spirokonParent!
        let parentRotator = CGAffineTransform(rotationAngle: parent.rotation)
        let parentFullScaleCenter = parent.position << transformPosition(for: parent)

        let sprite = (pixie as? Pixlet)!.sprite
        sprite.position = pixie.position << (parentRotator * transformPosition(for: pixie))
        sprite.size = pixie.size << transformSize(for: pixie)

        // Children must be translated after parent rotation; there's got to be a
        // more transform-y way of doing this, but I haven't figured it out
        sprite.position += parent.skNode.position - parentFullScaleCenter

//        print(": pixie \(pixie.position.compact()) -> \(sprite.position.compact()) size \(pixie.size.compact()) -> \(sprite.size.compact())")
    }

    func rollEverything(rotateBy radians: Double, startAt: Spirokonable? = nil) {
        let pixie = startAt ?? ancestorOfAll

        if pixie !== ancestorOfAll {
            rollPixie(pixie, rotateBy: radians)
        }

        for child in pixie.spirokonChildren {
            rollEverything(rotateBy: -radians / child.size.radius, startAt: child)
        }
    }

    func transformPosition(for child_: Spirokonable) -> CGAffineTransform {
        var child: Spirokonable! = child_
        var transform = CGAffineTransform.identity

        while let parent = child.spirokonParent {
            transform *= parent.size.asTransform()
            transform *= parent.position.asTransform()
            child = child.spirokonParent
        }

        return transform
    }

    func transformRotation(for child_: Spirokonable) -> Double {
        var child: Spirokonable! = child_
        var rotationScale = 1.0 / child.size.radius

        while let parent = child.spirokonParent, parent !== ancestorOfAll {
            let parentScale = CGSize(radius: 1) << transformSize(for: parent)
            let childScale = CGSize(radius: 1) << transformSize(for: child)

            rotationScale *= parentScale.radius / childScale.radius

            child = child.spirokonParent
        }

        return rotationScale
    }

    func transformSize(for child_: Spirokonable) -> CGAffineTransform {
        var child: Spirokonable! = child_
        var transform = CGAffineTransform.identity

        while let parent = child.spirokonParent {
            transform *= parent.size.asTransform()
            child = child.spirokonParent
        }

        return transform
    }
}
