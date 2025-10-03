# CleoAI 아키텍처 문서

## 📋 개요

CleoAI는 MVVM 패턴과 Service Layer를 기반으로 한 모듈화된 iOS 애플리케이션입니다. 음성 인식, 노트 관리, AI 요약 등의 기능을 제공합니다.

## 🏗️ 아키텍처 패턴

### MVVM (Model-View-ViewModel)
- **Model**: 데이터 구조와 비즈니스 로직
- **View**: SwiftUI 기반 사용자 인터페이스
- **ViewModel**: View와 Model 간의 데이터 바인딩 및 상태 관리

### Service Layer
- **AudioRecordingService**: 오디오 녹음 관련 기능
- **TranscriptionService**: 음성 인식 처리
- **NoteSummarizationService**: AI 기반 노트 요약

## 📁 프로젝트 구조

```
CleoAI/
├── App/                           # 앱 진입점
│   └── CleoAIApp.swift           # @main 앱 구조체
├── Core/                          # 핵심 비즈니스 로직
│   ├── Models/                    # 데이터 모델
│   │   ├── TranscriptionResult.swift
│   │   ├── AudioRecording.swift
│   │   └── Note.swift
│   ├── Services/                  # 서비스 레이어
│   │   ├── AudioRecordingService.swift
│   │   ├── TranscriptionService.swift
│   │   └── NoteSummarizationService.swift
│   └── Utils/                     # 유틸리티
│       ├── AudioUtils.swift
│       └── FileUtils.swift
├── Features/                      # 기능별 모듈
│   ├── Recording/                 # 녹음 기능
│   │   ├── ViewModels/
│   │   │   └── RecordingViewModel.swift
│   │   └── Views/
│   │       └── RecordingView.swift
│   ├── Transcription/             # 음성 인식
│   │   ├── ViewModels/
│   │   │   └── TranscriptionViewModel.swift
│   │   └── Views/
│   │       ├── TranscriptionResultView.swift
│   │       └── TranscriptionSettingsView.swift
│   └── Notes/                     # 노트 관리
│       ├── ViewModels/
│       │   └── NotesViewModel.swift
│       └── Views/
│           ├── NotesListView.swift
│           └── NoteDetailView.swift
├── Shared/                        # 공통 컴포넌트
│   ├── Components/                # 재사용 가능한 UI 컴포넌트
│   │   ├── TopBarView.swift
│   │   ├── BottomBarView.swift
│   │   ├── LanguagePickerView.swift
│   │   ├── PressableIconButton.swift
│   │   └── ActivityView.swift
│   ├── Extensions/                # 확장 기능
│   └── Constants/                 # 상수 정의
│       └── AppConstants.swift
└── Resources/                     # 리소스 파일
    └── Assets.xcassets
```

## 🔄 데이터 흐름

### 1. 녹음 프로세스
```
User Action → RecordingViewModel → AudioRecordingService → AVAudioEngine
```

### 2. 음성 인식 프로세스
```
AudioRecording → TranscriptionViewModel → TranscriptionService → WhisperKit
```

### 3. 노트 생성 프로세스
```
TranscriptionResult → TranscriptionViewModel → NoteSummarizationService → Note
```

## 🧩 주요 컴포넌트

### Models

#### TranscriptionResult
```swift
struct TranscriptionResult: Identifiable, Codable {
    let id = UUID()
    let text: String
    let language: String
    let model: String
    let audioDuration: TimeInterval
    let processingTime: TimeInterval
    let wordCount: Int
    let createdAt: Date
}
```

#### AudioRecording
```swift
struct AudioRecording: Identifiable {
    let id = UUID()
    let url: URL
    let duration: TimeInterval
    let fileSize: Int64
    let format: String
    let sampleRate: Double
    let channelCount: Int
    let createdAt: Date
}
```

#### Note
```swift
struct Note: Identifiable, Codable {
    let id = UUID()
    let title: String
    let content: String
    let summary: String?
    let keywords: [String]
    let category: NoteCategory
    let transcriptionResult: TranscriptionResult?
    let createdAt: Date
    let updatedAt: Date
}
```

### Services

#### AudioRecordingService
- AVAudioEngine을 사용한 실시간 오디오 녹음
- 오디오 레벨 모니터링
- 녹음 상태 관리

#### TranscriptionService
- WhisperKit을 사용한 음성 인식
- 진행 상황 표시
- 에러 처리

#### NoteSummarizationService
- AI 기반 텍스트 요약
- 키워드 추출
- 카테고리 분류

### ViewModels

#### RecordingViewModel
- 녹음 상태 관리
- 오디오 레벨 및 시간 추적
- 에러 처리

#### TranscriptionViewModel
- 음성 인식 프로세스 관리
- 결과 처리 및 노트 생성
- 설정 관리

#### NotesViewModel
- 노트 목록 관리
- 검색 및 필터링
- CRUD 작업

## 🔧 의존성 관리

### Swift Package Manager
- **WhisperKit**: 음성 인식 엔진
- 버전: release/v0.13.0

### 내부 의존성
- Combine 프레임워크: 반응형 프로그래밍
- AVFoundation: 오디오 처리
- SwiftUI: 사용자 인터페이스

## 🎯 설계 원칙

### 1. 단일 책임 원칙 (SRP)
- 각 클래스는 하나의 책임만 가짐
- 기능별로 명확히 분리

### 2. 의존성 역전 원칙 (DIP)
- Service Layer를 통한 의존성 주입
- 인터페이스 기반 설계

### 3. 개방-폐쇄 원칙 (OCP)
- 확장에는 열려있고 수정에는 닫혀있음
- 새로운 기능 추가 시 기존 코드 수정 최소화

### 4. 인터페이스 분리 원칙 (ISP)
- 클라이언트는 사용하지 않는 인터페이스에 의존하지 않음
- 작고 집중된 인터페이스 설계

## 🚀 확장성

### 새로운 기능 추가
1. `Features/` 폴더에 새로운 모듈 생성
2. 필요한 Model, Service, ViewModel, View 구현
3. 기존 코드 수정 없이 기능 확장

### 새로운 서비스 추가
1. `Core/Services/` 폴더에 서비스 클래스 생성
2. 필요한 의존성 주입
3. ViewModel에서 서비스 사용

## 🔒 보안 고려사항

### 데이터 보호
- 마이크 권한 요청 및 관리
- 로컬 파일 시스템 사용
- 민감한 데이터 암호화 (필요시)

### 메모리 관리
- Weak reference 사용으로 순환 참조 방지
- 적절한 메모리 해제
- 백그라운드 처리 시 메모리 최적화

## 📊 성능 최적화

### 메모리 최적화
- 이미지 및 오디오 파일 캐싱
- 불필요한 객체 생성 방지
- 메모리 사용량 모니터링

### CPU 최적화
- 백그라운드 큐에서 무거운 작업 처리
- UI 업데이트는 메인 큐에서 처리
- 적절한 스레드 관리

### 네트워크 최적화
- 모델 다운로드 최적화
- 캐싱 전략 구현
- 오프라인 지원

## 🧪 테스트 전략

### 단위 테스트
- Service Layer 테스트
- ViewModel 로직 테스트
- Utility 함수 테스트

### 통합 테스트
- 전체 워크플로우 테스트
- API 통합 테스트
- 데이터 흐름 테스트

### UI 테스트
- 사용자 시나리오 테스트
- 접근성 테스트
- 다양한 기기 테스트

## 📈 모니터링 및 로깅

### 로깅 전략
- 구조화된 로그 메시지
- 로그 레벨 관리
- 민감한 정보 제외

### 성능 모니터링
- 앱 시작 시간 측정
- 메모리 사용량 추적
- 사용자 행동 분석

## 🔄 마이그레이션 전략

### 버전 업그레이드
- 데이터 모델 버전 관리
- 하위 호환성 유지
- 점진적 마이그레이션

### 의존성 업데이트
- 정기적인 의존성 업데이트
- 호환성 테스트
- 롤백 계획 수립




