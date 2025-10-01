import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../data/notification_messages.dart';

/// 알림 서비스
/// 로컬 알림을 관리하고 스케줄링하는 서비스입니다.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // 알림 설정 상태
  bool _isInitialized = false;
  bool _waterRemindersEnabled = true;
  bool _goalAchievementEnabled = true;
  bool _friendActivityEnabled = true;
  bool _encouragementEnabled = true;
  bool _challengeEnabled = true;

  // 알림 설정 시간
  List<int> _reminderHours = [9, 12, 15, 18]; // 오전 9시, 12시, 3시, 6시
  int _encouragementHour = 20; // 오후 8시

  // Getters
  bool get isInitialized => _isInitialized;
  bool get waterRemindersEnabled => _waterRemindersEnabled;
  bool get goalAchievementEnabled => _goalAchievementEnabled;
  bool get friendActivityEnabled => _friendActivityEnabled;
  bool get encouragementEnabled => _encouragementEnabled;
  bool get challengeEnabled => _challengeEnabled;
  List<int> get reminderHours => _reminderHours;
  int get encouragementHour => _encouragementHour;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 타임존 초기화
      tz.initializeTimeZones();

      // Android 초기화 설정
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS 초기화 설정
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // 설정 로드
      await _loadSettings();
      
      _isInitialized = true;
      debugPrint('알림 서비스 초기화 완료');
    } catch (e) {
      debugPrint('알림 서비스 초기화 실패: $e');
      // 초기화 실패해도 앱은 계속 실행되도록 함
    }
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    // 알림 탭 시 앱으로 이동하거나 특정 화면으로 이동
    debugPrint('알림 탭됨: ${response.payload}');
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _waterRemindersEnabled = prefs.getBool('water_reminders_enabled') ?? true;
    _goalAchievementEnabled = prefs.getBool('goal_achievement_enabled') ?? true;
    _friendActivityEnabled = prefs.getBool('friend_activity_enabled') ?? true;
    _encouragementEnabled = prefs.getBool('encouragement_enabled') ?? true;
    _challengeEnabled = prefs.getBool('challenge_enabled') ?? true;
    
    final reminderHoursString = prefs.getString('reminder_hours');
    if (reminderHoursString != null) {
      _reminderHours = reminderHoursString.split(',').map(int.parse).toList();
    }
    
    _encouragementHour = prefs.getInt('encouragement_hour') ?? 20;
  }

  /// 설정 저장
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('water_reminders_enabled', _waterRemindersEnabled);
    await prefs.setBool('goal_achievement_enabled', _goalAchievementEnabled);
    await prefs.setBool('friend_activity_enabled', _friendActivityEnabled);
    await prefs.setBool('encouragement_enabled', _encouragementEnabled);
    await prefs.setBool('challenge_enabled', _challengeEnabled);
    await prefs.setString('reminder_hours', _reminderHours.join(','));
    await prefs.setInt('encouragement_hour', _encouragementHour);
  }

  /// 물 마시기 알림 설정
  void setWaterRemindersEnabled(bool enabled) {
    _waterRemindersEnabled = enabled;
    _saveSettings();
    if (enabled) {
      scheduleWaterReminders();
    } else {
      cancelWaterReminders();
    }
  }

  /// 목표 달성 알림 설정
  void setGoalAchievementEnabled(bool enabled) {
    _goalAchievementEnabled = enabled;
    _saveSettings();
  }

  /// 친구 활동 알림 설정
  void setFriendActivityEnabled(bool enabled) {
    _friendActivityEnabled = enabled;
    _saveSettings();
  }

  /// 격려 메시지 알림 설정
  void setEncouragementEnabled(bool enabled) {
    _encouragementEnabled = enabled;
    _saveSettings();
    if (enabled) {
      scheduleEncouragementReminder();
    } else {
      cancelEncouragementReminder();
    }
  }

  /// 챌린지 알림 설정
  void setChallengeEnabled(bool enabled) {
    _challengeEnabled = enabled;
    _saveSettings();
  }

  /// 알림 시간 설정
  void setReminderHours(List<int> hours) {
    _reminderHours = hours;
    _saveSettings();
    if (_waterRemindersEnabled) {
      cancelWaterReminders();
      scheduleWaterReminders();
    }
  }

  /// 격려 메시지 시간 설정
  void setEncouragementHour(int hour) {
    _encouragementHour = hour;
    _saveSettings();
    if (_encouragementEnabled) {
      cancelEncouragementReminder();
      scheduleEncouragementReminder();
    }
  }

  /// 물 마시기 알림 스케줄링
  Future<void> scheduleWaterReminders() async {
    if (!_waterRemindersEnabled) return;

    // 기존 알림 취소
    await cancelWaterReminders();

    for (int i = 0; i < _reminderHours.length; i++) {
      final hour = _reminderHours[i];
      final id = 1000 + i; // 고유 ID

      await _notifications.zonedSchedule(
        id,
        '물 마실 시간이에요!',
        NotificationMessages.getRandomWaterReminder(),
        _nextInstanceOfTime(hour),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminders',
            '물 마시기 알림',
            channelDescription: '정기적인 물 마시기 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// 격려 메시지 알림 스케줄링
  Future<void> scheduleEncouragementReminder() async {
    if (!_encouragementEnabled) return;

    await cancelEncouragementReminder();

    await _notifications.zonedSchedule(
      2000,
      '오늘도 화이팅!',
      NotificationMessages.getRandomEncouragement(),
      _nextInstanceOfTime(_encouragementHour),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'encouragement',
          '격려 메시지',
          channelDescription: '일일 격려 메시지',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 물 마시기 알림 취소
  Future<void> cancelWaterReminders() async {
    for (int i = 0; i < _reminderHours.length; i++) {
      await _notifications.cancel(1000 + i);
    }
  }

  /// 격려 메시지 알림 취소
  Future<void> cancelEncouragementReminder() async {
    await _notifications.cancel(2000);
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 즉시 알림 표시
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'instant',
          '즉시 알림',
          channelDescription: '즉시 표시되는 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// 목표 달성 알림
  Future<void> showGoalAchievementNotification() async {
    if (!_goalAchievementEnabled) return;

    await showInstantNotification(
      title: '🎉 목표 달성!',
      body: NotificationMessages.getRandomGoalAchievement(),
      payload: 'goal_achievement',
    );
  }

  /// 친구 활동 알림
  Future<void> showFriendActivityNotification(String friendName) async {
    if (!_friendActivityEnabled) return;

    await showInstantNotification(
      title: '👥 친구 활동',
      body: '$friendName님이 ${NotificationMessages.getRandomFriendActivity()}',
      payload: 'friend_activity',
    );
  }

  /// 챌린지 알림
  Future<void> showChallengeNotification(String challengeName) async {
    if (!_challengeEnabled) return;

    await showInstantNotification(
      title: '🎪 챌린지 알림',
      body: '$challengeName - ${NotificationMessages.getRandomChallenge()}',
      payload: 'challenge',
    );
  }

  /// 진행률 기반 알림
  Future<void> showProgressNotification(double progress) async {
    if (!_waterRemindersEnabled) return;

    final message = NotificationMessages.getProgressBasedMessage(progress);
    
    await showInstantNotification(
      title: '💧 물 섭취 현황',
      body: message,
      payload: 'progress',
    );
  }

  /// 시간대별 맞춤 알림
  Future<void> showTimeBasedNotification() async {
    if (!_waterRemindersEnabled) return;

    await showInstantNotification(
      title: '💧 물 마실 시간',
      body: NotificationMessages.getTimeBasedMessage(),
      payload: 'time_based',
    );
  }

  /// 다음 지정 시간 계산
  tz.TZDateTime _nextInstanceOfTime(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// 알림 권한 요청
  Future<bool> requestPermissions() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    return result ?? false;
  }

  /// 알림 권한 확인
  Future<bool> areNotificationsEnabled() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    
    return result ?? false;
  }

  /// 알림 채널 생성 (Android)
  Future<void> createNotificationChannels() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'water_reminders',
            '물 마시기 알림',
            description: '정기적인 물 마시기 알림',
            importance: Importance.high,
          ),
        );
        
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'encouragement',
            '격려 메시지',
            description: '일일 격려 메시지',
            importance: Importance.defaultImportance,
          ),
        );
        
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'instant',
            '즉시 알림',
            description: '즉시 표시되는 알림',
            importance: Importance.high,
          ),
        );
        debugPrint('알림 채널 생성 완료');
      }
    } catch (e) {
      debugPrint('알림 채널 생성 실패: $e');
    }
  }
}