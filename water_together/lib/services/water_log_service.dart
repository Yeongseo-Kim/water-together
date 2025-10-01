import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_log.dart';

class WaterLogService {
  static const String _waterLogsKey = 'water_logs';
  static const String _userWaterLogsKey = 'user_water_logs';

  // 싱글톤 패턴
  static final WaterLogService _instance = WaterLogService._internal();
  factory WaterLogService() => _instance;
  WaterLogService._internal();

  // 물 기록 저장
  Future<bool> saveWaterLog(WaterLog log) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_userWaterLogsKey}_${log.userId}';
      
      // 기존 기록들 불러오기
      final existingLogsJson = prefs.getStringList(userKey) ?? [];
      final existingLogs = existingLogsJson
          .map((json) => WaterLog.fromJson(jsonDecode(json)))
          .toList();
      
      // 새 기록 추가
      existingLogs.add(log);
      
      // 다시 저장
      final logsJson = existingLogs
          .map((log) => jsonEncode(log.toJson()))
          .toList();
      
      await prefs.setStringList(userKey, logsJson);
      return true;
    } catch (e) {
      print('Error saving water log: $e');
      return false;
    }
  }

  // 사용자의 모든 물 기록 조회
  Future<List<WaterLog>> getWaterLogs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_userWaterLogsKey}_${userId}';
      
      final logsJson = prefs.getStringList(userKey) ?? [];
      return logsJson
          .map((json) => WaterLog.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading water logs: $e');
      return [];
    }
  }

  // 특정 날짜의 물 기록 조회
  Future<List<WaterLog>> getWaterLogsByDate(String userId, DateTime date) async {
    try {
      final allLogs = await getWaterLogs(userId);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      return allLogs.where((log) => log.getDateKey() == dateKey).toList();
    } catch (e) {
      print('Error loading water logs by date: $e');
      return [];
    }
  }

  // 오늘의 물 기록 조회
  Future<List<WaterLog>> getTodayWaterLogs(String userId) async {
    return getWaterLogsByDate(userId, DateTime.now());
  }

  // 날짜별 누적 섭취량 계산
  Future<int> getTotalIntakeByDate(String userId, DateTime date) async {
    try {
      final logs = await getWaterLogsByDate(userId, date);
      return logs.fold<int>(0, (sum, log) => sum + log.amount);
    } catch (e) {
      print('Error calculating total intake: $e');
      return 0;
    }
  }

  // 오늘의 누적 섭취량 계산
  Future<int> getTodayTotalIntake(String userId) async {
    return getTotalIntakeByDate(userId, DateTime.now());
  }

  // 목표 달성 여부 확인
  Future<bool> isGoalAchieved(String userId, DateTime date, int dailyGoal) async {
    try {
      final totalIntake = await getTotalIntakeByDate(userId, date);
      return totalIntake >= dailyGoal;
    } catch (e) {
      print('Error checking goal achievement: $e');
      return false;
    }
  }

  // 오늘 목표 달성 여부 확인
  Future<bool> isTodayGoalAchieved(String userId, int dailyGoal) async {
    return isGoalAchieved(userId, DateTime.now(), dailyGoal);
  }

  // 특정 기간의 물 기록 조회 (시작일 ~ 종료일)
  Future<List<WaterLog>> getWaterLogsByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final allLogs = await getWaterLogs(userId);
      
      return allLogs.where((log) {
        return log.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               log.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      print('Error loading water logs by date range: $e');
      return [];
    }
  }

  // 주간 통계 조회
  Future<Map<String, int>> getWeeklyStats(String userId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      final logs = await getWaterLogsByDateRange(userId, startOfWeek, endOfWeek);
      
      final Map<String, int> weeklyStats = {};
      
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        final dayLogs = logs.where((log) => log.getDateKey() == dateKey).toList();
        weeklyStats[dateKey] = dayLogs.fold(0, (sum, log) => sum + log.amount);
      }
      
      return weeklyStats;
    } catch (e) {
      print('Error calculating weekly stats: $e');
      return {};
    }
  }

  // 월간 통계 조회
  Future<Map<String, int>> getMonthlyStats(String userId, DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      
      final logs = await getWaterLogsByDateRange(userId, startOfMonth, endOfMonth);
      
      final Map<String, int> monthlyStats = {};
      
      for (int day = 1; day <= endOfMonth.day; day++) {
        final date = DateTime(month.year, month.month, day);
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        final dayLogs = logs.where((log) => log.getDateKey() == dateKey).toList();
        monthlyStats[dateKey] = dayLogs.fold(0, (sum, log) => sum + log.amount);
      }
      
      return monthlyStats;
    } catch (e) {
      print('Error calculating monthly stats: $e');
      return {};
    }
  }

  // 물 기록 삭제
  Future<bool> deleteWaterLog(String userId, String logId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_userWaterLogsKey}_${userId}';
      
      final existingLogsJson = prefs.getStringList(userKey) ?? [];
      final existingLogs = existingLogsJson
          .map((json) => WaterLog.fromJson(jsonDecode(json)))
          .toList();
      
      // 해당 기록 제거
      existingLogs.removeWhere((log) => log.logId == logId);
      
      // 다시 저장
      final logsJson = existingLogs
          .map((log) => jsonEncode(log.toJson()))
          .toList();
      
      await prefs.setStringList(userKey, logsJson);
      return true;
    } catch (e) {
      print('Error deleting water log: $e');
      return false;
    }
  }

  // 사용자의 모든 물 기록 삭제
  Future<bool> clearAllWaterLogs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_userWaterLogsKey}_${userId}';
      
      await prefs.remove(userKey);
      return true;
    } catch (e) {
      print('Error clearing all water logs: $e');
      return false;
    }
  }

  // 물 기록 수정
  Future<bool> updateWaterLog(WaterLog updatedLog) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_userWaterLogsKey}_${updatedLog.userId}';
      
      final existingLogsJson = prefs.getStringList(userKey) ?? [];
      final existingLogs = existingLogsJson
          .map((json) => WaterLog.fromJson(jsonDecode(json)))
          .toList();
      
      // 해당 기록 찾아서 교체
      final index = existingLogs.indexWhere((log) => log.logId == updatedLog.logId);
      if (index >= 0) {
        existingLogs[index] = updatedLog;
        
        // 다시 저장
        final logsJson = existingLogs
            .map((log) => jsonEncode(log.toJson()))
            .toList();
        
        await prefs.setStringList(userKey, logsJson);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error updating water log: $e');
      return false;
    }
  }

  // 평균 섭취량 계산 (지난 N일)
  Future<double> getAverageIntake(String userId, int days) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days - 1));
      
      final logs = await getWaterLogsByDateRange(userId, startDate, now);
      
      final Map<String, int> dailyIntake = {};
      
      for (final log in logs) {
        final dateKey = log.getDateKey();
        dailyIntake[dateKey] = (dailyIntake[dateKey] ?? 0) + log.amount;
      }
      
      if (dailyIntake.isEmpty) return 0.0;
      
      final totalIntake = dailyIntake.values.fold(0, (sum, intake) => sum + intake);
      return totalIntake / dailyIntake.length;
    } catch (e) {
      print('Error calculating average intake: $e');
      return 0.0;
    }
  }

  // 연속 목표 달성 일수 계산
  Future<int> getConsecutiveGoalDays(String userId, int dailyGoal) async {
    try {
      final now = DateTime.now();
      int consecutiveDays = 0;
      
      for (int i = 0; i < 365; i++) { // 최대 1년까지 확인
        final date = now.subtract(Duration(days: i));
        final isAchieved = await isGoalAchieved(userId, date, dailyGoal);
        
        if (isAchieved) {
          consecutiveDays++;
        } else {
          break;
        }
      }
      
      return consecutiveDays;
    } catch (e) {
      print('Error calculating consecutive goal days: $e');
      return 0;
    }
  }

  // 특정 날짜의 총 섭취량 조회 (대시보드용)
  Future<int> getDailyTotalIntake(String userId, DateTime date) async {
    return getTotalIntakeByDate(userId, date);
  }

  // 특정 날짜의 목표 조회 (대시보드용)
  Future<int> getDailyGoal(String userId, DateTime date) async {
    // 현재는 사용자의 기본 목표를 반환하지만, 
    // 나중에 날짜별로 다른 목표를 설정할 수 있도록 확장 가능
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalKey = 'daily_goal_${userId}';
      return prefs.getInt(goalKey) ?? 1000; // 기본값 1000ml
    } catch (e) {
      print('Error getting daily goal: $e');
      return 1000;
    }
  }

  // 사용자의 기본 목표 설정
  Future<bool> setDailyGoal(String userId, int goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalKey = 'daily_goal_${userId}';
      await prefs.setInt(goalKey, goal);
      return true;
    } catch (e) {
      print('Error setting daily goal: $e');
      return false;
    }
  }
}
