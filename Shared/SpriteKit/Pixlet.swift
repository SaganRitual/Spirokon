// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class Pixlet: Spirokonable {
    enum SpriteType { case outerRing, pen, ring }

    var position = CGPoint.zero
    var size = CGSize.zero

    var spirokonChildren = [Spirokonable]()
    var spirokonParent: Spirokonable?

    var rotation: Double {
        get { sprite.zRotation }
        set { sprite.zRotation = newValue }
    }

    var skNode: SKNode { sprite }

    var rollMode = Spirokon.RollMode.normal

    let sprite: SKSpriteNode

    init(_ type: SpriteType, color: SKColor? = nil) {
        switch type {

        case .outerRing:
            sprite = SpritePool.rings1024_4.makeSprite()
            sprite.color = color!

        case .pen:
            rollMode = .doesNotRoll
            sprite = SpritePool.dotsPool.makeSprite()
            sprite.color = .red
            sprite.anchorPoint = .anchorAtCenter

        case .ring:
            sprite = SpritePool.spokeRings.makeSprite()
            sprite.color = color!
        }

        sprite.anchorPoint = .anchorAtCenter
    }
}
