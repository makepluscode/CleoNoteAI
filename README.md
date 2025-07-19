# WhisperKit 예제 프로젝트 (WhisperKitEx1)

이 프로젝트는 `WhisperKit` 프레임워크를 사용하여 iOS 앱에서 오디오 파일을 텍스트로 변환하는 간단한 예제입니다.

## 기능

- 앱에 포함된 `test.wav` 오디오 파일을 텍스트로 변환합니다.
- `WhisperKit`의 "tiny" 모델을 사용하여 음성 인식을 수행합니다.
- 변환 과정의 상태(대기, 처리 중, 완료, 오류)를 UI에 표시합니다.

## 요구 사항

- Xcode 15.0 이상
- iOS 17.0 이상
- macOS 14.0 이상

## 설정 및 실행 방법

1.  **저장소 복제 (Clone):**
    ```bash
    git clone <repository-url>
    cd WhisperKitEx1
    ```

2.  **프로젝트 열기:**
    `WhisperKitEx1.xcodeproj` 파일을 Xcode에서 엽니다.

3.  **의존성 설치:**
    Xcode가 자동으로 Swift Package Manager를 통해 `WhisperKit`을 포함한 모든 의존성을 다운로드하고 설정합니다.

4.  **빌드 및 실행:**
    Xcode 상단에서 실행할 시뮬레이터 또는 연결된 iOS 기기를 선택하고, 재생(▶) 버튼을 클릭하여 앱을 빌드하고 실행합니다.

## 사용법

1.  앱이 실행되면 "음성 인식 대기 중..."이라는 텍스트가 표시됩니다.
2.  **"WAV 파일 변환"** 버튼을 탭합니다.
3.  앱이 오디오 파일 처리를 시작하며, 버튼은 "처리 중..."으로 변경되고 비활성화됩니다.
4.  음성 인식이 완료되면, 변환된 텍스트가 화면에 표시됩니다.

## 프로젝트 구조

-   `WhisperKitEx1/ContentView.swift`: 앱의 메인 UI와 음성 인식 로직을 포함하는 핵심 파일입니다.
-   `WhisperKitEx1.xcodeproj`: Xcode 프로젝트 파일입니다.
-   `Resources/`: 음성 인식에 사용될 리소스 파일이 위치합니다. (현재는 코드에서 직접 번들 파일을 참조하고 있습니다.)
-   `ggml-tiny-q8_0.bin`: (현재 코드에서는 사용되지 않음) Whisper 모델 파일입니다.
-   `test.wav`: 음성 인식을 테스트하기 위한 샘플 오디오 파일입니다.
-   `.gitignore`: Git 버전 관리에서 제외할 파일 및 폴더 목록입니다.
-   `README.md`: 프로젝트 설명 파일입니다.

## 기술 스택

-   **언어:** Swift
-   **프레임워크:** SwiftUI
-   **핵심 의존성:** [WhisperKit](https://github.com/argmaxinc/WhisperKit)
