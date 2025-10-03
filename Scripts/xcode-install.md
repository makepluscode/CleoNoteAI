# Xcode를 통한 직접 설치 방법

## 📱 USB 연결 아이폰에 직접 설치하기

### 1. Xcode에서 프로젝트 열기
```bash
open CleoAI.xcodeproj
```

### 2. 디바이스 설정
1. Xcode 상단에서 **디바이스 선택** 드롭다운 클릭
2. 연결된 iPhone 선택 (예: "BGiness")
3. **Trust This Computer** 팝업이 나타나면 "Trust" 선택

### 3. 개발자 계정 설정
1. Xcode → Preferences → Accounts
2. Apple ID 추가 (무료 계정도 가능)
3. 프로젝트 설정에서 Team 선택

### 4. 빌드 및 실행
1. **⌘ + R** 또는 재생 버튼 클릭
2. Xcode가 자동으로 빌드하고 아이폰에 설치
3. 아이폰에서 앱 실행

### 5. 코드 서명 설정 (필요시)
- Project Navigator에서 "CleoAI" 프로젝트 선택
- "Signing & Capabilities" 탭
- "Automatically manage signing" 체크
- Team 선택

## ⚠️ 주의사항

### 무료 개발자 계정의 경우:
- 앱이 7일 후 만료됨
- 최대 3개의 앱만 설치 가능
- 앱 아이콘에 "Untrusted Developer" 표시

### 유료 개발자 계정의 경우:
- 앱이 1년간 유효
- 무제한 앱 설치
- App Store 배포 가능

## 🔧 문제 해결

### "Untrusted Developer" 오류:
1. iPhone 설정 → 일반 → VPN 및 기기 관리
2. 개발자 앱 섹션에서 신뢰할 수 있는 개발자 선택
3. "신뢰" 버튼 클릭

### 빌드 오류:
1. Product → Clean Build Folder (⌘ + Shift + K)
2. DerivedData 폴더 삭제
3. 다시 빌드 시도



