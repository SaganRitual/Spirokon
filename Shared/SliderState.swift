// We are a way for the cosmos to know itself. -- C. Sagan

import GameplayKit
import SwiftUI

class SliderStateBase: GKState {
    var anchorPosition: Double {
        get { sm.anchorPosition } set { sm.anchorPosition = newValue }
    }

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
    var easer: Easer!

    override func thumbInput(_ startStop: Bool, at thumbXPosition: Double) {
        precondition(startStop == true, "Shouldn't be possible")
        self.anchorPosition = thumbXPosition
//        print("thumb input while animaing")
//        self.thumbXPosition = thumbXPosition
        sm.enter(SliderStateDragging.self)
    }

    override func didEnter(from previousState: GKState?) {
        step = thumbXPosition - anchorPosition
        easer = Easer(intensity: 2, scale: 2.0)
//        print("moving from \(trackingPosition.asString(decimals: 3)) to \(thumbXPosition.asString(decimals: 3)) step \(step.asString(decimals: 3))")
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SliderStateDragging.Type || stateClass is SliderStateQuiet.Type
    }

    override func update(deltaTime seconds: TimeInterval) {
        let sign = step / abs(step)
        assert(sign.isFinite)

        let newCurrent = anchorPosition + step * easer.robjohn(deltaTime: seconds)

//        print("nc \(newCurrent.asString(decimals: 3))")
//        let direction_ = step / abs(step)
//        let direction = direction_.isFinite ? direction_ : 0

        defer {
//            print("started at \(thumbXPosition.asString(decimals: 3)) + \(step.asString(decimals: 3)) * \(seconds.asString(decimals: 3)) = \(newCurrent.asString(decimals: 3)) direction \(direction)")
        }

        if easer.totalElapsedTime >= 1.0 {
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
        self.anchorPosition = thumbXPosition
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

    var anchorPosition = 0.0
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

        thumbInput(true, at: sliderThumbPosition.value)
        sliderThumbPosition.value = newValue
        thumbInput(false, at: newValue)
    }

    func thumbInput(_ startStop: Bool, at thumbXPosition: Double) {
        currentState.thumbInput(startStop, at: thumbXPosition)
    }
}
