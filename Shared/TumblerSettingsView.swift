// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct TumblerSettingsView: View {
    @EnvironmentObject var tumblerModel: TumblerModel
    @EnvironmentObject var tumblerState: TumblerState

    @State private var penSliderThumbX = 0.0
    @State private var radiusSliderThumbX = 0.0

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
        Picker("", selection: tumblerModel.rollMode.binding) {
            ForEach(0..<modes.count) { makePickerSegment(for: modes[$0]) }
        }
        .pickerStyle(.segmented)
    }

    var penSlider: some View {
        HStack {
            Image(systemName: "pencil")
                .font(.largeTitle)

            Image(systemName: "minus.circle.fill")
                .onTapGesture {
                    tumblerState.penSliderState.tapStepper(
                        sliderState: tumblerState.penSliderState, direction: -1.0
                    )
                }

            Slider(
                value: tumblerState.penSliderState.sliderThumbPosition.binding,
                in: 0.0...1.0,
                label: { Text("Pen") },
                onEditingChanged: {
                    tumblerState.penSliderState.thumbInput(
                        $0, at: tumblerState.penSliderState.sliderThumbPosition.value
                    )
                }
            )
        }
    }

    var radiusSlider: some View {
        HStack {
            Image(systemName: "circle")
                .font(.largeTitle)

            Image(systemName: "minus.circle.fill")
                .onTapGesture {
                    tumblerState.radiusSliderState.tapStepper(
                        sliderState: tumblerState.radiusSliderState, direction: -1.0
                    )
                }

            Slider(
                value: tumblerState.radiusSliderState.sliderThumbPosition.binding,
                in: 0.0...1.0,
                label: { Text("Radius") },
                onEditingChanged: {
                    tumblerState.radiusSliderState.thumbInput(
                        $0, at: tumblerState.radiusSliderState.sliderThumbPosition.value
                    )
                }
            )
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
