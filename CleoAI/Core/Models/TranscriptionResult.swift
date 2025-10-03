import Foundation

struct TranscriptionResult: Identifiable, Codable {
    let id = UUID()
    let text: String
    let language: String
    let model: String
    let audioDuration: TimeInterval
    let processingTime: TimeInterval
    let wordCount: Int
    let createdAt: Date
    
    init(text: String, language: String, model: String, audioDuration: TimeInterval, processingTime: TimeInterval) {
        self.text = text
        self.language = language
        self.model = model
        self.audioDuration = audioDuration
        self.processingTime = processingTime
        self.wordCount = text.split { $0.isWhitespace || $0.isNewline }.count
        self.createdAt = Date()
    }
    
    var metadata: String {
        return "모델: \(model) | 언어: \(language) | 오디오 길이: \(String(format: "%.2f", audioDuration))초 | 단어 수: \(wordCount) | 전사 소요: \(String(format: "%.2f", processingTime))초"
    }
}




