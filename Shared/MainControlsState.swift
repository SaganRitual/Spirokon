// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class MainControlsState: ObservableObject {
    @Published var colorSpeed = 0.15
    @Published var cycleSpeed = 0.15
    @Published var dotDensity = 4.0
    @Published var trailDecay = 10.0

    static let colorSpeedRange = 0.0...2.0
    static let cycleSpeedRange = 0.0...1.0
    static let dotDensityRange = 0.0...30.0
    static let trailDecayRange = 0.0...60.0
}
