import SwiftUI

struct BottomBarView: View {
    @Binding var isTranscribing: Bool
    var onTranscription: () -> Void
    @Binding var selectedLanguage: String
    let languages: [String]

    var body: some View {
        VStack {
            HStack {
                LanguagePickerView(selectedLanguage: $selectedLanguage, languages: languages)
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 10)

            HStack {
                Button(action: {}) {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(true)

                Spacer()

                Button(action: {
                    if !isTranscribing {
                        onTranscription()
                    }
                }) {
                    if isTranscribing {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.red)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "stop.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                            )
                    } else {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 32, height: 32)
                    }
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(true)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }
} 