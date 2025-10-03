import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("노트 검색...", text: $viewModel.searchText)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(AppConstants.cornerRadius)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button("전체") {
                                viewModel.clearCategoryFilter()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedCategory == nil ? Color.accentColor : Color.gray.opacity(0.2))
                            .foregroundColor(viewModel.selectedCategory == nil ? .white : .primary)
                            .cornerRadius(16)
                            
                            ForEach(NoteCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    viewModel.selectedCategory = category
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(viewModel.selectedCategory == category ? Color.accentColor : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                
                // Notes List
                if viewModel.filteredNotes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "note.text")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("노트가 없습니다")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("음성 인식으로 첫 번째 노트를 만들어보세요")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.filteredNotes) { note in
                        NoteRowView(note: note) {
                            viewModel.selectNote(note)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("노트")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingNoteDetail) {
                if let note = viewModel.selectedNote {
                    NoteDetailView(note: note, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showingSettings) {
                Text("설정 화면")
                    .navigationTitle("설정")
            }
        }
    }
}

struct NoteRowView: View {
    let note: Note
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: note.category.icon)
                        .foregroundColor(.accentColor)
                    Text(note.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(note.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let summary = note.summary {
                    Text(summary)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if !note.keywords.isEmpty {
                    HStack {
                        ForEach(note.keywords.prefix(3), id: \.self) { keyword in
                            Text(keyword)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.2))
                                .foregroundColor(.accentColor)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}




