import Foundation
import Combine

protocol AudioRecordingProviding: AnyObject {
    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }
    var audioLevelPublisher: AnyPublisher<Float, Never> { get }
    var recordingTimePublisher: AnyPublisher<TimeInterval, Never> { get }
    var recordingBufferSizePublisher: AnyPublisher<UInt32, Never> { get }
    var recordingFormatInfoPublisher: AnyPublisher<String, Never> { get }
    var recordingFileSizePublisher: AnyPublisher<Int64, Never> { get }
    func startRecording() async throws
    func stopRecording() -> AudioRecording?
}

protocol TranscriptionProviding: AnyObject {
    var isTranscribingPublisher: AnyPublisher<Bool, Never> { get }
    var progressMessagePublisher: AnyPublisher<String, Never> { get }
    func transcribe(audioRecording: AudioRecording, model: String, language: String) async throws -> TranscriptionResult
}

protocol NoteSummarizationProviding: AnyObject {
    func generateSummary(from text: String) async -> String
    func extractKeywords(from text: String) async -> [String]
    func categorizeNote(from text: String) async -> NoteCategory
}

