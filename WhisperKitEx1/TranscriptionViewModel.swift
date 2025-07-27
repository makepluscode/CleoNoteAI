import Foundation
import AVFoundation
import WhisperKit

@MainActor
class TranscriptionViewModel: NSObject, ObservableObject {
    @Published var isTranscribing = false
    @Published var isRecording = false
    @Published var transcriptionResult = ""
    @Published var errorMessage: String?
    @Published var transcriptionMeta: String = ""
    @Published var selectedLanguage: String = "English"
    
    // MARK: - Real-time Recording Status
    @Published var audioLevel: Float = 0.0
    @Published var recordingTime: TimeInterval = 0.0
    @Published var recordingBufferSize: UInt32 = 1024
    @Published var recordingFormatInfo: String = ""
    @Published var recordingFileSize: Int64 = 0

    @Published var selectedModelName: String = "small"
    let availableModels: [String] = ["tiny", "base", "small", "medium", "large"]
    var modelSizeMB: Int {
        switch selectedModelName {
        case "tiny": return 75
        case "base": return 142
        case "small": return 244
        case "medium": return 769
        case "large": return 1550
        default: return 0
        }
    }
    
    // private let modelName = "tiny"
    // private let modelSizeMB = 75 // tiny 모델 약 75MB
    private var transcriptionStart: Date?
    
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?

    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
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
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine!.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Set format info for the UI
        recordingFormatInfo = "\(Int(recordingFormat.sampleRate)) Hz, \(recordingFormat.channelCount == 1 ? "Mono" : "Stereo")"
        
        // Reset file by removing old one
        try? FileManager.default.removeItem(at: audioFilename)

        do {
            audioFile = try AVAudioFile(forWriting: audioFilename, settings: recordingFormat.settings)
        } catch {
            errorMessage = "오디오 파일 생성 실패: \(error.localizedDescription)"
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: recordingBufferSize, format: recordingFormat) { [weak self] (buffer, when) in
            guard let self = self else { return }
            do {
                try self.audioFile?.write(from: buffer)
                
                let level = self.calculateAudioLevel(from: buffer)
                DispatchQueue.main.async {
                    self.audioLevel = level
                }
            } catch {
                // Errors in the tap are hard to propagate, log them for debugging
                print("Error writing to audio file: \(error)")
            }
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            audioEngine?.prepare()
            try audioEngine?.start()
            
            isRecording = true
            recordingStartTime = Date()
            
            // Start a timer to update recording time and file size
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let startTime = self.recordingStartTime else { return }
                self.recordingTime = Date().timeIntervalSince(startTime)
                self.updateRecordingFileSize()
            }
            
            transcriptionResult = ""
            transcriptionMeta = ""
            errorMessage = nil
        } catch {
            errorMessage = "녹음 시작 실패: \(error.localizedDescription)"
            isRecording = false
        }
    }

    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Final update to file size
        updateRecordingFileSize()
        
        // Use a brief delay to ensure the file handle is released before transcription
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.audioFile = nil
            self.isRecording = false
            self.transcribeRecordedFile()
        }
    }
    
    private func updateRecordingFileSize() {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: audioFilename.path)
            recordingFileSize = attributes[.size] as? Int64 ?? 0
        } catch {
            recordingFileSize = 0
        }
    }
    
    private func calculateAudioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let channelDataValue = channelData.pointee
        let channelDataValueArray = UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength))
        
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        
        let meterLevel = self.scaledPower(power: avgPower)
        return meterLevel
    }

    private func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }
        let minDb: Float = -80.0
        if power < minDb {
            return 0.0
        } else if power >= 0.0 {
            return 1.0
        } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
        }
    }

    private var progressTimer: Timer?
    private var progressDotCount: Int = 1

    func transcribeRecordedFile() {
        isTranscribing = true
        progressDotCount = 1
        let fileSizeMB = Double(recordingFileSize) / (1024.0 * 1024.0)
        let durationSec = getAudioDuration(url: audioFilename)
        let baseMessage = String(format: "%.1f MB, %.2f초 길이의 오디오 파일을 '%@' 모델로 (%@) 텍스트 변환 중입니다", fileSizeMB, durationSec, selectedModelName, selectedLanguage)
        transcriptionResult = baseMessage + "."
        transcriptionMeta = ""
        errorMessage = nil
        transcriptionStart = Date()
        // Start dot animation
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progressDotCount = (self.progressDotCount % 3) + 1
            let dots = String(repeating: ".", count: self.progressDotCount)
            self.transcriptionResult = baseMessage + dots
        }
        Task {
            do {
                let whisper = try await WhisperKit(model: selectedModelName)
                let result = try await whisper.transcribe(audioPath: audioFilename.path)
                let fullText = result.map(\.text).joined()
                transcriptionResult = fullText
                // 메타데이터 계산
                let duration = getAudioDuration(url: audioFilename)
                let wordCount = fullText.split { $0.isWhitespace || $0.isNewline }.count
                let elapsed = transcriptionStart.map { String(format: "%.2f", Date().timeIntervalSince($0)) } ?? "-"
                let lang = selectedLanguage
                transcriptionMeta = "모델: \(selectedModelName) (\(modelSizeMB)MB) | 언어: \(lang) | 오디오 길이: \(String(format: "%.2f", duration))초 | 단어 수: \(wordCount) | 전사 소요: \(elapsed)초"
            } catch {
                errorMessage = "전사 실패: \(error.localizedDescription)"
                transcriptionResult = ""
                transcriptionMeta = ""
            }
            isTranscribing = false
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }

    // 오디오 파일 길이(초) 계산
    private func getAudioDuration(url: URL) -> Double {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }

    // 전사 결과/메타데이터 초기화
    func clearTranscription() {
        transcriptionResult = ""
        transcriptionMeta = ""
        errorMessage = nil
    }

    // Helper to convert display language to code
    private var selectedLanguageCode: String? {
        switch selectedLanguage {
        case "English": return "en"
        case "한국어": return "ko"
        default: return nil
        }
    }
}
