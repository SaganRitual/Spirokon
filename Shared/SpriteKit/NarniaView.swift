// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

struct NarniaView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var narniaScene: NarniaScene

    var body: some View {
        SpriteView(scene: narniaScene).aspectRatio(1.0, contentMode: .fill).padding(.leading, 2)
    }
}
