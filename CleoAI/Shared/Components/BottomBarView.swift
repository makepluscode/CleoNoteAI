import SwiftUI

struct BottomBarView: View {
    @State private var isSettingsPresented = false
    @Binding var isTranscribing: Bool
    @Binding var isRecording: Bool
    var onTranscription: () -> Void
    @Binding var selectedLanguage: String
    let languages: [String]
    @Binding var selectedModelName: String
    let models: [String]

    var body: some View {
        VStack {
            // Language Picker
            HStack {
                LanguagePickerView(selectedLanguage: $selectedLanguage, languages: languages)
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 10)

            // Main Controls
            HStack {
                // Notes Button (placeholder for future implementation)
                Button(action: {}) {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .disabled(true)

                Spacer()

                // Record Button
                Button(action: onTranscription) {
                    if isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.accentColor)
                            .frame(width: AppConstants.buttonSize, height: AppConstants.buttonSize)
                    } else {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: AppConstants.buttonSize, height: AppConstants.buttonSize)
                    }
                }
                .disabled(isTranscribing)

                Spacer()

                // Settings Button
                Button(action: {
                    isSettingsPresented = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .sheet(isPresented: $isSettingsPresented) {
                    TranscriptionSettingsView(
                        selectedModelName: $selectedModelName,
                        selectedLanguage: $selectedLanguage
                    )
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }
}




