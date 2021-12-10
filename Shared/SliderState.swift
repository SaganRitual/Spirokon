// We are a way for the cosmos to know itself. -- C. Sagan

import GameplayKit
import SwiftUI

// 🙏 https://stackoverflow.com/users/1842511/creak
// https://stackoverflow.com/a/25730573/1610473
enum Easer {
    static func InOutQuadBlend(deltaTime: Double) -> Double {
        var t = deltaTime

        if t <= 0.5 { return 2.0 * t * t }

        t -= 0.5

        return 2.0 * t * (1.0 - t) + 0.5
    }

    static func ParametricBlend(deltaTime t: Double) -> Double {
        let sqt = t * t
        return sqt / (2.0 * (sqt - t) + 1.0)
    }
}

class SliderStateBase: GKState {
    var trackingPosition: Double {
        get { sm.trackingPosition.value } set { sm.trackingPosition.value = newValue }
    }

    var thumbXPosition: Double { sm.sliderThumbPosition.value }

    var step: Double {
        get { sm.step } set { sm.step = newValue }
    }

    var sm: SliderStateMachine { (super.stateMachine as? SliderStateMachine)! }

    func thumbInput(_ startStop: Bool, at xPosition: Double) { fatalError("Should not be possible") }
}

class SliderStateAnimating: SliderStateBase {
    override func thumbInput(_ startStop: Bool, at thumbXPosition: Double) {
        precondition(startStop == true, "Shouldn't be possible")
//        print("thumb input while animaing")
//        self.thumbXPosition = thumbXPosition
        sm.enter(SliderStateDragging.self)
    }

    override func didEnter(from previousState: GKState?) {
        step = thumbXPosition - trackingPosition
//        print("moving from \(trackingPosition) to \(thumbXPosition) step \(step)")
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SliderStateDragging.Type || stateClass is SliderStateQuiet.Type
    }

    override func update(deltaTime seconds: TimeInterval) {
        let sign = step / abs(step)
        assert(sign.isFinite)

        let newCurrent = trackingPosition + sign * Easer.ParametricBlend(deltaTime: seconds * 2)
//        print("nc \(newCurrent)")
        let direction_ = step / abs(step)
        let direction = direction_.isFinite ? direction_ : 0

        defer {
//            print("current \(trackingPosition) + \(step) * \(seconds) = \(newCurrent) direction \(direction)")
        }

        if (direction * newCurrent) >= (direction * thumbXPosition) {
            trackingPosition = thumbXPosition
//            print("Finished")
            sm.enter(SliderStateQuiet.self)
            return
        }

        trackingPosition = newCurrent
    }
}

class SliderStateDragging: SliderStateBase {
    override func thumbInput(_ startStop: Bool, at thumbXPosition: Double) {
        precondition(startStop == false, "Shouldn't be possible")
//        self.thumbXPosition = thumbXPosition

//        print("SliderStateDragging: start dragging from current \(trackingPosition) to target \(self.thumbXPosition)")

        sm.enter(SliderStateAnimating.self)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SliderStateAnimating.Type
    }
}

class SliderStateQuiet: SliderStateBase {
    override func thumbInput(_ startStop: Bool, at thumbXPosition: Double) {
        precondition(startStop == true, "Shouldn't be possible")
//        print("SliderStateQuiet: visible thumb only, starting position \(thumbXPosition)")
//        self.thumbXPosition = thumbXPosition
        sm.enter(SliderStateDragging.self)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SliderStateDragging.Type
    }
}

class SliderStateMachine: GKStateMachine, ObservableObject {
    override var currentState: SliderStateBase! { super.currentState as? SliderStateBase }

    let iconName: String
    let label: String
    var trackingPosition: SundellPublisher<Double>
    var sliderThumbPosition: SundellPublisher<Double>

    var step = 0.0

    init(iconName: String, label: String, trackingPosition: SundellPublisher<Double>) {
        self.iconName = iconName
        self.label = label
        self.trackingPosition = trackingPosition
        self.sliderThumbPosition = .init(trackingPosition.value)

//        print("Slider sm init", trackingPosition.value, sliderThumbPosition.value)

        super.init(states: [
            SliderStateAnimating(),
            SliderStateDragging(),
            SliderStateQuiet()
        ])

        enter(SliderStateQuiet.self)
    }

    func tapStepper(sliderState: SliderStateMachine, direction: Double) {
        let newValue: Double

        if sliderState.trackingPosition.value <= 0 && direction == -1.0 {
            // Moving left, if we're already at zero, or less due to
            // floating-point stuff, start over at 1
            newValue = 1.0
        } else if sliderState.trackingPosition.value >= 1 && direction == 1.0 {
            // Moving right, if we're already at 1.0, or greater due to
            // floating-point stuff, start over at 0
            newValue = 0.0
        } else {
            // If we're already on a 1/8 mark, move to the next one in the direction we're
            // moving. If we're not already on one, move to the nearest one.
            let t = sliderState.trackingPosition.value.truncatingRemainder(dividingBy: 0.125)
            newValue = sliderState.trackingPosition.value + (t == 0 ? 0.125 : t) * direction
        }

        print("tapStepper \(newValue)")
    }

    func thumbInput(_ startStop: Bool, at thumbXPosition: Double) {
        currentState.thumbInput(startStop, at: thumbXPosition)
    }
}
