// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct PixieView: View {
    var body: some View {
        Rectangle()
            .fill(Color.appBackgroundOrSomething)
            .zIndex(-1)
    }
}
