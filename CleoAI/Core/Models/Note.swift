import Foundation

struct Note: Identifiable, Codable {
    let id = UUID()
    let title: String
    let content: String
    let summary: String?
    let keywords: [String]
    let category: NoteCategory
    let transcriptionResult: TranscriptionResult?
    let createdAt: Date
    let updatedAt: Date
    
    init(title: String, content: String, summary: String? = nil, keywords: [String] = [], category: NoteCategory = .general, transcriptionResult: TranscriptionResult? = nil) {
        self.title = title
        self.content = content
        self.summary = summary
        self.keywords = keywords
        self.category = category
        self.transcriptionResult = transcriptionResult
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum NoteCategory: String, CaseIterable, Codable {
    case general = "일반"
    case meeting = "회의"
    case lecture = "강의"
    case interview = "인터뷰"
    case personal = "개인"
    
    var icon: String {
        switch self {
        case .general: return "doc.text"
        case .meeting: return "person.2"
        case .lecture: return "graduationcap"
        case .interview: return "mic"
        case .personal: return "person"
        }
    }
}




