import Foundation

struct AppConstants {
    
    // MARK: - App Info
    static let appName = "CleoAI"
    static let bundleIdentifier = "com.makepluscode.CleoAI"
    
    // MARK: - WhisperKit Models
    static let availableModels = ["tiny", "base", "small", "medium", "large"]
    static let defaultModel = "small"
    
    static func modelSizeMB(for model: String) -> Int {
        switch model {
        case "tiny": return 75
        case "base": return 142
        case "small": return 244
        case "medium": return 769
        case "large": return 1550
        default: return 0
        }
    }
    
    // MARK: - Languages
    static let availableLanguages = ["English", "한국어"]
    static let defaultLanguage = "English"
    
    static func languageCode(for language: String) -> String? {
        switch language {
        case "English": return "en"
        case "한국어": return "ko"
        default: return nil
        }
    }
    
    // MARK: - Audio Settings
    static let defaultBufferSize: UInt32 = 1024
    static let recordingUpdateInterval: TimeInterval = 0.1
    
    // MARK: - UI Constants
    static let cornerRadius: CGFloat = 12
    static let animationDuration: Double = 0.3
    static let buttonSize: CGFloat = 32
    
    // MARK: - File Extensions
    static let audioFileExtension = "wav"
    static let noteFileExtension = "json"
}




