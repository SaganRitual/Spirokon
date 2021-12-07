// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

struct NarniaView: View {
    let appModel: AppModel

    @StateObject var nscene: NarniaScene

    init(appModel: AppModel) {
        self.appModel = appModel
        self._nscene = StateObject(wrappedValue: NarniaScene(appModel: appModel))
    }

    var body: some View {
        ZStack {
            SpriteView(scene: nscene).aspectRatio(1.0, contentMode: .fill).padding(.leading, 2)

            ForEach(0..<appModel.tumblers.count) { nscene.makePixieView($0) }
        }
    }
}
