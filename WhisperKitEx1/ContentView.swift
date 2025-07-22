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
                InfoRow(label: "Language", value: viewModel.selectedLanguage)
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
                        PressableIconButton(action: { UIPasteboard.general.string = viewModel.transcriptionResult }, systemName: "doc.on.doc")
                        PressableIconButton(action: { showShareSheet = true }, systemName: "square.and.arrow.down")
                        PressableIconButton(action: { viewModel.clearTranscription() }, systemName: "trash")
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
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd-HHmmss"
    let dateString = formatter.string(from: Date())
    let fileURL = tempDir.appendingPathComponent("trans-\(dateString).txt")
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

struct PressableIconButton: View {
    let action: () -> Void
    let systemName: String
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .scaleEffect(isPressed ? 0.85 : 1.0)
                .opacity(isPressed ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
} 
