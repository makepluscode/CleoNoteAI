import Foundation

struct FileUtils {
    
    static func textToTempFile(text: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let dateString = formatter.string(from: Date())
        let fileURL = tempDir.appendingPathComponent("trans-\(dateString).txt")
        
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
    
    static func saveNoteToFile(_ note: Note) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "note-\(note.id.uuidString).json"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            let data = try JSONEncoder().encode(note)
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    static func loadNotesFromFiles() -> [Note] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            let noteFiles = fileURLs.filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix("note-") }
            
            var notes: [Note] = []
            for fileURL in noteFiles {
                if let data = try? Data(contentsOf: fileURL),
                   let note = try? JSONDecoder().decode(Note.self, from: data) {
                    notes.append(note)
                }
            }
            
            return notes.sorted { $0.createdAt > $1.createdAt }
        } catch {
            return []
        }
    }
}




