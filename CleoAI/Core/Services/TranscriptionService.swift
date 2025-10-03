import Foundation
import WhisperKit
import Combine

@MainActor
class TranscriptionService: ObservableObject {
    @Published var isTranscribing = false
    @Published var progressMessage = ""
    
    private var progressTimer: Timer?
    private var progressDotCount: Int = 1
    
    func transcribe(audioRecording: AudioRecording, model: String, language: String) async throws -> TranscriptionResult {
        isTranscribing = true
        progressDotCount = 1
        
        let fileSizeMB = Double(audioRecording.fileSize) / (1024.0 * 1024.0)
        let baseMessage = String(format: "%.1f MB, %.2f초 길이의 오디오 파일을 '%@' 모델로 (%@) 텍스트 변환 중입니다", fileSizeMB, audioRecording.duration, model, language)
        progressMessage = baseMessage + "."
        
        let transcriptionStart = Date()
        
        // Start progress animation
        startProgressAnimation(baseMessage: baseMessage)
        
        defer {
            isTranscribing = false
            stopProgressAnimation()
        }
        
        do {
            let whisper = try await WhisperKit(model: model)
            let result = try await whisper.transcribe(audioPath: audioRecording.url.path)
            let fullText = result.map(\.text).joined()
            
            let processingTime = Date().timeIntervalSince(transcriptionStart)
            
            return TranscriptionResult(
                text: fullText,
                language: language,
                model: model,
                audioDuration: audioRecording.duration,
                processingTime: processingTime
            )
        } catch {
            throw TranscriptionError.transcriptionFailed(error)
        }
    }
    
    private func startProgressAnimation(baseMessage: String) {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progressDotCount = (self.progressDotCount % 3) + 1
            let dots = String(repeating: ".", count: self.progressDotCount)
            self.progressMessage = baseMessage + dots
        }
    }
    
    private func stopProgressAnimation() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}

extension TranscriptionService: TranscriptionProviding {
    var isTranscribingPublisher: AnyPublisher<Bool, Never> { $isTranscribing.eraseToAnyPublisher() }
    var progressMessagePublisher: AnyPublisher<String, Never> { $progressMessage.eraseToAnyPublisher() }
}

enum TranscriptionError: LocalizedError {
    case transcriptionFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .transcriptionFailed(let error):
            return "전사 실패: \(error.localizedDescription)"
        }
    }
}




