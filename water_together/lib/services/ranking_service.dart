import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';
import '../models/user.dart';
import '../models/water_log.dart';
import 'friend_service.dart';

class RankingService {
  static const String _waterLogsKey = 'water_logs';
  static const String _usersKey = 'users';

  final FriendService _friendService = FriendService();

  // 일간 랭킹 조회 (친구 포함)
  Future<List<RankingItem>> getDailyRanking(String userId) async {
    try {
      final rankingItems = <RankingItem>[];

      // 현재 사용자 정보 조회
      final currentUser = await _getUser(userId);
      if (currentUser != null) {
        final userIntake = await _getTodayIntake(userId);
        final userAchievementRate = await _getAchievementRate(userId, currentUser.dailyWaterGoal);
        final userConsecutiveDays = await _getConsecutiveDays(userId, currentUser.dailyWaterGoal);

        rankingItems.add(RankingItem(
          userId: userId,
          nickname: currentUser.nickname,
          todayIntake: userIntake,
          dailyGoal: currentUser.dailyWaterGoal,
          achievementRate: userAchievementRate,
          consecutiveDays: userConsecutiveDays,
          isCurrentUser: true,
        ));
      }

      // 친구들의 정보 조회
      final friends = await _friendService.getFriends(userId);
      final acceptedFriends = friends.where((friend) => 
        friend.status == Friend.statusAccepted).toList();

      for (final friend in acceptedFriends) {
        final friendUser = await _getUser(friend.friendId);
        if (friendUser != null) {
          final friendIntake = await _getTodayIntake(friend.friendId);
          final friendAchievementRate = await _getAchievementRate(friend.friendId, friendUser.dailyWaterGoal);
          final friendConsecutiveDays = await _getConsecutiveDays(friend.friendId, friendUser.dailyWaterGoal);

          rankingItems.add(RankingItem(
            userId: friend.friendId,
            nickname: friend.friendNickname,
            todayIntake: friendIntake,
            dailyGoal: friendUser.dailyWaterGoal,
            achievementRate: friendAchievementRate,
            consecutiveDays: friendConsecutiveDays,
            isCurrentUser: false,
          ));
        }
      }

      // 랭킹 정렬 (섭취량 기준 내림차순, 동일하면 연속 달성 일수 기준)
      rankingItems.sort((a, b) {
        if (a.todayIntake != b.todayIntake) {
          return b.todayIntake.compareTo(a.todayIntake);
        }
        return b.consecutiveDays.compareTo(a.consecutiveDays);
      });

      return rankingItems;
    } catch (e) {
      print('Error getting daily ranking: $e');
      return [];
    }
  }

  // 주간 랭킹 조회
  Future<List<RankingItem>> getWeeklyRanking(String userId) async {
    try {
      final rankingItems = <RankingItem>[];

      // 현재 사용자 정보 조회
      final currentUser = await _getUser(userId);
      if (currentUser != null) {
        final userWeeklyIntake = await _getWeeklyIntake(userId);
        final userWeeklyGoal = currentUser.dailyWaterGoal * 7;
        final userAchievementRate = userWeeklyGoal > 0 ? (userWeeklyIntake / userWeeklyGoal).clamp(0.0, 1.0) : 0.0;

        rankingItems.add(RankingItem(
          userId: userId,
          nickname: currentUser.nickname,
          todayIntake: userWeeklyIntake,
          dailyGoal: userWeeklyGoal,
          achievementRate: userAchievementRate,
          consecutiveDays: await _getConsecutiveDays(userId, currentUser.dailyWaterGoal),
          isCurrentUser: true,
        ));
      }

      // 친구들의 정보 조회
      final friends = await _friendService.getFriends(userId);
      final acceptedFriends = friends.where((friend) => 
        friend.status == Friend.statusAccepted).toList();

      for (final friend in acceptedFriends) {
        final friendUser = await _getUser(friend.friendId);
        if (friendUser != null) {
          final friendWeeklyIntake = await _getWeeklyIntake(friend.friendId);
          final friendWeeklyGoal = friendUser.dailyWaterGoal * 7;
          final friendAchievementRate = friendWeeklyGoal > 0 ? (friendWeeklyIntake / friendWeeklyGoal).clamp(0.0, 1.0) : 0.0;

          rankingItems.add(RankingItem(
            userId: friend.friendId,
            nickname: friend.friendNickname,
            todayIntake: friendWeeklyIntake,
            dailyGoal: friendWeeklyGoal,
            achievementRate: friendAchievementRate,
            consecutiveDays: await _getConsecutiveDays(friend.friendId, friendUser.dailyWaterGoal),
            isCurrentUser: false,
          ));
        }
      }

      // 랭킹 정렬 (주간 섭취량 기준 내림차순)
      rankingItems.sort((a, b) => b.todayIntake.compareTo(a.todayIntake));

      return rankingItems;
    } catch (e) {
      print('Error getting weekly ranking: $e');
      return [];
    }
  }

  // 월간 랭킹 조회
  Future<List<RankingItem>> getMonthlyRanking(String userId, DateTime month) async {
    try {
      final rankingItems = <RankingItem>[];

      // 현재 사용자 정보 조회
      final currentUser = await _getUser(userId);
      if (currentUser != null) {
        final userMonthlyIntake = await _getMonthlyIntake(userId, month);
        final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
        final userMonthlyGoal = currentUser.dailyWaterGoal * daysInMonth;
        final userAchievementRate = userMonthlyGoal > 0 ? (userMonthlyIntake / userMonthlyGoal).clamp(0.0, 1.0) : 0.0;

        rankingItems.add(RankingItem(
          userId: userId,
          nickname: currentUser.nickname,
          todayIntake: userMonthlyIntake,
          dailyGoal: userMonthlyGoal,
          achievementRate: userAchievementRate,
          consecutiveDays: await _getConsecutiveDays(userId, currentUser.dailyWaterGoal),
          isCurrentUser: true,
        ));
      }

      // 친구들의 정보 조회
      final friends = await _friendService.getFriends(userId);
      final acceptedFriends = friends.where((friend) => 
        friend.status == Friend.statusAccepted).toList();

      for (final friend in acceptedFriends) {
        final friendUser = await _getUser(friend.friendId);
        if (friendUser != null) {
          final friendMonthlyIntake = await _getMonthlyIntake(friend.friendId, month);
          final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
          final friendMonthlyGoal = friendUser.dailyWaterGoal * daysInMonth;
          final friendAchievementRate = friendMonthlyGoal > 0 ? (friendMonthlyIntake / friendMonthlyGoal).clamp(0.0, 1.0) : 0.0;

          rankingItems.add(RankingItem(
            userId: friend.friendId,
            nickname: friend.friendNickname,
            todayIntake: friendMonthlyIntake,
            dailyGoal: friendMonthlyGoal,
            achievementRate: friendAchievementRate,
            consecutiveDays: await _getConsecutiveDays(friend.friendId, friendUser.dailyWaterGoal),
            isCurrentUser: false,
          ));
        }
      }

      // 랭킹 정렬 (월간 섭취량 기준 내림차순)
      rankingItems.sort((a, b) => b.todayIntake.compareTo(a.todayIntake));

      return rankingItems;
    } catch (e) {
      print('Error getting monthly ranking: $e');
      return [];
    }
  }

  // 사용자의 오늘 섭취량 조회
  Future<int> _getTodayIntake(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      
      final waterLogsJson = prefs.getStringList('${_waterLogsKey}_$userId') ?? [];
      final waterLogs = waterLogsJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return WaterLog.fromJson(data);
      }).toList();

      int totalIntake = 0;
      for (final log in waterLogs) {
        final logDate = log.date;
        if (logDate.year == today.year && 
            logDate.month == today.month && 
            logDate.day == today.day) {
          totalIntake += log.amount;
        }
      }

      return totalIntake;
    } catch (e) {
      print('Error getting today intake: $e');
      return 0;
    }
  }

  // 사용자의 주간 섭취량 조회
  Future<int> _getWeeklyIntake(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      
      final waterLogsJson = prefs.getStringList('${_waterLogsKey}_$userId') ?? [];
      final waterLogs = waterLogsJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return WaterLog.fromJson(data);
      }).toList();

      int totalIntake = 0;
      for (final log in waterLogs) {
        final logDate = log.date;
        if (logDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
            logDate.isBefore(now.add(const Duration(days: 1)))) {
          totalIntake += log.amount;
        }
      }

      return totalIntake;
    } catch (e) {
      print('Error getting weekly intake: $e');
      return 0;
    }
  }

  // 사용자의 월간 섭취량 조회
  Future<int> _getMonthlyIntake(String userId, DateTime month) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      
      final waterLogsJson = prefs.getStringList('${_waterLogsKey}_$userId') ?? [];
      final waterLogs = waterLogsJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return WaterLog.fromJson(data);
      }).toList();

      int totalIntake = 0;
      for (final log in waterLogs) {
        final logDate = log.date;
        if (logDate.isAfter(monthStart.subtract(const Duration(days: 1))) && 
            logDate.isBefore(monthEnd.add(const Duration(days: 1)))) {
          totalIntake += log.amount;
        }
      }

      return totalIntake;
    } catch (e) {
      print('Error getting monthly intake: $e');
      return 0;
    }
  }

  // 목표 달성률 계산
  Future<double> _getAchievementRate(String userId, int dailyGoal) async {
    try {
      final todayIntake = await _getTodayIntake(userId);
      if (dailyGoal == 0) return 0.0;
      return (todayIntake / dailyGoal).clamp(0.0, 1.0);
    } catch (e) {
      print('Error getting achievement rate: $e');
      return 0.0;
    }
  }

  // 연속 목표 달성 일수 조회
  Future<int> _getConsecutiveDays(String userId, int dailyGoal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final waterLogsJson = prefs.getStringList('${_waterLogsKey}_$userId') ?? [];
      final waterLogs = waterLogsJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return WaterLog.fromJson(data);
      }).toList();

      // 날짜별 섭취량 계산
      final Map<String, int> dailyIntake = {};
      for (final log in waterLogs) {
        final logDate = log.date;
        final dateKey = '${logDate.year}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}';
        dailyIntake[dateKey] = (dailyIntake[dateKey] ?? 0) + log.amount;
      }

      // 연속 달성 일수 계산
      int consecutiveDays = 0;
      final today = DateTime.now();
      
      for (int i = 0; i < 365; i++) { // 최대 1년까지 확인
        final checkDate = today.subtract(Duration(days: i));
        final dateKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
        
        final intake = dailyIntake[dateKey] ?? 0;
        if (intake >= dailyGoal) {
          consecutiveDays++;
        } else {
          break;
        }
      }

      return consecutiveDays;
    } catch (e) {
      print('Error getting consecutive days: $e');
      return 0;
    }
  }

  // 사용자 정보 조회
  Future<User?> _getUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      for (final json in usersJson) {
        final Map<String, dynamic> data = jsonDecode(json);
        if (data['userId'] == userId) {
          return User.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // 데모 랭킹 데이터 생성 (테스트용)
  Future<void> createDemoRankingData(String userId) async {
    try {
      // 데모 사용자 생성
      final demoUsers = [
        User(
          userId: 'friend_001',
          nickname: '물마시는친구1',
          password: 'password',
          dailyWaterGoal: 1200,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        User(
          userId: 'friend_002',
          nickname: '물마시는친구2',
          password: 'password',
          dailyWaterGoal: 1500,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        User(
          userId: 'friend_003',
          nickname: '물마시는친구3',
          password: 'password',
          dailyWaterGoal: 1000,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      final prefs = await SharedPreferences.getInstance();
      final usersJson = demoUsers.map((user) => jsonEncode(user.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJson);

      // 데모 물 섭취 기록 생성
      final today = DateTime.now();
      final demoLogs = [
        WaterLog(
          logId: 'log_001',
          userId: 'friend_001',
          amount: 1500,
          date: today,
          type: '한컵',
        ),
        WaterLog(
          logId: 'log_002',
          userId: 'friend_002',
          amount: 1200,
          date: today,
          type: '한컵',
        ),
        WaterLog(
          logId: 'log_003',
          userId: 'friend_003',
          amount: 800,
          date: today,
          type: '반컵',
        ),
      ];

      for (final log in demoLogs) {
        final existingLogs = prefs.getStringList('${_waterLogsKey}_${log.userId}') ?? [];
        existingLogs.add(jsonEncode(log.toJson()));
        await prefs.setStringList('${_waterLogsKey}_${log.userId}', existingLogs);
      }
    } catch (e) {
      print('Error creating demo ranking data: $e');
    }
  }
}

// 랭킹 아이템 클래스
class RankingItem {
  final String userId;
  final String nickname;
  final int todayIntake;
  final int dailyGoal;
  final double achievementRate;
  final int consecutiveDays;
  final bool isCurrentUser;

  RankingItem({
    required this.userId,
    required this.nickname,
    required this.todayIntake,
    required this.dailyGoal,
    required this.achievementRate,
    required this.consecutiveDays,
    required this.isCurrentUser,
  });

  // 달성률을 퍼센트로 반환
  int get achievementPercentage => (achievementRate * 100).round();

  // 목표 달성 여부
  bool get isGoalAchieved => todayIntake >= dailyGoal;

  // 랭킹 점수 계산 (섭취량 + 연속 달성 일수 보너스)
  int get rankingScore => todayIntake + (consecutiveDays * 10);
}
