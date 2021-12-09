// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct LlamaAssemblly: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.royalPurple)
                .cornerRadius(100)

            VStack {
                Text("Llocating Llamas")
                Text("\(appModel.llamasLlocated)")
            }
            .font(Font.system(size: 60))
        }
    }
}

struct LlamaAssemblly_Previews: PreviewProvider {
    static var previews: some View {
        LlamaAssemblly()
    }
}
