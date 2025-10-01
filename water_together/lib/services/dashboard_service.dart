import '../models/water_log.dart';
import '../models/user.dart';
import 'water_log_service.dart';

class DashboardService {
  final WaterLogService _waterLogService = WaterLogService();

  // 날짜별 데이터 집계
  Future<List<DailyWaterData>> getDailyWaterData(String userId, int days) async {
    try {
      final List<DailyWaterData> dailyData = [];
      final now = DateTime.now();
      
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dailyIntake = await _waterLogService.getDailyTotalIntake(userId, date);
        final goal = await _waterLogService.getDailyGoal(userId, date);
        
        dailyData.add(DailyWaterData(
          date: date,
          intake: dailyIntake,
          goal: goal,
          isAchieved: dailyIntake >= goal,
        ));
      }
      
      return dailyData;
    } catch (e) {
      print('Error getting daily water data: $e');
      return [];
    }
  }

  // 시각화 데이터 생성
  List<VisualizationData> generateVisualizationData(List<DailyWaterData> dailyData) {
    return dailyData.map((data) {
      final progress = data.goal > 0 ? (data.intake / data.goal).clamp(0.0, 1.0) : 0.0;
      final barCount = (progress * 20).round(); // 최대 20개 바
      
      return VisualizationData(
        date: data.date,
        intake: data.intake,
        goal: data.goal,
        progress: progress,
        barCount: barCount,
        isAchieved: data.isAchieved,
      );
    }).toList();
  }

  // 통계 계산
  Future<DashboardStats> calculateStats(String userId, int days) async {
    try {
      final dailyData = await getDailyWaterData(userId, days);
      
      if (dailyData.isEmpty) {
        return DashboardStats(
          totalIntake: 0,
          averageIntake: 0.0,
          achievementRate: 0.0,
          consecutiveDays: 0,
          bestDay: 0,
          totalDays: 0,
        );
      }

      final totalIntake = dailyData.fold<int>(0, (sum, data) => sum + data.intake);
      final averageIntake = totalIntake / dailyData.length;
      final achievedDays = dailyData.where((data) => data.isAchieved).length;
      final achievementRate = dailyData.isNotEmpty ? achievedDays / dailyData.length : 0.0;
      final bestDay = dailyData.map((data) => data.intake).reduce((a, b) => a > b ? a : b);
      
      // 연속 달성 일수 계산
      int consecutiveDays = 0;
      for (final data in dailyData) {
        if (data.isAchieved) {
          consecutiveDays++;
        } else {
          break;
        }
      }

      return DashboardStats(
        totalIntake: totalIntake,
        averageIntake: averageIntake,
        achievementRate: achievementRate,
        consecutiveDays: consecutiveDays,
        bestDay: bestDay,
        totalDays: dailyData.length,
      );
    } catch (e) {
      print('Error calculating stats: $e');
      return DashboardStats(
        totalIntake: 0,
        averageIntake: 0.0,
        achievementRate: 0.0,
        consecutiveDays: 0,
        bestDay: 0,
        totalDays: 0,
      );
    }
  }

  // 주간 통계
  Future<WeeklyStats> getWeeklyStats(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final dailyData = await getDailyWaterData(userId, 7);
      
      final weeklyIntake = dailyData.fold<int>(0, (sum, data) => sum + data.intake);
      final weeklyGoal = dailyData.fold<int>(0, (sum, data) => sum + data.goal);
      final achievedDays = dailyData.where((data) => data.isAchieved).length;
      
      return WeeklyStats(
        weeklyIntake: weeklyIntake,
        weeklyGoal: weeklyGoal,
        achievedDays: achievedDays,
        averageDailyIntake: dailyData.isNotEmpty ? weeklyIntake / dailyData.length : 0.0,
        weekStart: weekStart,
      );
    } catch (e) {
      print('Error getting weekly stats: $e');
      return WeeklyStats(
        weeklyIntake: 0,
        weeklyGoal: 0,
        achievedDays: 0,
        averageDailyIntake: 0.0,
        weekStart: DateTime.now(),
      );
    }
  }

  // 월간 통계
  Future<MonthlyStats> getMonthlyStats(String userId, DateTime month) async {
    try {
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      final daysInMonth = monthEnd.day;
      
      final dailyData = await getDailyWaterData(userId, daysInMonth);
      
      final monthlyIntake = dailyData.fold<int>(0, (sum, data) => sum + data.intake);
      final monthlyGoal = dailyData.fold<int>(0, (sum, data) => sum + data.goal);
      final achievedDays = dailyData.where((data) => data.isAchieved).length;
      
      return MonthlyStats(
        monthlyIntake: monthlyIntake,
        monthlyGoal: monthlyGoal,
        achievedDays: achievedDays,
        averageDailyIntake: dailyData.isNotEmpty ? monthlyIntake / dailyData.length : 0.0,
        month: month,
      );
    } catch (e) {
      print('Error getting monthly stats: $e');
      return MonthlyStats(
        monthlyIntake: 0,
        monthlyGoal: 0,
        achievedDays: 0,
        averageDailyIntake: 0.0,
        month: month,
      );
    }
  }

  // 목표 달성률 계산
  double calculateAchievementRate(int intake, int goal) {
    if (goal == 0) return 0.0;
    return (intake / goal).clamp(0.0, 1.0);
  }

  // 색상 구분을 위한 달성 여부 확인
  bool isGoalAchieved(int intake, int goal) {
    return intake >= goal;
  }

  // 시각화 바 생성
  String generateVisualizationBars(int intake, int goal, {int maxBars = 20}) {
    if (goal == 0) return '';
    
    final progress = (intake / goal).clamp(0.0, 1.0);
    final barCount = (progress * maxBars).round();
    
    return '█' * barCount + '░' * (maxBars - barCount);
  }

  // 날짜 포맷팅
  String formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  // 요일 포맷팅
  String formatWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }
}

// 데이터 모델들
class DailyWaterData {
  final DateTime date;
  final int intake;
  final int goal;
  final bool isAchieved;

  DailyWaterData({
    required this.date,
    required this.intake,
    required this.goal,
    required this.isAchieved,
  });
}

class VisualizationData {
  final DateTime date;
  final int intake;
  final int goal;
  final double progress;
  final int barCount;
  final bool isAchieved;

  VisualizationData({
    required this.date,
    required this.intake,
    required this.goal,
    required this.progress,
    required this.barCount,
    required this.isAchieved,
  });
}

class DashboardStats {
  final int totalIntake;
  final double averageIntake;
  final double achievementRate;
  final int consecutiveDays;
  final int bestDay;
  final int totalDays;

  DashboardStats({
    required this.totalIntake,
    required this.averageIntake,
    required this.achievementRate,
    required this.consecutiveDays,
    required this.bestDay,
    required this.totalDays,
  });
}

class WeeklyStats {
  final int weeklyIntake;
  final int weeklyGoal;
  final int achievedDays;
  final double averageDailyIntake;
  final DateTime weekStart;

  WeeklyStats({
    required this.weeklyIntake,
    required this.weeklyGoal,
    required this.achievedDays,
    required this.averageDailyIntake,
    required this.weekStart,
  });
}

class MonthlyStats {
  final int monthlyIntake;
  final int monthlyGoal;
  final int achievedDays;
  final double averageDailyIntake;
  final DateTime month;

  MonthlyStats({
    required this.monthlyIntake,
    required this.monthlyGoal,
    required this.achievedDays,
    required this.averageDailyIntake,
    required this.month,
  });
}
