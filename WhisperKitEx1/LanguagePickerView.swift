import SwiftUI

struct LanguagePickerView: View {
    @Binding var selectedLanguage: String
    let languages: [String]

    var body: some View {
        Menu {
            ForEach(languages, id: \.self) { lang in
                Button(lang) { selectedLanguage = lang }
            }
        } label: {
            Text(selectedLanguage)
                .foregroundColor(.blue)
                .font(.body)
        }
    }
} 