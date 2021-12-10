// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct LlamaLlocator: View {
    @EnvironmentObject var llamaState: LlamaState

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.royalPurple)
                .cornerRadius(100)

            VStack {
                Text("Llocating Llamas")
                Text("\(llamaState.llamasLlocated.asString(decimals: 2, fixedWidth: 8))")
                Text("\(llamaState.averageLlama.asString(decimals: 4, fixedWidth: 6))")
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
