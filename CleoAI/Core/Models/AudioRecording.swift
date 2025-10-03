import Foundation
import AVFoundation

struct AudioRecording: Identifiable {
    let id = UUID()
    let url: URL
    let duration: TimeInterval
    let fileSize: Int64
    let format: String
    let sampleRate: Double
    let channelCount: Int
    let createdAt: Date
    
    init(url: URL, duration: TimeInterval, fileSize: Int64, format: AVAudioFormat) {
        self.url = url
        self.duration = duration
        self.fileSize = fileSize
        self.format = "\(Int(format.sampleRate)) Hz, \(format.channelCount == 1 ? "Mono" : "Stereo")"
        self.sampleRate = format.sampleRate
        self.channelCount = Int(format.channelCount)
        self.createdAt = Date()
    }
    
    var fileSizeString: String {
        let mb = Double(fileSize) / (1024.0 * 1024.0)
        if mb >= 1.0 {
            return String(format: "%.1f MB", mb)
        } else {
            return String(format: "%.2f KB", Double(fileSize) / 1024.0)
        }
    }
}




