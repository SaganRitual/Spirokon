// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class TumblerModel: ObservableObject, Identifiable {
    let id = UUID()

    var pen: YAPublisher<Double>
    var radius: YAPublisher<Double>
    var rollMode: YAPublisher<Int>
    var showRing: YAPublisher<Bool>
    var draw: YAPublisher<Bool>

    init() {
        pen = YAPublisher(1.0)
        radius = YAPublisher(1.0)
        rollMode = YAPublisher(TumblerSettingsView.RollMode.normal.rawValue)
        showRing = YAPublisher(true)
        draw = YAPublisher(true)
    }
}
