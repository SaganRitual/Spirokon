// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appModel: AppModel

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
                ForEach(0..<appModel.tumblers.count) {
                    TumblerSettingsView(tumblerIx: $0, appModel: appModel)
                        .padding([.top, .bottom])
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
