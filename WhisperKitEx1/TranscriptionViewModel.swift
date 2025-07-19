import Foundation
import WhisperKit

@MainActor
class TranscriptionViewModel: ObservableObject {
    @Published var isTranscribing = false
    @Published var transcriptionResult = ""
    @Published var errorMessage: String?

    func transcribeTestWav() {
        isTranscribing = true
        transcriptionResult = "음성 인식을 시작합니다..."
        errorMessage = nil

        Task {
            guard let audioURL = Bundle.main.url(forResource: "test", withExtension: "wav") else {
                transcriptionResult = "오디오 파일을 찾을 수 없습니다."
                isTranscribing = false
                return
            }
            do {
                let whisper = try await WhisperKit(model: "tiny")
                let result = try await whisper.transcribe(audioPath: audioURL.path)
                let fullText = result.map(\.text).joined()
                transcriptionResult = fullText
            } catch {
                errorMessage = "전사 실패: \(error.localizedDescription)"
                transcriptionResult = ""
            }
            isTranscribing = false
        }
    }
} 