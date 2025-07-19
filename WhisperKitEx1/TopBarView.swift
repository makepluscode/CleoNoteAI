import SwiftUI

struct TopBarView: View {
    var body: some View {
        HStack {
            Spacer()
            Text("CleoAI")
                .font(.title2).bold()
            Image(systemName: "waveform")
                .foregroundColor(.accentColor)
            Spacer()
        }
        .padding(.top, 20)
    }
}