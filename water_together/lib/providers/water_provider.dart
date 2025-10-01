import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plant.dart';
import '../models/water_log.dart';
import '../models/inventory.dart';
import '../models/friend.dart';
import '../services/water_log_service.dart';
import '../services/plant_growth_service.dart';
import '../services/dashboard_service.dart';
import '../services/friend_service.dart';
import '../services/ranking_service.dart';
import '../services/invite_service.dart';

class WaterProvider extends ChangeNotifier {
  // 서비스 인스턴스
  final WaterLogService _waterLogService = WaterLogService();
  final PlantGrowthService _plantGrowthService = PlantGrowthService();
  final DashboardService _dashboardService = DashboardService();
  final FriendService _friendService = FriendService();
  final RankingService _rankingService = RankingService();
  final InviteService _inviteService = InviteService();

  // 현재 사용자 정보
  User? _currentUser;
  User? get currentUser => _currentUser;

  // 현재 식물 정보
  Plant? _currentPlant;
  Plant? get currentPlant => _currentPlant;

  // 오늘의 물 섭취량
  int _todayWaterIntake = 0;
  int get todayWaterIntake => _todayWaterIntake;

  // 오늘의 목표 섭취량
  int _dailyGoal = 1000; // 기본값 1L
  int get dailyGoal => _dailyGoal;

  // 물 기록 목록
  List<WaterLog> _waterLogs = [];
  List<WaterLog> get waterLogs => _waterLogs;

  // 인벤토리 (씨앗 목록)
  List<Inventory> _inventory = [];
  List<Inventory> get inventory => _inventory;

  // 친구 목록
  List<Friend> _friends = [];
  List<Friend> get friends => _friends;

  // 현재 선택된 탭 인덱스
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // 사용자 설정
  void setCurrentUser(User user) {
    _currentUser = user;
    _dailyGoal = user.dailyWaterGoal;
    notifyListeners();
  }

  // 목표 섭취량 설정
  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(dailyWaterGoal: goal);
    }
    notifyListeners();
  }

  // 현재 식물 설정
  void setCurrentPlant(Plant plant) {
    _currentPlant = plant;
    notifyListeners();
  }

  // 물 섭취 기록 추가
  Future<void> addWaterLog(WaterLog log) async {
    try {
      // 서비스를 통해 저장
      final success = await _waterLogService.saveWaterLog(log);
      if (!success) {
        print('Failed to save water log');
        return;
      }

      // 로컬 상태 업데이트
      _waterLogs.add(log);
      _todayWaterIntake += log.amount;
      
      // 식물 성장 처리
      if (_currentUser != null && _currentPlant != null) {
        final grownPlant = await _plantGrowthService.waterPlant(_currentUser!.userId, log.amount);
        if (grownPlant != null) {
          _currentPlant = grownPlant;
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error adding water log: $e');
    }
  }

  // 오늘의 물 섭취량 계산
  Future<void> calculateTodayIntake() async {
    try {
      if (_currentUser == null) return;

      // 서비스에서 오늘의 섭취량 조회
      _todayWaterIntake = await _waterLogService.getTodayTotalIntake(_currentUser!.userId);
      
      // 오늘의 기록들도 로컬에 로드
      _waterLogs = await _waterLogService.getTodayWaterLogs(_currentUser!.userId);
      
      notifyListeners();
    } catch (e) {
      print('Error calculating today intake: $e');
    }
  }

  // 목표 달성 여부 확인
  bool isGoalAchieved() {
    return _todayWaterIntake >= _dailyGoal;
  }

  // 목표 달성률 계산 (0.0 ~ 1.0)
  double getGoalAchievementRate() {
    if (_dailyGoal == 0) return 0.0;
    return (_todayWaterIntake / _dailyGoal).clamp(0.0, 1.0);
  }

  // 인벤토리에 씨앗 추가
  Future<void> addToInventory(Inventory item) async {
    try {
      // 서비스를 통해 인벤토리 업데이트
      _inventory = await _plantGrowthService.getInventory(_currentUser?.userId ?? '');
      notifyListeners();
    } catch (e) {
      print('Error adding to inventory: $e');
    }
  }

  // 씨앗 사용
  Future<void> useSeed(String seedId) async {
    try {
      if (_currentUser == null) return;
      
      // 서비스를 통해 씨앗 사용
      await _plantGrowthService.useSeedFromInventory(_currentUser!.userId, seedId);
      
      // 로컬 인벤토리 업데이트
      _inventory = await _plantGrowthService.getInventory(_currentUser!.userId);
      notifyListeners();
    } catch (e) {
      print('Error using seed: $e');
    }
  }

  // 새로운 씨앗 심기
  Future<bool> plantNewSeed(String seedId) async {
    try {
      if (_currentUser == null) return false;

      // 서비스를 통해 새 식물 심기
      final newPlant = await _plantGrowthService.plantNewSeed(_currentUser!.userId, seedId);
      
      if (newPlant != null) {
        _currentPlant = newPlant;
        _inventory = await _plantGrowthService.getInventory(_currentUser!.userId);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error planting new seed: $e');
      return false;
    }
  }

  // 친구 목록 로드
  Future<void> loadFriends() async {
    try {
      if (_currentUser == null) return;
      
      _friends = await _friendService.getFriends(_currentUser!.userId);
      notifyListeners();
    } catch (e) {
      print('Error loading friends: $e');
    }
  }

  // 친구 추가 요청 전송
  Future<bool> sendFriendRequest(String friendId) async {
    try {
      if (_currentUser == null) return false;
      
      final success = await _friendService.sendFriendRequest(_currentUser!.userId, friendId);
      if (success) {
        await loadFriends();
      }
      return success;
    } catch (e) {
      print('Error sending friend request: $e');
      return false;
    }
  }

  // 친구 요청 수락
  Future<bool> acceptFriendRequest(String friendId) async {
    try {
      if (_currentUser == null) return false;
      
      final success = await _friendService.acceptFriendRequest(_currentUser!.userId, friendId);
      if (success) {
        await loadFriends();
      }
      return success;
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  // 친구 요청 거절
  Future<bool> rejectFriendRequest(String friendId) async {
    try {
      if (_currentUser == null) return false;
      
      final success = await _friendService.rejectFriendRequest(_currentUser!.userId, friendId);
      if (success) {
        await loadFriends();
      }
      return success;
    } catch (e) {
      print('Error rejecting friend request: $e');
      return false;
    }
  }

  // 친구 삭제
  Future<bool> removeFriend(String friendId) async {
    try {
      if (_currentUser == null) return false;
      
      final success = await _friendService.removeFriend(_currentUser!.userId, friendId);
      if (success) {
        await loadFriends();
      }
      return success;
    } catch (e) {
      print('Error removing friend: $e');
      return false;
    }
  }

  // 친구 검색
  Future<List<User>> searchUsers(String query) async {
    try {
      return await _friendService.searchUsers(query);
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // 친구의 오늘 섭취량 조회
  Future<int> getFriendTodayIntake(String friendId) async {
    try {
      return await _friendService.getFriendTodayIntake(friendId);
    } catch (e) {
      print('Error getting friend today intake: $e');
      return 0;
    }
  }

  // 친구의 목표 달성률 조회
  Future<double> getFriendAchievementRate(String friendId) async {
    try {
      return await _friendService.getFriendAchievementRate(friendId);
    } catch (e) {
      print('Error getting friend achievement rate: $e');
      return 0.0;
    }
  }

  // 일간 랭킹 조회
  Future<List<RankingItem>> getDailyRanking() async {
    try {
      if (_currentUser == null) return [];
      return await _rankingService.getDailyRanking(_currentUser!.userId);
    } catch (e) {
      print('Error getting daily ranking: $e');
      return [];
    }
  }

  // 주간 랭킹 조회
  Future<List<RankingItem>> getWeeklyRanking() async {
    try {
      if (_currentUser == null) return [];
      return await _rankingService.getWeeklyRanking(_currentUser!.userId);
    } catch (e) {
      print('Error getting weekly ranking: $e');
      return [];
    }
  }

  // 월간 랭킹 조회
  Future<List<RankingItem>> getMonthlyRanking(DateTime month) async {
    try {
      if (_currentUser == null) return [];
      return await _rankingService.getMonthlyRanking(_currentUser!.userId, month);
    } catch (e) {
      print('Error getting monthly ranking: $e');
      return [];
    }
  }

  // 초대 링크 생성
  Future<String> generateInviteLink() async {
    try {
      if (_currentUser == null) return '';
      return await _inviteService.generateInviteLink(_currentUser!.userId);
    } catch (e) {
      print('Error generating invite link: $e');
      return '';
    }
  }

  // 초대 링크 처리
  Future<bool> processInviteLink(String inviteCode, String newUserId) async {
    try {
      return await _inviteService.processInviteLink(inviteCode, newUserId);
    } catch (e) {
      print('Error processing invite link: $e');
      return false;
    }
  }

  // 초대 통계 조회
  Future<InviteStats> getInviteStats() async {
    try {
      if (_currentUser == null) {
        return InviteStats(
          totalInvites: 0,
          successfulInvites: 0,
          totalRewards: 0,
          successRate: 0.0,
        );
      }
      return await _inviteService.getInviteStats(_currentUser!.userId);
    } catch (e) {
      print('Error getting invite stats: $e');
      return InviteStats(
        totalInvites: 0,
        successfulInvites: 0,
        totalRewards: 0,
        successRate: 0.0,
      );
    }
  }

  // 도감 조회
  Future<List<Plant>> getCollection() async {
    try {
      if (_currentUser == null) return [];
      return await _plantGrowthService.getCollection(_currentUser!.userId);
    } catch (e) {
      print('Error getting collection: $e');
      return [];
    }
  }

  // 식물 성장 통계 조회
  Future<Map<String, dynamic>> getGrowthStats() async {
    try {
      if (_currentUser == null) return {};
      return await _plantGrowthService.getGrowthStats(_currentUser!.userId);
    } catch (e) {
      print('Error getting growth stats: $e');
      return {};
    }
  }

  // 주간 통계 조회 (Map 버전)
  Future<Map<String, int>> getWeeklyStatsMap() async {
    try {
      if (_currentUser == null) return {};
      return await _waterLogService.getWeeklyStats(_currentUser!.userId);
    } catch (e) {
      print('Error getting weekly stats: $e');
      return {};
    }
  }

  // 월간 통계 조회 (Map 버전)
  Future<Map<String, int>> getMonthlyStatsMap(DateTime month) async {
    try {
      if (_currentUser == null) return {};
      return await _waterLogService.getMonthlyStats(_currentUser!.userId, month);
    } catch (e) {
      print('Error getting monthly stats: $e');
      return {};
    }
  }

  // 평균 섭취량 조회
  Future<double> getAverageIntake(int days) async {
    try {
      if (_currentUser == null) return 0.0;
      return await _waterLogService.getAverageIntake(_currentUser!.userId, days);
    } catch (e) {
      print('Error getting average intake: $e');
      return 0.0;
    }
  }

  // 연속 목표 달성 일수 조회
  Future<int> getConsecutiveGoalDays() async {
    try {
      if (_currentUser == null) return 0;
      return await _waterLogService.getConsecutiveGoalDays(_currentUser!.userId, _dailyGoal);
    } catch (e) {
      print('Error getting consecutive goal days: $e');
      return 0;
    }
  }

  // 물 기록 삭제
  Future<bool> deleteWaterLog(String logId) async {
    try {
      if (_currentUser == null) return false;
      
      final success = await _waterLogService.deleteWaterLog(_currentUser!.userId, logId);
      if (success) {
        // 로컬 상태에서도 제거
        _waterLogs.removeWhere((log) => log.logId == logId);
        await calculateTodayIntake(); // 오늘 섭취량 재계산
      }
      return success;
    } catch (e) {
      print('Error deleting water log: $e');
      return false;
    }
  }

  // 물 기록 수정
  Future<bool> updateWaterLog(WaterLog updatedLog) async {
    try {
      final success = await _waterLogService.updateWaterLog(updatedLog);
      if (success) {
        // 로컬 상태 업데이트
        final index = _waterLogs.indexWhere((log) => log.logId == updatedLog.logId);
        if (index >= 0) {
          _waterLogs[index] = updatedLog;
          await calculateTodayIntake(); // 오늘 섭취량 재계산
        }
      }
      return success;
    } catch (e) {
      print('Error updating water log: $e');
      return false;
    }
  }

  // 식물 성장 애니메이션 정보 조회
  Map<String, dynamic>? getGrowthStageInfo() {
    if (_currentPlant == null) return null;
    return _plantGrowthService.getGrowthStageInfo(_currentPlant!);
  }

  // 새 씨앗 심기 가능 여부 확인
  Future<bool> canPlantNewSeed() async {
    try {
      if (_currentUser == null) return false;
      return await _plantGrowthService.canPlantNewSeed(_currentUser!.userId);
    } catch (e) {
      print('Error checking if can plant new seed: $e');
      return false;
    }
  }

  // 식물 데이터베이스 조회
  Map<String, dynamic>? getPlantData(String seedId) {
    return _plantGrowthService.getPlantData(seedId);
  }

  // 모든 식물 데이터베이스 조회
  Map<String, Map<String, dynamic>> getAllPlantData() {
    return _plantGrowthService.getAllPlantData();
  }

  // 희귀도별 씨앗 필터링
  List<String> getSeedsByRarity(String rarity) {
    return _plantGrowthService.getSeedsByRarity(rarity);
  }

  // 탭 변경
  void changeTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // 씨앗 선물 기능
  Future<bool> giftSeedToFriend(String friendId, String seedId, int quantity) async {
    try {
      if (_currentUser == null) return false;
      
      final success = await _plantGrowthService.giftSeedToFriend(
        _currentUser!.userId, 
        friendId, 
        seedId, 
        quantity
      );
      
      if (success) {
        // 로컬 인벤토리 업데이트
        _inventory = await _plantGrowthService.getInventory(_currentUser!.userId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      print('Error gifting seed: $e');
      return false;
    }
  }

  // 씨앗 교환 기능
  Future<bool> exchangeSeeds(String fromSeedId, int fromQuantity, String toSeedId) async {
    try {
      if (_currentUser == null) return false;
      
      final success = await _plantGrowthService.exchangeSeeds(
        _currentUser!.userId,
        fromSeedId,
        fromQuantity,
        toSeedId
      );
      
      if (success) {
        // 로컬 인벤토리 업데이트
        _inventory = await _plantGrowthService.getInventory(_currentUser!.userId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      print('Error exchanging seeds: $e');
      return false;
    }
  }

  // 일일 씨앗 보상 받기
  Future<void> claimDailySeedReward() async {
    try {
      if (_currentUser == null) return;
      
      await _plantGrowthService.giveDailySeedReward(_currentUser!.userId);
      
      // 로컬 인벤토리 업데이트
      _inventory = await _plantGrowthService.getInventory(_currentUser!.userId);
      notifyListeners();
    } catch (e) {
      print('Error claiming daily seed reward: $e');
    }
  }

  // 연속 로그인 일수 조회
  Future<int> getConsecutiveLoginDays() async {
    try {
      if (_currentUser == null) return 0;
      return await _plantGrowthService.getConsecutiveLoginDays(_currentUser!.userId);
    } catch (e) {
      print('Error getting consecutive login days: $e');
      return 0;
    }
  }

  // 계절별 씨앗 목록 조회
  List<String> getSeedsBySeason(String season) {
    return _plantGrowthService.getSeedsBySeason(season);
  }

  // 카테고리별 씨앗 목록 조회
  List<String> getSeedsByCategory(String category) {
    return _plantGrowthService.getSeedsByCategory(category);
  }

  // 대시보드 데이터 조회
  Future<List<DailyWaterData>> getDashboardData(int days) async {
    try {
      if (_currentUser == null) return [];
      return await _dashboardService.getDailyWaterData(_currentUser!.userId, days);
    } catch (e) {
      print('Error getting dashboard data: $e');
      return [];
    }
  }

  // 대시보드 통계 조회
  Future<DashboardStats> getDashboardStats(int days) async {
    try {
      if (_currentUser == null) {
        return DashboardStats(
          totalIntake: 0,
          averageIntake: 0.0,
          achievementRate: 0.0,
          consecutiveDays: 0,
          bestDay: 0,
          totalDays: 0,
        );
      }
      return await _dashboardService.calculateStats(_currentUser!.userId, days);
    } catch (e) {
      print('Error getting dashboard stats: $e');
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

  // 주간 통계 조회
  Future<WeeklyStats> getWeeklyStats() async {
    try {
      if (_currentUser == null) {
        return WeeklyStats(
          weeklyIntake: 0,
          weeklyGoal: 0,
          achievedDays: 0,
          averageDailyIntake: 0.0,
          weekStart: DateTime.now(),
        );
      }
      return await _dashboardService.getWeeklyStats(_currentUser!.userId);
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

  // 월간 통계 조회
  Future<MonthlyStats> getMonthlyStats(DateTime month) async {
    try {
      if (_currentUser == null) {
        return MonthlyStats(
          monthlyIntake: 0,
          monthlyGoal: 0,
          achievedDays: 0,
          averageDailyIntake: 0.0,
          month: month,
        );
      }
      return await _dashboardService.getMonthlyStats(_currentUser!.userId, month);
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

  // 초기 데이터 로드 (앱 시작 시)
  Future<void> loadInitialData() async {
    try {
      print('Starting initial data load...');
      
      // 기본 사용자 생성 (임시)
      _currentUser = User(
        userId: 'user_001',
        nickname: '물마시는사람',
        password: 'password',
        dailyWaterGoal: 1000,
        createdAt: DateTime.now(),
      );
      print('User created: ${_currentUser!.nickname}');

      // 서비스에서 현재 식물 로드
      try {
        _currentPlant = await _plantGrowthService.getCurrentPlant(_currentUser!.userId);
        print('Current plant loaded: ${_currentPlant?.name ?? 'null'}');
      } catch (e) {
        print('Error loading current plant: $e');
        _currentPlant = null;
      }
      
      // 식물이 없으면 기본 식물 생성
      if (_currentPlant == null) {
        _currentPlant = Plant(
          plantId: 'plant_001',
          name: '기본 식물',
          stage: 0,
          growthProgress: 0,
          totalGrowthRequired: 2000,
          imagePath: '🌱',
        );
        print('Default plant created: ${_currentPlant!.name}');
        
        try {
          await _plantGrowthService.saveCurrentPlant(_currentUser!.userId, _currentPlant!);
          print('Default plant saved');
        } catch (e) {
          print('Error saving default plant: $e');
        }
      }

      // 서비스에서 인벤토리 로드
      try {
        _inventory = await _plantGrowthService.getInventory(_currentUser!.userId);
        print('Inventory loaded: ${_inventory.length} items');
      } catch (e) {
        print('Error loading inventory: $e');
        _inventory = [];
      }
      
      // 인벤토리가 비어있으면 초기 씨앗 지급
      if (_inventory.isEmpty) {
        try {
          await _plantGrowthService.giveInitialSeeds(_currentUser!.userId);
          _inventory = await _plantGrowthService.getInventory(_currentUser!.userId);
          print('Initial seeds given: ${_inventory.length} items');
        } catch (e) {
          print('Error giving initial seeds: $e');
        }
      }

      // 오늘의 물 섭취량 계산
      try {
        await calculateTodayIntake();
        print('Today intake calculated: $_todayWaterIntake ml');
      } catch (e) {
        print('Error calculating today intake: $e');
        _todayWaterIntake = 0;
      }

      // 친구 목록 로드
      try {
        await loadFriends();
        print('Friends loaded: ${_friends.length} friends');
      } catch (e) {
        print('Error loading friends: $e');
        _friends = [];
      }

      print('Initial data load completed successfully');
      notifyListeners();
    } catch (e) {
      print('Critical error in loadInitialData: $e');
      // 최소한의 기본값이라도 설정
      if (_currentUser == null) {
        _currentUser = User(
          userId: 'user_001',
          nickname: '물마시는사람',
          password: 'password',
          dailyWaterGoal: 1000,
          createdAt: DateTime.now(),
        );
      }
      if (_currentPlant == null) {
        _currentPlant = Plant(
          plantId: 'plant_001',
          name: '기본 식물',
          stage: 0,
          growthProgress: 0,
          totalGrowthRequired: 2000,
          imagePath: '🌱',
        );
      }
      notifyListeners();
    }
  }
}
