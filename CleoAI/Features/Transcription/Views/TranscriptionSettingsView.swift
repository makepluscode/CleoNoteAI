import SwiftUI

struct TranscriptionSettingsView: View {
    @Binding var selectedModelName: String
    @Binding var selectedLanguage: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Model Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("모델 선택")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(AppConstants.availableModels, id: \.self) { model in
                        Button(action: {
                            selectedModelName = model
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(model.capitalized)
                                        .font(.title3)
                                        .foregroundColor(model == selectedModelName ? .accentColor : .primary)
                                    
                                    Text("\(AppConstants.modelSizeMB(for: model)) MB")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if model == selectedModelName {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                    .fill(model == selectedModelName ? Color.accentColor.opacity(0.15) : Color.clear)
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                Divider()
                
                // Language Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("언어 선택")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(AppConstants.availableLanguages, id: \.self) { language in
                        Button(action: {
                            selectedLanguage = language
                        }) {
                            HStack {
                                Text(language)
                                    .font(.title3)
                                    .foregroundColor(language == selectedLanguage ? .accentColor : .primary)
                                
                                Spacer()
                                
                                if language == selectedLanguage {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                    .fill(language == selectedLanguage ? Color.accentColor.opacity(0.15) : Color.clear)
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                Spacer()
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}




