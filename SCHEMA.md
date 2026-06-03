# CleoNoteAI — Wiki Schema

## Domain

CleoAI iOS 앱(음성 인식 기반 AI 노트) 개발: 기능 개발, 버그 수정, 릴리스 관리.  
AVFoundation·WhisperKit 기반 STT 파이프라인과 SwiftUI UI가 핵심. 결정권은 로버트에게 있다.

---

## Directory Structure

```
CleoNoteAI/
├── SCHEMA.md          # 이 파일 — 저장소 규칙 기준
├── AGENT.md           # LLM 작업 절차 지시서
├── CleoAI/            # 앱 소스코드
│   ├── App/           # 앱 진입점
│   ├── Core/          # 핵심 비즈니스 로직 (Models, Services, Managers)
│   ├── Features/      # 기능별 View + ViewModel
│   └── Shared/        # 공통 컴포넌트
├── CleoAITests/       # 유닛 테스트
├── Scripts/           # 빌드·릴리스 스크립트
│   └── release.sh     # 릴리스 자동화
├── Doc/               # 개발 문서
├── Documentation/     # 공개 문서
├── altstore-source.json  # SideStore OTA 배포 설정
└── .hermes/           # Hermes Agent 저장 공간 (Git 트래킹)
    ├── SOUL.md
    └── memories/
```

---

## Conventions

- **언어:** Swift 5.0, SwiftUI
- **아키텍처:** MVVM + Service Layer
- **파일명:** PascalCase (Swift 관례)
- **브랜치:** `main` 단일 브랜치 (태그로 버전 관리)
- **버전 형식:** `MAJOR.MINOR.PATCH` (예: `1.0.1`)
- **배포 방식:** SideStore OTA (unsigned IPA, 개발자 계정 불필요)
- **인코딩:** UTF-8

---

## Frontmatter

해당 없음 — 소스코드 저장소로 마크다운 위키 대신 코드·문서 구조로 운영.

릴리스 관련 주요 파일:
```json
// altstore-source.json 핵심 필드
{
  "version": "X.Y.Z",
  "versionDate": "YYYY-MM-DD",
  "downloadURL": "https://github.com/.../releases/download/vX.Y.Z/CleoAI.ipa",
  "size": 0
}
```

---

## Tag Taxonomy

| 태그 | 설명 |
|------|------|
| `STT` | 음성 인식 (WhisperKit) |
| `UI` | SwiftUI View 컴포넌트 |
| `모델` | Core Data·데이터 모델 |
| `서비스` | Service Layer 비즈니스 로직 |
| `릴리스` | 버전 bump·IPA 빌드·배포 |
| `버그` | 버그 수정 |
| `성능` | 성능 최적화 |
| `테스트` | 유닛·UI 테스트 |

---

## Page Thresholds

| 조건 | 액션 |
|------|------|
| 새 기능 설계 | `Doc/` 에 설계 문서 작성 |
| 릴리스 | `altstore-source.json` + GitHub Release + 태그 |
| 주요 아키텍처 변경 | `AGENT.md` 저장소 구조 섹션 업데이트 |

---

## Commit Rules

| 프리픽스 | 대상 | Conventional 등가 |
|---------|------|-----------------|
| `[기능]` | 새 기능 추가 | `feat` |
| `[수정]` | 버그·오류 수정 | `fix` |
| `[개선]` | 리팩토링·성능·UX 향상 | `refactor/improve` |
| `[빌드]` | Scripts/, CI, 빌드 설정, `.hermes/SOUL.md` | `chore/build` |
| `[메모리]` | `.hermes/memories/` 전용 | — |

- **형식:** `[프리픽스] (모듈명) 한국어 명사형 본문`
- **명사형만** — 동사형 금지
- **혼합 커밋 금지** — `[기능]`/`[수정]` + `[빌드]` 분리 필수
- 예: `[기능] (STT) WhisperKit 오프라인 모드 지원`, `[수정] (UI) 노트 목록 스크롤 버그`

---

## Update Policy

1. 코드 변경 전 → 해당 스킬(`ios-app-release`, `ios-sideload-build`) 참조
2. 릴리스 시 → Prerequisite Checks 순서대로 실행 (Xcode 버전, 코드사인, gh auth)
3. `xcodebuild archive` 실패 시 → `xcodebuild build` + 수동 IPA 방식 사용 (`ios-sideload-build` 스킬)
4. 코드사인 인증서 없는 환경 → unsigned IPA 빌드로 대체, 사용자에게 Sideloadly 안내
