import XCTest
@testable import CleoAI

final class RecordingViewModelTests: XCTestCase {
    func testStartAndStopRecordingUpdatesState() {
        let mock = MockAudioService()
        let vm = RecordingViewModel(audioService: mock)
        
        XCTAssertFalse(vm.isRecording)
        vm.startRecording()
        // Allow async to propagate
        RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        XCTAssertTrue(vm.isRecording)
        
        _ = vm.stopRecording()
        RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        XCTAssertFalse(vm.isRecording)
        
        XCTAssertEqual(mock.startedCount, 1)
        XCTAssertEqual(mock.stoppedCount, 1)
    }
    
    func testPublishesAudioMetrics() {
        let mock = MockAudioService()
        let vm = RecordingViewModel(audioService: mock)
        
        mock.send(level: 0.7, time: 1.2, fileSize: 2048, formatInfo: "44100 Hz, Mono")
        RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        
        XCTAssertEqual(vm.audioLevel, 0.7, accuracy: 0.0001)
        XCTAssertEqual(vm.recordingTime, 1.2, accuracy: 0.0001)
        XCTAssertEqual(vm.recordingFileSize, 2048)
        XCTAssertEqual(vm.recordingFormatInfo, "44100 Hz, Mono")
    }
}

