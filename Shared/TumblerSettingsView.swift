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

        // Zero ring never draws
        if tumblerIx == 0 {
            drawDots = false
            tumblerDraw.value = false
        }
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
            ).onChange(of: drawDots, perform: { tumblerDraw.value = $0 })
        :
            Toggle(
                isOn: $showRing,
                label: {
                    Image(systemName: "eye.circle.fill")
                }
            ).onChange(of: showRing, perform: { tumblerShow.value = $0 })

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

                    tumblerRadius.value = r
                }

            Slider(
                value: tumblerRadius.binding,
                in: 0.0...1.0,
                label: { Text("Radius") }
            )
        }
    }

    var penSlider: some View {
        HStack {
            Image(systemName: "pencil")
                .font(.largeTitle)

            Slider(
                value: tumblerPen.binding,
                in: 0.0...1.0,
                label: { Text("Pen") }
            )
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
