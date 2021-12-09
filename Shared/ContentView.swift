// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                SettingsView()
                NarniaView(appModel: appModel).padding(5)
            }
            .opacity(appModel.narniaIsReady ? 1.0 : 0.0)
            .animation(.linear, value: appModel.narniaIsReady)

            LlamaAssemblly()
                .opacity(appModel.narniaIsReady ? 0.0 : 1.0)
                .animation(.linear, value: appModel.narniaIsReady)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewInterfaceOrientation(.landscapeLeft)
    }
}
