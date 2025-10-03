import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: note.category.icon)
                                .foregroundColor(.accentColor)
                            Text(note.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(note.createdAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(note.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(AppConstants.cornerRadius)
                    
                    // Summary
                    if let summary = note.summary {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("요약")
                                .font(.headline)
                            Text(summary)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(AppConstants.cornerRadius)
                    }
                    
                    // Keywords
                    if !note.keywords.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("키워드")
                                .font(.headline)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(note.keywords, id: \.self) { keyword in
                                    Text(keyword)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.2))
                                        .foregroundColor(.accentColor)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(AppConstants.cornerRadius)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("내용")
                            .font(.headline)
                        Text(note.content)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(AppConstants.cornerRadius)
                    
                    // Transcription Metadata
                    if let transcriptionResult = note.transcriptionResult {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("전사 정보")
                                .font(.headline)
                            Text(transcriptionResult.metadata)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(AppConstants.cornerRadius)
                    }
                }
                .padding()
            }
            .navigationTitle("노트 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button(action: { /* TODO: Edit note */ }) {
                            Image(systemName: "pencil")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let fileURL = FileUtils.textToTempFile(text: note.content) {
                    ActivityView(activityItems: [fileURL])
                }
            }
        }
    }
}




