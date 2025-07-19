import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranscriptionViewModel()
    @State private var selectedLanguage = "English"
    let languages = ["English", "한국어"]

    var body: some View {
        VStack {
            TopBarView()
            Spacer()
            if !viewModel.transcriptionResult.isEmpty {
                ScrollView {
                    Text(viewModel.transcriptionResult)
                        .padding()
                        .foregroundColor(.white)
                }
            }
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            Spacer()
            BottomBarView(
                isTranscribing: $viewModel.isTranscribing,
                onTranscription: viewModel.transcribeTestWav,
                selectedLanguage: $selectedLanguage,
                languages: languages
            )
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
} 