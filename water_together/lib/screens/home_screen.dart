import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../widgets/plant_pot.dart';
import '../widgets/water_record_button.dart';
import '../widgets/inventory_widget.dart';
import '../widgets/welcome_message.dart';
import '../widgets/tutorial_overlay.dart';
import 'collection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcome = true;
  bool _showTutorial = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
              IconButton(
                onPressed: () => _navigateToCollection(context),
                icon: const Icon(Icons.book),
                tooltip: '도감',
              ),
            ],
          ),
          body: Consumer<WaterProvider>(
            builder: (context, waterProvider, child) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 환영 멘트
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '안녕하세요! ${waterProvider.currentUser?.nickname ?? '사용자'}님',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '오늘도 건강한 하루를 위해 물을 마셔보세요! 💧',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: waterProvider.getGoalAchievementRate(),
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      waterProvider.isGoalAchieved() 
                                          ? Colors.green 
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${(waterProvider.getGoalAchievementRate() * 100).round()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 식물 화분과 인벤토리
                      Row(
                        children: [
                          // 식물 화분
                          Expanded(
                            flex: 2,
                            child: PlantPot(
                              plant: waterProvider.currentPlant,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // 인벤토리
                          Expanded(
                            flex: 1,
                            child: InventoryWidget(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 물 기록 버튼
                      Center(
                        child: WaterRecordButton(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // 웰컴 메시지 오버레이
        if (_showWelcome)
          Consumer<WaterProvider>(
            builder: (context, waterProvider, child) {
              return WelcomeMessage(
                nickname: waterProvider.currentUser?.nickname ?? '사용자',
                onStartTutorial: _startTutorial,
              );
            },
          ),
        
        // 튜토리얼 오버레이
        if (_showTutorial)
          TutorialOverlay(
            child: Container(), // 빈 컨테이너
            onTutorialComplete: _completeTutorial,
          ),
      ],
    );
  }

  void _navigateToCollection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CollectionScreen(),
      ),
    );
  }

  void _startTutorial() {
    setState(() {
      _showWelcome = false;
      _showTutorial = true;
    });
  }

  void _completeTutorial() {
    setState(() {
      _showTutorial = false;
    });
  }
}