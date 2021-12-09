// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class TumblerModel: ObservableObject, Identifiable {
    enum TumblerType { case outerRing, innerRing }

    let tumblerType: TumblerType

    init(_ tumblerType: TumblerType) { self.tumblerType = tumblerType }

    @Published var pen = 1.0
    @Published var radius = 1.0
    @Published var rollMode = Spirokon.RollMode.normal
}
