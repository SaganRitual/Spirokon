// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var appState: AppState

    @State private var colorSpeed = 0.0
    @State private var cycleSpeed = 0.0
    @State private var dotDensity = 0.0
    @State private var trailDecay = 0.0

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "speedometer")
                    .font(.largeTitle)

                Slider(
                    value: Binding(
                        get: { cycleSpeed },
                        set: { cycleSpeed = $0; appState.cycleSpeed = $0 }
                    ),
                    in: AppState.cycleSpeedRange,
                    label: { Text("Speed") }
                ).onAppear { cycleSpeed = appState.cycleSpeed }
            }

            HStack {
                Image(systemName: "circle.dotted")
                    .font(.largeTitle)

                Slider(
                    value: Binding(
                        get: { dotDensity },
                        set: { dotDensity = $0; appState.dotDensity = $0 }
                    ),
                    in: AppState.dotDensityRange,
                    label: { Text("Density") }
                ).onAppear { dotDensity = appState.dotDensity }
            }

            HStack {
                Image(systemName: "paintbrush")
                    .font(.largeTitle)

                Slider(
                    value: Binding(
                        get: { colorSpeed },
                        set: { colorSpeed = $0; appState.colorSpeed = $0 }
                    ),
                    in: AppState.colorSpeedRange,
                    label: { Text("Color speed") }
                ).onAppear { colorSpeed = appState.colorSpeed }
            }

            HStack {
                Image(systemName: "timer")
                    .font(.largeTitle)

                Slider(
                    value: Binding(
                        get: { trailDecay },
                        set: { trailDecay = $0; appState.trailDecay = $0 }
                    ),
                    in: AppState.trailDecayRange,
                    label: { Text("Trail decay") }
                ).onAppear { trailDecay = appState.trailDecay }
            }
        }
    }
}

struct AppUIView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsView()
            .preferredColorScheme(.dark)
    }
}
