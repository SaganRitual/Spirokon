// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class AppModel: ObservableObject {
    @Published var tumblers: [TumblerModel]

    var colorSpeed = YAPublisher(0.15)
    var cycleSpeed = YAPublisher(0.15)
    var dotDensity = YAPublisher(4.0)
    var trailDecay = YAPublisher(10.0)

    static let colorSpeedRange = 0.0...2.0
    static let cycleSpeedRange = 0.0...1.0
    static let dotDensityRange = 0.0...30.0
    static let trailDecayRange = 0.0...60.0

    init(_ cTumblers: Int = 2) {
        tumblers = (0..<cTumblers).map {
            let t = TumblerModel()

            if $0 == 0 { t.radiusSliderState.trackingPosition = 1.0; t.draw.value = false; t.showRing.value = true }

            if $0 != 0 { t.radiusSliderState.trackingPosition = 0.5; t.penSliderState.trackingPosition = 0.75 }

            if $0 == 1 { t.showRing.value = true; t.draw.value = true }
            if $0 > 1  { t.showRing.value = false; t.draw.value = false }

            return t
        }
    }
}
