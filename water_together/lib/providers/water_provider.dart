import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plant.dart';
import '../models/water_log.dart';
import '../models/inventory.dart';
import '../models/friend.dart';

class WaterProvider extends ChangeNotifier {
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
  void addWaterLog(WaterLog log) {
    _waterLogs.add(log);
    _todayWaterIntake += log.amount;
    
    // 식물 성장 처리
    if (_currentPlant != null) {
      _currentPlant = _currentPlant!.addWater(log.amount);
      
      // 성장 단계 확인
      if (_currentPlant!.canGrowToNextStage()) {
        _currentPlant = _currentPlant!.growToNextStage();
      }
    }
    
    notifyListeners();
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
  void loadInitialData() {
    // 기본 사용자 생성 (임시)
    _currentUser = User(
      userId: 'user_001',
      nickname: '물마시는사람',
      password: 'password',
      dailyWaterGoal: 1000,
      createdAt: DateTime.now(),
    );

    // 기본 식물 생성 (씨앗 상태)
    _currentPlant = Plant(
      plantId: 'plant_001',
      name: '기본 식물',
      stage: 0,
      growthProgress: 0,
      totalGrowthRequired: 2000,
      imagePath: '🌱',
    );

    // 기본 씨앗 인벤토리
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
}
