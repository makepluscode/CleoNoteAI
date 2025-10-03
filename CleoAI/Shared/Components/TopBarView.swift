import SwiftUI

struct TopBarView: View {
    var body: some View {
        HStack {
            Spacer()
            Text(AppConstants.appName)
                .font(.title2)
                .fontWeight(.bold)
            Image(systemName: "waveform")
                .foregroundColor(.accentColor)
            Spacer()
        }
        .padding(.top, 20)
    }
}




