// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class TumblerState: ObservableObject {
    @Published var draw = true
    @Published var penSliderState = SliderStateMachine()
    @Published var radiusSliderState = SliderStateMachine()
    @Published var showRing = true
}
