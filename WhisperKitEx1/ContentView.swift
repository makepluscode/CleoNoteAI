import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranscriptionViewModel()
    let languages = ["English", "한국어"]

    var body: some View {
        VStack {
            TopBarView()
            Spacer()
            if !viewModel.transcriptionResult.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.transcriptionResult)
                            .padding()
                            .foregroundColor(.white)
                        if !viewModel.transcriptionMeta.isEmpty {
                            Text(viewModel.transcriptionMeta)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding([.leading, .bottom, .trailing])
                        }
                    }
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
                isRecording: $viewModel.isRecording,
                onTranscription: viewModel.toggleRecording,
                selectedLanguage: $viewModel.selectedLanguage,
                languages: languages
            )
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
} 