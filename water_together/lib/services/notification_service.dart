import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';
import 'settings_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final SettingsService _settingsService = SettingsService();

  // 알림 초기화
  Future<void> init() async {
    // timezone 초기화
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 권한 요청
    await _requestPermissions();
    
    // 알림 채널 생성
    await createNotificationChannels();
  }

  // 알림 권한 요청
  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    // 알림 탭 시 처리 로직 (선택사항)
    debugPrint('알림 탭됨: ${response.payload}');
  }

  // 물 마시기 알림 스케줄링
  Future<void> scheduleWaterReminders() async {
    final isEnabled = await _settingsService.getNotificationEnabled();
    if (!isEnabled) return;

    final times = await _settingsService.getNotificationTimes();
    
    // 기존 알림 취소
    await cancelAllNotifications();

    // 각 시간에 알림 스케줄링
    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      await _scheduleDailyNotification(
        id: i + 1,
        hour: hour,
        minute: minute,
        title: '물 마시기 시간이에요! 💧',
        body: _getRandomWaterMessage(),
      );
    }
  }

  // 일일 알림 스케줄링
  Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'water_reminder',
      '물 마시기 알림',
      channelDescription: '정기적인 물 마시기 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(_nextInstanceOfTime(hour, minute), tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 다음 알림 시간 계산
  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // 목표 달성 알림
  Future<void> showGoalAchievementNotification() async {
    final isEnabled = await _settingsService.getGoalAchievementNotification();
    if (!isEnabled) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'goal_achievement',
      '목표 달성 알림',
      channelDescription: '하루 목표 달성 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '목표 달성! 🎉',
      '오늘의 물 마시기 목표를 달성했어요!',
      details,
    );
  }

  // 식물 성장 알림
  Future<void> showPlantGrowthNotification(String plantName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'plant_growth',
      '식물 성장 알림',
      channelDescription: '식물 성장 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '식물이 성장했어요! 🌱',
      '$plantName이 한 단계 성장했어요!',
      details,
    );
  }

  // 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // 랜덤 물 마시기 메시지 생성
  String _getRandomWaterMessage() {
    final messages = [
      '물을 마셔서 건강한 하루를 보내세요! 💧',
      '수분 보충이 필요해요! 물 한 잔 어떠세요?',
      '건강한 습관을 위해 물을 마셔보세요! 🌊',
      '물 마시기 시간이에요! 함께 마셔요!',
      '수분 부족을 방지하기 위해 물을 마셔주세요!',
      '물 한 잔으로 상쾌한 기분을 느껴보세요! ✨',
      '건강한 몸을 위해 물을 마셔주세요! 💪',
      '물 마시기로 활력 넘치는 하루를 만들어요!',
      '수분 섭취로 피부도 건강하게! 물을 마셔요!',
      '물 마시기 습관으로 건강한 라이프스타일을!',
    ];
    
    return messages[Random().nextInt(messages.length)];
  }

  // 알림 채널 생성 (Android)
  Future<void> createNotificationChannels() async {
    const AndroidNotificationChannel waterReminderChannel = AndroidNotificationChannel(
      'water_reminder',
      '물 마시기 알림',
      description: '정기적인 물 마시기 알림',
      importance: Importance.high,
    );

    const AndroidNotificationChannel goalAchievementChannel = AndroidNotificationChannel(
      'goal_achievement',
      '목표 달성 알림',
      description: '하루 목표 달성 알림',
      importance: Importance.high,
    );

    const AndroidNotificationChannel plantGrowthChannel = AndroidNotificationChannel(
      'plant_growth',
      '식물 성장 알림',
      description: '식물 성장 알림',
      importance: Importance.high,
    );

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(waterReminderChannel);
      await androidImplementation.createNotificationChannel(goalAchievementChannel);
      await androidImplementation.createNotificationChannel(plantGrowthChannel);
    }
  }

  // 알림 권한 상태 확인
  Future<bool> isNotificationPermissionGranted() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    
    return true; // iOS는 기본적으로 true
  }

  // 알림 설정 변경 시 스케줄 업데이트
  Future<void> updateNotificationSchedule() async {
    await scheduleWaterReminders();
  }
}
