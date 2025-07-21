import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranscriptionViewModel()
    @State private var showShareSheet = false
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
                            HStack(alignment: .center, spacing: 8) {
                                Text(viewModel.transcriptionMeta)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer(minLength: 8)
                                // 복사 아이콘
                                Button(action: {
                                    UIPasteboard.general.string = viewModel.transcriptionResult
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.accentColor)
                                }
                                // 저장 아이콘
                                Button(action: {
                                    showShareSheet = true
                                }) {
                                    Image(systemName: "square.and.arrow.down")
                                        .foregroundColor(.accentColor)
                                }
                                // 삭제 아이콘
                                Button(action: {
                                    viewModel.clearTranscription()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.accentColor)
                                }
                            }
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
        .sheet(isPresented: $showShareSheet) {
            let text = viewModel.transcriptionResult
            ActivityView(activityItems: [textToTempFile(text: text)])
        }
    }
}

// 텍스트를 임시 txt 파일로 저장하여 공유
func textToTempFile(text: String) -> URL {
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent("transcription.txt")
    try? text.write(to: fileURL, atomically: true, encoding: .utf8)
    return fileURL
}

// UIKit의 UIActivityViewController를 SwiftUI에서 사용
import UIKit
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 