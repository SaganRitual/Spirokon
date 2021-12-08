// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class Dotter {
    let nscene: NarniaScene
    var dotSize: CGSize
    var currentColor = YAColor.css("#FF0000")

    init(_ nscene: NarniaScene, dotSize: CGSize) {
        self.nscene = nscene
        self.dotSize = dotSize
    }

    func color(_ color: YAColor, _ alpha: Double = 1.0) -> SKColor {
        color.withAlphaComponent(alpha)
    }

    func dropDot(at position: CGPoint, deltaTime: TimeInterval) {
        let colorRotation = deltaTime * nscene.appModel.colorSpeed.value
        currentColor = currentColor.rotateHue(byAngle: colorRotation)

        let dot = SpritePool.dotsPool.makeSprite()
        dot.position = position
        dot.size = dotSize
        dot.color = currentColor
        dot.alpha = 1
        nscene.addChild(dot)

        let fade = SKAction.fadeOut(withDuration: nscene.appModel.trailDecay.value)
        dot.run(fade) { dot.removeFromParent() }
    }
}
