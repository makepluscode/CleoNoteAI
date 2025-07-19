import SwiftUI

struct TopBarView: View {
    var body: some View {
        HStack {
            Spacer()
            Text("WhisperKit")
                .font(.title2).bold()
            Image(systemName: "waveform")
                .foregroundColor(.pink)
            Spacer()
        }
        .padding(.top, 20)
    }
} 