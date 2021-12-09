// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

struct NarniaView: View {
    let appModel: AppModel
    @ObservedObject var appState: AppState

    @StateObject var nscene: NarniaScene

    init(appModel: AppModel, appState: AppState) {
        self.appModel = appModel
        self._appState = ObservedObject(wrappedValue: appState)
        self._nscene = StateObject(wrappedValue: NarniaScene(appModel: appModel, appState: appState))
    }

    var body: some View {
        ZStack {
            SpriteView(scene: nscene).aspectRatio(1.0, contentMode: .fill).padding(.leading, 2)

            if appState.readyComponents.contains(.narnia) && !appState.readyComponents.contains(.pixieViews) {
                ForEach(0..<appModel.tumblers.count) { nscene.makePixieView($0) }
                    .onAppear { appState.markComponentReady(.pixieViews) }
            }
        }
    }
}
