// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

protocol Spirokonable: AnyObject {
    var position: CGPoint { get }
    var rollMode: Spirokon.RollMode { get }
    var rotation: Double { get set }
    var rotationOffsetFromParent: Double { get set }
    var size: CGSize { get }
    var spirokonChildren: [Spirokonable] { get set }
    var spirokonParent: Spirokonable? { get set }
    var skNode: SKNode { get }
    var xPosition: SundellPublisher<Double> { get set }
}

extension Spirokonable {
    var rollMode: Spirokon.RollMode { .normal }

    // swiftlint:disable unused_setter_value
    var rotationOffsetFromParent: Double { get { .zero } set { } }
    // swiftlint:enable unused_setter_value
}

class Spirokon {
    enum RollMode: Hashable { case compensate, doesNotRoll, fullStop, normal }

    private var all = [Spirokonable]()
    private let ancestorOfAll: Spirokonable
    private let appModel: AppModel
    private let appState: AppState

    var scene: NarniaScene { (ancestorOfAll as? NarniaScene)! }

    init(appModel: AppModel, appState: AppState, ancestorOfAll: Spirokonable) {
        self.appModel = appModel
        self.appState = appState
        self.ancestorOfAll = ancestorOfAll
    }

    func addChild(_ child: Spirokonable, to parent: Spirokonable) {
        precondition(child.spirokonParent == nil, "Child already has a parent")
        parent.spirokonChildren.append(child)
        child.spirokonParent = parent
    }

    func dropDots(currentTime: Double, deltaTime: Double) {
        for tumblerIx in 0..<appModel.tumblers.count {
            guard appState.tumblerStates[tumblerIx].draw else { continue }
            let pixie = scene.pixies[tumblerIx]

            scene.dotter.dropDot(at: pixie.pen.sprite.position, deltaTime: deltaTime)
        }
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

    func rollPixie(_ pixie: Spirokonable, rotateBy radians: Double) {
        // As of 2021.12.08, we allow the UI to set the size of a pixie to zero, which
        // makes us want to rotate it infinitely in response to any parental rotation. Don't
        // do that, but don't consider it an error. Just skip the infinite rotation and move on
        // to the next pixie.
        if radians.isInfinite { return }

        let parent = pixie.spirokonParent!

        switch pixie.rollMode {
        case .normal:
            pixie.rotation -= radians
            pixie.rotationOffsetFromParent = pixie.rotation - parent.rotation

        case .fullStop:
            pixie.rotation = parent.rotation + pixie.rotationOffsetFromParent

        case .compensate:
            pixie.rotationOffsetFromParent = pixie.rotation - parent.rotation

        case .doesNotRoll: break
        }

//        print(pixie.rollMode == .doesNotRoll ? " " : "*", terminator: "")
//        print("Roll by \(radians.asString(decimals: 4, fixedWidth: 10))", terminator: "")

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
