# CleoAI — 에이전트 지시서

## 개요

이 저장소는 **CleoAI** iOS 앱(음성 인식 기반 AI 노트)의 개발 워크스페이스다.
**Hermes Agent** (cleoai 프로파일)가 개발을 보조한다.

## 저장소 구조

```
CleoNoteAI/
├── AGENT.md           # 이 파일 — 에이전트 지시서
├── CleoAI/            # 앱 소스코드
│   ├── App/
│   ├── Core/
│   ├── Features/
│   └── Shared/
├── Scripts/           # 빌드·릴리스 스크립트
├── altstore-source.json
└── .hermes/           # Hermes Agent 저장 공간 (Git 트래킹)
    ├── SOUL.md
    └── memories/
```

## 기술 스택

| 항목 | 내용 |
|------|------|
| 언어 | Swift 5.0 |
| UI | SwiftUI |
| 아키텍처 | MVVM + Service Layer |
| 음성 인식 | WhisperKit |
| 배포 | SideStore OTA |

## 릴리스 워크플로

```bash
./Scripts/release.sh patch   # 1.0.0 → 1.0.1
./Scripts/release.sh minor   # 1.0.0 → 1.1.0
./Scripts/release.sh major   # 1.0.0 → 2.0.0
```

---

## Hermes Agent 연동

이 저장소는 **Hermes Agent** (cleoai 프로파일)와 연결되어 있다.

```
Hermes 프로파일: cleoai
게이트웨이 봇: @cleonoteai_bot (Telegram)
모델: deepseek-v4-flash
```

### .hermes/ 디렉토리

`.hermes/` 는 Hermes Agent의 저장 공간이며 Git으로 트래킹된다.

```
.hermes/
├── SOUL.md           # 에이전트 페르소나 (시스템 프롬프트)
└── memories/
    ├── MEMORY.md     # 에이전트 장기 메모리
    └── USER.md       # 사용자 프로필 메모리
```

- **SOUL.md**: 에이전트의 역할·도메인·개발 규칙. 매 세션 로드된다.
- **MEMORY.md**: 에이전트가 누적하는 개발 지식. Git push로 영속화된다.
- **USER.md**: 사용자 선호·컨텍스트. Git push로 영속화된다.

이 파일들을 수정하면 다음 대화부터 즉시 반영된다. 재시작 불필요.

## Git 커밋 규칙 (Dev 타입)

### 프리픽스

| 프리픽스 | 대상 | conventional 대응 |
|---------|------|-------------------|
| `[기능]` | 새 기능 추가 | feat |
| `[수정]` | 버그·오류 수정 | fix |
| `[개선]` | 리팩토링·성능·UX 향상 | refactor/improve |
| `[하네스]` | `Scripts/`, CI, 빌드 설정, `AGENT.md` | chore/build |
| `[메모리]` | `.hermes/` 전용 | — |

### 형식

```
[프리픽스] 모듈명 한국어 명사형 본문
```

모듈명은 선택. 어느 영역인지 명확할 때 붙임.

### 규칙

- 명사형만 — 동사형 금지 (추가한다 X, 수정한다 X)
- 한국어 필수 — Swift·Python·기술 용어는 영어 유지
- 혼합 커밋 금지 — [기능]/[수정]/[개선] + [하네스] 분리 필수
- 에이전트는 초안 제시 → 사용자 승인 후 실행

### 예시

```
[기능] Recording 마이크 권한 처리 추가
[기능] WhisperKit medium 모델 선택 옵션
[수정] Transcription 백그라운드 크래시
[수정] ch03 MuJoCo 뷰어 인수 파싱 오류
[개선] Notes 검색 인덱싱 성능 향상
[개선] SO-ARM101 MJCF 예제 구조 정리
[하네스] release.sh 버전 자동 증가 로직
[하네스] Xcode 15 빌드 설정 업데이트
[메모리] CleoAI WhisperKit 모델 선택 기록
```
