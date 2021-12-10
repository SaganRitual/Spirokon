// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

@main
struct ThreqApp: App {
    @StateObject var appModel: AppModel
    @StateObject var appState: AppState
    @StateObject var llamaState: LlamaState
    @StateObject var mainControlsState: MainControlsState
    @StateObject var narniaScene: NarniaScene

    init() {
        let m = AppModel()
        let s = AppState(appModel: m)
        let L = LlamaState()
        let c = MainControlsState()
        let n = NarniaScene(appModel: m, appState: s, llamaState: L, mainControlsState: c)

        _appModel = StateObject(wrappedValue: m)
        _appState = StateObject(wrappedValue: s)
        _llamaState = StateObject(wrappedValue: L)
        _mainControlsState = StateObject(wrappedValue: c)
        _narniaScene = StateObject(wrappedValue: n)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
                .environmentObject(appState)
                .environmentObject(llamaState)
                .environmentObject(mainControlsState)
                .environmentObject(narniaScene)
        }
    }
}
