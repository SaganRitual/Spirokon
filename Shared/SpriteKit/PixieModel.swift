// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

class PixieModel: ObservableObject {
    let color: SKColor
    let pen: PixletPen
    let ring: PixletRing

    var showRing: AnyCancellable!

    init(_ tumblerModel: TumblerModel, _ tumblerState: TumblerState) {
        self.color = YAColor(Color.pixieBorder).rotateHue(byAngle: Double.random(in: 0..<1))

        pen = PixletPen(tumblerModel, .pen, tumblerModel.pen)

        // Never show a pen for the outer ring, at least not yet
        if tumblerModel.tumblerType == .outerRing { pen.sprite.color = .clear }

        ring = PixletRing(tumblerModel, tumblerModel.tumblerType == .outerRing ? .outerRing : .ring, tumblerModel.radius, color: color)
        showRing = tumblerState.$showRing.sink { self.showPixie($0) }
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
