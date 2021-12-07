// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

class PixieModel: ObservableObject {
    let armSprite: SKSpriteNode
    let penSprite: SKSpriteNode
    let ringSprite: SKSpriteNode

    let color: SKColor

    init(_ tumblerIx: Int, _ duration: TimeInterval = 2.0) {
        self.ringSprite = SpritePool.rings1024_4.makeSprite()
        self.armSprite = SpritePool.linesPool.makeSprite()
        self.penSprite = SpritePool.dotsPool.makeSprite()

        self.color = YAColor(Color.pixieBorder).scale(.allCases.randomElement()!, by: Double.random(in: 0.25...0.75))
        ringSprite.color = self.color
        ringSprite.anchorPoint = .anchorAtCenter

        if tumblerIx != 0 {
            armSprite.size = CGSize(width: ringSprite.size.radius, height: 3)
            armSprite.color = self.color
            armSprite.anchorPoint = .anchorDueWest
            ringSprite.addChild(armSprite)

            penSprite.size = CGSize(radius: 6)
            penSprite.color = .red
            penSprite.anchorPoint = .anchorAtCenter
            armSprite.addChild(penSprite)
        }
    }

    func beAdopted(by scene: NarniaScene) {
        scene.addChild(self.ringSprite)
    }

    func beAdopted(by pixie: PixieModel) {
        pixie.ringSprite.addChild(self.ringSprite)
    }

    func showPixie(_ show: Bool) {
        armSprite.color = show ? color : .clear
        ringSprite.color = show ? color : .clear
    }
}
