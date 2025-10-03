import Foundation
import Combine

@MainActor
class TranscriptionViewModel: ObservableObject {
    @Published var isTranscribing = false
    @Published var transcriptionResult: TranscriptionResult?
    @Published var progressMessage = ""
    @Published var errorMessage: String?
    @Published var selectedLanguage: String = AppConstants.defaultLanguage
    @Published var selectedModelName: String = AppConstants.defaultModel
    
    private let transcriptionService: TranscriptionProviding
    private let noteSummarizationService: NoteSummarizationProviding
    private var cancellables = Set<AnyCancellable>()
    
    init(
        transcriptionService: TranscriptionProviding = TranscriptionService(),
        noteSummarizationService: NoteSummarizationProviding = NoteSummarizationService()
    ) {
        self.transcriptionService = transcriptionService
        self.noteSummarizationService = noteSummarizationService
        setupBindings()
    }
    
    private func setupBindings() {
        transcriptionService.isTranscribingPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.isTranscribing, on: self)
            .store(in: &cancellables)
        
        transcriptionService.progressMessagePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.progressMessage, on: self)
            .store(in: &cancellables)
    }
    
    func transcribe(audioRecording: AudioRecording) {
        Task {
            do {
                let result = try await transcriptionService.transcribe(
                    audioRecording: audioRecording,
                    model: selectedModelName,
                    language: selectedLanguage
                )
                transcriptionResult = result
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
                transcriptionResult = nil
            }
        }
    }
    
    func createNote(from transcriptionResult: TranscriptionResult) async -> Note {
        let summary = await noteSummarizationService.generateSummary(from: transcriptionResult.text)
        let keywords = await noteSummarizationService.extractKeywords(from: transcriptionResult.text)
        let category = await noteSummarizationService.categorizeNote(from: transcriptionResult.text)
        
        let title = generateTitle(from: transcriptionResult.text)
        
        return Note(
            title: title,
            content: transcriptionResult.text,
            summary: summary,
            keywords: keywords,
            category: category,
            transcriptionResult: transcriptionResult
        )
    }
    
    private func generateTitle(from text: String) -> String {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        if words.count <= 5 {
            return text
        } else {
            return words.prefix(5).joined(separator: " ") + "..."
        }
    }
    
    func clearTranscription() {
        transcriptionResult = nil
        errorMessage = nil
        progressMessage = ""
    }
    
    func clearError() {
        errorMessage = nil
    }
}




