// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class TumblerModel: ObservableObject, Identifiable {
    let id = UUID()

    var pen: YAPublisher<Double>
    var radius: YAPublisher<Double>
    var rollMode: YAPublisher<Spirokon.RollMode>
    var showRing: YAPublisher<Bool>
    var draw: YAPublisher<Bool>

    var radiusSliderState = SliderStateMachine()
    var penSliderState = SliderStateMachine()

    init() {
        pen = YAPublisher(1.0)
        radius = YAPublisher(1.0)
        rollMode = YAPublisher(.normal)
        showRing = YAPublisher(true)
        draw = YAPublisher(true)
    }
}
