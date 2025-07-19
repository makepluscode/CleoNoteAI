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
            HStack(spacing: 8) {
                Text(selectedLanguage)
                    .foregroundColor(.blue)
                    .font(.body)
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundColor(.blue)
                    .font(.body)
            }
        }
    }
} 