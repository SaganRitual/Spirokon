// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct TumblerSettingsView: View {
    @ObservedObject var tumblerDraw: YAPublisher<Bool>
    @ObservedObject var tumblerPen: YAPublisher<Double>
    @ObservedObject var tumblerRadius: YAPublisher<Double>
    @ObservedObject var tumblerRollMode: YAPublisher<Spirokon.RollMode>
    @ObservedObject var tumblerShow: YAPublisher<Bool>

    // These are necessary for the view to know how to display the buttons
    @State private var drawDots = true
    @State private var pen = 0.0
    @State private var radius = 0.0
    @State private var rollMode = Spirokon.RollMode.normal
    @State private var showRing = true

    let appModel: AppModel
    let tumblerIx: Int

    init(tumblerIx: Int, appModel: AppModel) {
        self.appModel = appModel
        self.tumblerIx = tumblerIx

        _tumblerDraw = ObservedObject(wrappedValue: appModel.tumblers[tumblerIx].draw)
        _tumblerPen = ObservedObject(wrappedValue: appModel.tumblers[tumblerIx].pen)
        _tumblerRadius = ObservedObject(wrappedValue: appModel.tumblers[tumblerIx].radius)
        _tumblerRollMode = ObservedObject(wrappedValue: appModel.tumblers[tumblerIx].rollMode)
        _tumblerShow = ObservedObject(wrappedValue: appModel.tumblers[tumblerIx].showRing)
    }

    var modes: [Spirokon.RollMode] {
        tumblerIx == 0 ? [.fullStop, .normal] : [.fullStop, .compensate, .normal]
    }

    var cToggles: Int { tumblerIx == 0 ? 1 : 2 }

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

    func makeToggle(_ ix: Int) -> some View {
        let toggle = ix > 0 ?

            Toggle(
                isOn: $drawDots,
                label: {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                }
            )
            .onAppear { drawDots = tumblerDraw.value }
            .onChange(of: drawDots, perform: { tumblerDraw.value = $0 })
        :
            Toggle(
                isOn: $showRing,
                label: {
                    Image(systemName: "eye.circle.fill")
                }
            )
            .onAppear { showRing = tumblerShow.value }
            .onChange(of: showRing, perform: { tumblerShow.value = $0 })

        return toggle
            .toggleStyle(.button)
            .controlSize(SwiftUI.ControlSize.small)
    }

    var rollModePicker: some View {
        Picker("", selection: tumblerRollMode.binding) {
            ForEach(0..<modes.count) {
                makePickerSegment(for: modes[$0])
            }
        }
        .pickerStyle(.segmented)
    }

    var radiusSlider: some View {
        HStack {
            Image(systemName: "plusminus.circle")
                .font(.largeTitle)
                .onTapGesture {
                    // Poor man's slider snap
                    var r = tumblerRadius.value
                    r -= r.truncatingRemainder(dividingBy: 0.125)

                    r -= 0.125
                    if r <= 0 {
                        r = 1
                    }

                    appModel.tumblers[tumblerIx].radiusSliderState.userInput(true, at: radius)
                    appModel.tumblers[tumblerIx].radiusSliderState.userInput(false, at: r)
                    tumblerRadius.value = r
                    radius = r
                }

            Slider(
                value: Binding(get: { radius }, set: { radius = $0; tumblerRadius.value = $0 }),
                in: 0.0...1.0,
                label: { Text("Radius") },
                onEditingChanged: { appModel.tumblers[tumblerIx].radiusSliderState.userInput($0, at: radius) }
            ).onAppear { radius = appModel.tumblers[tumblerIx].radiusSliderState.trackingPosition }
        }
    }

    var penSlider: some View {
        HStack {
            Image(systemName: "pencil")
                .font(.largeTitle)
                .onTapGesture {
                    // Poor man's slider snap
                    var r = tumblerPen.value
                    r -= r.truncatingRemainder(dividingBy: 0.125)

                    r -= 0.125
                    if r <= 0 {
                        r = 1
                    }

                    appModel.tumblers[tumblerIx].penSliderState.userInput(true, at: pen)
                    appModel.tumblers[tumblerIx].penSliderState.userInput(false, at: r)
                    tumblerPen.value = r
                    pen = r
                }

            Slider(
                value: Binding(get: { pen }, set: { pen = $0; tumblerPen.value = $0 }),
                in: 0.0...1.0,
                label: { Text("Pen") },
                onEditingChanged: { appModel.tumblers[tumblerIx].penSliderState.userInput($0, at: pen) }
            ).onAppear { pen = appModel.tumblers[tumblerIx].penSliderState.trackingPosition }
        }
    }

    var body: some View {
        VStack {
            HStack {
                rollModePicker
                ForEach(0..<cToggles) { makeToggle($0) }
            }.padding(.bottom)

            radiusSlider

            if tumblerIx != 0 { penSlider }
        }
        .frame(minWidth: 200)
    }
}
