// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class Dotter {
    let nscene: NarniaScene
    var dotSize: CGSize

    init(_ nscene: NarniaScene, dotSize: CGSize) {
        self.nscene = nscene
        self.dotSize = dotSize
    }

    func color(_ color: YAColor, _ alpha: Double = 1.0) -> SKColor {
        color.withAlphaComponent(alpha)
    }

    func dropDot(
        on ringSprite: SKSpriteNode, at position: CGPoint, currentTime: TimeInterval
    ) {
        let dotsColorSpeed = nscene.appModel.colorSpeed.value
        let fractionOfCycle = currentTime.truncatingRemainder(dividingBy: dotsColorSpeed)
        let hue = fractionOfCycle / dotsColorSpeed
        let color = YAColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)

        let dot = SpritePool.dotsPool.makeSprite()
        dot.position = ringSprite.convert(position, to: nscene)
        dot.size = dotSize
        dot.color = color
        dot.alpha = 1
        nscene.addChild(dot)

        let fade = SKAction.fadeOut(withDuration: nscene.appModel.trailDecay.value)
        dot.run(fade) { dot.removeFromParent() }
    }
}
