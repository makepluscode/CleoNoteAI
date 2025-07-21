import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranscriptionViewModel()
    @State private var showShareSheet = false
    let languages = ["English", "한국어"]

    var body: some View {
        VStack {
            TopBarView()
            Spacer()

            if viewModel.isRecording {
                RecordingStatusView(viewModel: viewModel)
            } else if !viewModel.transcriptionResult.isEmpty {
                TranscriptionResultView(viewModel: viewModel, showShareSheet: $showShareSheet)
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
                languages: languages,
                selectedModelName: $viewModel.selectedModelName,
                models: viewModel.availableModels
            )
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .sheet(isPresented: $showShareSheet) {
            if let fileURL = textToTempFile(text: viewModel.transcriptionResult) {
                ActivityView(activityItems: [fileURL])
            }
        }
    }
}

struct RecordingStatusView: View {
    @ObservedObject var viewModel: TranscriptionViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Recording Time
            Text(formatTime(viewModel.recordingTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.accentColor)

            // Audio Level Meter
            ProgressView(value: viewModel.audioLevel)
                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                .frame(height: 8)
                .padding(.horizontal)

            // Detailed Info Grid
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "Buffer Size", value: "\(viewModel.recordingBufferSize) frames")
                InfoRow(label: "Audio Format", value: viewModel.recordingFormatInfo)
                InfoRow(label: "File Size", value: fileSizeString(viewModel.recordingFileSize))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }

    private func fileSizeString(_ bytes: Int64) -> String {
        let mb = Double(bytes) / (1024.0 * 1024.0)
        if mb >= 1.0 {
            return String(format: "%.1f MB", mb)
        } else {
            return String(format: "%.2f KB", Double(bytes) / 1024.0)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

struct TranscriptionResultView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    @Binding var showShareSheet: Bool

    var body: some View {
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
                        // Action Buttons
                        Button(action: { UIPasteboard.general.string = viewModel.transcriptionResult }) {
                            Image(systemName: "doc.on.doc")
                        }
                        Button(action: { showShareSheet = true }) {
                            Image(systemName: "square.and.arrow.down")
                        }
                        Button(action: { viewModel.clearTranscription() }) {
                            Image(systemName: "trash")
                        }
                    }
                    .foregroundColor(.accentColor)
                    .padding([.leading, .bottom, .trailing])
                }
            }
        }
    }
}

// Utility Functions
func textToTempFile(text: String) -> URL? {
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent("transcription.txt")
    do {
        try text.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    } catch {
        return nil
    }
}

import UIKit
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 
