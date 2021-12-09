// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct LlamaLlocator: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var appState: AppState

    var llamasLlocated: Double {
        Double(appState.llamasLlocated) + Double.random(in: 0..<1)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.royalPurple)
                .cornerRadius(100)

            VStack {
                Text("Llocating Llamas")
                Text("\(llamasLlocated.asString(decimals: 2, fixedWidth: 8)) : \(appState.averageLlama.asString(decimals: 4, fixedWidth: 6))")
            }
            .font(Font.system(size: 60).monospaced())
        }
    }
}

struct LlamaAssemblly_Previews: PreviewProvider {
    static var previews: some View {
        LlamaLlocator()
    }
}
