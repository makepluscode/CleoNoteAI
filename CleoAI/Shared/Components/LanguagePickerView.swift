import SwiftUI

struct LanguagePickerView: View {
    @Binding var selectedLanguage: String
    let languages: [String]

    var body: some View {
        Menu {
            ForEach(languages, id: \.self) { language in
                Button(language) { 
                    selectedLanguage = language 
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(selectedLanguage)
                    .foregroundColor(.accentColor)
                    .font(.body)
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundColor(.accentColor)
                    .font(.body)
            }
        }
    }
}




