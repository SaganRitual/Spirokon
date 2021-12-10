// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                SettingsView()
                NarniaView().padding(5)
            }
//            .opacity(appState.readyComponents.contains(.narnia) ? 1.0 : 0.0)
//            .animation(.linear, value: appState.readyComponents.contains(.narnia))

//            LlamaLlocator()
//                .opacity(appState.readyComponents.contains(.narnia) ? 0.0 : 1.0)
//                .animation(.linear, value: appState.readyComponents.contains(.narnia))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewInterfaceOrientation(.landscapeLeft)
    }
}
