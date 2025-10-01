# 물먹자 투게더 - 문서 기반 수정 우선순위 Task List

## 📋 문서 개요
- **문서명**: Document-Based Priority Fix Task List
- **생성일**: 2025-01-27
- **버전**: 1.0
- **목적**: 문서 요구사항과 현재 코드 차이점 분석 및 수정 우선순위 가이드

---

## 🎯 현재 상황 분석

### 📊 완성도 평가
| 기능 영역 | 문서 요구사항 | 현재 구현도 | 우선순위 |
|-----------|---------------|--------------|----------|
| 네비게이션 | 100% | 75% | 🔴 높음 |
| 튜토리얼 | 100% | 0% | 🔴 높음 |
| 도감 시스템 | 100% | 20% | 🔴 높음 |
| 친구 시스템 | 100% | 60% | 🟠 중간 |
| 인벤토리 | 100% | 70% | 🟠 중간 |
| 홈 화면 | 100% | 80% | 🟠 중간 |
| 애니메이션 | 100% | 10% | 🟡 낮음 |
| 효과음 | 100% | 0% | 🟡 낮음 |

**전체 완성도: 약 40%** (문서 요구사항 대비)

---

## 🔴 Week 1: 핵심 구조 수정 (높은 우선순위)

### Day 1: 네비게이션 구조 변경

#### Task 1.1: 하단 네비게이션 수정
**목표**: 설정 탭 제거, 도감 탭 추가

**파일 수정**:
- `lib/screens/main_screen.dart`

**구체적 작업**:
```dart
// 기존 코드 (라인 45-62)
items: const [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
  BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '대시보드'),
  BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구·랭킹'),
  BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'), // 제거
],

// 수정 후 코드
items: const [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
  BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '대시보드'),
  BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구·랭킹'),
  BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark), label: '도감'), // 추가
],
```

**탭 전환 로직 수정**:
```dart
// 기존 코드 (라인 17-22)
final List<Widget> _screens = [
  const HomeScreen(),
  const DashboardScreen(),
  const FriendsRankingScreen(),
  const SettingsScreen(), // 제거
];

// 수정 후 코드
final List<Widget> _screens = [
  const HomeScreen(),
  const DashboardScreen(),
  const FriendsRankingScreen(),
  const CollectionScreen(), // 추가
];
```

**✅ 확인사항**:
1. 하단 네비게이션에서 설정 탭이 제거되었는지 확인
2. 도감 탭이 추가되었는지 확인
3. 도감 탭 클릭 시 CollectionScreen이 표시되는지 확인

#### Task 1.2: 홈 화면 상단 네비게이션에 설정 아이콘 추가
**목표**: 설정을 상단 네비게이션으로 이동

**파일 수정**:
- `lib/screens/home_screen.dart`

**구체적 작업**:
```dart
// 기존 AppBar 수정 (라인 12-40)
AppBar(
  title: Consumer<WaterProvider>(
    builder: (context, waterProvider, child) {
      return Text(
        waterProvider.currentUser?.nickname ?? '물먹자 투게더',
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    },
  ),
  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  actions: [
    Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              '${waterProvider.todayWaterIntake}ml / ${waterProvider.dailyGoal}ml',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    ),
    // 설정 아이콘 추가
    IconButton(
      onPressed: () => _showSettings(context),
      icon: const Icon(Icons.settings),
    ),
  ],
),
```

**설정 화면 표시 메서드 추가**:
```dart
// 파일 하단에 추가
void _showSettings(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SettingsScreen(),
    ),
  );
}
```

**✅ 확인사항**:
1. 홈 화면 상단에 설정 아이콘이 표시되는지 확인
2. 설정 아이콘 클릭 시 설정 화면이 표시되는지 확인

### Day 2: 도감 시스템 기본 구현

#### Task 2.1: CollectionScreen 생성
**목표**: 기본 도감 화면 구현

**파일 생성**:
- `lib/screens/collection_screen.dart`

**구체적 작업**:
```dart
import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도감'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.collections_bookmark, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '도감 기능을 구현 중입니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '곧 수집한 식물들을 확인할 수 있어요!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

**✅ 확인사항**:
1. CollectionScreen 파일이 생성되었는지 확인
2. 도감 탭 클릭 시 기본 화면이 표시되는지 확인

#### Task 2.2: main_screen.dart에 CollectionScreen import 추가
**목표**: CollectionScreen을 main_screen에서 사용할 수 있도록 import

**파일 수정**:
- `lib/screens/main_screen.dart`

**구체적 작업**:
```dart
// 기존 import에 추가 (라인 1-7)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'friends_ranking_screen.dart';
import 'settings_screen.dart';
import 'collection_screen.dart'; // 추가
```

**✅ 확인사항**:
1. import 에러가 없는지 확인
2. 앱이 정상 실행되는지 확인

### Day 3: 튜토리얼 시스템 구현 (참고: Task_List_3.md)

#### Task 3.1: 튜토리얼 시스템 간략 구현
**목표**: 기본 튜토리얼 오버레이 구현

**참고 문서**: `docs/development/Task_List_3.md` (Day 1-2 섹션)

**파일 생성**:
- `lib/widgets/tutorial_overlay.dart`
- `lib/services/tutorial_service.dart`

**간략 구현**:
```dart
// lib/widgets/tutorial_overlay.dart
import 'package:flutter/material.dart';

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int currentStep = 0;
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (isVisible && currentStep < 2)
          _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    final steps = [
      '물 기록 버튼 💧',
      '씨앗 심기 🌱',
    ];
    
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                steps[currentStep],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                currentStep == 0 
                  ? '한모금 버튼을 눌러 기록하는 방법 안내'
                  : '인벤토리에서 씨앗 선택 후 심기 버튼 안내',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextStep,
                child: Text(currentStep == 1 ? '완료' : '다음'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (currentStep < 1) {
      setState(() {
        currentStep++;
      });
    } else {
      setState(() {
        isVisible = false;
      });
      widget.onComplete?.call();
    }
  }
}
```

**✅ 확인사항**:
1. 튜토리얼 오버레이가 표시되는지 확인
2. 2단계 튜토리얼이 순서대로 진행되는지 확인
3. 완료 후 오버레이가 사라지는지 확인

#### Task 3.2: 홈 화면에 튜토리얼 통합
**목표**: 홈 화면에 튜토리얼 오버레이 적용

**파일 수정**:
- `lib/screens/home_screen.dart`

**구체적 작업**:
```dart
// HomeScreen을 StatefulWidget으로 변경
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showWelcomeMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... 기존 AppBar 코드 ...
      body: TutorialOverlay(
        onComplete: () {
          setState(() {
            showWelcomeMessage = true;
          });
          
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                showWelcomeMessage = false;
              });
            }
          });
        },
        child: Stack(
          children: [
            // 기존 body 내용
            Consumer<WaterProvider>(
              builder: (context, waterProvider, child) {
                return SingleChildScrollView(
                  // ... 기존 코드 ...
                );
              },
            ),
            // 웰컴 메시지
            if (showWelcomeMessage)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '같이 마셔요',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '이제 물 마시기 습관을 시작해보세요!',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

**✅ 확인사항**:
1. 홈 화면에서 튜토리얼이 정상 작동하는지 확인
2. 튜토리얼 완료 후 "같이 마셔요" 웰컴 메시지가 표시되는지 확인
3. 웰컴 메시지가 3초 후 자동으로 사라지는지 확인

---

## 🟠 Week 2: 도감 시스템 완성 (중간 우선순위)

### Day 4: 도감 화면 상세 구현

#### Task 4.1: PlantGridWidget 생성
**목표**: 식물 그리드 위젯 구현

**파일 생성**:
- `lib/widgets/plant_grid_widget.dart`

**구체적 작업**:
```dart
import 'package:flutter/material.dart';

class PlantGridWidget extends StatelessWidget {
  const PlantGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 식물 데이터
    final plants = [
      {'id': 'plant_001', 'name': '기본 식물', 'collected': true, 'image': '🌱'},
      {'id': 'plant_002', 'name': '튤립', 'collected': true, 'image': '🌷'},
      {'id': 'plant_003', 'name': '민들레', 'collected': false, 'image': '🌼'},
      {'id': 'plant_004', 'name': '해바라기', 'collected': true, 'image': '🌻'},
      {'id': 'plant_005', 'name': '장미', 'collected': false, 'image': '🌹'},
      {'id': 'plant_006', 'name': '벚꽃', 'collected': false, 'image': '🌸'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 도감 완성도 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '도감 완성도',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: plants.where((p) => p['collected'] == true).length / plants.length,
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Text(
                  '${plants.where((p) => p['collected'] == true).length}/${plants.length} 수집 완료',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 식물 그리드
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                final isCollected = plant['collected'] as bool;
                
                return GestureDetector(
                  onTap: () {
                    if (isCollected) {
                      _showPlantDetail(context, plant);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCollected 
                          ? Theme.of(context).colorScheme.surface
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCollected 
                            ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isCollected ? plant['image'] as String : '?',
                          style: TextStyle(
                            fontSize: 32,
                            color: isCollected ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isCollected ? plant['name'] as String : '미발견',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCollected ? null : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPlantDetail(BuildContext context, Map<String, dynamic> plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plant['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              plant['image'] as String,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              '이 식물은 물을 주면 성장합니다.\n충분한 물을 주어 완전히 키워보세요!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
```

**✅ 확인사항**:
1. 식물 그리드가 정상 표시되는지 확인
2. 수집된 식물과 미수집 식물이 구분되어 표시되는지 확인
3. 식물 클릭 시 상세 정보가 표시되는지 확인

#### Task 4.2: CollectionScreen에 PlantGridWidget 적용
**목표**: CollectionScreen에 PlantGridWidget 통합

**파일 수정**:
- `lib/screens/collection_screen.dart`

**구체적 작업**:
```dart
import 'package:flutter/material.dart';
import '../widgets/plant_grid_widget.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도감'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const PlantGridWidget(),
    );
  }
}
```

**✅ 확인사항**:
1. 도감 화면에 식물 그리드가 표시되는지 확인
2. 도감 완성도가 정상 계산되어 표시되는지 확인

### Day 5: 인벤토리 팝업 시스템 개선

#### Task 5.1: InventoryPopup 위젯 생성
**목표**: 개선된 인벤토리 팝업 구현

**파일 생성**:
- `lib/widgets/inventory_popup.dart`

**구체적 작업**:
```dart
import 'package:flutter/material.dart';

class InventoryPopup extends StatelessWidget {
  final List<Map<String, dynamic>> seeds;

  const InventoryPopup({
    super.key,
    required this.seeds,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '인벤토리',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 씨앗 그리드
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: seeds.length,
                itemBuilder: (context, index) {
                  final seed = seeds[index];
                  return GestureDetector(
                    onTap: () => _showSeedDetail(context, seed),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            seed['image'],
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            seed['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${seed['quantity']}개',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSeedDetail(BuildContext context, Map<String, dynamic> seed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(seed['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              seed['image'],
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(seed['description']),
            const SizedBox(height: 16),
            Text('보유 수량: ${seed['quantity']}개'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 인벤토리 팝업도 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${seed['name']}을(를) 심었습니다!')),
              );
            },
            child: const Text('심기'),
          ),
        ],
      ),
    );
  }
}
```

**✅ 확인사항**:
1. 인벤토리 팝업이 정상 표시되는지 확인
2. 씨앗 클릭 시 상세 정보가 표시되는지 확인
3. 심기 버튼이 정상 작동하는지 확인

#### Task 5.2: 홈 화면 인벤토리 버튼 수정
**목표**: 홈 화면의 인벤토리 버튼을 새로운 팝업과 연동

**파일 수정**:
- `lib/screens/home_screen.dart`

**구체적 작업**:
```dart
// 기존 _showInventoryDialog 메서드 수정 (라인 283-331)
void _showInventoryDialog(BuildContext context) {
  // 임시 씨앗 데이터
  final seeds = [
    {
      'id': 'seed_001',
      'name': '기본 씨앗',
      'image': '🌱',
      'quantity': 3,
      'description': '기본적인 식물 씨앗입니다.',
    },
    {
      'id': 'seed_002',
      'name': '튤립 씨앗',
      'image': '🌷',
      'quantity': 1,
      'description': '아름다운 튤립 씨앗입니다.',
    },
    {
      'id': 'seed_003',
      'name': '민들레 씨앗',
      'image': '🌼',
      'quantity': 2,
      'description': '노란 민들레 씨앗입니다.',
    },
  ];

  showDialog(
    context: context,
    builder: (context) => InventoryPopup(seeds: seeds),
  );
}
```

**import 추가**:
```dart
// 파일 상단에 추가
import '../widgets/inventory_popup.dart';
```

**✅ 확인사항**:
1. 인벤토리 버튼 클릭 시 새로운 팝업이 표시되는지 확인
2. 씨앗 미리보기 기능이 정상 작동하는지 확인

---

## 🟡 Week 3: 친구 시스템 강화 (중간 우선순위)

### Day 6: 친구 초대 시스템 구현

#### Task 6.1: InviteDialog 위젯 생성
**목표**: 친구 초대 다이얼로그 구현

**파일 생성**:
- `lib/widgets/invite_dialog.dart`

**구체적 작업**:
```dart
import 'package:flutter/material.dart';

class InviteDialog extends StatelessWidget {
  const InviteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('친구 초대'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            '친구를 초대하고 함께 물 마시기를 시작해보세요!',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '친구가 가입하면 랜덤 씨앗을 받을 수 있어요!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => _shareInviteLink(context),
          child: const Text('초대하기'),
        ),
      ],
    );
  }

  void _shareInviteLink(BuildContext context) {
    const inviteMessage = '''
물먹자 투게더에 초대합니다! 🌱

하루 물 섭취 습관을 재미있게 형성해보세요!
식물을 키우고 친구와 함께 목표를 달성해보세요.

다운로드: https://watertogether.app
''';

    // 공유 기능 (실제로는 share_plus 패키지 사용)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('초대 링크가 복사되었습니다!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }
}
```

**✅ 확인사항**:
1. 친구 초대 다이얼로그가 정상 표시되는지 확인
2. 초대하기 버튼 클릭 시 스낵바가 표시되는지 확인

#### Task 6.2: 홈 화면에 친구 초대 버튼 추가
**목표**: 홈 화면에 친구 초대 기능 추가

**파일 수정**:
- `lib/screens/home_screen.dart`

**구체적 작업**:
```dart
// 기존 인벤토리 및 도감 접근 부분 수정 (라인 177-202)
Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _showInventoryDialog(context),
        icon: const Icon(Icons.inventory),
        label: const Text('인벤토리'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _showCollectionDialog(context),
        icon: const Text('📖', style: TextStyle(fontSize: 18)),
        label: const Text('도감'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ),
  ],
),

const SizedBox(height: 16),

// 친구 초대 버튼 추가
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () => _showInviteDialog(context),
    icon: const Icon(Icons.share),
    label: const Text('친구 초대'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
  ),
),
```

**초대 다이얼로그 표시 메서드 추가**:
```dart
// 파일 하단에 추가
void _showInviteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const InviteDialog(),
  );
}
```

**import 추가**:
```dart
// 파일 상단에 추가
import '../widgets/invite_dialog.dart';
```

**✅ 확인사항**:
1. 친구 초대 버튼이 홈 화면에 표시되는지 확인
2. 친구 초대 버튼 클릭 시 다이얼로그가 표시되는지 확인

---

## 🟢 Week 4: 사용자 경험 개선 (낮은 우선순위)

### Day 7: 애니메이션 시스템 준비

#### Task 7.1: pubspec.yaml에 애니메이션 패키지 추가
**목표**: Lottie 애니메이션 패키지 추가

**파일 수정**:
- `water_together/pubspec.yaml`

**구체적 작업**:
```yaml
# dependencies 섹션에 추가
dependencies:
  flutter:
    sdk: flutter
  
  # 기존 패키지들...
  
  # 애니메이션
  lottie: ^2.7.0
  
  # 효과음
  audioplayers: ^5.2.1
```

**패키지 설치**:
```bash
cd /Users/eldrac/Desktop/water/water_together
flutter pub get
```

**✅ 확인사항**:
1. 패키지가 정상 설치되었는지 확인
2. 앱이 정상 실행되는지 확인

#### Task 7.2: 기본 애니메이션 위젯 생성
**목표**: 기본 애니메이션 위젯 구조 생성

**파일 생성**:
- `lib/widgets/water_drop_animation.dart`

**구체적 작업**:
```dart
import 'package:flutter/material.dart';

class WaterDropAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const WaterDropAnimation({
    super.key,
    this.onComplete,
  });

  @override
  State<WaterDropAnimation> createState() => _WaterDropAnimationState();
}

class _WaterDropAnimationState extends State<WaterDropAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _animation.value,
            child: Opacity(
              opacity: 1.0 - _animation.value,
              child: const Text(
                '💧',
                style: TextStyle(fontSize: 64),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

**✅ 확인사항**:
1. 애니메이션 위젯이 정상 생성되었는지 확인
2. 애니메이션이 정상 작동하는지 확인

### Day 8: 효과음 시스템 준비

#### Task 8.1: AudioService 생성
**목표**: 효과음 재생 서비스 구현

**파일 생성**:
- `lib/services/audio_service.dart`

**구체적 작업**:
```dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // 물 기록 효과음
  Future<void> playWaterDropSound() async {
    try {
      // 실제로는 assets/sounds/water_drop.wav 파일 사용
      // await _audioPlayer.play(AssetSource('sounds/water_drop.wav'));
      
      // 임시로 시스템 사운드 사용
      print('💧 물 기록 효과음 재생');
    } catch (e) {
      print('효과음 재생 실패: $e');
    }
  }

  // 식물 성장 효과음
  Future<void> playPlantGrowthSound() async {
    try {
      // await _audioPlayer.play(AssetSource('sounds/plant_growth.wav'));
      print('🌱 식물 성장 효과음 재생');
    } catch (e) {
      print('효과음 재생 실패: $e');
    }
  }

  // 목표 달성 효과음
  Future<void> playGoalAchievementSound() async {
    try {
      // await _audioPlayer.play(AssetSource('sounds/goal_achievement.wav'));
      print('🎉 목표 달성 효과음 재생');
    } catch (e) {
      print('효과음 재생 실패: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
```

**✅ 확인사항**:
1. AudioService가 정상 생성되었는지 확인
2. 효과음 재생 메서드가 정상 작동하는지 확인

---

## 📋 전체 작업 체크리스트

### Week 1 체크리스트
- [ ] 하단 네비게이션에서 설정 탭 제거
- [ ] 하단 네비게이션에 도감 탭 추가
- [ ] 홈 화면 상단에 설정 아이콘 추가
- [ ] CollectionScreen 기본 구현
- [ ] TutorialOverlay 기본 구현
- [ ] 홈 화면에 튜토리얼 통합
- [ ] 웰컴 메시지 구현

### Week 2 체크리스트
- [ ] PlantGridWidget 구현
- [ ] CollectionScreen에 PlantGridWidget 적용
- [ ] InventoryPopup 위젯 구현
- [ ] 홈 화면 인벤토리 버튼 수정
- [ ] 씨앗 상세 정보 팝업 구현

### Week 3 체크리스트
- [ ] InviteDialog 위젯 구현
- [ ] 홈 화면에 친구 초대 버튼 추가
- [ ] 친구 초대 공유 기능 구현
- [ ] 초대 보상 시스템 준비

### Week 4 체크리스트
- [ ] pubspec.yaml에 애니메이션 패키지 추가
- [ ] WaterDropAnimation 위젯 구현
- [ ] AudioService 구현
- [ ] 기본 효과음 시스템 준비

---

## 🎯 성공 기준

### Week 1 완료 기준
- [ ] 네비게이션 구조가 문서 요구사항과 일치
- [ ] 튜토리얼 시스템이 정상 작동
- [ ] 도감 화면이 기본적으로 표시됨

### Week 2 완료 기준
- [ ] 도감 시스템이 완전히 구현됨
- [ ] 인벤토리 팝업이 개선됨
- [ ] 씨앗 미리보기 기능이 작동함

### Week 3 완료 기준
- [ ] 친구 초대 시스템이 구현됨
- [ ] 공유 기능이 작동함
- [ ] 초대 보상 시스템이 준비됨

### Week 4 완료 기준
- [ ] 애니메이션 시스템이 준비됨
- [ ] 효과음 시스템이 준비됨
- [ ] 향후 확장을 위한 기반이 마련됨

---

## 📞 문제 해결 가이드

### 자주 발생하는 에러
1. **import 에러**: 파일 경로 확인
2. **컴파일 에러**: `flutter pub get` 실행
3. **위젯 에러**: Scaffold, MaterialApp 확인
4. **상태 관리 에러**: Provider 사용법 확인

### 유용한 명령어
```bash
# 앱 실행
flutter run

# 패키지 설치
flutter pub get

# 빌드 정리
flutter clean

# 의존성 확인
flutter doctor
```

### 질문할 때 포함할 내용
1. **에러 메시지**: 정확한 에러 메시지 복사
2. **코드**: 문제가 발생한 코드 부분
3. **단계**: 어떤 Task에서 문제가 발생했는지
4. **시도한 해결법**: 이미 시도해본 해결 방법

---

## 📚 참고 문서

- **튜토리얼 시스템 상세 구현**: `docs/development/Task_List_3.md` (Day 1-2 섹션)
- **파일 구조 가이드**: `docs/design/File_Structure_Guide.md`
- **UI 디자인 가이드**: `docs/design/UI_Design_Guide.md`
- **기술 사양서**: `docs/development/TechSpec.md`

---

*문서 생성일: 2025-01-27*  
*마지막 업데이트: 문서 기반 수정 우선순위 Task List 완성*  
*다음 검토 예정일: 2025-02-03*


