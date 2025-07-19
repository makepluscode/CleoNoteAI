// SwiftUI 프레임워크를 가져옵니다. UI 요소를 만드는 데 사용됩니다.
import SwiftUI
// WhisperKit 프레임워크를 가져옵니다. 음성 인식을 위해 필요합니다.
import WhisperKit

// 앱의 메인 화면을 정의하는 SwiftUI 뷰입니다.
struct ContentView: View {
    // @State 프로퍼티 래퍼는 뷰의 상태를 저장하고, 값이 변경되면 뷰를 자동으로 업데이트합니다.
    
    // 음성 인식 결과를 저장할 문자열 변수입니다. 초기값은 "음성 인식 중..."입니다.
    @State private var transcript: String = "음성 인식 대기 중..."
    // 음성 인식 처리 중인지 여부를 나타내는 불리언 변수입니다.
    @State private var isProcessing = false

    // MARK: - Body
    
    // 뷰의 본문을 정의합니다. 화면에 표시될 내용을 구성합니다.
    var body: some View {
        // 자식 뷰들을 수직으로 배열하는 컨테이너입니다. spacing은 뷰 사이의 간격입니다.
        VStack(spacing: 20) {
            // 음성 인식 결과를 표시하는 텍스트 뷰입니다.
            Text(transcript)
                // 텍스트를 여러 줄로 표시할 때 가운데 정렬합니다.
                .multilineTextAlignment(.center)
                // 뷰 주위에 여백을 추가합니다.
                .padding()

            // "Transcribe WAV" 버튼입니다. 탭하면 transcribe 함수를 호출합니다.
            Button(action: transcribe) {
                // 버튼의 텍스트입니다. isProcessing 상태에 따라 "처리 중..." 또는 "WAV 파일 변환"으로 표시됩니다.
                Text(isProcessing ? "처리 중..." : "WAV 파일 변환")
                    // 텍스트 주위에 여백을 추가합니다.
                    .padding()
                    // 배경색을 설정합니다. isProcessing 상태에 따라 회색 또는 파란색으로 변경됩니다.
                    .background(isProcessing ? Color.gray : Color.blue)
                    // 전경색(텍스트 색상)을 흰색으로 설정합니다.
                    .foregroundColor(.white)
                    // 모서리를 둥글게 만듭니다.
                    .cornerRadius(10)
            }
            // isProcessing이 true일 때 버튼을 비활성화합니다.
            .disabled(isProcessing)
        }
        // VStack 전체에 여백을 추가합니다.
        .padding()
    }

    // MARK: - Transcription
    
    /// "test.wav" 오디오 파일의 음성을 텍스트로 변환하는 함수입니다.
    private func transcribe() {
        // 처리 중 상태를 true로 설정하여 UI를 업데이트합니다.
        isProcessing = true
        
        // 비동기 작업을 수행하기 위해 Task를 생성합니다.
        Task {
            // 메인 스레드에서 UI를 업데이트하기 위해 @MainActor를 사용합니다.
            await MainActor.run {
                // 음성 인식 시작 메시지를 표시합니다.
                transcript = "음성 인식을 시작합니다..."
            }
            
            do {
                // 앱 번들에서 "test.wav" 파일의 URL을 가져옵니다. 파일이 없으면 오류를 처리합니다.
                guard let audioURL = Bundle.main.url(forResource: "test", withExtension: "wav") else {
                    // 파일이 없을 경우 UI에 오류 메시지를 표시합니다.
                    await MainActor.run {
                        transcript = "오디오 파일을 찾을 수 없습니다."
                        isProcessing = false
                    }
                    return
                }

                // WhisperKit를 "tiny" 모델로 초기화합니다. 모델은 필요시 다운로드됩니다.
                let whisper = try await WhisperKit(model: "tiny")

                // 오디오 파일의 음성을 텍스트로 변환합니다.
                // transcribe 함수는 여러 개의 TranscriptionResult 객체를 배열로 반환합니다.
                let result = try await whisper.transcribe(audioPath: audioURL.path)
                
                // 변환된 텍스트 조각들을 하나의 문자열로 합칩니다.
                let fullText = result.map(\.text).joined()

                // 메인 스레드에서 UI를 업데이트합니다.
                await MainActor.run {
                    // 변환된 전체 텍스트를 화면에 표시합니다.
                    transcript = fullText
                }
            } catch {
                // 오류가 발생하면 메인 스레드에서 UI에 오류 메시지를 표시합니다.
                await MainActor.run {
                    transcript = "오류 발생: \(error.localizedDescription)"
                }
            }
            
            // 처리가 완료되면 메인 스레드에서 isProcessing 상태를 false로 설정하여 UI를 업데이트합니다.
            await MainActor.run {
                isProcessing = false
            }
        }
    }
}
