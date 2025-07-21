import SwiftUI

struct BottomBarView: View {
    @State private var isModelMenuPresented = false
    @Binding var isTranscribing: Bool
    @Binding var isRecording: Bool
    var onTranscription: () -> Void
    @Binding var selectedLanguage: String
    let languages: [String]
    @Binding var selectedModelName: String
    let models: [String]

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
                        .foregroundColor(.gray)
                }
                .disabled(true)

                Spacer()

                Button(action: {
                    onTranscription()
                }) {
                    if isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.accentColor)
                            .frame(width: 32, height: 32)
                    } else {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 32, height: 32)
                    }
                }

                Spacer()

                Button(action: {
                    isModelMenuPresented = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .actionSheet(isPresented: $isModelMenuPresented) {
                    ActionSheet(
                        title: Text("모델 선택"),
                        buttons: models.map { model in
                            .default(Text(model + (model == selectedModelName ? " ✅" : ""))) {
                                selectedModelName = model
                            }
                        } + [.cancel()]
                    )
                }
                .onTapGesture {
                    isModelMenuPresented = true
                }
                .disabled(false)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }
}