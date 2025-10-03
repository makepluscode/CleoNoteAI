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
    
    private let audioService: AudioRecordingProviding
    private var cancellables = Set<AnyCancellable>()
    
    init(audioService: AudioRecordingProviding = AudioRecordingService()) {
        self.audioService = audioService
        setupBindings()
    }
    
    private func setupBindings() {
        audioService.isRecordingPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.isRecording, on: self)
            .store(in: &cancellables)
        
        audioService.audioLevelPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.audioLevel, on: self)
            .store(in: &cancellables)
        
        audioService.recordingTimePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.recordingTime, on: self)
            .store(in: &cancellables)
        
        audioService.recordingBufferSizePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.recordingBufferSize, on: self)
            .store(in: &cancellables)
        
        audioService.recordingFormatInfoPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.recordingFormatInfo, on: self)
            .store(in: &cancellables)
        
        audioService.recordingFileSizePublisher
            .receive(on: DispatchQueue.main)
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
                try await audioService.startRecording()
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func stopRecording() -> AudioRecording? {
        return audioService.stopRecording()
    }
    
    func clearError() {
        errorMessage = nil
    }
}




