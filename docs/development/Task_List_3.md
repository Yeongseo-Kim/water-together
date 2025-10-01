# 물먹자 투게더 - 신입 개발자용 단계별 구현 가이드

## 📋 문서 개요
- **문서명**: Step-by-Step Implementation Guide for Junior Developers
- **생성일**: 2025-01-27
- **버전**: 2.0
- **목적**: 신입 개발자도 쉽게 따라할 수 있는 단계별 기능 구현 가이드

---

## 🎯 개발 시작 전 준비사항

### 필수 지식
- **Flutter 기본**: 위젯, 상태 관리, 네비게이션
- **Dart 언어**: 클래스, 함수, 비동기 처리
- **Provider 패턴**: 상태 관리 기본 개념
- **SharedPreferences**: 로컬 데이터 저장

### 개발 환경 설정
```bash
# 1. Flutter 프로젝트 디렉토리로 이동
cd /Users/eldrac/Desktop/water/water_together

# 2. 패키지 설치
flutter pub get

# 3. 앱 실행 (테스트용)
flutter run
```

### 개발 원칙
- **단계별 구현**: 한 번에 하나씩 기능 구현
- **테스트 우선**: 각 단계마다 앱 실행하여 확인
- **에러 해결**: 컴파일 에러부터 차근차근 해결
- **문서 참조**: 기존 코드와 문서를 참고하여 구현

---

## 🚀 Phase 1: Critical Features (2주) - 신입 개발자 시작 단계

---

## 🔴 Phase 1: Critical Features (즉시 구현 필요) - 2주

### 목표
MVP의 핵심 기능을 완성하여 실제 사용 가능한 앱 만들기

---

## 📚 Day 1-2: 튜토리얼 오버레이 위젯 구현

### Step 1: 튜토리얼 오버레이 기본 구조 만들기

#### 1.1 파일 생성 및 기본 구조
```bash
# 1. 위젯 폴더에 파일 생성
touch lib/widgets/tutorial_overlay.dart
touch lib/widgets/tutorial_step_widget.dart
```

#### 1.2 TutorialOverlay 위젯 기본 코드 작성
```dart
// lib/widgets/tutorial_overlay.dart
import 'package:flutter/material.dart';

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    super.key,
    required this.child,
    required this.steps,
    this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int currentStep = 0;
  bool isVisible = true; // 앱 첫 실행 시 바로 표시

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (isVisible && currentStep < widget.steps.length)
          _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    final step = widget.steps[currentStep];
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                step.description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // UserFlow.md 요구사항: 스킵/재보기 없음 (강제 2단계)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(currentStep == widget.steps.length - 1 ? '완료' : '다음'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (currentStep < widget.steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      _completeTutorial();
    }
  }

  // UserFlow.md 요구사항: 스킵 기능 제거 (강제 2단계 완료)

  void _completeTutorial() {
    setState(() {
      isVisible = false;
    });
    widget.onComplete?.call();
  }
}

// 튜토리얼 단계 모델
class TutorialStep {
  final String title;
  final String description;
  final GlobalKey targetKey;
  final String? imagePath;

  TutorialStep({
    required this.title,
    required this.description,
    required this.targetKey,
    this.imagePath,
  });
}
```

#### 1.3 테스트 방법
```bash
# 앱 실행하여 확인
flutter run
```

**✅ 확인사항**: 
1. 앱이 정상 실행되고 튜토리얼 오버레이가 표시되는지 확인
2. 정확히 2단계만 있는지 확인 (물 기록 버튼 + 씨앗 심기)
3. 스킵 버튼이 없고 "다음" 버튼만 있는지 확인
4. 2단계 완료 후 튜토리얼이 종료되는지 확인

### Step 2: 튜토리얼 단계 위젯 구현

#### 2.1 TutorialStepWidget 구현
```dart
// lib/widgets/tutorial_step_widget.dart
import 'package:flutter/material.dart';

class TutorialStepWidget extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final bool isLastStep;

  const TutorialStepWidget({
    super.key,
    required this.title,
    required this.description,
    this.onNext,
    this.onSkip,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  child: const Text('건너뛰기'),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton(
                onPressed: onNext,
                child: Text(isLastStep ? '완료' : '다음'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### 2.2 테스트 방법
```bash
# 앱 실행하여 확인
flutter run
```

**✅ 확인사항**: 튜토리얼 단계 위젯이 정상 표시되는지 확인

### Step 3: 홈 화면에 튜토리얼 통합

#### 3.1 홈 화면 수정
```dart
// lib/screens/home_screen.dart 수정
// 기존 코드에 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showWelcomeMessage = false;

  // UserFlow.md 요구사항: 정확히 2단계 강제 오버레이 (스킵/재보기 없음)
  final List<TutorialStep> tutorialSteps = [
    TutorialStep(
      title: '물 기록 버튼 💧',
      description: '한모금 버튼을 눌러 기록하는 방법 안내\n한모금, 반컵, 한컵 중에서 선택할 수 있어요.',
      targetKey: GlobalKey(),
    ),
    TutorialStep(
      title: '씨앗 심기 🌱',
      description: '인벤토리에서 씨앗 선택 후 심기 버튼 안내\n씨앗을 클릭하면 미리보기를 볼 수 있어요.',
      targetKey: GlobalKey(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... 기존 코드 ...
      body: TutorialOverlay(
        steps: tutorialSteps,
        onComplete: () {
          // UserFlow.md 요구사항: 튜토리얼 완료 후 홈 화면에 웰컴 메시지 표시
          setState(() {
            showWelcomeMessage = true;
          });
          
          // 3초 후 웰컴 메시지 숨기기
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
            Consumer<WaterProvider>(
              builder: (context, waterProvider, child) {
                return SingleChildScrollView(
                  // ... 기존 코드 ...
                );
              },
            ),
            // UserFlow.md 요구사항: 튜토리얼 완료 후 홈 화면에 웰컴 메시지 표시
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '같이 마셔요',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
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

#### 3.3 테스트 방법
```bash
# 앱 실행하여 확인
flutter run
```

**✅ 확인사항**: 
1. 홈 화면에서 튜토리얼이 정상 작동하는지 확인
2. 정확히 2단계 튜토리얼이 순서대로 진행되는지 확인
3. 튜토리얼 완료 후 "같이 마셔요" 웰컴 메시지가 표시되는지 확인
4. 웰컴 메시지가 3초 후 자동으로 사라지는지 확인

---

## 📚 Day 3-4: 튜토리얼 서비스 구현

### Step 4: 튜토리얼 서비스 기본 구조

#### 4.1 TutorialService 클래스 생성
```dart
// lib/services/tutorial_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';
  
  // 싱글톤 패턴
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();

  // 튜토리얼 완료 여부 확인
  Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  // 튜토리얼 완료 처리
  Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  // 튜토리얼 리셋 (디버그용)
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
  }
}
```

#### 4.2 테스트 방법
```dart
// 테스트 코드 작성
void testTutorialService() async {
  final service = TutorialService();
  
  // 초기 상태 확인
  bool completed = await service.isTutorialCompleted();
  print('튜토리얼 완료 상태: $completed');
  
  // 튜토리얼 완료 처리
  await service.completeTutorial();
  
  // 완료 후 상태 확인
  completed = await service.isTutorialCompleted();
  print('튜토리얼 완료 상태: $completed');
}
```

**✅ 확인사항**: SharedPreferences가 정상 작동하는지 확인

### Step 5: 인벤토리 팝업 시스템 구현

#### 5.1 인벤토리 팝업 위젯 생성
```bash
# 인벤토리 팝업 관련 파일들 생성
touch lib/widgets/inventory_popup.dart
touch lib/widgets/seed_preview_widget.dart
```

#### 5.2 InventoryPopup 구현
```dart
// lib/widgets/inventory_popup.dart
import 'package:flutter/material.dart';
import 'seed_preview_widget.dart';

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
            
            // UserFlow.md 요구사항: 씨앗 목록을 팝업으로 미리보기
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
                  return SeedPreviewWidget(
                    seed: seed,
                    onTap: () => _showSeedDetail(context, seed),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UserFlow.md 요구사항: 씨앗 클릭 시 팝업(이름/설명, 심기 버튼, 미등록이면 '?' 표시)
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
              // UserFlow.md 요구사항: 심기 버튼 클릭 시 새로운 식물 심기
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

#### 5.3 SeedPreviewWidget 구현
```dart
// lib/widgets/seed_preview_widget.dart
import 'package:flutter/material.dart';

class SeedPreviewWidget extends StatelessWidget {
  final Map<String, dynamic> seed;
  final VoidCallback onTap;

  const SeedPreviewWidget({
    super.key,
    required this.seed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
  }
}
```

#### 5.4 홈 화면에 인벤토리 팝업 연동
```dart
// lib/screens/home_screen.dart 수정
// UserFlow.md 요구사항: 우측(중단) 인벤토리 (씨앗 아이콘, 터치 시 "심기" 버튼)

// 인벤토리 버튼 수정
GestureDetector(
  onTap: () => _showInventoryPopup(context),
  child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.green.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        const Icon(Icons.inventory, size: 24, color: Colors.green),
        const SizedBox(height: 4),
        const Text('인벤토리', style: TextStyle(fontSize: 12)),
        Text('${_getSeedCount()}개', style: const TextStyle(fontSize: 10)),
      ],
    ),
  ),
),

// UserFlow.md 요구사항: 인벤토리에서 씨앗 선택 > 팝업에서 씨앗 미리보기
void _showInventoryPopup(BuildContext context) {
  // 임시 씨앗 데이터 (실제로는 WaterProvider에서 가져오기)
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

int _getSeedCount() {
  // 실제로는 WaterProvider에서 가져오기
  return 6; // 임시 값
}
```

#### 5.5 테스트 방법
```bash
# 앱 실행하여 확인
flutter run
```

**✅ 확인사항**: 
1. 인벤토리 버튼 클릭 시 팝업이 나타나는지 확인
2. 씨앗 클릭 시 상세 정보 팝업이 표시되는지 확인 (UserFlow.md 요구사항)
3. 심기 버튼이 정상 작동하는지 확인
4. 튜토리얼 완료 후 "같이 마셔요" 웰컴 메시지가 홈 화면에 표시되는지 확인
5. 인벤토리에서 씨앗 선택 > 팝업에서 씨앗 미리보기 방식이 정상 작동하는지 확인

#### 1.1.2 튜토리얼 서비스 구현
```dart
// 구현할 파일들
lib/services/tutorial_service.dart
lib/models/tutorial_state.dart
```

**기능 요구사항**:
- 튜토리얼 완료 상태 관리
- SharedPreferences로 완료 상태 저장
- 튜토리얼 재실행 방지 로직
- 튜토리얼 단계별 진행 관리

**서비스 메서드**:
- `startTutorial()`: 튜토리얼 시작
- `completeTutorial()`: 튜토리얼 완료
- `isTutorialCompleted()`: 완료 여부 확인
- `resetTutorial()`: 튜토리얼 리셋 (디버그용)

#### 1.1.3 웰컴 메시지 구현
```dart
// 구현할 파일들
lib/screens/welcome_screen.dart
lib/widgets/welcome_message_widget.dart
```

**기능 요구사항**:
- "같이 마셔요" 멘트 표시
- CTA 버튼 ("물 기록해보세요!")
- 튜토리얼과 연동
- 애니메이션 효과

---

## 📚 Day 5-7: 회원가입/로그인 시스템 구현

### Step 6: 로그인 화면 기본 구조

#### 6.1 로그인 화면 파일 생성
```bash
# 로그인 관련 파일들 생성
touch lib/screens/login_screen.dart
touch lib/widgets/login_form_widget.dart
```

#### 6.2 LoginScreen 기본 코드 작성
```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 로고
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // 앱 이름
                const Text(
                  '물먹자 투게더',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                
                // 부제목
                const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                
                // 로그인 폼
                const LoginFormWidget(),
                
                const SizedBox(height: 24),
                
                // 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('계정이 없으신가요? '),
                    TextButton(
                      onPressed: () {
                        // 회원가입 화면으로 이동
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text('회원가입'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 6.3 LoginFormWidget 구현
```dart
// lib/widgets/login_form_widget.dart
import 'package:flutter/material.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 아이디 입력 필드
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: '아이디',
              hintText: '아이디를 입력하세요',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '아이디를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // 비밀번호 입력 필드
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '비밀번호를 입력하세요',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // 로그인 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // 로그인 로직 구현
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 시도 중...')),
      );
    }
  }
}
```

#### 6.4 테스트 방법
```bash
# 앱 실행하여 확인
flutter run
```

**✅ 확인사항**: 로그인 화면이 정상 표시되고 폼 검증이 작동하는지 확인

#### 1.2.2 회원가입 플로우 구현
```dart
// 구현할 파일들
lib/screens/signup_screen.dart
lib/screens/goal_setting_screen.dart
lib/screens/starter_seed_screen.dart
lib/services/auth_service.dart
```

**회원가입 단계**:
1. **닉네임 입력**: 중복 확인
2. **아이디/비밀번호 설정**: 유효성 검사
3. **하루 목표 설정**: 드래그 슬라이더 (500ml-3000ml)
4. **스타터 씨앗 선택**: 3개 중 1개 선택
5. **홈 화면 진입**: 튜토리얼 자동 실행

**기능 요구사항**:
- 단계별 유효성 검사
- 뒤로가기 방지 (완료 전)
- 데이터 저장 및 검증
- 에러 처리 및 사용자 피드백

#### 1.2.3 사용자 인증 서비스 구현
```dart
// 구현할 파일들
lib/services/auth_service.dart
lib/models/auth_user.dart
lib/utils/validation_utils.dart
```

**기능 요구사항**:
- 사용자 등록/로그인
- 비밀번호 암호화
- 세션 관리
- 자동 로그인

---

## 📚 Day 8-10: 데이터 저장 시스템 구현

### Step 7: SharedPreferences 기본 서비스

#### 7.1 StorageService 기본 구조
```bash
# 저장소 관련 파일들 생성
touch lib/services/storage_service.dart
touch lib/services/user_data_service.dart
```

#### 7.2 StorageService 구현
```dart
// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _userDataKey = 'user_data';
  static const String _waterLogsKey = 'water_logs';
  static const String _plantDataKey = 'plant_data';
  static const String _inventoryKey = 'inventory';
  static const String _friendsKey = 'friends';
  static const String _settingsKey = 'settings';

  // 싱글톤 패턴
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // SharedPreferences 인스턴스
  SharedPreferences? _prefs;

  // 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 사용자 데이터 저장
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    if (_prefs == null) await initialize();
    return await _prefs!.setString(_userDataKey, jsonEncode(userData));
  }

  // 사용자 데이터 불러오기
  Future<Map<String, dynamic>?> getUserData() async {
    if (_prefs == null) await initialize();
    final userDataString = _prefs!.getString(_userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // 물 기록 저장
  Future<bool> saveWaterLogs(List<Map<String, dynamic>> waterLogs) async {
    if (_prefs == null) await initialize();
    return await _prefs!.setString(_waterLogsKey, jsonEncode(waterLogs));
  }

  // 물 기록 불러오기
  Future<List<Map<String, dynamic>>> getWaterLogs() async {
    if (_prefs == null) await initialize();
    final waterLogsString = _prefs!.getString(_waterLogsKey);
    if (waterLogsString != null) {
      final List<dynamic> decoded = jsonDecode(waterLogsString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // 설정 저장
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    if (_prefs == null) await initialize();
    return await _prefs!.setString(_settingsKey, jsonEncode(settings));
  }

  // 설정 불러오기
  Future<Map<String, dynamic>> getSettings() async {
    if (_prefs == null) await initialize();
    final settingsString = _prefs!.getString(_settingsKey);
    if (settingsString != null) {
      return jsonDecode(settingsString);
    }
    return {};
  }

  // 모든 데이터 삭제 (디버그용)
  Future<void> clearAllData() async {
    if (_prefs == null) await initialize();
    await _prefs!.clear();
  }
}
```

#### 7.3 테스트 방법
```dart
// 테스트 코드 작성
void testStorageService() async {
  final storage = StorageService();
  await storage.initialize();

  // 사용자 데이터 저장 테스트
  final userData = {
    'userId': 'user_001',
    'nickname': '테스트유저',
    'dailyGoal': 1000,
  };
  
  bool saved = await storage.saveUserData(userData);
  print('사용자 데이터 저장: $saved');
  
  // 사용자 데이터 불러오기 테스트
  final loadedData = await storage.getUserData();
  print('불러온 사용자 데이터: $loadedData');
}
```

**✅ 확인사항**: SharedPreferences가 정상 작동하는지 확인

### Step 8: UserDataService 구현

#### 8.1 UserDataService 구현
```dart
// lib/services/user_data_service.dart
import 'storage_service.dart';
import '../models/user.dart';
import '../models/water_log.dart';
import '../models/plant.dart';
import '../models/inventory.dart';

class UserDataService {
  final StorageService _storage = StorageService();

  // 사용자 정보 저장
  Future<bool> saveUser(User user) async {
    final userData = {
      'userId': user.userId,
      'nickname': user.nickname,
      'password': user.password,
      'dailyWaterGoal': user.dailyWaterGoal,
      'createdAt': user.createdAt.toIso8601String(),
    };
    return await _storage.saveUserData(userData);
  }

  // 사용자 정보 불러오기
  Future<User?> loadUser() async {
    final userData = await _storage.getUserData();
    if (userData != null) {
      return User(
        userId: userData['userId'],
        nickname: userData['nickname'],
        password: userData['password'],
        dailyWaterGoal: userData['dailyWaterGoal'],
        createdAt: DateTime.parse(userData['createdAt']),
      );
    }
    return null;
  }

  // 물 기록 저장
  Future<bool> saveWaterLogs(List<WaterLog> waterLogs) async {
    final logsData = waterLogs.map((log) => {
      'logId': log.logId,
      'userId': log.userId,
      'date': log.date.toIso8601String(),
      'amount': log.amount,
      'type': log.type,
    }).toList();
    return await _storage.saveWaterLogs(logsData);
  }

  // 물 기록 불러오기
  Future<List<WaterLog>> loadWaterLogs() async {
    final logsData = await _storage.getWaterLogs();
    return logsData.map((data) => WaterLog(
      logId: data['logId'],
      userId: data['userId'],
      date: DateTime.parse(data['date']),
      amount: data['amount'],
      type: data['type'],
    )).toList();
  }

  // 설정 저장
  Future<bool> saveSettings({
    required int dailyGoal,
    required bool notificationsEnabled,
    required List<int> reminderHours,
  }) async {
    final settings = {
      'dailyGoal': dailyGoal,
      'notificationsEnabled': notificationsEnabled,
      'reminderHours': reminderHours,
    };
    return await _storage.saveSettings(settings);
  }

  // 설정 불러오기
  Future<Map<String, dynamic>> loadSettings() async {
    return await _storage.getSettings();
  }
}
```

#### 8.2 테스트 방법
```dart
// 테스트 코드 작성
void testUserDataService() async {
  final userDataService = UserDataService();

  // 사용자 생성 및 저장
  final user = User(
    userId: 'user_001',
    nickname: '테스트유저',
    password: 'password123',
    dailyWaterGoal: 1000,
    createdAt: DateTime.now(),
  );

  bool saved = await userDataService.saveUser(user);
  print('사용자 저장: $saved');

  // 사용자 불러오기
  final loadedUser = await userDataService.loadUser();
  print('불러온 사용자: ${loadedUser?.nickname}');
}
```

**✅ 확인사항**: 사용자 데이터가 정상 저장/불러오기 되는지 확인

---

## 🟠 Phase 2: High Priority Features (1-2주) - 핵심 기능 완성

### 목표
앱의 핵심 게이미피케이션 기능을 완성하여 사용자 참여도 향상

---

## 📚 Day 11-13: 식물 성장 시스템 완성

### Step 9: 식물 성장 서비스 구현

#### 9.1 PlantGrowthService 파일 생성
```bash
# 식물 성장 관련 파일들 생성
touch lib/services/plant_growth_service.dart
touch lib/services/reward_service.dart
touch lib/data/plant_database.dart
```

#### 9.2 PlantGrowthService 기본 구현
```dart
// lib/services/plant_growth_service.dart
import '../models/plant.dart';
import '../models/inventory.dart';

class PlantGrowthService {
  // 싱글톤 패턴
  static final PlantGrowthService _instance = PlantGrowthService._internal();
  factory PlantGrowthService() => _instance;
  PlantGrowthService._internal();

  // 식물 성장 조건 정의
  static const Map<int, int> growthRequirements = {
    0: 500,   // 씨앗 → 줄기: 500ml
    1: 1000,  // 줄기 → 꽃: 1000ml 누적
    2: 2000,  // 꽃 → 열매: 2000ml 누적
  };

  // 식물에 물 주기
  Plant waterPlant(Plant plant, int waterAmount) {
    final newPlant = plant.addWater(waterAmount);
    
    // 성장 단계 확인
    if (newPlant.canGrowToNextStage()) {
      return newPlant.growToNextStage();
    }
    
    return newPlant;
  }

  // 성장 가능 여부 확인
  bool canPlantGrow(Plant plant) {
    return plant.canGrowToNextStage();
  }

  // 다음 성장까지 필요한 물의 양
  int getWaterNeededForNextStage(Plant plant) {
    final currentProgress = plant.growthProgress;
    final requiredAmount = growthRequirements[plant.stage] ?? 0;
    
    if (currentProgress >= requiredAmount) {
      return 0; // 이미 성장 가능
    }
    
    return requiredAmount - currentProgress;
  }

  // 성장 완료 여부 확인
  bool isPlantFullyGrown(Plant plant) {
    return plant.stage >= 3; // 열매 단계
  }

  // 성장 완료 시 보상 계산
  List<Inventory> calculateGrowthRewards(Plant plant) {
    if (!isPlantFullyGrown(plant)) {
      return [];
    }

    final rewards = <Inventory>[];
    
    // 해당 식물 씨앗 1개 지급
    rewards.add(Inventory(
      userId: 'current_user', // 실제로는 현재 사용자 ID
      seedId: plant.plantId,
      quantity: 1,
      plantName: plant.name,
    ));

    // 랜덤 씨앗 1개 추가 지급
    final randomSeed = _getRandomSeed();
    rewards.add(Inventory(
      userId: 'current_user',
      seedId: randomSeed['seedId'],
      quantity: 1,
      plantName: randomSeed['plantName'],
    ));

    return rewards;
  }

  // 랜덤 씨앗 선택
  Map<String, String> _getRandomSeed() {
    final seeds = [
      {'seedId': 'seed_001', 'plantName': '기본 씨앗'},
      {'seedId': 'seed_002', 'plantName': '튤립 씨앗'},
      {'seedId': 'seed_003', 'plantName': '민들레 씨앗'},
      {'seedId': 'seed_004', 'plantName': '해바라기 씨앗'},
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % seeds.length;
    return seeds[random];
  }
}
```

#### 9.3 테스트 방법
```dart
// 테스트 코드 작성
void testPlantGrowthService() {
  final growthService = PlantGrowthService();

  // 기본 식물 생성
  final plant = Plant(
    plantId: 'plant_001',
    name: '테스트 식물',
    stage: 0,
    growthProgress: 0,
    totalGrowthRequired: 2000,
    imagePath: '🌱',
  );

  // 물 주기 테스트
  final wateredPlant = growthService.waterPlant(plant, 500);
  print('물 준 후 식물: ${wateredPlant.stage}단계, 진행도: ${wateredPlant.growthProgress}');

  // 성장 가능 여부 확인
  bool canGrow = growthService.canPlantGrow(wateredPlant);
  print('성장 가능: $canGrow');

  // 필요한 물의 양 확인
  int waterNeeded = growthService.getWaterNeededForNextStage(wateredPlant);
  print('다음 성장까지 필요한 물: ${waterNeeded}ml');
}
```

**✅ 확인사항**: 식물 성장 로직이 정상 작동하는지 확인

### Step 10: RewardService 구현

#### 10.1 RewardService 구현
```dart
// lib/services/reward_service.dart
import '../models/inventory.dart';
import '../models/plant.dart';
import 'plant_growth_service.dart';

class RewardService {
  final PlantGrowthService _growthService = PlantGrowthService();

  // 성장 완료 보상 지급
  Future<List<Inventory>> giveGrowthRewards(Plant plant) async {
    if (!_growthService.isPlantFullyGrown(plant)) {
      return [];
    }

    final rewards = _growthService.calculateGrowthRewards(plant);
    
    // 보상 지급 로직 (실제로는 인벤토리에 추가)
    for (final reward in rewards) {
      await _addToInventory(reward);
    }

    return rewards;
  }

  // 인벤토리에 아이템 추가
  Future<void> _addToInventory(Inventory item) async {
    // 실제로는 UserDataService를 통해 인벤토리에 추가
    print('보상 지급: ${item.plantName} x${item.quantity}');
  }

  // 챌린지 완료 보상
  Future<List<Inventory>> giveChallengeRewards(String challengeId) async {
    // 챌린지별 보상 정의
    final challengeRewards = <String, List<Inventory>>{
      'daily_goal': [
        Inventory(
          userId: 'current_user',
          seedId: 'seed_special_001',
          quantity: 1,
          plantName: '특별 씨앗',
        ),
      ],
      'weekly_streak': [
        Inventory(
          userId: 'current_user',
          seedId: 'seed_rare_001',
          quantity: 1,
          plantName: '희귀 씨앗',
        ),
      ],
    };

    return challengeRewards[challengeId] ?? [];
  }

  // 친구 초대 보상
  Future<List<Inventory>> giveInviteRewards() async {
    return [
      Inventory(
        userId: 'current_user',
        seedId: 'seed_friend_001',
        quantity: 1,
        plantName: '친구 씨앗',
      ),
    ];
  }
}
```

#### 10.2 테스트 방법
```dart
// 테스트 코드 작성
void testRewardService() async {
  final rewardService = RewardService();

  // 성장 완료된 식물 생성
  final grownPlant = Plant(
    plantId: 'plant_001',
    name: '완성된 식물',
    stage: 3, // 열매 단계
    growthProgress: 2000,
    totalGrowthRequired: 2000,
    imagePath: '🌰',
  );

  // 성장 보상 지급
  final rewards = await rewardService.giveGrowthRewards(grownPlant);
  print('성장 보상: ${rewards.length}개');

  // 챌린지 보상 지급
  final challengeRewards = await rewardService.giveChallengeRewards('daily_goal');
  print('챌린지 보상: ${challengeRewards.length}개');
}
```

**✅ 확인사항**: 보상 시스템이 정상 작동하는지 확인

---

## 📚 Day 14-16: 도감 시스템 완성 (하단 네비게이션 추가)

### Step 11: 도감 화면 구현

#### 11.1 도감 화면 파일 생성
```bash
# 도감 관련 파일들 생성
touch lib/screens/collection_screen.dart
touch lib/widgets/plant_grid_widget.dart
touch lib/widgets/plant_detail_popup.dart
```

#### 11.2 CollectionScreen 기본 구현
```dart
// lib/screens/collection_screen.dart
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

#### 11.3 하단 네비게이션에 도감 탭 추가
```dart
// lib/screens/main_screen.dart 수정
// 기존 BottomNavigationBar에 도감 탭 추가

BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  currentIndex: waterProvider.currentTabIndex,
  onTap: (index) {
    waterProvider.setCurrentTabIndex(index);
  },
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '홈',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: '대시보드',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: '친구·랭킹',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.collections_bookmark),
      label: '도감',
    ),
  ],
),

// 탭 전환 로직 수정
Widget _getCurrentScreen() {
  switch (waterProvider.currentTabIndex) {
    case 0:
      return const HomeScreen();
    case 1:
      return const DashboardScreen();
    case 2:
      return const FriendsRankingScreen();
    case 3:
      return const CollectionScreen(); // 도감 화면 추가
    default:
      return const HomeScreen();
  }
}
```

#### 11.4 PlantGridWidget 구현
```dart
// lib/widgets/plant_grid_widget.dart
import 'package:flutter/material.dart';
import 'plant_detail_popup.dart';

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
      builder: (context) => PlantDetailPopup(plant: plant),
    );
  }
}
```

#### 11.5 PlantDetailPopup 구현
```dart
// lib/widgets/plant_detail_popup.dart
import 'package:flutter/material.dart';

class PlantDetailPopup extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantDetailPopup({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 식물 이미지
            Text(
              plant['image'] as String,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            
            // 식물 이름
            Text(
              plant['name'] as String,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 식물 설명
            const Text(
              '이 식물은 물을 주면 성장합니다.\n충분한 물을 주어 완전히 키워보세요!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 11.6 테스트 방법
```bash
# 앱 실행하여 확인
flutter run
```

**✅ 확인사항**: 
1. 하단 네비게이션에 도감 탭이 추가되었는지 확인
2. 도감 탭 클릭 시 도감 화면이 표시되는지 확인
3. 식물 클릭 시 상세 팝업이 나타나는지 확인
4. 도감 완성도가 정상 표시되는지 확인

---

## 📚 Day 17-20: 친구 초대 시스템 구현

### Step 12: 친구 초대 기본 기능

#### 12.1 친구 초대 파일 생성
```bash
# 친구 초대 관련 파일들 생성
touch lib/widgets/invite_dialog.dart
touch lib/services/invite_service.dart
```

#### 12.2 InviteDialog 구현
```dart
// lib/widgets/invite_dialog.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

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

    Share.share(inviteMessage);
    Navigator.of(context).pop();
  }
}
```

#### 12.3 InviteService 구현
```dart
// lib/services/invite_service.dart
import 'dart:math';

class InviteService {
  // 싱글톤 패턴
  static final InviteService _instance = InviteService._internal();
  factory InviteService() => _instance;
  InviteService._internal();

  // 초대 링크 생성
  String generateInviteLink(String userId) {
    return 'https://watertogether.app/invite/$userId';
  }

  // 딥링크 생성
  String generateDeepLink(String userId) {
    return 'watertogether://friend/invite/$userId';
  }

  // 초대 보상 지급
  List<Map<String, dynamic>> getInviteRewards() {
    final random = Random();
    final rewards = [
      {'seedId': 'seed_001', 'plantName': '기본 씨앗', 'quantity': 1},
      {'seedId': 'seed_002', 'plantName': '튤립 씨앗', 'quantity': 1},
      {'seedId': 'seed_003', 'plantName': '민들레 씨앗', 'quantity': 1},
    ];
    
    return [rewards[random.nextInt(rewards.length)]];
  }

  // 초대 성공 처리
  Future<bool> processInviteSuccess(String inviterId, String newUserId) async {
    // 실제로는 서버에 초대 성공 정보 전송
    print('초대 성공: $inviterId가 $newUserId를 초대했습니다');
    return true;
  }
}
```

#### 12.4 홈 화면에 초대 버튼 추가
```dart
// lib/screens/home_screen.dart 수정
// 기존 코드에 추가

// 친구 초대 버튼 추가
ElevatedButton.icon(
  onPressed: () => _showInviteDialog(context),
  icon: const Icon(Icons.share),
  label: const Text('친구 초대'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
  ),
),

// 초대 다이얼로그 표시
void _showInviteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const InviteDialog(),
  );
}
```

#### 12.5 테스트 방법
```bash
# 앱 실행하여 확인
flutter run
```

**✅ 확인사항**: 친구 초대 버튼이 정상 작동하고 공유 기능이 동작하는지 확인

---

## 📚 Day 21-23: 설정 시스템 구현 (상단 네비게이션으로 이동)

### Step 13: 설정 화면을 상단 네비게이션으로 이동

#### 13.1 홈 화면에 상단 네비게이션 추가
```dart
// lib/screens/home_screen.dart 수정
// 상단 네비게이션 바 추가

AppBar(
  title: Row(
    children: [
      Text('안녕하세요, ${waterProvider.currentUser?.nickname ?? '사용자'}님'),
      const Spacer(),
      Text('${waterProvider.todayWaterIntake}ml / ${waterProvider.dailyGoal}ml'),
    ],
  ),
  actions: [
    IconButton(
      onPressed: () => _showSettings(context),
      icon: const Icon(Icons.settings),
    ),
  ],
),

// 설정 화면 표시 메서드
void _showSettings(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SettingsScreen(),
    ),
  );
}
```

#### 13.2 기존 하단 네비게이션에서 설정 제거
```dart
// lib/screens/main_screen.dart 수정
// 하단 네비게이션에서 설정 탭 제거

BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  currentIndex: waterProvider.currentTabIndex,
  onTap: (index) {
    waterProvider.setCurrentTabIndex(index);
  },
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '홈',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: '대시보드',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: '친구·랭킹',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.collections_bookmark),
      label: '도감',
    ),
  ],
),

// 탭 전환 로직 수정 (설정 제거)
Widget _getCurrentScreen() {
  switch (waterProvider.currentTabIndex) {
    case 0:
      return const HomeScreen();
    case 1:
      return const DashboardScreen();
    case 2:
      return const FriendsRankingScreen();
    case 3:
      return const CollectionScreen();
    default:
      return const HomeScreen();
  }
}
```

#### 13.3 SettingsScreen 수정
```dart
// lib/screens/settings_screen.dart 수정
// 상단 네비게이션에서 접근하도록 수정

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 목표 섭취량 설정
              Card(
                child: ListTile(
                  leading: const Icon(Icons.water_drop),
                  title: const Text('하루 목표 섭취량'),
                  subtitle: Text('${waterProvider.dailyGoal}ml'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showGoalSettingDialog(context, waterProvider),
                ),
              ),
              
              // 알림 설정
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('알림 설정'),
                  subtitle: const Text('물 마시기 알림'),
                  trailing: Switch(
                    value: true, // 실제로는 설정에서 가져오기
                    onChanged: (value) {
                      // 알림 설정 변경
                    },
                  ),
                ),
              ),
              
              // 계정 정보
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('계정 정보'),
                  subtitle: Text(waterProvider.currentUser?.nickname ?? '사용자'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 계정 정보 화면으로 이동
                  },
                ),
              ),
              
              // 로그아웃
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('로그아웃'),
                  onTap: () => _showLogoutDialog(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showGoalSettingDialog(BuildContext context, WaterProvider waterProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 섭취량 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('현재 목표: ${waterProvider.dailyGoal}ml'),
            Slider(
              value: waterProvider.dailyGoal.toDouble(),
              min: 500,
              max: 3000,
              divisions: 25,
              label: '${waterProvider.dailyGoal}ml',
              onChanged: (value) {
                waterProvider.setDailyGoal(value.toInt());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 로그아웃 처리
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
```

#### 13.4 테스트 방법
```bash
# 앱 실행하여 확인
flutter run
```

**✅ 확인사항**: 
1. 홈 화면 상단에 설정 아이콘이 표시되는지 확인
2. 설정 아이콘 클릭 시 설정 화면이 표시되는지 확인
3. 하단 네비게이션에서 설정 탭이 제거되었는지 확인
4. 설정 화면의 모든 기능이 정상 작동하는지 확인
5. 목표 섭취량 설정이 정상 작동하는지 확인

---

## 🎯 신입 개발자를 위한 개발 팁

### 📚 학습 자료
- **Flutter 공식 문서**: https://flutter.dev/docs
- **Dart 언어 가이드**: https://dart.dev/guides
- **Provider 패턴**: https://pub.dev/packages/provider
- **SharedPreferences**: https://pub.dev/packages/shared_preferences

### 🔧 개발 도구
- **VS Code**: Flutter 확장 프로그램 설치
- **Android Studio**: 에뮬레이터 설정
- **Flutter Inspector**: 위젯 트리 디버깅
- **Hot Reload**: 코드 변경 시 즉시 반영

### 🐛 자주 발생하는 에러와 해결법

#### 1. 컴파일 에러
```bash
# 패키지 설치
flutter pub get

# 캐시 정리
flutter clean
flutter pub get
```

#### 2. 위젯 에러
```dart
// MaterialApp이 없는 경우
return MaterialApp(
  home: YourWidget(),
);

// Scaffold가 없는 경우
return Scaffold(
  body: YourWidget(),
);
```

#### 3. 상태 관리 에러
```dart
// Provider 사용 시
Consumer<YourProvider>(
  builder: (context, provider, child) {
    return Text(provider.data);
  },
)
```

### 📝 코드 작성 규칙

#### 1. 파일 명명 규칙
- 클래스: `PascalCase` (예: `TutorialOverlay`)
- 파일: `snake_case` (예: `tutorial_overlay.dart`)
- 변수: `camelCase` (예: `currentStep`)

#### 2. 주석 작성
```dart
/// 클래스 설명
class MyClass {
  /// 메서드 설명
  void myMethod() {
    // 인라인 주석
  }
}
```

#### 3. 에러 처리
```dart
try {
  // 위험한 코드
} catch (e) {
  print('에러 발생: $e');
  // 에러 처리
}
```

---

## 🎉 결론

이 가이드는 신입 개발자도 쉽게 따라할 수 있도록 단계별로 구성되었습니다.

**개발 순서**:
1. **Day 1-2**: 튜토리얼 오버레이 위젯
2. **Day 3-4**: 튜토리얼 서비스 및 웰컴 메시지
3. **Day 5-7**: 로그인/회원가입 시스템
4. **Day 8-10**: 데이터 저장 시스템
5. **Day 11-13**: 식물 성장 시스템
6. **Day 14-16**: 도감 시스템
7. **Day 17-20**: 친구 초대 시스템

**핵심 원칙**:
- **단계별 구현**: 한 번에 하나씩 기능 구현
- **테스트 우선**: 각 단계마다 앱 실행하여 확인
- **에러 해결**: 컴파일 에러부터 차근차근 해결
- **문서 참조**: 기존 코드와 문서를 참고하여 구현

**예상 완성 시점**: 3주 후 (Phase 1-2 완료)
**최종 목표**: 실제 사용 가능한 완전한 MVP 앱 완성

---

## 📞 도움이 필요할 때

### 질문할 때 포함할 내용
1. **에러 메시지**: 정확한 에러 메시지 복사
2. **코드**: 문제가 발생한 코드 부분
3. **단계**: 어떤 단계에서 문제가 발생했는지
4. **시도한 해결법**: 이미 시도해본 해결 방법

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

---

*문서 생성일: 2025-01-27*  
*마지막 업데이트: 신입 개발자용 단계별 구현 가이드 완성*  
*다음 검토 예정일: 2025-02-03*
