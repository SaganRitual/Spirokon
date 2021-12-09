// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class Dotter {
    let appState: AppState
    var currentColor = YAColor.css("#FF0000")
    var dotSize: CGSize
    let nscene: NarniaScene

    init(
        _ appState: AppState, _ nscene: NarniaScene, dotSize: CGSize
    ) {
        self.appState = appState
        self.dotSize = dotSize
        self.nscene = nscene
    }

    func color(_ color: YAColor, _ alpha: Double = 1.0) -> SKColor {
        color.withAlphaComponent(alpha)
    }

    func dropDot(at position: CGPoint, deltaTime: TimeInterval) {
        let colorRotation = deltaTime * appState.colorSpeed
        currentColor = currentColor.rotateHue(byAngle: colorRotation)

        let dot = SpritePool.dotsPool.makeSprite()
        dot.position = position
        dot.size = dotSize
        dot.color = currentColor
        dot.alpha = 1
        nscene.addChild(dot)

        let fade = SKAction.fadeOut(withDuration: appState.trailDecay)
        dot.run(fade) { dot.removeFromParent() }
    }
}
