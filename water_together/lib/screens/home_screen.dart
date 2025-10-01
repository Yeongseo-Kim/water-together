import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../models/water_log.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        ],
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          return SingleChildScrollView(
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
                        '오늘도 충분한 물을 마셔보세요! 💧',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      // 목표 달성률 표시
                      LinearProgressIndicator(
                        value: waterProvider.getGoalAchievementRate(),
                        backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          waterProvider.isGoalAchieved() 
                            ? Colors.green 
                            : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        waterProvider.isGoalAchieved() 
                          ? '🎉 목표 달성! 잘했어요!' 
                          : '목표까지 ${waterProvider.dailyGoal - waterProvider.todayWaterIntake}ml 남았어요',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 화분 및 식물 상태 표시
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '내 화분',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 식물 표시
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Center(
                          child: Text(
                            waterProvider.currentPlant?.getStageImagePath() ?? '🌱',
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        waterProvider.currentPlant?.name ?? '기본 식물',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPlantStageText(waterProvider.currentPlant?.stage ?? 0),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      // 성장 진행률
                      if (waterProvider.currentPlant != null)
                        LinearProgressIndicator(
                          value: waterProvider.currentPlant!.getGrowthProgressRate(),
                          backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 물 기록 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showWaterRecordDialog(context),
                    icon: const Icon(Icons.water_drop, size: 24),
                    label: const Text(
                      '물 기록하기',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 인벤토리 및 도감 접근
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
              ],
            ),
          );
        },
      ),
    );
  }

  String _getPlantStageText(int stage) {
    switch (stage) {
      case 0:
        return '씨앗 단계 - 물을 주어 성장시켜보세요!';
      case 1:
        return '줄기 단계 - 계속 물을 주세요!';
      case 2:
        return '꽃 단계 - 거의 다 자랐어요!';
      case 3:
        return '열매 단계 - 완전히 자랐습니다! 🎉';
      default:
        return '씨앗 단계';
    }
  }

  void _showWaterRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('물 기록하기'),
          content: const Text('얼마나 마셨나요?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _recordWater(context, '한모금', 50);
              },
              child: const Text('한모금 (50ml)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _recordWater(context, '반컵', 150);
              },
              child: const Text('반컵 (150ml)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _recordWater(context, '한컵', 300);
              },
              child: const Text('한컵 (300ml)'),
            ),
          ],
        );
      },
    );
  }

  void _recordWater(BuildContext context, String type, int amount) {
    final waterProvider = context.read<WaterProvider>();
    final now = DateTime.now();
    
    final waterLog = WaterLog(
      logId: 'log_${now.millisecondsSinceEpoch}',
      userId: waterProvider.currentUser?.userId ?? 'user_001',
      date: now,
      amount: amount,
      type: type,
    );
    
    waterProvider.addWaterLog(waterLog);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type (${amount}ml) 기록되었습니다!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInventoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<WaterProvider>(
          builder: (context, waterProvider, child) {
            return AlertDialog(
              title: const Text('인벤토리'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: waterProvider.inventory.length,
                  itemBuilder: (context, index) {
                    final item = waterProvider.inventory[index];
                    return ListTile(
                      leading: const Text('🌱', style: TextStyle(fontSize: 24)),
                      title: Text(item.plantName),
                      subtitle: Text('수량: ${item.quantity}개'),
                      trailing: item.hasSeeds()
                          ? ElevatedButton(
                              onPressed: () {
                                waterProvider.useSeed(item.seedId);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('씨앗을 심었습니다!'),
                                  ),
                                );
                              },
                              child: const Text('심기'),
                            )
                          : const Text('없음'),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('닫기'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCollectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('도감'),
          content: const Text('수집한 식물들을 확인할 수 있습니다.\n(아직 수집된 식물이 없습니다)'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
