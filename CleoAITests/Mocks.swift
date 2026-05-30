import Foundation
import Combine
@testable import CleoAI

final class MockAudioService: AudioRecordingProviding {
    private let isRecordingSubject = CurrentValueSubject<Bool, Never>(false)
    private let audioLevelSubject = CurrentValueSubject<Float, Never>(0.0)
    private let recordingTimeSubject = CurrentValueSubject<TimeInterval, Never>(0.0)
    private let recordingBufferSizeSubject = CurrentValueSubject<UInt32, Never>(AppConstants.defaultBufferSize)
    private let recordingFormatInfoSubject = CurrentValueSubject<String, Never>("")
    private let recordingFileSizeSubject = CurrentValueSubject<Int64, Never>(0)
    
    var isRecordingPublisher: AnyPublisher<Bool, Never> { isRecordingSubject.eraseToAnyPublisher() }
    var audioLevelPublisher: AnyPublisher<Float, Never> { audioLevelSubject.eraseToAnyPublisher() }
    var recordingTimePublisher: AnyPublisher<TimeInterval, Never> { recordingTimeSubject.eraseToAnyPublisher() }
    var recordingBufferSizePublisher: AnyPublisher<UInt32, Never> { recordingBufferSizeSubject.eraseToAnyPublisher() }
    var recordingFormatInfoPublisher: AnyPublisher<String, Never> { recordingFormatInfoSubject.eraseToAnyPublisher() }
    var recordingFileSizePublisher: AnyPublisher<Int64, Never> { recordingFileSizeSubject.eraseToAnyPublisher() }
    
    private(set) var startedCount = 0
    private(set) var stoppedCount = 0
    var nextAudioRecording: AudioRecording? = nil
    
    func startRecording() async throws {
        startedCount += 1
        isRecordingSubject.send(true)
    }
    
    func stopRecording() -> AudioRecording? {
        stoppedCount += 1
        isRecordingSubject.send(false)
        return nextAudioRecording
    }
    
    // Test helpers
    func send(level: Float, time: TimeInterval, fileSize: Int64, formatInfo: String = "") {
        audioLevelSubject.send(level)
        recordingTimeSubject.send(time)
        recordingFileSizeSubject.send(fileSize)
        recordingFormatInfoSubject.send(formatInfo)
    }
}

final class MockTranscriptionService: TranscriptionProviding {
    private let isTranscribingSubject = CurrentValueSubject<Bool, Never>(false)
    private let progressMessageSubject = CurrentValueSubject<String, Never>("")
    
    var isTranscribingPublisher: AnyPublisher<Bool, Never> { isTranscribingSubject.eraseToAnyPublisher() }
    var progressMessagePublisher: AnyPublisher<String, Never> { progressMessageSubject.eraseToAnyPublisher() }
    
    var resultToReturn: TranscriptionResult?
    var errorToThrow: Error?
    
    func transcribe(audioRecording: AudioRecording, model: String, language: String) async throws -> TranscriptionResult {
        isTranscribingSubject.send(true)
        defer { isTranscribingSubject.send(false) }
        progressMessageSubject.send("processing...")
        if let error = errorToThrow { throw error }
        if let res = resultToReturn { return res }
        return TranscriptionResult(text: "hello world", language: language, model: model, audioDuration: audioRecording.duration, processingTime: 0.1)
    }
}

final class MockNoteSummarizationService: NoteSummarizationProviding {
    func generateSummary(from text: String) async -> String { "summary:" + text }
    func extractKeywords(from text: String) async -> [String] { ["kw1", "kw2"] }
    func categorizeNote(from text: String) async -> NoteCategory { .general }
}

