// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class AppModel: ObservableObject {
    @Published var tumblers: [TumblerModel]

    var cycleSpeed = YAPublisher(0.15)
    var colorSpeed = YAPublisher(0.15)
    var dotDensity = YAPublisher(20.0)
    var trailDecay = YAPublisher(10.0)

    init(_ cTumblers: Int = 2) {
        tumblers = (0..<cTumblers).map {
            let t = TumblerModel()
            if $0 != 0 { t.radius.value = 0.5 }
            return t
        }
    }
}
