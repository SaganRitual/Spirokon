// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct TumblerSettingsView: View {
    @EnvironmentObject var tumblerModel: TumblerModel
    @EnvironmentObject var tumblerState: TumblerState

    var modes: [Spirokon.RollMode] {
        tumblerModel.tumblerType == .outerRing ? [.fullStop, .normal] : [.fullStop, .compensate, .normal]
    }

    enum TumblerToggleType { case drawDots, showRing }
    var toggles: [TumblerToggleType] {
        tumblerModel.tumblerType == .outerRing ? [.showRing] : [.showRing, .drawDots]
    }

    func makePickerSegment(for mode: Spirokon.RollMode) -> some View {
        let image: Image

        switch mode {
        case .fullStop:   image = Image(systemName: "xmark.circle.fill")
        case .compensate: image = Image(systemName: "gobackward")
        case .normal:     image = Image(systemName: "play.circle.fill")

        case .doesNotRoll:
            preconditionFailure("This is only for rings, not for pens; serious program bug here")
        }

        return image.tag(mode)
    }

    func makeToggle(_ type: TumblerToggleType) -> some View {
        switch type {
        case .drawDots:
            return Toggle(
                isOn: Binding(
                    get: { tumblerState.draw },
                    set: { tumblerState.draw = $0 }
                ),

                label: {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                }
            )
            .toggleStyle(.button)
            .controlSize(SwiftUI.ControlSize.small)

        case .showRing:
            return Toggle(
                isOn: Binding(
                    get: { tumblerState.showRing },
                    set: { tumblerState.showRing = $0 }
                ),
                label: {
                    Image(systemName: "eye.circle.fill")
                }
            )
            .toggleStyle(.button)
            .controlSize(SwiftUI.ControlSize.small)
        }
    }

    var rollModePicker: some View {
        Picker(
            "",
            selection: Binding(
                get: { tumblerModel.rollMode },
                set: { tumblerModel.rollMode = $0 }
            )
        ) {
            ForEach(0..<modes.count) {
                makePickerSegment(for: modes[$0])
            }
        }
        .pickerStyle(.segmented)
    }

    func tapTrack(sliderState: SliderStateMachine, direction: Double) {
        let newValue: Double

        if sliderState.trackingPosition <= 0 && direction == -1.0 {
            // Moving left, if we're already at zero, or less due to
            // floating-point stuff, start over at 1
            newValue = 1.0
        } else if sliderState.trackingPosition >= 1 && direction == 1.0 {
            // Moving right, if we're already at 1.0, or greater due to
            // floating-point stuff, start over at 0
            newValue = 0.0
        } else {
            // If we're already on a 1/8 mark, move to the next one in the direction we're
            // moving. If we're not already on one, move to the nearest one.
            let t = sliderState.trackingPosition.truncatingRemainder(dividingBy: 0.125)
            newValue = sliderState.trackingPosition + (t == 0 ? 0.125 : t) * direction
        }

        sliderState.trackInput(fromPosition: sliderState.trackingPosition, toPosition: newValue)
    }

    var radiusSlider: some View {
        HStack {
            Image(systemName: "circle")
                .font(.largeTitle)

            Image(systemName: "minus.circle.fill")
                .onTapGesture {
                    tapTrack(
                        sliderState: tumblerState.radiusSliderState,
                        direction: -1.0
                    )
                }

            Slider(
                value: Binding(
                    get: { tumblerState.radiusSliderState.trackingPosition },
                    set: { tumblerState.radiusSliderState.trackingPosition = $0 }
                ),
                in: 0.0...1.0,
                label: { Text("Radius") },
                onEditingChanged: {
                    tumblerState.radiusSliderState.thumbInput($0, at: tumblerState.radiusSliderState.trackingPosition)
                }
            )

            Image(systemName: "plus.circle.fill")
                .onTapGesture {
                    tapTrack(
                        sliderState: tumblerState.radiusSliderState,
                        direction: 1.0
                    )
                }
        }
    }

    var penSlider: some View {
        HStack {
            Image(systemName: "pencil")
                .font(.largeTitle)

            Image(systemName: "minus.circle.fill")
                .onTapGesture {
                    tapTrack(
                        sliderState: tumblerState.penSliderState,
                        direction: -1.0
                    )
                }

            Slider(
                value: Binding(
                    get: { tumblerState.penSliderState.trackingPosition },
                    set: { tumblerState.penSliderState.trackingPosition = $0 }
                ),
                in: 0.0...1.0,
                label: { Text("Pen") },
                onEditingChanged: {
                    tumblerState.penSliderState.thumbInput($0, at: tumblerState.penSliderState.trackingPosition)
                }
            )

            Image(systemName: "plus.circle.fill")
                .onTapGesture {
                    tapTrack(
                        sliderState: tumblerState.penSliderState,
                        direction: 1.0
                    )
                }
        }
    }

    var body: some View {
        VStack {
            HStack {
                rollModePicker
                ForEach(0..<toggles.count) { makeToggle(toggles[$0]) }
            }.padding(.bottom)

            radiusSlider

            if tumblerModel.tumblerType == .innerRing { penSlider }
        }
        .frame(minWidth: 200)
    }
}
