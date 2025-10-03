import Foundation
import Combine

@MainActor
class RecordingViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    @Published var recordingTime: TimeInterval = 0.0
    @Published var recordingBufferSize: UInt32 = AppConstants.defaultBufferSize
    @Published var recordingFormatInfo: String = ""
    @Published var recordingFileSize: Int64 = 0
    @Published var errorMessage: String?
    
    private let audioRecordingService = AudioRecordingService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        audioRecordingService.$isRecording
            .assign(to: \.isRecording, on: self)
            .store(in: &cancellables)
        
        audioRecordingService.$audioLevel
            .assign(to: \.audioLevel, on: self)
            .store(in: &cancellables)
        
        audioRecordingService.$recordingTime
            .assign(to: \.recordingTime, on: self)
            .store(in: &cancellables)
        
        audioRecordingService.$recordingBufferSize
            .assign(to: \.recordingBufferSize, on: self)
            .store(in: &cancellables)
        
        audioRecordingService.$recordingFormatInfo
            .assign(to: \.recordingFormatInfo, on: self)
            .store(in: &cancellables)
        
        audioRecordingService.$recordingFileSize
            .assign(to: \.recordingFileSize, on: self)
            .store(in: &cancellables)
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        Task {
            do {
                try await audioRecordingService.startRecording()
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func stopRecording() -> AudioRecording? {
        return audioRecordingService.stopRecording()
    }
    
    func clearError() {
        errorMessage = nil
    }
}




