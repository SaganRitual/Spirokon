// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class TumblerModel: ObservableObject, Identifiable {
    enum TumblerType { case outerRing, innerRing }

    let tumblerType: TumblerType

    init(_ tumblerType: TumblerType) { self.tumblerType = tumblerType }

    var pen = SundellPublisher(1.0)
    var radius = SundellPublisher(1.0)
    var rollMode = SundellPublisher(Spirokon.RollMode.normal)
}
