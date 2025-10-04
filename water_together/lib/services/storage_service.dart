import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 로컬 데이터 저장 서비스
/// SharedPreferences를 래핑하여 타입 안전한 데이터 저장/불러오기 제공
class StorageService {
  static const String _userKey = 'user_data';
  static const String _waterLogsKey = 'water_logs';
  static const String _settingsKey = 'app_settings';
  static const String _inventoryKey = 'inventory_data';
  static const String _plantsKey = 'plants_data';
  
  // 싱글톤 패턴
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  /// SharedPreferences 초기화
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 사용자 데이터 저장
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    await initialize();
    try {
      final jsonString = jsonEncode(userData);
      return await _prefs!.setString(_userKey, jsonString);
    } catch (e) {
      print('사용자 데이터 저장 실패: $e');
      return false;
    }
  }

  /// 사용자 데이터 불러오기
  Future<Map<String, dynamic>?> loadUserData() async {
    await initialize();
    try {
      final jsonString = _prefs!.getString(_userKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('사용자 데이터 불러오기 실패: $e');
      return null;
    }
  }

  /// 물 기록 리스트 저장
  Future<bool> saveWaterLogs(List<Map<String, dynamic>> waterLogs) async {
    await initialize();
    try {
      final jsonString = jsonEncode(waterLogs);
      return await _prefs!.setString(_waterLogsKey, jsonString);
    } catch (e) {
      print('물 기록 저장 실패: $e');
      return false;
    }
  }

  /// 물 기록 리스트 불러오기
  Future<List<Map<String, dynamic>>> loadWaterLogs() async {
    await initialize();
    try {
      final jsonString = _prefs!.getString(_waterLogsKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('물 기록 불러오기 실패: $e');
      return [];
    }
  }

  /// 앱 설정 저장
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    await initialize();
    try {
      final jsonString = jsonEncode(settings);
      return await _prefs!.setString(_settingsKey, jsonString);
    } catch (e) {
      print('설정 저장 실패: $e');
      return false;
    }
  }

  /// 앱 설정 불러오기
  Future<Map<String, dynamic>> loadSettings() async {
    await initialize();
    try {
      final jsonString = _prefs!.getString(_settingsKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return _getDefaultSettings();
    } catch (e) {
      print('설정 불러오기 실패: $e');
      return _getDefaultSettings();
    }
  }

  /// 인벤토리 데이터 저장
  Future<bool> saveInventoryData(Map<String, dynamic> inventoryData) async {
    await initialize();
    try {
      final jsonString = jsonEncode(inventoryData);
      return await _prefs!.setString(_inventoryKey, jsonString);
    } catch (e) {
      print('인벤토리 데이터 저장 실패: $e');
      return false;
    }
  }

  /// 인벤토리 데이터 불러오기
  Future<Map<String, dynamic>> loadInventoryData() async {
    await initialize();
    try {
      final jsonString = _prefs!.getString(_inventoryKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return _getDefaultInventoryData();
    } catch (e) {
      print('인벤토리 데이터 불러오기 실패: $e');
      return _getDefaultInventoryData();
    }
  }

  /// 식물 데이터 저장
  Future<bool> savePlantsData(List<Map<String, dynamic>> plantsData) async {
    await initialize();
    try {
      final jsonString = jsonEncode(plantsData);
      return await _prefs!.setString(_plantsKey, jsonString);
    } catch (e) {
      print('식물 데이터 저장 실패: $e');
      return false;
    }
  }

  /// 식물 데이터 불러오기
  Future<List<Map<String, dynamic>>> loadPlantsData() async {
    await initialize();
    try {
      final jsonString = _prefs!.getString(_plantsKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('식물 데이터 불러오기 실패: $e');
      return [];
    }
  }

  /// 기본 설정값 반환
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'dailyWaterGoal': 2000, // 기본 목표량 2000ml
      'notificationsEnabled': true,
      'soundEnabled': true,
      'themeMode': 'system', // 'light', 'dark', 'system'
      'language': 'ko',
    };
  }

  /// 기본 인벤토리 데이터 반환
  Map<String, dynamic> _getDefaultInventoryData() {
    return {
      'seeds': [
        {
          'id': 'seed_1',
          'name': '해바라기 씨앗',
          'image': '🌻',
          'quantity': 3,
          'description': '밝고 화사한 해바라기를 키울 수 있어요!',
          'rarity': 'common',
        },
        {
          'id': 'seed_2',
          'name': '장미 씨앗',
          'image': '🌹',
          'quantity': 1,
          'description': '아름다운 장미를 키울 수 있어요!',
          'rarity': 'rare',
        },
        {
          'id': 'seed_3',
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

  /// 특정 키의 데이터 삭제
  Future<bool> removeData(String key) async {
    await initialize();
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      print('데이터 삭제 실패: $e');
      return false;
    }
  }

  /// 모든 데이터 삭제 (로그아웃 시 사용)
  Future<bool> clearAllData() async {
    await initialize();
    try {
      return await _prefs!.clear();
    } catch (e) {
      print('모든 데이터 삭제 실패: $e');
      return false;
    }
  }

  /// 데이터 존재 여부 확인
  Future<bool> hasData(String key) async {
    await initialize();
    return _prefs!.containsKey(key);
  }

  /// 저장된 모든 키 목록 반환
  Future<Set<String>> getAllKeys() async {
    await initialize();
    return _prefs!.getKeys();
  }
}

