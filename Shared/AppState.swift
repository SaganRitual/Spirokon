// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class AppState: ObservableObject {
    var tumblerStates = [TumblerState]()

//    enum Component { case app, narnia, pixieViews, settingsView, spirokon }
//
//    @Published var readyComponents = Set<Component>()
//
//    func markComponentReady(_ component: Component) {
//        readyComponents.insert(component)
//        if readyComponents.contains(.narnia) &&
//            readyComponents.contains(.pixieViews) &&
//            readyComponents.contains(.settingsView) &&
//            readyComponents.contains(.spirokon)
//        {
//            readyComponents.insert(.app)
//        }
//
//        readyComponents.insert(.app)
//    }
//
//    var appIsReady: Bool { true }// readyComponents.contains(.app) }

    init(appModel: AppModel) {
        let outerRingModel = appModel.tumblers[0]
        let outerRing = TumblerState(outerRingModel)

        outerRing.draw = false
        outerRing.showRing = true

        tumblerStates.append(outerRing)

        let innerRings: [TumblerState] = (1..<AppModel.cTumblers).map {
            let tumblerModel = appModel.tumblers[$0]
            let tumblerState = TumblerState(tumblerModel)

            tumblerState.showRing = $0 == 1
            tumblerState.draw = $0 == 1

            return tumblerState
        }

        tumblerStates.append(contentsOf: innerRings)
    }
}
