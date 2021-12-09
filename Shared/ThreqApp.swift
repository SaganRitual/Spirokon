// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

@main
struct ThreqApp: App {
    @StateObject var appModel: AppModel
    @StateObject var appState: AppState

    init() {
        let m = AppModel()
        let s = AppState(appModel: m)

        _appModel = StateObject(wrappedValue: m)
        _appState = StateObject(wrappedValue: s)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
                .environmentObject(appState)
        }
    }
}
