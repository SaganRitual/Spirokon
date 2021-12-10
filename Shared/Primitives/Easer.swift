// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

// 🙏 https://stackoverflow.com/users/1842511/creak
// https://stackoverflow.com/a/25730573/1610473
struct Easer {
    static func InOutQuadBlend(deltaTime: Double) -> Double {
        var t = deltaTime

        if t <= 0.5 { return 2.0 * t * t }

        t -= 0.5

        return 2.0 * t * (1.0 - t) + 0.5
    }

    let intensity: Double   // The more intense, the steeper the middle and the flatter the ends
    let scale: Double       // Scale the amount of time needed to complete the ease
    var totalElapsedTime = 0.0

    init(intensity: Double, scale: Double) {
        self.intensity = intensity
        self.scale = scale
    }

    // 🙏 https://math.stackexchange.com/users/13854/robjohn
    // https://math.stackexchange.com/a/121755/182584
    mutating func robjohn(deltaTime: Double) -> Double {
        totalElapsedTime += deltaTime / scale

        let scaled = totalElapsedTime
        let sRaised = pow(scaled, intensity)
        let diffed = 1.0 - scaled
        let dRaised = pow(diffed, intensity)

        return sRaised / (sRaised + dRaised)
    }

    static func ParametricBlend(deltaTime t: Double) -> Double {
        let sqt = t * t
        return sqt / (2.0 * (sqt - t) + 1.0)
    }
}
