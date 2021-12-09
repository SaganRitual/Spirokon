// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var appState: AppState

    #if os(macOS)
    let name = "Spirokon macOS"
    #elseif os(iOS)
    let name = "Spirokon iOS"
    #else
    #error("Not supported, at least not yet")
    #endif

    var body: some View {
        VStack {
            Text(self.name)
                .font(.largeTitle)

            AppSettingsView()
                .padding([.top, .bottom])

            ScrollView(.vertical, showsIndicators: false) {
                ForEach(0..<AppModel.cTumblers) {
                    TumblerSettingsView()
                        .padding([.top, .bottom])
                        .environmentObject(appModel.tumblers[$0])
                        .environmentObject(appState.tumblerStates[$0])
                }
            }
        }.padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
