import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plant.dart';
import '../models/water_log.dart';
import '../models/inventory.dart';
import '../models/friend.dart';
import '../services/notification_service.dart';
import '../services/user_data_service.dart';
import '../services/plant_config_service.dart';
import '../widgets/plant_completion_dialog.dart';

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

  // 식물 완성 팝업 관련
  bool _showCompletionDialog = false;
  String _completedPlantName = '';
  String _completedPlantImage = '';
  String _rewardPlantSeed = '';
  String _rewardRandomSeed = '';
  
  bool get showCompletionDialog => _showCompletionDialog;
  String get completedPlantName => _completedPlantName;
  String get completedPlantImage => _completedPlantImage;
  String get rewardPlantSeed => _rewardPlantSeed;
  String get rewardRandomSeed => _rewardRandomSeed;

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

  // 완성된 식물 제거 (새로운 씨앗 심기를 위해)
  Future<void> removeCompletedPlant() async {
    if (_currentPlant != null && _currentPlant!.completedAt != null) {
      _currentPlant = null;
      
      // 사용자 식물 제거
      if (_currentUser != null) {
        await _userDataService.updateUserPlant(_currentUser!.userId, null);
        // _currentUser의 plant 필드도 동기화
        _currentUser = _currentUser!.copyWith(plant: null);
      }
      
      notifyListeners();
      print('완성된 식물이 제거되었습니다. 새로운 씨앗을 심을 수 있습니다.');
    }
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
        print('🌱 물 추가 전 - 단계: ${_currentPlant!.stage}, 진행도: ${_currentPlant!.growthProgress}/${_currentPlant!.totalGrowthRequired}');
        
        _currentPlant = _currentPlant!.addWater(log.amount);
        
        print('💧 물 추가 후 - 단계: ${_currentPlant!.stage}, 진행도: ${_currentPlant!.growthProgress}/${_currentPlant!.totalGrowthRequired}');
        print('🔍 완성 여부: ${_currentPlant!.isFullyGrown()}, 다음 단계 가능: ${_currentPlant!.canGrowToNextStage()}');
        
        // 최종 단계 보상 확인 (성장 단계 업그레이드 전에 확인)
        // 완성된 식물은 더 이상 보상을 받지 않음 (completedAt이 null인 경우만)
        if (_currentPlant!.isFullyGrown() && _currentPlant!.completedAt == null) {
          print('🎉 최종 단계 보상 지급 시작');
          await _giveFinalStageReward();
        }
        
        // 성장 단계 확인
        if (_currentPlant!.canGrowToNextStage()) {
          print('📈 다음 단계로 성장!');
          _currentPlant = _currentPlant!.growToNextStage();
          print('🌿 성장 후 - 단계: ${_currentPlant!.stage}, 진행도: ${_currentPlant!.growthProgress}/${_currentPlant!.totalGrowthRequired}');
        }
        
        // 사용자 식물 업데이트
        if (_currentUser != null) {
          await _userDataService.updateUserPlant(_currentUser!.userId, _currentPlant!);
          // _currentUser의 plant 필드도 동기화
          _currentUser = _currentUser!.copyWith(plant: _currentPlant);
          print('🔄 사용자 데이터 동기화 완료 - Stage: ${_currentUser!.plant?.stage}, 진행도: ${_currentUser!.plant?.growthProgress}');
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
    
    // 인벤토리 데이터 저장
    _saveInventoryData();
    
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

  // 식물 심기 기능
  Future<bool> plantSeed(String seedId, String seedName, String seedImage) async {
    try {
      // 이미 식물이 있고 완성되지 않은 경우 심기 방지
      if (_currentPlant != null && _currentPlant!.completedAt == null) {
        print('이미 식물이 심어져 있습니다. 기존 식물을 완성한 후 새로운 씨앗을 심어주세요.');
        return false;
      }
      
      // 식물 설정에서 해당 식물 정보 가져오기
      // 씨앗 이름에서 "씨앗" 제거하고 순수한 식물 이름만 사용
      String cleanPlantName = seedName.replaceAll(' 씨앗', '').replaceAll('씨앗', '');
      print('🌱 씨앗 심기: $seedName → $cleanPlantName');
      final plantConfig = PlantConfigService.instance.getPlantConfig(cleanPlantName);
      print('🌱 식물 설정 로드: ${plantConfig != null ? "성공" : "실패"}');
      if (plantConfig != null) {
        print('🌱 단계별 이미지: ${plantConfig.stageImages}');
        print('🌱 단계별 요구량: ${plantConfig.stageRequirements}');
      }
      
      // 새로운 식물 생성
      final newPlant = Plant(
        plantId: 'plant_${DateTime.now().millisecondsSinceEpoch}',
        plantTypeId: cleanPlantName, // PlantConfig의 plantId 참조
        name: cleanPlantName,
        stage: 0, // 씨앗 단계
        growthProgress: 0,
        totalGrowthRequired: plantConfig?.stageRequirements[0] ?? 500, // 설정에서 가져오기
        imagePath: plantConfig?.stageImages[0] ?? seedImage, // 설정에서 가져오기
        createdAt: DateTime.now(),
        completedAt: null,
        totalWaterConsumed: 0,
      );

      // 현재 식물 교체
      _currentPlant = newPlant;
      
      // 사용자 식물 업데이트
      if (_currentUser != null) {
        await _userDataService.updateUserPlant(_currentUser!.userId, newPlant);
        // _currentUser의 plant 필드도 동기화
        _currentUser = _currentUser!.copyWith(plant: newPlant);
      }

      // 인벤토리에서 씨앗 수량 차감 (있는 경우에만)
      final inventoryIndex = _inventory.indexWhere((inv) => inv.seedId == seedId);
      if (inventoryIndex >= 0 && _inventory[inventoryIndex].hasSeeds()) {
        _inventory[inventoryIndex] = _inventory[inventoryIndex].useSeed();
        // 인벤토리 데이터 저장
        await _saveInventoryData();
      }

      notifyListeners();
      return true; // 심기 성공
    } catch (e) {
      print('식물 심기 실패: $e');
      return false; // 심기 실패
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
      // 식물 설정 먼저 로드
      await PlantConfigService.instance.loadPlantConfigs();
      
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
      plantTypeId: '민들레',
      name: '기본 식물',
      stage: 0,
      growthProgress: 0,
      totalGrowthRequired: 500,
      imagePath: '🌱',
      createdAt: DateTime.now(),
      completedAt: null,
      totalWaterConsumed: 0,
    );

    _inventory = [
      Inventory(
        userId: 'user_001',
        seedId: 'seed_001',
        quantity: 3,
        plantName: '기본 씨앗',
        image: '🌱',
      ),
    ];

    notifyListeners();
  }

  // 인벤토리 데이터 로드
  // 인벤토리 데이터 저장
  Future<void> _saveInventoryData() async {
    try {
      final inventoryData = {
        'seeds': _inventory.map((item) => {
          'id': item.seedId,
          'name': item.plantName,
          'image': item.image,
          'quantity': item.quantity,
          'description': '${item.plantName}을(를) 키울 수 있어요!',
          'rarity': 'common',
        }).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await _userDataService.saveInventoryData(inventoryData);
    } catch (e) {
      print('인벤토리 데이터 저장 실패: $e');
    }
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
          image: seedData['image'] ?? '🌱',
        ));
      }
    } catch (e) {
      print('인벤토리 데이터 로드 실패: $e');
    }
  }

  // 인벤토리 데이터를 JSON 형태로 가져오기 (UI에서 사용)
  List<Map<String, dynamic>> getInventoryItems() {
    return _inventory.map((item) => {
      'id': item.seedId,
      'name': item.plantName,
      'image': item.image,
      'quantity': item.quantity,
      'description': '${item.plantName}을(를) 키울 수 있어요!',
      'rarity': 'common',
    }).toList();
  }

  // 씨앗 이름에 따른 이미지 가져오기
  String _getSeedImage(String plantName) {
    // "씨앗" 제거하고 식물 이름만 추출
    String cleanName = plantName.replaceAll(' 씨앗', '').replaceAll('씨앗', '');
    
    switch (cleanName) {
      case '민들레':
        return '🌼';
      case '해바라기':
        return '🌻';
      case '선인장':
        return '🌵';
      case '장미':
        return '🌹';
      case '튤립':
        return '🌷';
      case '기본':
        return '🌱';
      default:
        return '🌱';
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

  // 최종 단계 보상 지급
  Future<void> _giveFinalStageReward() async {
    if (_currentPlant == null) return;
    
    try {
      // 보상 씨앗 정보 수집
      final plantSeedImage = _currentPlant!.currentStageImage;
      final randomSeedImage = _getRandomSeedImage();
      
      // 1. 해당 식물의 씨앗 1개 추가
      await _addPlantSeedReward();
      
      // 2. 랜덤 씨앗 1개 추가
      await _addRandomSeedReward();
      
      // 3. 도감에 완성된 식물 추가
      await _addToCollection();
      
      // 4. 식물을 완성 상태로 표시 (completedAt 설정)
      _currentPlant = _currentPlant!.copyWith(completedAt: DateTime.now());
      if (_currentUser != null) {
        await _userDataService.updateUserPlant(_currentUser!.userId, _currentPlant!);
        // _currentUser의 plant 필드도 동기화
        _currentUser = _currentUser!.copyWith(plant: _currentPlant);
      }
      
      // 5. 팝업 데이터 설정
      _completedPlantName = _currentPlant!.name;
      _completedPlantImage = plantSeedImage;
      _rewardPlantSeed = plantSeedImage;
      _rewardRandomSeed = randomSeedImage;
      _showCompletionDialog = true;
      
      // 6. 축하 메시지 표시
      _showCelebrationMessage();
      
      notifyListeners();
      
    } catch (e) {
      print('최종 단계 보상 지급 실패: $e');
    }
  }

  // 해당 식물의 씨앗 보상 추가
  Future<void> _addPlantSeedReward() async {
    if (_currentPlant == null) return;
    
    final seedData = {
      'id': 'seed_${_currentPlant!.plantId}_reward',
      'name': '${_currentPlant!.name} 씨앗',
      'image': _currentPlant!.imagePath,
      'quantity': 1,
      'description': '완성한 ${_currentPlant!.name}에서 얻은 씨앗입니다.',
      'rarity': 'reward',
    };
    
    await _userDataService.addSeed(seedData);
    
    // 인벤토리 새로고침
    await _loadInventoryData();
    // 인벤토리 데이터 저장
    await _saveInventoryData();
  }

  // 랜덤 씨앗 보상 추가
  Future<void> _addRandomSeedReward() async {
    final randomSeeds = [
      {'name': '해바라기 씨앗', 'image': '🌻', 'description': '밝고 화사한 해바라기 씨앗입니다.'},
      {'name': '장미 씨앗', 'image': '🌹', 'description': '아름다운 장미 씨앗입니다.'},
      {'name': '튤립 씨앗', 'image': '🌷', 'description': '우아한 튤립 씨앗입니다.'},
      {'name': '민들레 씨앗', 'image': '🌼', 'description': '노란 민들레 씨앗입니다.'},
      {'name': '선인장 씨앗', 'image': '🌵', 'description': '사막의 선인장 씨앗입니다.'},
    ];
    
    final randomSeed = randomSeeds[DateTime.now().millisecondsSinceEpoch % randomSeeds.length];
    
    final seedData = {
      'id': 'seed_random_${DateTime.now().millisecondsSinceEpoch}',
      'name': randomSeed['name'],
      'image': randomSeed['image'],
      'quantity': 1,
      'description': randomSeed['description'],
      'rarity': 'random',
    };
    
    await _userDataService.addSeed(seedData);
    
    // 인벤토리 새로고침
    await _loadInventoryData();
    // 인벤토리 데이터 저장
    await _saveInventoryData();
  }

  // 도감에 완성된 식물 추가
  Future<void> _addToCollection() async {
    if (_currentPlant == null) return;
    
    // 향후 도감 시스템 구현 시 사용할 데이터 구조
    // final collectionData = {
    //   'plantId': _currentPlant!.plantId,
    //   'name': _currentPlant!.name,
    //   'image': _currentPlant!.imagePath,
    //   'completedAt': DateTime.now().toIso8601String(),
    //   'stage': _currentPlant!.stage,
    // };
    
    print('도감에 추가된 식물: ${_currentPlant!.name}');
  }

  // 축하 메시지 표시
  void _showCelebrationMessage() {
    if (_currentPlant == null) return;
    
    // 축하 메시지 표시 (향후 UI에 반영)
    print('🎉 축하합니다! ${_currentPlant!.name}이(가) 완성되었습니다!');
    print('보상으로 ${_currentPlant!.name} 씨앗 1개와 랜덤 씨앗 1개를 받았습니다!');
  }

  // 랜덤 씨앗 이미지 가져오기
  String _getRandomSeedImage() {
    final randomSeeds = ['🌻', '🌹', '🌷', '🌼', '🌵'];
    return randomSeeds[DateTime.now().millisecondsSinceEpoch % randomSeeds.length];
  }

  // 완성 팝업 닫기
  void closeCompletionDialog() {
    _showCompletionDialog = false;
    notifyListeners();
  }
}
