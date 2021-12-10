// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class AppModel: ObservableObject {
    @Published var tumblers: [TumblerModel]

    static let cTumblers = 5

    init() {
        tumblers = (0..<Self.cTumblers).map {
            let tumblerType: TumblerModel.TumblerType = $0 == 0 ? .outerRing : .innerRing
            let newTumbler = TumblerModel(tumblerType)

            newTumbler.rollMode.value = .normal

            if tumblerType == .outerRing {
                newTumbler.radius.value = 1.0
                newTumbler.pen.value = 0.0    // Future feature, pen in the outermost ring?
            }

            if tumblerType == .innerRing {
                newTumbler.radius.value = 0.625
                newTumbler.pen.value = 0.0375
            }

            return newTumbler
        }
    }
}
