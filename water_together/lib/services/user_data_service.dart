import 'storage_service.dart';
import '../models/user.dart';
import '../models/water_log.dart';
import '../models/plant.dart';

/// 사용자 데이터 관리 서비스
/// 모델 객체와 JSON 간 변환, 데이터 검증, 기본값 처리 담당
class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  final StorageService _storageService = StorageService();

  /// 사용자 데이터 저장
  Future<bool> saveUser(User user) async {
    try {
      final userData = user.toJson();
      return await _storageService.saveUserData(userData);
    } catch (e) {
      print('사용자 저장 실패: $e');
      return false;
    }
  }

  /// 사용자 데이터 불러오기
  Future<User?> loadUser() async {
    try {
      final userData = await _storageService.loadUserData();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('사용자 불러오기 실패: $e');
      return null;
    }
  }

  /// 기본 사용자 생성
  Future<User> createDefaultUser(String nickname) async {
    final now = DateTime.now();
    final userId = 'user_${now.millisecondsSinceEpoch}';
    
    final defaultUser = User(
      userId: userId,
      nickname: nickname,
      password: '', // 로컬 앱이므로 비밀번호 불필요
      dailyWaterGoal: 2000, // 기본 목표량 2000ml
      createdAt: now,
      plant: null, // 초기에는 식물 없음
    );

    await saveUser(defaultUser);
    return defaultUser;
  }

  /// 물 기록 저장
  Future<bool> saveWaterLogs(List<WaterLog> waterLogs) async {
    try {
      final logsData = waterLogs.map((log) => log.toJson()).toList();
      return await _storageService.saveWaterLogs(logsData);
    } catch (e) {
      print('물 기록 저장 실패: $e');
      return false;
    }
  }

  /// 물 기록 불러오기
  Future<List<WaterLog>> loadWaterLogs() async {
    try {
      final logsData = await _storageService.loadWaterLogs();
      return logsData.map((data) => WaterLog.fromJson(data)).toList();
    } catch (e) {
      print('물 기록 불러오기 실패: $e');
      return [];
    }
  }

  /// 특정 날짜의 물 기록 불러오기
  Future<List<WaterLog>> loadWaterLogsByDate(DateTime date) async {
    try {
      final allLogs = await loadWaterLogs();
      final targetDateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      return allLogs.where((log) => log.getDateKey() == targetDateKey).toList();
    } catch (e) {
      print('날짜별 물 기록 불러오기 실패: $e');
      return [];
    }
  }

  /// 오늘의 물 기록 불러오기
  Future<List<WaterLog>> loadTodayWaterLogs() async {
    return await loadWaterLogsByDate(DateTime.now());
  }

  /// 오늘의 총 물 섭취량 계산
  Future<int> getTodayWaterIntake() async {
    try {
      final todayLogs = await loadTodayWaterLogs();
      return todayLogs.fold<int>(0, (sum, log) => sum + log.amount);
    } catch (e) {
      print('오늘 물 섭취량 계산 실패: $e');
      return 0;
    }
  }

  /// 물 기록 추가
  Future<bool> addWaterLog(WaterLog waterLog) async {
    try {
      final existingLogs = await loadWaterLogs();
      existingLogs.add(waterLog);
      return await saveWaterLogs(existingLogs);
    } catch (e) {
      print('물 기록 추가 실패: $e');
      return false;
    }
  }

  /// 사용자 목표량 업데이트
  Future<bool> updateDailyGoal(String userId, int newGoal) async {
    try {
      final user = await loadUser();
      if (user != null && user.userId == userId) {
        final updatedUser = user.copyWith(dailyWaterGoal: newGoal);
        return await saveUser(updatedUser);
      }
      return false;
    } catch (e) {
      print('목표량 업데이트 실패: $e');
      return false;
    }
  }

  /// 사용자 닉네임 업데이트
  Future<bool> updateNickname(String userId, String newNickname) async {
    try {
      final user = await loadUser();
      if (user != null && user.userId == userId) {
        final updatedUser = user.copyWith(nickname: newNickname);
        return await saveUser(updatedUser);
      }
      return false;
    } catch (e) {
      print('닉네임 업데이트 실패: $e');
      return false;
    }
  }

  /// 사용자 식물 업데이트
  Future<bool> updateUserPlant(String userId, Plant? plant) async {
    try {
      final user = await loadUser();
      if (user != null && user.userId == userId) {
        final updatedUser = plant == null 
          ? user.copyWith(clearPlant: true)
          : user.copyWith(plant: plant);
        return await saveUser(updatedUser);
      }
      return false;
    } catch (e) {
      print('사용자 식물 업데이트 실패: $e');
      return false;
    }
  }

  /// 앱 설정 저장
  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      return await _storageService.saveSettings(settings);
    } catch (e) {
      print('앱 설정 저장 실패: $e');
      return false;
    }
  }

  /// 앱 설정 불러오기
  Future<Map<String, dynamic>> loadAppSettings() async {
    try {
      return await _storageService.loadSettings();
    } catch (e) {
      print('앱 설정 불러오기 실패: $e');
      return {
        'dailyWaterGoal': 2000,
        'notificationsEnabled': true,
        'soundEnabled': true,
        'themeMode': 'system',
        'language': 'ko',
      };
    }
  }

  /// 인벤토리 데이터 저장
  Future<bool> saveInventoryData(Map<String, dynamic> inventoryData) async {
    try {
      return await _storageService.saveInventoryData(inventoryData);
    } catch (e) {
      print('인벤토리 데이터 저장 실패: $e');
      return false;
    }
  }

  /// 인벤토리 데이터 불러오기
  Future<Map<String, dynamic>> loadInventoryData() async {
    try {
      return await _storageService.loadInventoryData();
    } catch (e) {
      print('인벤토리 데이터 불러오기 실패: $e');
      return {
        'seeds': [
          {
            'id': 'seed_1',
            'name': '민들레 씨앗',
            'image': '🌼',
            'quantity': 3,
            'description': '밝고 화사한 민들레를 키울 수 있어요!',
            'rarity': 'common',
          },
          {
            'id': 'seed_2',
            'name': '해바라기 씨앗',
            'image': '🌻',
            'quantity': 2,
            'description': '태양을 따라 도는 해바라기를 키울 수 있어요!',
            'rarity': 'rare',
          },
          {
            'id': 'seed_3',
            'name': '선인장 씨앗',
            'image': '🌵',
            'quantity': 2,
            'description': '조용하고 물을 적게 마시는 선인장을 키울 수 있어요!',
            'rarity': 'common',
          },
          {
            'id': 'seed_4',
            'name': '장미 씨앗',
            'image': '🌹',
            'quantity': 1,
            'description': '신비롭고 아름다운 장미를 키울 수 있어요!',
            'rarity': 'epic',
          },
          {
            'id': 'seed_5',
            'name': '튤립 씨앗',
            'image': '🌷',
            'quantity': 2,
            'description': '우아한 튤립을 키울 수 있어요!',
            'rarity': 'common',
          },
        ],
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 씨앗 수량 업데이트
  Future<bool> updateSeedQuantity(String seedId, int newQuantity) async {
    try {
      final inventoryData = await loadInventoryData();
      final seeds = List<Map<String, dynamic>>.from(inventoryData['seeds'] ?? []);
      
      final seedIndex = seeds.indexWhere((seed) => seed['id'] == seedId);
      if (seedIndex != -1) {
        seeds[seedIndex]['quantity'] = newQuantity;
        inventoryData['seeds'] = seeds;
        inventoryData['lastUpdated'] = DateTime.now().toIso8601String();
        return await saveInventoryData(inventoryData);
      }
      return false;
    } catch (e) {
      print('씨앗 수량 업데이트 실패: $e');
      return false;
    }
  }

  /// 씨앗 추가
  Future<bool> addSeed(Map<String, dynamic> seedData) async {
    try {
      final inventoryData = await loadInventoryData();
      final seeds = List<Map<String, dynamic>>.from(inventoryData['seeds'] ?? []);
      
      // 이미 존재하는 씨앗인지 확인
      final existingIndex = seeds.indexWhere((seed) => seed['id'] == seedData['id']);
      if (existingIndex != -1) {
        // 기존 씨앗 수량 증가
        seeds[existingIndex]['quantity'] = (seeds[existingIndex]['quantity'] ?? 0) + (seedData['quantity'] ?? 1);
      } else {
        // 새 씨앗 추가
        seeds.add(seedData);
      }
      
      inventoryData['seeds'] = seeds;
      inventoryData['lastUpdated'] = DateTime.now().toIso8601String();
      return await saveInventoryData(inventoryData);
    } catch (e) {
      print('씨앗 추가 실패: $e');
      return false;
    }
  }

  /// 모든 데이터 초기화 (로그아웃)
  Future<bool> clearAllUserData() async {
    try {
      return await _storageService.clearAllData();
    } catch (e) {
      print('사용자 데이터 초기화 실패: $e');
      return false;
    }
  }

  /// 데이터 백업 (향후 클라우드 연동용)
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      final user = await loadUser();
      final waterLogs = await loadWaterLogs();
      final settings = await loadAppSettings();
      final inventory = await loadInventoryData();
      
      return {
        'user': user?.toJson(),
        'waterLogs': waterLogs.map((log) => log.toJson()).toList(),
        'settings': settings,
        'inventory': inventory,
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('데이터 백업 실패: $e');
      return {};
    }
  }

  /// 데이터 복원 (향후 클라우드 연동용)
  Future<bool> importUserData(Map<String, dynamic> data) async {
    try {
      if (data['user'] != null) {
        await _storageService.saveUserData(data['user']);
      }
      if (data['waterLogs'] != null) {
        await _storageService.saveWaterLogs(data['waterLogs']);
      }
      if (data['settings'] != null) {
        await _storageService.saveSettings(data['settings']);
      }
      if (data['inventory'] != null) {
        await _storageService.saveInventoryData(data['inventory']);
      }
      return true;
    } catch (e) {
      print('데이터 복원 실패: $e');
      return false;
    }
  }
}
