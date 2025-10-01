import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsService {
  static const String _dailyGoalKey = 'daily_water_goal';
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _goalAchievementNotificationKey = 'goal_achievement_notification';
  static const String _notificationTimesKey = 'notification_times';
  static const String _userSettingsKey = 'user_settings';

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  // SharedPreferences 초기화
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 하루 목표 섭취량 설정
  Future<bool> setDailyGoal(int goal) async {
    await init();
    return await _prefs!.setInt(_dailyGoalKey, goal);
  }

  // 하루 목표 섭취량 조회
  Future<int> getDailyGoal() async {
    await init();
    return _prefs!.getInt(_dailyGoalKey) ?? 2000; // 기본값 2000ml
  }

  // 물 마시기 알림 설정
  Future<bool> setNotificationEnabled(bool enabled) async {
    await init();
    return await _prefs!.setBool(_notificationEnabledKey, enabled);
  }

  // 물 마시기 알림 상태 조회
  Future<bool> getNotificationEnabled() async {
    await init();
    return _prefs!.getBool(_notificationEnabledKey) ?? true; // 기본값 true
  }

  // 목표 달성 알림 설정
  Future<bool> setGoalAchievementNotification(bool enabled) async {
    await init();
    return await _prefs!.setBool(_goalAchievementNotificationKey, enabled);
  }

  // 목표 달성 알림 상태 조회
  Future<bool> getGoalAchievementNotification() async {
    await init();
    return _prefs!.getBool(_goalAchievementNotificationKey) ?? true; // 기본값 true
  }

  // 알림 시간 설정 (리스트)
  Future<bool> setNotificationTimes(List<String> times) async {
    await init();
    return await _prefs!.setStringList(_notificationTimesKey, times);
  }

  // 알림 시간 조회
  Future<List<String>> getNotificationTimes() async {
    await init();
    return _prefs!.getStringList(_notificationTimesKey) ?? 
           ['09:00', '12:00', '15:00', '18:00']; // 기본값
  }

  // 사용자 설정 전체 저장
  Future<bool> saveUserSettings(Map<String, dynamic> settings) async {
    await init();
    final settingsJson = jsonEncode(settings);
    return await _prefs!.setString(_userSettingsKey, settingsJson);
  }

  // 사용자 설정 전체 조회
  Future<Map<String, dynamic>> getUserSettings() async {
    await init();
    final settingsJson = _prefs!.getString(_userSettingsKey);
    if (settingsJson != null) {
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    }
    return {}; // 빈 맵 반환
  }

  // 설정 초기화
  Future<bool> resetSettings() async {
    await init();
    return await _prefs!.clear();
  }

  // 특정 설정 삭제
  Future<bool> removeSetting(String key) async {
    await init();
    return await _prefs!.remove(key);
  }

  // 모든 설정 조회 (디버깅용)
  Future<Map<String, dynamic>> getAllSettings() async {
    await init();
    final keys = _prefs!.getKeys();
    final Map<String, dynamic> settings = {};
    
    for (String key in keys) {
      final value = _prefs!.get(key);
      settings[key] = value;
    }
    
    return settings;
  }

  // 설정 변경 감지용 스트림 (선택사항)
  Stream<Map<String, dynamic>> get settingsStream async* {
    while (true) {
      yield await getAllSettings();
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
