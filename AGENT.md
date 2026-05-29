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
