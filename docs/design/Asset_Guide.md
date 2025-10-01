# 물먹자 투게더 - 에셋 가이드

## 📋 문서 개요
- **문서명**: Asset Guide
- **생성일**: 2025-01-27
- **버전**: 1.0
- **목적**: 게이미피케이션 중심의 무료 에셋 활용 가이드

---

## 🎯 에셋 전략

### 핵심 원칙
- **무료 우선**: 상업적 사용 가능한 무료 에셋 활용
- **게이미피케이션 중심**: 물 마시기 습관을 재미있게 만드는 요소
- **Flutter 최적화**: Flutter 앱에 최적화된 형식 사용
- **확장성**: 향후 고급 에셋으로 업그레이드 가능한 구조

### 에셋 우선순위
1. **Phase 1**: Flutter 기본 아이콘 + 이모티콘 (즉시 구현)
2. **Phase 2**: 무료 이미지 + Lottie 애니메이션 (1-2주 후)
3. **Phase 3**: 고급 에셋 + AI 생성 (1개월 후)

---

## 🎨 에셋 종류별 사용법

### 1. 이미지 에셋

#### 식물 이미지 (핵심 게이미피케이션)
```
assets/images/plants/
├── seed_001/               # 기본 씨앗
│   ├── stage_0.png        # 🌱 씨앗
│   ├── stage_1.png        # 🌿 줄기
│   ├── stage_2.png        # 🌸 꽃
│   └── stage_3.png        # 🌰 열매
├── seed_002/               # 튤립
└── seed_003/               # 민들레
```

**게이미피케이션 포인트:**
- 각 성장 단계마다 **시각적으로 뚜렷한 변화**
- 성장할 때마다 **색상이 더 화려해짐**
- 완성된 식물은 **반짝이는 효과** 추가

#### UI 요소 이미지
```
assets/images/ui/
├── plant_pot.png          # 화분 이미지
├── water_drop.png         # 물방울 아이콘
├── inventory_bag.png      # 인벤토리 가방
├── book_icon.png          # 도감 책 아이콘
└── progress_bar.png       # 진행률 바
```

#### 버튼과 인터랙션
```
assets/images/ui/buttons/
├── water_record_button.png    # 물 기록 버튼
├── plant_seed_button.png      # 씨앗 심기 버튼
├── friend_add_button.png      # 친구 추가 버튼
└── share_button.png           # 공유 버튼
```

### 2. 애니메이션 에셋

#### Lottie 애니메이션 (핵심 피드백)
```
assets/animations/
├── water_drop.json        # 물 기록 시 물방울 효과
├── plant_growth.json      # 식물 성장 애니메이션
├── seed_planting.json     # 씨앗 심기 애니메이션
├── goal_achievement.json  # 목표 달성 축하
├── level_up.json          # 레벨업 효과
└── friend_notification.json # 친구 활동 알림
```

**게이미피케이션 포인트:**
- 물 기록 시 **물방울이 튀는 효과**
- 식물 성장 시 **빛나는 성장 애니메이션**
- 목표 달성 시 **축하 폭죽 효과**

### 3. 효과음 에셋

#### 게임적 효과음
```
assets/sounds/
├── water_drop.wav         # 물 기록 효과음
├── plant_growth.wav       # 식물 성장 효과음
├── seed_planting.wav      # 씨앗 심기 효과음
├── goal_achievement.wav    # 목표 달성 효과음
├── button_click.wav       # 버튼 클릭 효과음
├── level_up.wav           # 레벨업 효과음
└── friend_notification.wav # 친구 활동 알림음
```

### 4. 아이콘 에셋

#### Flutter 기본 아이콘 활용
```dart
// 물 관련 아이콘
Icons.water_drop           # 물방울
Icons.local_drink          # 물컵
Icons.water                # 물

// 식물 관련 아이콘
Icons.eco                  # 생태
Icons.agriculture          # 농업
Icons.park                 # 공원

// UI 관련 아이콘
Icons.home                 # 홈
Icons.dashboard            # 대시보드
Icons.people               # 친구
Icons.settings             # 설정
```

---

## 🌐 에셋 소스

### 무료 이미지 사이트

#### 1. Unsplash (https://unsplash.com/)
- **특징**: 고품질 무료 사진
- **용도**: 식물, 자연 사진
- **라이선스**: 상업적 사용 가능
- **추천 검색어**: "plant", "water", "garden", "nature"

#### 2. Pixabay (https://pixabay.com/)
- **특징**: 무료 이미지/일러스트
- **용도**: PNG, SVG 형식 지원
- **라이선스**: 저작권 걱정 없음
- **추천 검색어**: "water drop", "plant growth", "garden"

#### 3. Freepik (https://freepik.com/)
- **특징**: 고품질 일러스트
- **용도**: 게임 스타일 이미지
- **라이선스**: 무료 계정으로 일일 다운로드
- **추천 검색어**: "game ui", "plant game", "water game"

### 무료 아이콘 사이트

#### 1. Flaticon (https://flaticon.com/)
- **특징**: 무료 아이콘 대량 보유
- **용도**: PNG, SVG 형식
- **라이선스**: 일일 다운로드 제한
- **추천 검색어**: "water", "plant", "game"

#### 2. Feather Icons (https://feathericons.com/)
- **특징**: 미니멀한 아이콘
- **용도**: SVG 형식
- **라이선스**: 완전 무료
- **추천**: Flutter와 잘 어울림

#### 3. Material Icons (https://fonts.google.com/icons)
- **특징**: Google Material Design
- **용도**: Flutter와 완벽 호환
- **라이선스**: 완전 무료
- **추천**: Flutter 기본 아이콘

### 무료 애니메이션 사이트

#### 1. LottieFiles (https://lottiefiles.com/)
- **특징**: 무료 Lottie 애니메이션
- **용도**: 물방울, 성장 효과
- **라이선스**: 상업적 사용 가능
- **추천 검색어**: "water", "growth", "celebration"

#### 2. Lordicon (https://lordicon.com/)
- **특징**: 무료 애니메이션 아이콘
- **용도**: 고품질 애니메이션
- **라이선스**: 일일 다운로드 제한
- **추천 검색어**: "water drop", "plant", "success"

### 무료 효과음 사이트

#### 1. Freesound (https://freesound.org/)
- **특징**: 무료 효과음 대량 보유
- **용도**: 물방울, 자연음
- **라이선스**: CC 라이선스
- **추천 검색어**: "water drop", "plant", "success"

#### 2. Zapsplat (https://zapsplat.com/)
- **특징**: 고품질 효과음
- **용도**: 게임 효과음
- **라이선스**: 무료 계정으로 다운로드
- **추천 검색어**: "water", "plant", "game"

---

## 💻 에셋 적용 예시

### 1. Flutter 기본 아이콘 사용
```dart
// 물 기록 버튼
IconButton(
  icon: Icon(Icons.water_drop, color: Colors.blue),
  onPressed: () => _recordWater(),
)

// 식물 상태 표시
Icon(Icons.eco, color: Colors.green, size: 50)

// 네비게이션 아이콘
BottomNavigationBarItem(
  icon: Icon(Icons.home),
  label: '홈',
)
```

### 2. 이미지 에셋 사용
```dart
// 식물 이미지 표시
Image.asset(
  'assets/images/plants/seed_001/stage_${plant.stage}.png',
  width: 100,
  height: 100,
)

// UI 요소 이미지
Image.asset(
  'assets/images/ui/plant_pot.png',
  width: 200,
  height: 200,
)
```

### 3. Lottie 애니메이션 사용
```dart
// 물방울 애니메이션
Lottie.asset(
  'assets/animations/water_drop.json',
  width: 100,
  height: 100,
)

// 식물 성장 애니메이션
Lottie.asset(
  'assets/animations/plant_growth.json',
  width: 150,
  height: 150,
)
```

### 4. 효과음 사용
```dart
// 효과음 재생
AudioPlayer().play(AssetSource('sounds/water_drop.wav'))

// 식물 성장 효과음
AudioPlayer().play(AssetSource('sounds/plant_growth.wav'))
```

---

## 🚀 구현 단계별 가이드

### Phase 1: 즉시 구현 (무료)
1. **Flutter 기본 아이콘** 활용
2. **이모티콘** 활용 (이미 구현됨)
3. **Unsplash**에서 무료 식물 사진 다운로드
4. **LottieFiles**에서 무료 애니메이션 다운로드

### Phase 2: 품질 향상 (1-2주 후)
1. **Freepik** 크레딧 구매 (월 $10)
2. **Zapsplat** 프리미엄 구독 (월 $20)
3. **LottieFiles** 프리미엄 구독 (월 $15)

### Phase 3: 고급 에셋 (1개월 후)
1. **Midjourney** 구독으로 고품질 이미지 생성 (월 $10)
2. **Runway ML**로 애니메이션 생성 (월 $15)
3. **DALL-E 3**로 특별한 이미지 생성

---

## 📝 라이선스 정보

### 사용 가능한 라이선스
- **CC0**: 완전 무료, 상업적 사용 가능
- **CC BY**: 저작자 표시 필요
- **CC BY-SA**: 저작자 표시 + 동일 조건
- **MIT**: 오픈소스 라이선스
- **Apache 2.0**: 오픈소스 라이선스

### 주의사항
- 다운로드 시 라이선스 확인 필수
- 상업적 사용 가능 여부 확인
- 저작자 표시 필요 시 크레딧 추가
- 라이선스 변경 시 재확인 필요

---

## 🔗 관련 문서
- [File Structure Guide](./File_Structure_Guide.md) - 파일 구조 및 설정 가이드
- [UI Design Guide](./UI_Design_Guide.md) - UI 디자인 가이드
- [Tech Spec](../development/TechSpec.md) - 기술 사양서

---

*문서 생성일: 2025-01-27*  
*마지막 업데이트: 2025-01-27 - pubspec.yaml 패키지 버전 최신화 반영*  
*다음 검토 예정일: 2025-02-27*
