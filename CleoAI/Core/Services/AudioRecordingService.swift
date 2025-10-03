import Foundation
import AVFoundation
import Combine
import UIKit

class AudioRecordingService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    @Published var recordingTime: TimeInterval = 0.0
    @Published var recordingBufferSize: UInt32 = 1024
    @Published var recordingFormatInfo: String = ""
    @Published var recordingFileSize: Int64 = 0
    
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var originalBrightness: CGFloat = 0.5
    
    private let audioFilename: URL = {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("recorded.wav")
    }()
    
    func startRecording() throws {
        guard !isRecording else { return }
        
        // Save current brightness and set to minimum
        saveBrightnessAndDim()
        
        // Prevent screen from auto-locking during recording
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Configure audio session
        try configureAudioSession()
        
        audioEngine = AVAudioEngine()
        let inputNode = audioEngine!.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        recordingFormatInfo = "\(Int(recordingFormat.sampleRate)) Hz, \(recordingFormat.channelCount == 1 ? "Mono" : "Stereo")"
        
        // Remove old file
        try? FileManager.default.removeItem(at: audioFilename)
        
        do {
            audioFile = try AVAudioFile(forWriting: audioFilename, settings: recordingFormat.settings)
        } catch {
            throw AudioRecordingError.fileCreationFailed(error)
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
                print("Error writing to audio file: \(error)")
            }
        }
        
        do {
            audioEngine?.prepare()
            try audioEngine?.start()
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
            recordingStartTime = Date()
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let startTime = self.recordingStartTime else { return }
                DispatchQueue.main.async {
                    self.recordingTime = Date().timeIntervalSince(startTime)
                    self.updateRecordingFileSize()
                }
            }
        } catch {
            throw AudioRecordingError.recordingStartFailed(error)
        }
    }
    
    func stopRecording() -> AudioRecording? {
        guard isRecording else { return nil }
        
        // Restore original brightness
        restoreBrightness()
        
        // Re-enable auto-lock
        UIApplication.shared.isIdleTimerDisabled = false
        
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        updateRecordingFileSize()
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
        audioFile = nil
        
        let duration = getAudioDuration(url: audioFilename)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        
        return AudioRecording(
            url: audioFilename,
            duration: duration,
            fileSize: recordingFileSize,
            format: format
        )
    }
    
    private func updateRecordingFileSize() {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: audioFilename.path)
            let size = attributes[.size] as? Int64 ?? 0
            DispatchQueue.main.async {
                self.recordingFileSize = size
            }
        } catch {
            DispatchQueue.main.async {
                self.recordingFileSize = 0
            }
        }
    }
    
    private func calculateAudioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let channelDataValue = channelData.pointee
        let channelDataValueArray = UnsafeBufferPointer(start: channelDataValue, count: Int(buffer.frameLength))
        
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        
        return scaledPower(power: avgPower)
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
    
    private func getAudioDuration(url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
    
    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
        try session.setActive(true)
    }
    
    private func saveBrightnessAndDim() {
        DispatchQueue.main.async {
            // Save current brightness
            self.originalBrightness = UIScreen.main.brightness
            print("💡 [AudioRecording] Original brightness: \(self.originalBrightness)")
            
            // Set brightness to minimum (0.01 to keep screen visible)
            UIScreen.main.brightness = 0.01
            print("🌑 [AudioRecording] Brightness set to minimum: 0.01")
        }
    }
    
    private func restoreBrightness() {
        DispatchQueue.main.async {
            // Restore original brightness
            UIScreen.main.brightness = self.originalBrightness
            print("💡 [AudioRecording] Brightness restored to: \(self.originalBrightness)")
        }
    }
}

enum AudioRecordingError: LocalizedError {
    case fileCreationFailed(Error)
    case recordingStartFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileCreationFailed(let error):
            return "오디오 파일 생성 실패: \(error.localizedDescription)"
        case .recordingStartFailed(let error):
            return "녹음 시작 실패: \(error.localizedDescription)"
        }
    }
}




