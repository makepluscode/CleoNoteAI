sequenceDiagram
    participant User
    participant ContentView
    participant WhisperKit
    participant MainActor

    User->>ContentView: "WAV 파일 변환" 버튼 탭
    ContentView->>ContentView: transcribe() 함수 호출
    ContentView->>MainActor: isProcessing = true (UI 업데이트)
    ContentView->>MainActor: transcript = "음성 인식을 시작합니다..." (UI 업데이트)

    alt 오디오 파일 로드
        ContentView->>Bundle: "test.wav" 파일 URL 요청
        alt 파일 로드 성공
            Bundle-->>ContentView: audioURL 반환
        else 파일 로드 실패
            Bundle-->>ContentView: nil 반환
            ContentView->>MainActor: transcript = "오디오 파일을 찾을 수 없습니다." (UI 업데이트)
            ContentView->>MainActor: isProcessing = false (UI 업데이트)
        end
    end

    ContentView->>WhisperKit: WhisperKit(model: "tiny") 초기화
    Note right of WhisperKit: 필요시 "tiny" 모델 다운로드
    WhisperKit-->>ContentView: whisper 인스턴스 반환

    ContentView->>WhisperKit: transcribe(audioPath: audioURL.path) 호출
    WhisperKit-->>ContentView: [TranscriptionResult] 배열 반환

    ContentView->>ContentView: 결과 텍스트 가공 (map & joined)
    ContentView->>MainActor: transcript = "변환된 전체 텍스트" (UI 업데이트)

    ContentView->>MainActor: isProcessing = false (UI 업데이트)
