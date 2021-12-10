// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class AppState: ObservableObject {
    @Published var mainControlsState = MainControlsState()
    @Published var tumblerStates = [TumblerState]()

    enum Component { case app, narnia, pixieViews, settingsView, spirokon }

    @Published var readyComponents = Set<Component>()

    let llamaState = LlamaState()

    func markComponentReady(_ component: Component) {
        readyComponents.insert(component)
        if readyComponents.contains(.narnia) &&
            readyComponents.contains(.pixieViews) &&
            readyComponents.contains(.settingsView) &&
            readyComponents.contains(.spirokon)
        {
            readyComponents.insert(.app)
        }
    }

    var appIsReady: Bool { readyComponents.contains(.app) }

    init(appModel: AppModel) {
        let outerRing = TumblerState()
        outerRing.radiusSliderState.trackingPosition = appModel.tumblers[0].radius
        outerRing.draw = false
        outerRing.showRing = true

        tumblerStates.append(outerRing)

        let innerRings: [TumblerState] = (1..<AppModel.cTumblers).map {
            let newTumbler = TumblerState()

            if $0 != 0 {
                newTumbler.radiusSliderState.trackingPosition = appModel.tumblers[$0].radius
                newTumbler.penSliderState.trackingPosition = appModel.tumblers[$0].pen
            }

            if $0 == 1 {
                newTumbler.showRing = true
                newTumbler.draw = true
            }

            if $0 > 1  {
                newTumbler.showRing = false
                newTumbler.draw = false
            }

            return newTumbler
        }

        tumblerStates.append(contentsOf: innerRings)
    }
}
