// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class Dotter {
    let mainControlsState: MainControlsState
    var currentColor = YAColor.css("#FF0000")
    var dotSize: CGSize
    let nscene: NarniaScene

    init(
        _ mainControlsState: MainControlsState, _ nscene: NarniaScene, dotSize: CGSize
    ) {
        self.dotSize = dotSize
        self.nscene = nscene
        self.mainControlsState = mainControlsState
    }

    func color(_ color: YAColor, _ alpha: Double = 1.0) -> SKColor {
        color.withAlphaComponent(alpha)
    }

    func dropDot(at position: CGPoint, deltaTime: TimeInterval) {
        let colorRotation = deltaTime * mainControlsState.colorSpeed
        currentColor = currentColor.rotateHue(byAngle: colorRotation)

        let dot = SpritePool.dotsPool.makeSprite()
        dot.position = position
        dot.size = dotSize
        dot.color = currentColor
        dot.alpha = 1
        nscene.addChild(dot)

        let fade = SKAction.fadeOut(withDuration: mainControlsState.trailDecay)
        dot.run(fade) { dot.removeFromParent() }
    }
}
