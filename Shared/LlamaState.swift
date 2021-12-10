// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class LlamaState: ObservableObject {
    @Published var averageLlama = 0.0
    @Published var llamasLlocated = 0.0

    var llamaAverager = Cbuffer<Double>(cElements: 100, mode: .putOnlyRing)

    func llocateLlama(_ deltaTime: Double) {
        llamasLlocated += 1 + Double.random(in: 0..<1)
        llamaAverager.put(deltaTime)

        averageLlama = llamaAverager.elements.reduce(0.0, { $0 + ($1 ?? 0.0) }) / Double(llamaAverager.count)
        assert(averageLlama.isFinite)
    }
}
