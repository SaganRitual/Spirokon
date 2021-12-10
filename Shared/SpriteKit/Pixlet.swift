// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

class PixletPen: Pixlet, Spirokonable {
    var position: CGPoint { CGPoint(x: xPosition.value, y: 0) }
    var size: CGSize { CGSize(radius: 0.01) }
}

class PixletRing: Pixlet, Spirokonable {
    var position: CGPoint {
        self.spriteType == .outerRing ? CGPoint.zero : CGPoint(x: 1 - xPosition.value, y: 0)
    }

    var rotationOffsetFromParent: Double = 0.0

    var size: CGSize { CGSize(radius: xPosition.value) }
}

class Pixlet {
    enum SpriteType { case outerRing, pen, ring }
    let spriteType: SpriteType

    var xPosition: SundellPublisher<Double>

    var spirokonChildren = [Spirokonable]()
    var spirokonParent: Spirokonable?

    var rotation: Double {
        get { sprite.zRotation }
        set { sprite.zRotation = newValue }
    }

    var skNode: SKNode { sprite }

    var rollMode = Spirokon.RollMode.normal
    var rollModeObserver: AnyCancellable!

    let sprite: SKSpriteNode

    init(_ tumblerModel: TumblerModel, _ spriteType: SpriteType, _ xPosition: SundellPublisher<Double>, color: SKColor? = nil) {
        self.spriteType = spriteType
        self.xPosition = xPosition

        switch spriteType {

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

        rollModeObserver = tumblerModel.rollMode.publisher.sink { self.rollMode = $0 }
    }
}
