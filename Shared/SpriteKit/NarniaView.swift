// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

struct NarniaView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var llamaState: LlamaState
    @EnvironmentObject var narniaScene: NarniaScene

    var body: some View {
        ZStack {
            SpriteView(scene: narniaScene).aspectRatio(1.0, contentMode: .fill).padding(.leading, 2)

            if appState.readyComponents.contains(.narnia) && !appState.readyComponents.contains(.pixieViews) {
                ForEach(0..<appModel.tumblers.count) { narniaScene.makePixieView($0) }
                    .onAppear { appState.markComponentReady(.pixieViews) }
            }
        }
    }
}
