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
    var targetPosition: Double {
        get { sm.targetPosition } set { sm.targetPosition = newValue }
    }

    var trackingPosition: Double {
        get { sm.trackingPosition } set { sm.trackingPosition = newValue }
    }

    var sliderPosition: Double {
        get { sm.sliderPosition } set { sm.sliderPosition = newValue }

    }

    var step: Double {
        get { sm.step } set { sm.step = newValue }
    }

    var sm: SliderStateMachine { (super.stateMachine as? SliderStateMachine)! }

    func userInput(_ startStop: Bool, at position: Double) { fatalError("Should not be possible") }
}

class SliderStateAnimating: SliderStateBase {
    override func userInput(_ startStop: Bool, at position: Double) {
        sm.enter(SliderStateDragging.self)
    }

    override func didEnter(from previousState: GKState?) {
        step = targetPosition - trackingPosition
//        print("moving from \(trackingPosition) to \(targetPosition) step \(step)")

//        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) {
//            self.sm.update(deltaTime: 0.1)
//        }
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SliderStateDragging.Type || stateClass is SliderStateQuiet.Type
    }

    override func update(deltaTime seconds: TimeInterval) {
        let sign = step / abs(step)
        assert(sign.isFinite)

        let newCurrent = trackingPosition + sign * Easer.ParametricBlend(deltaTime: seconds)
//        print("nc \(newCurrent)")
        let direction_ = step / abs(step)
        let direction = direction_.isFinite ? direction_ : 0

        defer {
//            print("current \(trackingPosition) + \(step) * \(seconds) = \(newCurrent) direction \(direction)")
        }

        if (direction * newCurrent) >= (direction * targetPosition) {
            trackingPosition = targetPosition
            sm.enter(SliderStateQuiet.self)
            return
        }

        trackingPosition = newCurrent

//        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) {
//            self.sm.update(deltaTime: 0.1)
//        }
    }
}

class SliderStateDragging: SliderStateBase {
    override func userInput(_ startStop: Bool, at position: Double) {
        precondition(startStop == false, "Shouldn't be possible")

        targetPosition = position
//        print("start dragging from current \(trackingPosition) to target \(targetPosition)")

        sm.enter(SliderStateAnimating.self)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SliderStateAnimating.Type
    }
}

class SliderStateQuiet: SliderStateBase {
    override func userInput(_ startStop: Bool, at position: Double) {
        precondition(startStop == true, "Shouldn't be possible")

        sliderPosition = position
        targetPosition = position
        trackingPosition = position
        sm.enter(SliderStateDragging.self)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SliderStateDragging.Type
    }
}

class SliderStateMachine: GKStateMachine, ObservableObject {
    override var currentState: SliderStateBase! { super.currentState as? SliderStateBase }

    @objc dynamic var targetPosition = 0.0
    @objc dynamic var trackingPosition = 0.0
    @objc dynamic var sliderPosition = 0.0
    @objc dynamic var step = 0.0

    init() {
        super.init(states: [
            SliderStateAnimating(),
            SliderStateDragging(),
            SliderStateQuiet()
        ])

        enter(SliderStateQuiet.self)
    }

    func userInput(_ startStop: Bool, at position: Double) { currentState.userInput(startStop, at: position) }
}
