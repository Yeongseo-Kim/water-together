import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plant.dart';
import '../models/water_log.dart';
import '../models/inventory.dart';
import '../models/friend.dart';
import '../services/notification_service.dart';
import '../services/user_data_service.dart';

class WaterProvider extends ChangeNotifier {
  // 서비스들
  final NotificationService _notificationService = NotificationService();
  final UserDataService _userDataService = UserDataService();

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
  final List<WaterLog> _waterLogs = [];
  List<WaterLog> get waterLogs => _waterLogs;

  // 인벤토리 (씨앗 목록)
  List<Inventory> _inventory = [];
  List<Inventory> get inventory => _inventory;

  // 친구 목록
  final List<Friend> _friends = [];
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
  Future<void> setDailyGoal(int goal) async {
    try {
      _dailyGoal = goal;
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(dailyWaterGoal: goal);
        await _userDataService.updateDailyGoal(_currentUser!.userId, goal);
      }
      notifyListeners();
    } catch (e) {
      print('목표량 설정 실패: $e');
    }
  }

  // 현재 식물 설정
  void setCurrentPlant(Plant plant) {
    _currentPlant = plant;
    notifyListeners();
  }

  // 물 섭취 기록 추가
  Future<void> addWaterLog(WaterLog log) async {
    try {
      _waterLogs.add(log);
      _todayWaterIntake += log.amount;
      
      // 데이터 서비스에 저장
      await _userDataService.addWaterLog(log);
      
      // 식물 성장 처리
      if (_currentPlant != null) {
        _currentPlant = _currentPlant!.addWater(log.amount);
        
        // 성장 단계 확인
        if (_currentPlant!.canGrowToNextStage()) {
          _currentPlant = _currentPlant!.growToNextStage();
        }
        
        // 사용자 식물 업데이트
        if (_currentUser != null) {
          await _userDataService.updateUserPlant(_currentUser!.userId, _currentPlant!);
        }
      }
      
      // 목표 달성 확인 및 알림
      _checkGoalAchievement();
      
      // 진행률 기반 알림 (50%, 75% 달성 시)
      _checkProgressMilestones();
      
      notifyListeners();
    } catch (e) {
      print('물 기록 추가 실패: $e');
    }
  }

  // 오늘의 물 섭취량 계산
  void calculateTodayIntake() {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    _todayWaterIntake = _waterLogs
        .where((log) => log.getDateKey() == todayKey)
        .fold(0, (sum, log) => sum + log.amount);
    
    notifyListeners();
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
  void addToInventory(Inventory item) {
    final existingIndex = _inventory.indexWhere((inv) => inv.seedId == item.seedId);
    
    if (existingIndex >= 0) {
      _inventory[existingIndex] = _inventory[existingIndex].addSeeds(item.quantity);
    } else {
      _inventory.add(item);
    }
    
    notifyListeners();
  }

  // 씨앗 사용
  void useSeed(String seedId) {
    final index = _inventory.indexWhere((inv) => inv.seedId == seedId);
    
    if (index >= 0 && _inventory[index].hasSeeds()) {
      _inventory[index] = _inventory[index].useSeed();
      notifyListeners();
    }
  }

  // 친구 추가
  void addFriend(Friend friend) {
    _friends.add(friend);
    notifyListeners();
  }

  // 친구 요청 수락
  void acceptFriend(String friendId) {
    final index = _friends.indexWhere((friend) => friend.friendId == friendId);
    
    if (index >= 0) {
      _friends[index] = _friends[index].acceptFriend();
      notifyListeners();
    }
  }

  // 탭 변경
  void changeTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // 초기 데이터 로드 (앱 시작 시)
  Future<void> loadInitialData() async {
    try {
      // 저장된 사용자 데이터 불러오기
      _currentUser = await _userDataService.loadUser();
      
      if (_currentUser == null) {
        // 사용자가 없으면 기본 사용자 생성
        _currentUser = await _userDataService.createDefaultUser('물마시는사람');
      }
      
      _dailyGoal = _currentUser!.dailyWaterGoal;
      _currentPlant = _currentUser!.plant;

      // 물 기록 불러오기
      _waterLogs.clear();
      _waterLogs.addAll(await _userDataService.loadWaterLogs());
      
      // 오늘의 물 섭취량 계산
      calculateTodayIntake();

      // 인벤토리 데이터 불러오기
      await _loadInventoryData();

      notifyListeners();
    } catch (e) {
      print('초기 데이터 로드 실패: $e');
      // 실패 시 기본값으로 설정
      _setDefaultData();
    }
  }

  // 기본 데이터 설정 (에러 시 사용)
  void _setDefaultData() {
    _currentUser = User(
      userId: 'user_001',
      nickname: '물마시는사람',
      password: '',
      dailyWaterGoal: 2000,
      createdAt: DateTime.now(),
    );

    _currentPlant = Plant(
      plantId: 'plant_001',
      name: '기본 식물',
      stage: 0,
      growthProgress: 0,
      totalGrowthRequired: 2000,
      imagePath: '🌱',
    );

    _inventory = [
      Inventory(
        userId: 'user_001',
        seedId: 'seed_001',
        quantity: 3,
        plantName: '기본 씨앗',
      ),
    ];

    notifyListeners();
  }

  // 인벤토리 데이터 로드
  Future<void> _loadInventoryData() async {
    try {
      final inventoryData = await _userDataService.loadInventoryData();
      final seeds = inventoryData['seeds'] as List<dynamic>? ?? [];
      
      _inventory.clear();
      for (final seedData in seeds) {
        _inventory.add(Inventory(
          userId: _currentUser?.userId ?? 'unknown',
          seedId: seedData['id'] ?? '',
          quantity: seedData['quantity'] ?? 0,
          plantName: seedData['name'] ?? '',
        ));
      }
    } catch (e) {
      print('인벤토리 데이터 로드 실패: $e');
    }
  }

  // 목표 달성 확인
  void _checkGoalAchievement() {
    if (isGoalAchieved()) {
      _notificationService.showGoalAchievementNotification();
    }
  }

  // 진행률 마일스톤 확인
  void _checkProgressMilestones() {
    final progress = getGoalAchievementRate();
    
    // 50% 달성 시 알림
    if (progress >= 0.5 && progress < 0.6) {
      _notificationService.showProgressNotification(progress);
    }
    // 75% 달성 시 알림
    else if (progress >= 0.75 && progress < 0.8) {
      _notificationService.showProgressNotification(progress);
    }
  }

  // 친구 활동 알림 (외부에서 호출)
  void notifyFriendActivity(String friendName) {
    _notificationService.showFriendActivityNotification(friendName);
  }

  // 챌린지 알림 (외부에서 호출)
  void notifyChallenge(String challengeName) {
    _notificationService.showChallengeNotification(challengeName);
  }

  // 시간대별 맞춤 알림 (외부에서 호출)
  void showTimeBasedNotification() {
    _notificationService.showTimeBasedNotification();
  }
}
