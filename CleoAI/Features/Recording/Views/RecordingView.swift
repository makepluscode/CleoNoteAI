import SwiftUI

struct RecordingView: View {
    @ObservedObject var viewModel: RecordingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Recording Time
            Text(AudioUtils.formatTime(viewModel.recordingTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.accentColor)
            
            // Audio Level Meter
            ProgressView(value: viewModel.audioLevel)
                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                .frame(height: 8)
                .padding(.horizontal)
            
            // Recording Info Grid
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "Buffer Size", value: "\(viewModel.recordingBufferSize) frames")
                InfoRow(label: "Audio Format", value: viewModel.recordingFormatInfo)
                InfoRow(label: "File Size", value: fileSizeString(viewModel.recordingFileSize))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(AppConstants.cornerRadius)
        }
        .padding()
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




