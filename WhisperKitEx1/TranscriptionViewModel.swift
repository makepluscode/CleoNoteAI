import Foundation
import AVFoundation
import WhisperKit

@MainActor
class TranscriptionViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isTranscribing = false
    @Published var isRecording = false
    @Published var transcriptionResult = ""
    @Published var errorMessage: String?
    @Published var transcriptionMeta: String = ""
    @Published var selectedLanguage: String = "English"

    private var audioRecorder: AVAudioRecorder?
    private var audioFilename: URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("recorded.wav")
    }
    private let modelName = "tiny"
    private let modelSizeMB = 75 // tiny 모델 약 75MB
    private var transcriptionStart: Date?

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            transcriptionResult = ""
            transcriptionMeta = ""
            errorMessage = nil
        } catch {
            errorMessage = "녹음 시작 실패: \(error.localizedDescription)"
            isRecording = false
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        transcribeRecordedFile()
    }

    func transcribeRecordedFile() {
        isTranscribing = true
        transcriptionResult = "음성 인식을 시작합니다..."
        transcriptionMeta = ""
        errorMessage = nil
        transcriptionStart = Date()
        Task {
            do {
                let whisper = try await WhisperKit(model: modelName)
                let result = try await whisper.transcribe(audioPath: audioFilename.path)
                let fullText = result.map(\.text).joined()
                transcriptionResult = fullText
                // 메타데이터 계산
                let duration = getAudioDuration(url: audioFilename)
                let wordCount = fullText.split { $0.isWhitespace || $0.isNewline }.count
                let elapsed = transcriptionStart.map { String(format: "%.2f", Date().timeIntervalSince($0)) } ?? "-"
                let lang = selectedLanguage
                transcriptionMeta = "모델: \(modelName) (\(modelSizeMB)MB) | 언어: \(lang) | 오디오 길이: \(String(format: "%.2f", duration))초 | 단어 수: \(wordCount) | 전사 소요: \(elapsed)초"
            } catch {
                errorMessage = "전사 실패: \(error.localizedDescription)"
                transcriptionResult = ""
                transcriptionMeta = ""
            }
            isTranscribing = false
        }
    }

    // 오디오 파일 길이(초) 계산
    private func getAudioDuration(url: URL) -> Double {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
} 