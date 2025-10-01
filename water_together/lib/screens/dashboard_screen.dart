import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../models/water_log.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 오늘의 요약
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
                        '오늘의 요약',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            context,
                            '섭취량',
                            '${waterProvider.todayWaterIntake}ml',
                            Icons.water_drop,
                          ),
                          _buildSummaryItem(
                            context,
                            '목표',
                            '${waterProvider.dailyGoal}ml',
                            Icons.flag,
                          ),
                          _buildSummaryItem(
                            context,
                            '달성률',
                            '${(waterProvider.getGoalAchievementRate() * 100).toInt()}%',
                            Icons.check_circle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 기록 표
                Text(
                  '최근 기록',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // 헤더
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: Text('날짜', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('시각화', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('섭취량', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('달성여부', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      
                      // 데이터 행들
                      if (waterProvider.waterLogs.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          child: const Text(
                            '아직 기록이 없습니다.\n홈 화면에서 물을 기록해보세요!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...waterProvider.waterLogs.take(7).map((log) => _buildLogRow(context, log)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildLogRow(BuildContext context, WaterLog log) {
    final dateStr = '${log.date.month}/${log.date.day}';
    final visualization = _getVisualization(log.amount);
    final isAchieved = log.isGoalAchieved(1000); // 기본 목표 1000ml
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(dateStr)),
          Expanded(flex: 2, child: Text(visualization)),
          Expanded(flex: 2, child: Text('${log.amount}ml')),
          Expanded(
            flex: 2,
            child: Icon(
              isAchieved ? Icons.check_circle : Icons.cancel,
              color: isAchieved ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _getVisualization(int amount) {
    final bars = (amount / 50).round(); // 50ml당 하나의 바
    return '█' * bars.clamp(0, 20); // 최대 20개 바
  }
}
