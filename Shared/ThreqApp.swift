// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

@main
struct ThreqApp: App {
    let appModel = AppModel(5)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
    }
}
