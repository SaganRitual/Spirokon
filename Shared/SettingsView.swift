// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        VStack {
            Text("Spirokon iOS")
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
