import Foundation
import Combine

@MainActor
class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var selectedNote: Note?
    @Published var searchText = ""
    @Published var selectedCategory: NoteCategory?
    @Published var isShowingNoteDetail = false
    
    private var allNotes: [Note] = []
    
    init() {
        loadNotes()
    }
    
    var filteredNotes: [Note] {
        var filtered = allNotes
        
        if !searchText.isEmpty {
            filtered = filtered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.keywords.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    func loadNotes() {
        notes = FileUtils.loadNotesFromFiles()
        allNotes = notes
    }
    
    func saveNote(_ note: Note) {
        if let fileURL = FileUtils.saveNoteToFile(note) {
            print("Note saved to: \(fileURL.path)")
            loadNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        // TODO: Implement note deletion
        loadNotes()
    }
    
    func selectNote(_ note: Note) {
        selectedNote = note
        isShowingNoteDetail = true
    }
    
    func clearSelection() {
        selectedNote = nil
        isShowingNoteDetail = false
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    func clearCategoryFilter() {
        selectedCategory = nil
    }
}




