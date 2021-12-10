// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var mainControlsState: MainControlsState

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "speedometer")
                    .font(.largeTitle)

                Slider(
                    value: Binding(
                        get: { mainControlsState.cycleSpeed },
                        set: { mainControlsState.cycleSpeed = $0 }
                    ),
                    in: MainControlsState.cycleSpeedRange,
                    label: { Text("Speed") }
                )
            }

            HStack {
                Image(systemName: "circle.dotted")
                    .font(.largeTitle)

                Slider(
                    value: Binding(
                        get: { mainControlsState.dotDensity },
                        set: { mainControlsState.dotDensity = $0 }
                    ),
                    in: MainControlsState.dotDensityRange,
                    label: { Text("Density") }
                )
            }

            HStack {
                Image(systemName: "paintbrush")
                    .font(.largeTitle)

                Slider(
                    value: Binding(
                        get: { mainControlsState.colorSpeed },
                        set: { mainControlsState.colorSpeed = $0 }
                    ),
                    in: MainControlsState.colorSpeedRange,
                    label: { Text("Color speed") }
                )
            }

            HStack {
                Image(systemName: "timer")
                    .font(.largeTitle)

                Slider(
                    value: Binding(
                        get: { mainControlsState.trailDecay },
                        set: { mainControlsState.trailDecay = $0 }
                    ),
                    in: MainControlsState.trailDecayRange,
                    label: { Text("Trail decay") }
                )
            }
        }
    }
}
