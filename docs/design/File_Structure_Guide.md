# 물먹자 투게더 - 파일 구조 가이드

## 📋 문서 개요
- **문서명**: File Structure Guide
- **생성일**: 2025-01-27
- **버전**: 1.0
- **목적**: 에셋 파일 구조 및 Flutter 설정 가이드

---

## 📁 에셋 폴더 구조

### 전체 구조
```
water_together/
├── assets/
│   ├── images/
│   │   ├── plants/              # 식물 이미지들
│   │   ├── ui/                  # UI 요소들
│   │   ├── backgrounds/         # 배경 이미지들
│   │   └── effects/             # 효과 이미지들
│   ├── animations/              # Lottie 애니메이션들
│   ├── sounds/                  # 효과음들
│   └── icons/                   # 커스텀 아이콘들
├── lib/
└── pubspec.yaml
```

### 상세 폴더 구조

#### 1. 식물 이미지 (핵심 게이미피케이션)
```
assets/images/plants/
├── seed_001/               # 기본 씨앗
│   ├── stage_0.png        # 🌱 씨앗 (50x50px)
│   ├── stage_1.png        # 🌿 줄기 (50x50px)
│   ├── stage_2.png        # 🌸 꽃 (50x50px)
│   └── stage_3.png        # 🌰 열매 (50x50px)
├── seed_002/               # 튤립
│   ├── stage_0.png
│   ├── stage_1.png
│   ├── stage_2.png
│   └── stage_3.png
├── seed_003/               # 민들레
└── seed_004/               # 해바라기
```

#### 2. UI 요소 이미지
```
assets/images/ui/
├── plant_pot.png          # 화분 이미지 (200x200px)
├── water_drop.png         # 물방울 아이콘 (30x30px)
├── inventory_bag.png      # 인벤토리 가방 (40x40px)
├── book_icon.png          # 도감 책 아이콘 (40x40px)
├── progress_bar.png       # 진행률 바 (300x20px)
└── buttons/
    ├── water_record_button.png    # 물 기록 버튼 (100x50px)
    ├── plant_seed_button.png      # 씨앗 심기 버튼 (100x50px)
    ├── friend_add_button.png      # 친구 추가 버튼 (100x50px)
    └── share_button.png           # 공유 버튼 (100x50px)
```

#### 3. 배경 이미지
```
assets/images/backgrounds/
├── spring_garden.png      # 봄 정원 배경 (1080x1920px)
├── summer_garden.png      # 여름 정원 배경 (1080x1920px)
├── autumn_garden.png      # 가을 정원 배경 (1080x1920px)
└── winter_garden.png      # 겨울 정원 배경 (1080x1920px)
```

#### 4. 효과 이미지
```
assets/images/effects/
├── sparkle.png            # 반짝임 효과 (20x20px)
├── rainbow.png            # 무지개 효과 (100x50px)
├── stars.png              # 별 효과 (30x30px)
├── hearts.png             # 하트 효과 (25x25px)
└── confetti.png           # 색종이 효과 (50x50px)
```

#### 5. 애니메이션 파일
```
assets/animations/
├── water_drop.json        # 물방울 애니메이션
├── plant_growth.json      # 식물 성장 애니메이션
├── seed_planting.json     # 씨앗 심기 애니메이션
├── goal_achievement.json  # 목표 달성 축하
├── level_up.json          # 레벨업 효과
└── friend_notification.json # 친구 활동 알림
```

#### 6. 효과음 파일
```
assets/sounds/
├── water_drop.wav         # 물 기록 효과음 (1-2초)
├── plant_growth.wav       # 식물 성장 효과음 (2-3초)
├── seed_planting.wav      # 씨앗 심기 효과음 (1-2초)
├── goal_achievement.wav    # 목표 달성 효과음 (3-4초)
├── button_click.wav       # 버튼 클릭 효과음 (0.5초)
├── level_up.wav           # 레벨업 효과음 (2-3초)
└── friend_notification.wav # 친구 활동 알림음 (1-2초)
```

#### 7. 커스텀 아이콘
```
assets/icons/
├── water_drop.svg         # 물방울 아이콘
├── plant_growth.svg       # 식물 성장 아이콘
├── friend_add.svg         # 친구 추가 아이콘
└── achievement.svg        # 성취 아이콘
```

---

## ⚙️ pubspec.yaml 설정

### 기본 설정
```yaml
name: water_together
description: "물먹자 투게더 - 하루 물 섭취 습관을 재미있게 형성하도록 돕는 소셜 건강 앱"
version: 1.0.0+1

environment:
  sdk: ^3.5.4

dependencies:
  flutter:
    sdk: flutter
  
  # 상태 관리
  provider: ^6.1.2
  
  # 로컬 저장소
  shared_preferences: ^2.2.3
  
  # 알림
  flutter_local_notifications: ^19.4.2
  timezone: ^0.10.1
  
  # 날짜/시간 처리
  intl: ^0.20.2
  
  # JSON 직렬화
  json_annotation: ^4.9.0
  
  # 딥링크 처리
  uni_links: ^0.5.1
  
  # 공유 기능
  share_plus: ^12.0.0
  
  # 애니메이션
  lottie: ^2.7.0
  
  # 효과음
  audioplayers: ^5.2.1
  
  # 이미지 처리
  cached_network_image: ^3.3.1
  
  # SVG 지원
  flutter_svg: ^2.0.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # JSON 직렬화 코드 생성
  json_serializable: ^6.11.1
  build_runner: ^2.8.0
  
  # 린트 규칙
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
  
  # 에셋 등록
  assets:
    # 식물 이미지들
    - assets/images/plants/
    
    # UI 요소들
    - assets/images/ui/
    - assets/images/ui/buttons/
    
    # 배경 이미지들
    - assets/images/backgrounds/
    
    # 효과 이미지들
    - assets/images/effects/
    
    # 애니메이션들
    - assets/animations/
    
    # 효과음들
    - assets/sounds/
    
    # 커스텀 아이콘들
    - assets/icons/
```

### 패키지 설명
- **flutter_local_notifications**: 로컬 알림 기능
- **timezone**: 시간대 처리
- **intl**: 국제화 및 날짜/시간 포맷팅
- **uni_links**: 딥링크 처리 (향후 app_links로 교체 예정)
- **share_plus**: 공유 기능
- **lottie**: Lottie 애니메이션 지원
- **audioplayers**: 효과음 재생
- **cached_network_image**: 이미지 캐싱
- **flutter_svg**: SVG 아이콘 지원
- **json_serializable**: JSON 직렬화 코드 생성
- **build_runner**: 코드 생성 도구
- **flutter_lints**: 코드 품질 검사

---

## 💻 코드에서 사용법

### 1. 이미지 로드
```dart
// 식물 이미지 표시
Image.asset(
  'assets/images/plants/seed_001/stage_${plant.stage}.png',
  width: 100,
  height: 100,
  fit: BoxFit.contain,
)

// UI 요소 이미지
Image.asset(
  'assets/images/ui/plant_pot.png',
  width: 200,
  height: 200,
)

// 배경 이미지
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/backgrounds/spring_garden.png'),
      fit: BoxFit.cover,
    ),
  ),
)
```

### 2. 애니메이션 사용
```dart
// Lottie 애니메이션
Lottie.asset(
  'assets/animations/water_drop.json',
  width: 100,
  height: 100,
  repeat: true,
  animate: true,
)

// 조건부 애니메이션
if (showGrowthAnimation)
  Lottie.asset(
    'assets/animations/plant_growth.json',
    width: 150,
    height: 150,
    onLoaded: (composition) {
      // 애니메이션 로드 완료 시 처리
    },
  )
```

### 3. 효과음 재생
```dart
// 효과음 재생
AudioPlayer audioPlayer = AudioPlayer();

// 물방울 효과음
await audioPlayer.play(AssetSource('sounds/water_drop.wav'));

// 식물 성장 효과음
await audioPlayer.play(AssetSource('sounds/plant_growth.wav'));

// 목표 달성 효과음
await audioPlayer.play(AssetSource('sounds/goal_achievement.wav'));
```

### 4. SVG 아이콘 사용
```dart
// SVG 아이콘
SvgPicture.asset(
  'assets/icons/water_drop.svg',
  width: 30,
  height: 30,
  color: Colors.blue,
)
```

### 5. 조건부 이미지 로드
```dart
// 식물 성장 단계별 이미지
Widget getPlantImage(Plant plant) {
  return Image.asset(
    'assets/images/plants/${plant.seedId}/stage_${plant.stage}.png',
    width: 100,
    height: 100,
    errorBuilder: (context, error, stackTrace) {
      // 이미지 로드 실패 시 기본 이모티콘 표시
      return Text(
        plant.getStageEmoji(),
        style: TextStyle(fontSize: 50),
      );
    },
  );
}
```

---

## 🚀 성능 최적화

### 1. 이미지 최적화
```dart
// 이미지 캐싱
CachedNetworkImage(
  imageUrl: 'https://example.com/plant.png',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 100,
  memCacheHeight: 100,
)

// 로컬 이미지 최적화
Image.asset(
  'assets/images/plants/seed_001/stage_0.png',
  width: 100,
  height: 100,
  cacheWidth: 100,
  cacheHeight: 100,
)
```

### 2. 메모리 관리
```dart
// 애니메이션 메모리 관리
class PlantGrowthAnimation extends StatefulWidget {
  @override
  _PlantGrowthAnimationState createState() => _PlantGrowthAnimationState();
}

class _PlantGrowthAnimationState extends State<PlantGrowthAnimation> {
  late AnimationController _controller;
  
  @override
  void dispose() {
    _controller.dispose(); // 메모리 해제
    super.dispose();
  }
}
```

### 3. 로딩 최적화
```dart
// 지연 로딩
FutureBuilder<List<String>>(
  future: _loadPlantImages(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return Image.asset(snapshot.data![index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

## 📝 파일 명명 규칙

### 이미지 파일
- **형식**: `{카테고리}_{이름}_{상태}.png`
- **예시**: `plant_tulip_stage_0.png`, `ui_button_water.png`
- **크기**: 최적화된 크기 사용 (50x50px, 100x100px 등)

### 애니메이션 파일
- **형식**: `{기능}_{동작}.json`
- **예시**: `water_drop.json`, `plant_growth.json`
- **크기**: 최적화된 크기 (100x100px 권장)

### 효과음 파일
- **형식**: `{기능}_{동작}.wav`
- **예시**: `water_drop.wav`, `plant_growth.wav`
- **길이**: 1-4초 권장

### SVG 아이콘
- **형식**: `{기능}_{상태}.svg`
- **예시**: `water_drop.svg`, `plant_growth.svg`
- **크기**: 벡터 형식으로 크기 조절 가능

---

## 🔧 개발 도구

### 1. 이미지 최적화 도구
- **TinyPNG**: PNG 압축
- **Squoosh**: Google 이미지 최적화
- **ImageOptim**: macOS 이미지 최적화

### 2. 애니메이션 도구
- **LottieFiles**: Lottie 애니메이션 생성
- **After Effects**: 고급 애니메이션 제작
- **Figma**: 간단한 애니메이션 제작

### 3. 효과음 도구
- **Audacity**: 무료 오디오 편집
- **GarageBand**: macOS 오디오 편집
- **Online Audio Converter**: 형식 변환

---

## 🐛 문제 해결

### 1. 이미지 로드 실패
```dart
// 에러 처리
Image.asset(
  'assets/images/plants/seed_001/stage_0.png',
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.error);
  },
)
```

### 2. 애니메이션 로드 실패
```dart
// Lottie 에러 처리
Lottie.asset(
  'assets/animations/water_drop.json',
  errorBuilder: (context, error, stackTrace) {
    return Text('애니메이션 로드 실패');
  },
)
```

### 3. 효과음 재생 실패
```dart
// 오디오 에러 처리
try {
  await audioPlayer.play(AssetSource('sounds/water_drop.wav'));
} catch (e) {
  print('효과음 재생 실패: $e');
}
```

---

## 🔗 관련 문서
- [Asset Guide](./Asset_Guide.md) - 에셋 사용 가이드
- [UI Design Guide](./UI_Design_Guide.md) - UI 디자인 가이드
- [Tech Spec](../development/TechSpec.md) - 기술 사양서

---

*문서 생성일: 2025-01-27*  
*마지막 업데이트: 2025-01-27 - pubspec.yaml 최신 버전 반영 및 패키지 업데이트*  
*다음 검토 예정일: 2025-02-27*
