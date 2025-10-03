import Foundation

class NoteSummarizationService: ObservableObject {
    
    func generateSummary(from text: String) async -> String {
        // TODO: Implement AI-powered summarization
        // For now, return a simple extractive summary
        return extractiveSummary(from: text)
    }
    
    func extractKeywords(from text: String) async -> [String] {
        // TODO: Implement keyword extraction
        // For now, return simple word frequency analysis
        return extractKeywordsSimple(from: text)
    }
    
    func categorizeNote(from text: String) async -> NoteCategory {
        // TODO: Implement AI-powered categorization
        // For now, return simple rule-based categorization
        return categorizeNoteSimple(from: text)
    }
    
    private func extractiveSummary(from text: String) -> String {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard sentences.count > 1 else { return text }
        
        // Simple extractive summary: take first 2-3 sentences
        let summarySentences = Array(sentences.prefix(min(3, sentences.count)))
        return summarySentences.joined(separator: ". ") + "."
    }
    
    private func extractKeywordsSimple(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
        
        let wordFrequency = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return Array(wordFrequency.prefix(5).map { $0.key })
    }
    
    private func categorizeNoteSimple(from text: String) -> NoteCategory {
        let lowercasedText = text.lowercased()
        
        if lowercasedText.contains("회의") || lowercasedText.contains("meeting") {
            return .meeting
        } else if lowercasedText.contains("강의") || lowercasedText.contains("lecture") {
            return .lecture
        } else if lowercasedText.contains("인터뷰") || lowercasedText.contains("interview") {
            return .interview
        } else {
            return .general
        }
    }
}




