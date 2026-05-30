import XCTest
import AVFoundation
@testable import CleoAI

final class TranscriptionViewModelTests: XCTestCase {
    func testTranscribeSuccessSetsResult() async throws {
        let transcriber = MockTranscriptionService()
        let intel = MockNoteSummarizationService()
        let vm = TranscriptionViewModel(transcriptionService: transcriber, noteSummarizationService: intel)
        
        let dummyURL = URL(fileURLWithPath: "/tmp/a.wav")
        let recording = AudioRecording(url: dummyURL, duration: 1.0, fileSize: 1000, format: AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!)
        
        await vm.transcribe(audioRecording: recording)
        RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertNotNil(vm.transcriptionResult)
        XCTAssertNil(vm.errorMessage)
    }
    
    func testTranscribeErrorSetsError() async {
        struct DummyError: Error {}
        let transcriber = MockTranscriptionService()
        transcriber.errorToThrow = DummyError()
        let intel = MockNoteSummarizationService()
        let vm = TranscriptionViewModel(transcriptionService: transcriber, noteSummarizationService: intel)
        
        let dummyURL = URL(fileURLWithPath: "/tmp/a.wav")
        let recording = AudioRecording(url: dummyURL, duration: 1.0, fileSize: 1000, format: AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!)
        
        await vm.transcribe(audioRecording: recording)
        RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertNil(vm.transcriptionResult)
        XCTAssertNotNil(vm.errorMessage)
    }
    
    func testCreateNoteUsesIntelligence() async {
        let transcriber = MockTranscriptionService()
        let intel = MockNoteSummarizationService()
        let vm = TranscriptionViewModel(transcriptionService: transcriber, noteSummarizationService: intel)
        
        let res = TranscriptionResult(text: "hello world from test", language: "en", model: "tiny", audioDuration: 1.0, processingTime: 0.1)
        let note = await vm.createNote(from: res)
        
        XCTAssertEqual(note.summary, "summary:" + res.text)
        XCTAssertEqual(note.keywords.count, 2)
        XCTAssertEqual(note.category, .general)
    }
}

