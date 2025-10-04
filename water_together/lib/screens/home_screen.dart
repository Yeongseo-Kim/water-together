import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../models/water_log.dart';
import '../models/water_amount.dart';
import 'settings_screen.dart';
import '../widgets/tutorial_overlay.dart';
import '../services/tutorial_service.dart';
import '../widgets/inventory_popup.dart';
import '../data/plant_messages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showWelcomeMessage = false;
  bool showTutorial = false;
  final TutorialService _tutorialService = TutorialService();
  
  // 인벤토리 관련 상태
  int _currentInventoryPage = 0;
  final int _itemsPerPage = 4;
  
  // 식물 메시지 관련 상태
  String _currentPlantMessage = '';
  bool _showPlantMessage = false;

  // UserFlow.md 요구사항: 정확히 2단계 강제 오버레이 (스킵/재보기 없음)
  final List<TutorialStep> tutorialSteps = [
    TutorialStep(
      title: '물 기록 버튼 💧',
      description: '한모금 버튼을 눌러 기록하는 방법 안내\n한모금, 반컵, 한컵 중에서 선택할 수 있어요.',
      targetKey: GlobalKey(), // 향후 특정 위젯 하이라이트용
    ),
    TutorialStep(
      title: '씨앗 심기 🌱',
      description: '인벤토리에서 씨앗 선택 후 심기 버튼 안내\n씨앗을 클릭하면 미리보기를 볼 수 있어요.',
      targetKey: GlobalKey(), // 향후 특정 위젯 하이라이트용
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
    _showInitialPlantMessage();
  }

  Future<void> _checkTutorialStatus() async {
    final isCompleted = await _tutorialService.isTutorialCompleted();
    if (!isCompleted) {
      setState(() {
        showTutorial = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${waterProvider.todayWaterIntake}ml / ${waterProvider.dailyGoal}ml',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => _showSettings(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: showTutorial ? TutorialOverlay(
        steps: tutorialSteps,
        onComplete: () async {
          await _tutorialService.completeTutorial();
          setState(() {
            showTutorial = false;
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
        child: _buildHomeContent(),
      ) : Stack(
        children: [
          _buildHomeContent(),
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
    );
  }

  Widget _buildHomeContent() {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 오늘의 물 섭취량
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘의 물 섭취량',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: waterProvider.todayWaterIntake / waterProvider.dailyGoal,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${waterProvider.todayWaterIntake}ml / ${waterProvider.dailyGoal}ml',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 식물 상태 + 인벤토리
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '내 식물 🌱',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 식물 상태 영역
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          if (waterProvider.currentUser?.plant != null) ...[
                            Row(
                              children: [
                                // 화분 영역
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.brown.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.brown.shade300),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.local_florist,
                                      size: 60,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // 식물 정보 영역
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        waterProvider.currentUser!.plant!.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '단계 ${waterProvider.currentUser!.plant!.stage}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // 빈 화분 - 가운데 정렬
                            Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.brown.shade300),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.local_florist,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          // 식물 메시지 영역
                          if (_showPlantMessage) ...[
                            const SizedBox(height: 12),
                            AnimatedOpacity(
                              opacity: _showPlantMessage ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _currentPlantMessage,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 인벤토리 영역 (하늘색 배경으로 감싸기)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '씨앗 보관함',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // 왼쪽 화살표
                              IconButton(
                                onPressed: _canGoLeft ? () => _previousInventoryPage() : null,
                                icon: const Icon(Icons.chevron_left),
                                style: IconButton.styleFrom(
                                  backgroundColor: _canGoLeft ? Colors.blue.shade100 : Colors.grey.shade200,
                                  foregroundColor: _canGoLeft ? Colors.blue.shade800 : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 인벤토리 슬롯들
                              ..._buildInventorySlots(),
                              const SizedBox(width: 8),
                              // 오른쪽 화살표
                              IconButton(
                                onPressed: _canGoRight ? () => _nextInventoryPage() : null,
                                icon: const Icon(Icons.chevron_right),
                                style: IconButton.styleFrom(
                                  backgroundColor: _canGoRight ? Colors.blue.shade100 : Colors.grey.shade200,
                                  foregroundColor: _canGoRight ? Colors.blue.shade800 : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 물 기록하기 버튼들
              const Text(
                '물 기록하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _recordWater(waterProvider, WaterAmount.sip),
                      icon: const Icon(Icons.water_drop, size: 20),
                      label: const Text('한모금\n(50ml)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _recordWater(waterProvider, WaterAmount.halfCup),
                      icon: const Icon(Icons.local_drink, size: 20),
                      label: const Text('반컵\n(100ml)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green.shade100,
                        foregroundColor: Colors.green.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _recordWater(waterProvider, WaterAmount.fullCup),
                      icon: const Icon(Icons.local_cafe, size: 20),
                      label: const Text('한컵\n(200ml)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange.shade100,
                        foregroundColor: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        );
      },
    );
  }

  void _recordWater(WaterProvider waterProvider, WaterAmount amount) async {
    final now = DateTime.now();
    final waterLog = WaterLog(
      logId: '${now.millisecondsSinceEpoch}_${waterProvider.currentUser?.userId ?? 'unknown'}',
      userId: waterProvider.currentUser?.userId ?? 'unknown',
      date: now,
      amount: amount.mlAmount,
      type: amount.displayName,
    );
    
    await waterProvider.addWaterLog(waterLog);

    // 식물 메시지 표시
    _showPlantWaterMessage(amount.mlAmount);

    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${amount.displayName} 기록되었습니다!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  // 초기 식물 메시지 표시
  void _showInitialPlantMessage() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentPlantMessage = _getPlantMessage();
          _showPlantMessage = true;
        });
      }
    });
  }

  // 물 마신 후 식물 메시지 표시
  void _showPlantWaterMessage(int waterAmount) {
    setState(() {
      _currentPlantMessage = _getPlantWaterMessage(waterAmount);
      _showPlantMessage = true;
    });
  }

  // 식물 메시지 가져오기
  String _getPlantMessage() {
    // 임시로 기본 씨앗 메시지 사용 (실제로는 현재 식물에 따라 결정)
    return PlantMessages.getMessage(
      plantId: 'seed_001',
      category: 'greeting',
    );
  }

  // 물 마신 후 식물 메시지 가져오기
  String _getPlantWaterMessage(int waterAmount) {
    return PlantMessages.getWaterMessage('seed_001', waterAmount);
  }


  // 인벤토리 관련 메서드들
  bool get _canGoLeft => _currentInventoryPage > 0;
  
  bool get _canGoRight {
    final totalItems = _getInventoryItems().length;
    final totalPages = (totalItems / _itemsPerPage).ceil();
    return _currentInventoryPage < totalPages - 1;
  }
  
  void _previousInventoryPage() {
    if (_canGoLeft) {
      setState(() {
        _currentInventoryPage--;
      });
    }
  }
  
  void _nextInventoryPage() {
    if (_canGoRight) {
      setState(() {
        _currentInventoryPage++;
      });
    }
  }
  
  List<Map<String, dynamic>> _getInventoryItems() {
    // 임시 씨앗 데이터 (실제로는 WaterProvider에서 가져오기)
    return [
      {
        'id': 'seed_001',
        'name': '기본 씨앗',
        'image': '🌱',
        'quantity': 3,
        'description': '기본적인 식물 씨앗입니다. 물을 주면 자라요!',
      },
      {
        'id': 'seed_002',
        'name': '튤립 씨앗',
        'image': '🌷',
        'quantity': 1,
        'description': '아름다운 튤립 씨앗입니다. 봄에 피어나요.',
      },
      {
        'id': 'seed_003',
        'name': '민들레 씨앗',
        'image': '🌼',
        'quantity': 2,
        'description': '노란 민들레 씨앗입니다. 바람에 날려가요.',
      },
      {
        'id': 'seed_004',
        'name': '장미 씨앗',
        'image': '🌹',
        'quantity': 1,
        'description': '사랑의 꽃 장미 씨앗입니다.',
      },
      {
        'id': 'seed_005',
        'name': '해바라기 씨앗',
        'image': '🌻',
        'quantity': 0,
        'description': '태양을 따라 도는 해바라기 씨앗입니다.',
      },
      {
        'id': 'seed_006',
        'name': '선인장 씨앗',
        'image': '🌵',
        'quantity': 2,
        'description': '사막의 선인장 씨앗입니다. 물을 적게 마셔요.',
      },
    ];
  }
  
  List<Widget> _buildInventorySlots() {
    final items = _getInventoryItems();
    final startIndex = _currentInventoryPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, items.length);
    final currentPageItems = items.sublist(startIndex, endIndex);
    
    List<Widget> slots = [];
    
    // 현재 페이지의 아이템들
    for (int i = 0; i < currentPageItems.length; i++) {
      final item = currentPageItems[i];
      slots.add(
        Expanded(
          child: _buildInventorySlot(item),
        ),
      );
      if (i < currentPageItems.length - 1) {
        slots.add(const SizedBox(width: 8));
      }
    }
    
    // 빈 슬롯들로 채우기
    while (slots.length < 7) { // 4개 슬롯 + 3개 간격 = 7개 요소
      slots.add(
        Expanded(
          child: _buildEmptySlot(),
        ),
      );
      if (slots.length < 7) {
        slots.add(const SizedBox(width: 8));
      }
    }
    
    return slots;
  }
  
  Widget _buildInventorySlot(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _showSeedPreview(context, item),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                item['image'],
                style: const TextStyle(fontSize: 32),
              ),
            ),
            if (item['quantity'] > 0)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item['quantity']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptySlot() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('씨앗이 없습니다'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            '⋯',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
  
  void _showSeedPreview(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(item['image'], style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(item['name']),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['description']),
            const SizedBox(height: 16),
            Text('보유 수량: ${item['quantity']}개'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          if (item['quantity'] > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // 씨앗 심기 로직 추가 예정
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} 심기 기능은 준비 중입니다'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('심기'),
            ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정'),
        content: const Text('설정 화면으로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: const Text('이동'),
          ),
        ],
      ),
    );
  }
}