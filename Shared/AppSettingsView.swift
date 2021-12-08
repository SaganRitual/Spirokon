// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "speedometer")
                    .font(.largeTitle)

                Slider(
                    value: appModel.cycleSpeed.binding,
                    in: AppModel.cycleSpeedRange,
                    label: { Text("Speed") }
                )
            }

            HStack {
                Image(systemName: "circle.dotted")
                    .font(.largeTitle)

                Slider(
                    value: appModel.dotDensity.binding,
                    in: AppModel.dotDensityRange,
                    label: { Text("Density") }
                )
            }

            HStack {
                Image(systemName: "paintbrush")
                    .font(.largeTitle)

                Slider(
                    value: appModel.colorSpeed.binding,
                    in: AppModel.colorSpeedRange,
                    label: { Text("Color speed") }
                )
            }

            HStack {
                Image(systemName: "timer")
                    .font(.largeTitle)

                Slider(
                    value: appModel.trailDecay.binding,
                    in: AppModel.trailDecayRange,
                    label: { Text("Trail decay") }
                )
            }
        }
    }
}

struct AppUIView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsView()
//            .previewInterfaceOrientation(.landscapeLeft)
            .preferredColorScheme(.dark)
    }
}
