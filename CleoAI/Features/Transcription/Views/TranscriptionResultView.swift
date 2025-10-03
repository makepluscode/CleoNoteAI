import SwiftUI

struct TranscriptionResultView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    @Binding var showShareSheet: Bool
    @State private var showCreateNoteSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if let result = viewModel.transcriptionResult {
                    Text(result.text)
                        .padding()
                        .foregroundColor(.white)
                    
                    // Metadata and Actions
                    HStack(alignment: .center, spacing: 8) {
                        Text(result.metadata)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer(minLength: 8)
                        
                        // Action Buttons
                        PressableIconButton(
                            action: { UIPasteboard.general.string = result.text },
                            systemName: "doc.on.doc"
                        )
                        PressableIconButton(
                            action: { showShareSheet = true },
                            systemName: "square.and.arrow.down"
                        )
                        PressableIconButton(
                            action: { showCreateNoteSheet = true },
                            systemName: "note.text.badge.plus"
                        )
                        PressableIconButton(
                            action: { viewModel.clearTranscription() },
                            systemName: "trash"
                        )
                    }
                    .foregroundColor(.accentColor)
                    .padding([.leading, .bottom, .trailing])
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let result = viewModel.transcriptionResult,
               let fileURL = FileUtils.textToTempFile(text: result.text) {
                ActivityView(activityItems: [fileURL])
            }
        }
        .sheet(isPresented: $showCreateNoteSheet) {
            if let result = viewModel.transcriptionResult {
                CreateNoteView(transcriptionResult: result, viewModel: viewModel)
            }
        }
    }
}

struct CreateNoteView: View {
    let transcriptionResult: TranscriptionResult
    @ObservedObject var viewModel: TranscriptionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var noteTitle = ""
    @State private var noteCategory: NoteCategory = .general
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("노트 제목", text: $noteTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Picker("카테고리", selection: $noteCategory) {
                    ForEach(NoteCategory.allCases, id: \.self) { category in
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }
                        .tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Text("내용 미리보기")
                    .font(.headline)
                
                ScrollView {
                    Text(transcriptionResult.text)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(AppConstants.cornerRadius)
                }
                .frame(maxHeight: 200)
                
                Spacer()
            }
            .padding()
            .navigationTitle("노트 생성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("생성") {
                        createNote()
                    }
                    .disabled(noteTitle.isEmpty || isCreating)
                }
            }
        }
    }
    
    private func createNote() {
        isCreating = true
        
        Task {
            let note = await viewModel.createNote(from: transcriptionResult)
            let finalNote = Note(
                title: noteTitle.isEmpty ? note.title : noteTitle,
                content: note.content,
                summary: note.summary,
                keywords: note.keywords,
                category: noteCategory,
                transcriptionResult: note.transcriptionResult
            )
            
            // Save note logic would go here
            dismiss()
        }
    }
}




