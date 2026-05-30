# CleoAI

CleoAI는 음성 인식(STT)과 AI 기반 노트 요약 기능을 제공하는 iOS 애플리케이션입니다.

## 🚀 주요 기능

- **실시간 음성 녹음**: 고품질 오디오 녹음 및 실시간 레벨 미터
- **음성 인식**: WhisperKit을 활용한 정확한 음성-텍스트 변환
- **AI 노트 요약**: 전사 결과를 자동으로 요약하고 키워드 추출
- **노트 관리**: 카테고리별 노트 분류 및 검색 기능
- **다국어 지원**: 한국어, 영어 지원
- **다양한 모델**: tiny, base, small, medium, large 모델 선택 가능

## 🏗️ 아키텍처

### 모듈 구조
```
CleoAI/
├── App/                    # 앱 진입점
├── Core/                   # 핵심 비즈니스 로직
│   ├── Models/            # 데이터 모델
│   ├── Services/          # 서비스 레이어
│   └── Utils/             # 유틸리티 함수
├── Features/              # 기능별 모듈
│   ├── Recording/         # 녹음 기능
│   ├── Transcription/     # 음성 인식
│   └── Notes/             # 노트 관리
├── Shared/                # 공통 컴포넌트
│   ├── Components/        # 재사용 가능한 UI 컴포넌트
│   ├── Extensions/        # 확장 기능
│   └── Constants/         # 상수 정의
└── Resources/             # 리소스 파일
```

### 기술 스택
- **언어**: Swift 5.0
- **UI 프레임워크**: SwiftUI
- **아키텍처**: MVVM + Service Layer
- **음성 인식**: WhisperKit
- **오디오 처리**: AVFoundation

## 📋 요구사항

- Xcode 15.0 이상
- iOS 18.5 이상
- macOS 14.0 이상

## 📲 SideStore OTA 설치 (추천)

SideStore를 통해 iPhone에서 직접 OTA로 설치하고 업데이트할 수 있습니다.

### 1. SideStore Source 추가
iPhone의 SideStore 앱에서:
1. **Sources** 탭 → **+** 버튼
2. 아래 URL 입력:
   ```
   https://raw.githubusercontent.com/makepluscode/CleoNoteAI/main/altstore-source.json
   ```
3. **Add** 버튼 탭

### 2. 앱 설치
1. **Browse** 탭에서 **CleoAI** 검색
2. **FREE** (또는 가격 표시) 버튼 탭
3. Apple ID로 로그인하여 서명
4. 앱이 자동으로 설치됨

### 3. 업데이트
SideStore가 백그라운드에서 자동으로 앱 만료를 갱신하고,
새 버전이 릴리스되면 SideStore에서 업데이트 알림을 보여줍니다.

### 릴리스 스크립트로 새 버전 배포
```bash
# 로컬 Mac에서 실행 (Apple 개발자 인증서 필요)
./Scripts/release.sh patch   # 패치 버전 업 (1.0.0 → 1.0.1)
./Scripts/release.sh minor   # 마이너 버전 업 (1.0.0 → 1.1.0)
./Scripts/release.sh major   # 메이저 버전 업 (1.0.0 → 2.0.0)
```
스크립트가 자동으로:
- 버전 번호 증가
- IPA 빌드
- Git 태그 + GitHub Release 생성
- SideStore source.json 업데이트

## 🛠️ 설치 및 실행

### 1. 저장소 클론
```bash
git clone <repository-url>
cd CleoNoteAI
```

### 2. Xcode에서 프로젝트 열기
```bash
open CleoAI.xcodeproj
```

### 3. 의존성 설치
Xcode가 자동으로 Swift Package Manager를 통해 WhisperKit을 다운로드하고 설정합니다.

### 4. 빌드 및 실행
Xcode에서 시뮬레이터 또는 실제 기기를 선택하고 실행합니다.

## 🔧 CLI 빌드

### 빌드 스크립트 사용
```bash
# Debug 빌드 (시뮬레이터)
./Scripts/build.sh debug simulator

# Release 빌드 (디바이스)
./Scripts/build.sh release device
```

### 배포 스크립트 사용
```bash
# 아카이브 생성
./Scripts/deploy.sh archive

# IPA 내보내기
./Scripts/deploy.sh export
```

## 📱 사용법

### 1. 음성 녹음
- 앱 실행 후 중앙의 원형 버튼을 탭하여 녹음 시작
- 실시간으로 오디오 레벨과 녹음 시간 확인
- 다시 탭하여 녹음 중지

### 2. 음성 인식
- 녹음 중지 후 자동으로 음성 인식 시작
- 선택한 모델과 언어로 텍스트 변환
- 진행 상황을 실시간으로 확인

### 3. 노트 생성
- 전사 결과에서 "노트 생성" 버튼 탭
- 제목과 카테고리 설정
- AI가 자동으로 요약과 키워드 생성

### 4. 노트 관리
- 노트 목록에서 검색 및 필터링
- 카테고리별 노트 분류
- 노트 상세 보기 및 공유

## ⚙️ 설정

### 모델 선택
- 설정 버튼을 통해 WhisperKit 모델 선택
- 모델 크기에 따른 정확도와 속도 트레이드오프 고려

### 언어 설정
- 한국어/영어 선택 가능
- 선택한 언어에 맞는 최적화된 인식

## 🔒 권한

앱은 다음 권한을 요청합니다:
- **마이크 접근**: 음성 녹음을 위해 필요

## 🧪 테스트

### 단위 테스트
```bash
xcodebuild test -project CleoAI.xcodeproj -scheme CleoAI -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI 테스트
```bash
xcodebuild test -project CleoAI.xcodeproj -scheme CleoAI -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CleoAIUITests
```

## 📈 성능 최적화

- **메모리 관리**: 적절한 메모리 해제 및 weak reference 사용
- **백그라운드 처리**: 음성 인식을 백그라운드에서 처리
- **캐싱**: 모델 및 결과 캐싱으로 성능 향상

## 🤝 기여하기

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 지원

문제가 발생하거나 기능 요청이 있으시면 GitHub Issues를 통해 알려주세요.

---

**CleoAI** - 음성으로 시작하는 스마트한 노트 관리