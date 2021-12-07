// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class Spirokon {
    let nscene: NarniaScene

    var previousPositions = [CGPoint]()
    var previousZRotations = [Double]()

    var appModel: AppModel { nscene.appModel }
    var dotter: Dotter { nscene.dotter }
    var pixies: [PixieModel] { nscene.pixies }
    var tumblers: [TumblerModel] { nscene.appModel.tumblers }

    var accumulatedDelta = 0.0

    init(nscene: NarniaScene) {
        self.nscene = nscene
    }

    func dropDots(currentTime: Double, deltaTime: Double) {
        accumulatedDelta += deltaTime

        let clickDuration = 1.0 / appModel.dotDensity.value
        let clicks = Int(accumulatedDelta / clickDuration)
        if clicks == 0 { return }

//        let newPositions = nscene.pixies.map { $0.ringSprite.position }
//        let newZRotations = nscene.pixies.map { $0.ringSprite.zRotation }

        for tumblerIx in 0..<tumblers.count {
            let pixie = pixies[tumblerIx]

            pixie.ringSprite.position = previousPositions[tumblerIx]
            pixie.ringSprite.zRotation = previousZRotations[tumblerIx]
        }

        for click in 0..<clicks {
            let deltaClick = Double(click + 1) * clickDuration

            rotate(deltaTime: deltaClick) { [self] tumblerIx in
                let tumbler = tumblers[tumblerIx]
                let pixie = pixies[tumblerIx]
                guard tumbler.draw.value == true else {
                    pixie.penSprite.color = .clear
                    return
                }

                pixie.penSprite.color = .red

                dotter.dropDot(
                    on: pixie.ringSprite, at: pixie.penSprite.position,
                    currentTime: currentTime + deltaClick
                )
            }
        }

        accumulatedDelta -= Double(clicks) * clickDuration
        precondition(accumulatedDelta >= 0)

//        for tumblerIx in 0..<tumblers.count {
//            let pixie = pixies[tumblerIx]
//
//            pixie.ringSprite.position = newPositions[tumblerIx]
//            pixie.ringSprite.zRotation = newZRotations[tumblerIx]
//        }
    }

    func rotate(deltaTime: Double, dropDot: ((Int) -> Void)? = nil) {
        var compensation = 0.0
        var direction = 1.0
        var radialScale = 1.0

        if dropDot == nil {
            self.previousPositions = nscene.pixies.map { $0.ringSprite.position }
            self.previousZRotations = nscene.pixies.map { $0.ringSprite.zRotation }
        }

        for tumblerIx in 0..<tumblers.count {
            let pixie = pixies[tumblerIx]
            let model = tumblers[tumblerIx]

            defer {
                dropDot?(tumblerIx)
                direction *= -1 // Each child is always the opposite direction
            }

            // Full stop
            if model.rollMode.value == TumblerSettingsView.RollMode.stop.rawValue {
                compensation = 0    // My child's compensation will be zero
                continue
            }

            let rollThisDelta = Double.tau * deltaTime * appModel.cycleSpeed.value

            pixie.ringSprite.zRotation += direction * compensation

            // Only compensate for parent's roll
            if model.rollMode.value == TumblerSettingsView.RollMode.compensateForParent.rawValue {
                compensation = 0    // My child's compensation will be zero
                continue
            }

            radialScale /= model.radius.value

            let myRotation = rollThisDelta * radialScale

            pixie.ringSprite.zRotation += direction * myRotation

            compensation = myRotation
        }
    }
}
