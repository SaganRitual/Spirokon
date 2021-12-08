// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

class PixieModel: ObservableObject {
    let pen: Pixlet
    let ring: Pixlet

    let color: SKColor

    init(_ tumblerIx: Int) {

        self.color = YAColor(Color.pixieBorder).rotateHue(byAngle: Double.random(in: 0..<1))

        pen = Pixlet(.pen)
        pen.size = CGSize(radius: 0.01)
        pen.sprite.isHidden = tumblerIx == 0

        ring = Pixlet(tumblerIx == 0 ? .outerRing : .ring, color: color)
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
