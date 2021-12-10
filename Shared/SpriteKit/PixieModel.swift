// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

class PixieModel: ObservableObject {
    let pen: PixletPen
    let ring: PixletRing

    let color: SKColor

    init(_ tumblerModel: TumblerModel) {

        self.color = YAColor(Color.pixieBorder).rotateHue(byAngle: Double.random(in: 0..<1))

        pen = PixletPen(.pen, tumblerModel.pen)

        // Never show a pen for the outer ring, at least not yet
        if tumblerModel.tumblerType == .outerRing { pen.sprite.color = .clear }

        ring = PixletRing(tumblerModel.tumblerType == .outerRing ? .outerRing : .ring, tumblerModel.radius, color: color)
    }

    func addToScene(_ scene: NarniaScene) {
        scene.addChild(ring.sprite)
        scene.addChild(pen.sprite)
    }

    func showPixie(_ show: Bool) {
        ring.sprite.isHidden = !show
        pen.sprite.isHidden = !show
    }
}
