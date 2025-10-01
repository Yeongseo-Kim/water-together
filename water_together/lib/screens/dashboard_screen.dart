import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../models/water_log.dart';
import '../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  List<VisualizationData> _visualizationData = [];
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final waterProvider = Provider.of<WaterProvider>(context, listen: false);
      if (waterProvider.currentUser != null) {
        // 최근 7일 데이터 로드
        final dailyData = await _dashboardService.getDailyWaterData(
          waterProvider.currentUser!.userId, 
          7
        );
        
        _visualizationData = _dashboardService.generateVisualizationData(dailyData);
        _stats = await _dashboardService.calculateStats(
          waterProvider.currentUser!.userId, 
          7
        );
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 통계 요약 카드
                _buildStatsCard(context, waterProvider),
                
                const SizedBox(height: 24),
                
                // 날짜별 표 형태 레이아웃
                _buildDataTable(context),
                
                const SizedBox(height: 24),
                
                // 누적 통계 요약 정보
                _buildSummaryStats(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // 통계 요약 카드
  Widget _buildStatsCard(BuildContext context, WaterProvider waterProvider) {
    return Container(
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
    );
  }

  // 날짜별 표 형태 레이아웃
  Widget _buildDataTable(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    Expanded(flex: 3, child: Text('시각화', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('섭취량', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('달성여부', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              
              // 데이터 행들
              if (_visualizationData.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: const Text(
                    '아직 기록이 없습니다.\n홈 화면에서 물을 기록해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ..._visualizationData.map((data) => _buildDataRow(context, data)),
            ],
          ),
        ),
      ],
    );
  }

  // 누적 통계 요약 정보
  Widget _buildSummaryStats(BuildContext context) {
    if (_stats == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7일 통계',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                '평균',
                '${_stats!.averageIntake.toInt()}ml',
                Icons.trending_up,
              ),
              _buildStatItem(
                context,
                '달성률',
                '${(_stats!.achievementRate * 100).toInt()}%',
                Icons.check_circle_outline,
              ),
              _buildStatItem(
                context,
                '연속',
                '${_stats!.consecutiveDays}일',
                Icons.local_fire_department,
              ),
            ],
          ),
        ],
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

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildDataRow(BuildContext context, VisualizationData data) {
    final dateStr = _dashboardService.formatDate(data.date);
    final weekdayStr = _dashboardService.formatWeekday(data.date);
    final visualization = _dashboardService.generateVisualizationBars(data.intake, data.goal);
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        color: data.isAchieved 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(weekdayStr, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              visualization,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: data.isAchieved ? Colors.green : Colors.blue,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${data.intake}ml',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Icon(
              data.isAchieved ? Icons.check_circle : Icons.cancel,
              color: data.isAchieved ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
