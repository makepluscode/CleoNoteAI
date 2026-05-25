import SwiftUI

struct ContentView: View {
    @StateObject private var audioService = AudioRecordingService()
    @StateObject private var transcriptionService = TranscriptionService()
    @StateObject private var noteSummarizationService = NoteSummarizationService()
    
    @StateObject private var recordingViewModel: RecordingViewModel
    @StateObject private var transcriptionViewModel: TranscriptionViewModel
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var showShareSheet = false
    @State private var showNotesView = false
    
    init() {
        let audioService = AudioRecordingService()
        let transcriptionService = TranscriptionService()
        let noteSummarizationService = NoteSummarizationService()
        
        _audioService = StateObject(wrappedValue: audioService)
        _transcriptionService = StateObject(wrappedValue: transcriptionService)
        _noteSummarizationService = StateObject(wrappedValue: noteSummarizationService)
        _recordingViewModel = StateObject(wrappedValue: RecordingViewModel(audioService: audioService))
        _transcriptionViewModel = StateObject(wrappedValue: TranscriptionViewModel(
            transcriptionService: transcriptionService,
            noteSummarizationService: noteSummarizationService
        ))
    }
    
    var body: some View {
        VStack {
            TopBarView()
            Spacer()

            // Main Content Area
            if recordingViewModel.isRecording {
                RecordingView(viewModel: recordingViewModel)
            } else if transcriptionViewModel.isTranscribing {
                ProgressView(transcriptionViewModel.progressMessage)
                    .padding()
                    .foregroundColor(.white)
            } else if let result = transcriptionViewModel.transcriptionResult {
                TranscriptionResultView(
                    viewModel: transcriptionViewModel,
                    showShareSheet: $showShareSheet
                )
            }
            
            // Error Display
            if let error = recordingViewModel.errorMessage ?? transcriptionViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
            
            // Bottom Controls
            BottomBarView(
                isTranscribing: $transcriptionViewModel.isTranscribing,
                isRecording: $recordingViewModel.isRecording,
                onTranscription: handleTranscription,
                selectedLanguage: $transcriptionViewModel.selectedLanguage,
                languages: AppConstants.availableLanguages,
                selectedModelName: $transcriptionViewModel.selectedModelName,
                models: AppConstants.availableModels
            )
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .sheet(isPresented: $showShareSheet) {
            if let result = transcriptionViewModel.transcriptionResult,
               let fileURL = FileUtils.textToTempFile(text: result.text) {
                ActivityView(activityItems: [fileURL])
            }
        }
        .sheet(isPresented: $showNotesView) {
            NotesListView(viewModel: notesViewModel)
        }
    }
    
    private func handleTranscription() {
        if recordingViewModel.isRecording {
            // Stop recording and start transcription
            if let audioRecording = recordingViewModel.stopRecording() {
                transcriptionViewModel.transcribe(audioRecording: audioRecording)
            }
        } else {
            // Start recording
            recordingViewModel.startRecording()
        }
    }
}




