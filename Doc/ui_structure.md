# UI 구조 다이어그램

아래는 현재 SwiftUI 화면의 파일별 구조와 의존성입니다.

```mermaid
flowchart TD
    A[ContentView.swift]
    A --> B[TopBarView.swift]
    A --> C[BottomBarView.swift]
    C --> D[LanguagePickerView.swift]
    A --> H[RecordingStatusView (ContentView.swift)]
    A --> I[TranscriptionResultView (ContentView.swift)]
    A --> E[TranscriptionViewModel.swift]
    A --> F[Assets.xcassets/AccentColor]
    A --> G[Assets.xcassets/AppIcon]

    subgraph UI
      B
      C
      D
      H
      I
    end
    subgraph Logic
      E
    end
    subgraph Resources
      F
      G
    end
```
