import Foundation
import AVFoundation
import WhisperKit

@MainActor
class TranscriptionViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isTranscribing = false
    @Published var isRecording = false
    @Published var transcriptionResult = ""
    @Published var errorMessage: String?

    private var audioRecorder: AVAudioRecorder?
    private var audioFilename: URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("recorded.wav")
    }

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
        errorMessage = nil
        Task {
            do {
                let whisper = try await WhisperKit(model: "tiny")
                let result = try await whisper.transcribe(audioPath: audioFilename.path)
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