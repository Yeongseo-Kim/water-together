import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();
  
  bool _notificationEnabled = true;
  bool _goalAchievementNotification = true;
  List<String> _notificationTimes = ['09:00', '12:00', '15:00', '18:00'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationEnabled = await _settingsService.getNotificationEnabled();
    final goalAchievementNotification = await _settingsService.getGoalAchievementNotification();
    final notificationTimes = await _settingsService.getNotificationTimes();
    
    setState(() {
      _notificationEnabled = notificationEnabled;
      _goalAchievementNotification = goalAchievementNotification;
      _notificationTimes = notificationTimes;
    });
  }

  Future<void> _updateNotificationEnabled(bool value) async {
    await _settingsService.setNotificationEnabled(value);
    setState(() {
      _notificationEnabled = value;
    });
    
    if (value) {
      await _notificationService.updateNotificationSchedule();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> _updateGoalAchievementNotification(bool value) async {
    await _settingsService.setGoalAchievementNotification(value);
    setState(() {
      _goalAchievementNotification = value;
    });
  }

  Future<void> _updateNotificationTimes(List<String> times) async {
    await _settingsService.setNotificationTimes(times);
    setState(() {
      _notificationTimes = times;
    });
    
    if (_notificationEnabled) {
      await _notificationService.updateNotificationSchedule();
    }
  }

  void _showNotificationTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => NotificationTimeDialog(
        currentTimes: _notificationTimes,
        onTimesChanged: _updateNotificationTimes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 정보
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사용자 정보',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            waterProvider.currentUser?.nickname.isNotEmpty == true 
                                ? waterProvider.currentUser!.nickname[0] 
                                : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(waterProvider.currentUser?.nickname ?? '사용자'),
                        subtitle: Text('아이디: ${waterProvider.currentUser?.userId ?? 'user_001'}'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 목표 설정
                Text(
                  '목표 설정',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '하루 목표 섭취량',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '현재 목표: ${waterProvider.dailyGoal}ml',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: waterProvider.dailyGoal.toDouble(),
                        min: 500,
                        max: 3000,
                        divisions: 25,
                        label: '${waterProvider.dailyGoal}ml',
                        onChanged: (value) {
                          waterProvider.setDailyGoal(value.round());
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('500ml', style: Theme.of(context).textTheme.bodySmall),
                          Text('3000ml', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 알림 설정
                Text(
                  '알림 설정',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('물 마시기 알림'),
                        subtitle: const Text('정기적으로 물 마시기를 알려드립니다'),
                        value: _notificationEnabled,
                        onChanged: _updateNotificationEnabled,
                      ),
                      if (_notificationEnabled) ...[
                        ListTile(
                          title: const Text('알림 시간 설정'),
                          subtitle: Text(_notificationTimes.join(', ')),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _showNotificationTimeDialog,
                        ),
                      ],
                      SwitchListTile(
                        title: const Text('목표 달성 알림'),
                        subtitle: const Text('목표 달성 시 알림을 받습니다'),
                        value: _goalAchievementNotification,
                        onChanged: _updateGoalAchievementNotification,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 기타 설정
                Text(
                  '기타',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('앱 정보'),
                        subtitle: const Text('버전 1.0.0'),
                        onTap: () {
                          _showAppInfoDialog(context);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('도움말'),
                        subtitle: const Text('사용법 안내'),
                        onTap: () {
                          _showHelpDialog(context);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('앱 정보'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('물먹자 투게더'),
              SizedBox(height: 8),
              Text('버전: 1.0.0'),
              SizedBox(height: 8),
              Text('하루 물 섭취 습관을 재미있게 형성하도록 돕는 소셜 건강 앱입니다.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('도움말'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('사용법 안내', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('1. 홈 화면에서 물 기록 버튼을 눌러 물을 마신 양을 기록하세요.'),
                SizedBox(height: 4),
                Text('2. 물을 마실 때마다 식물이 성장합니다.'),
                SizedBox(height: 4),
                Text('3. 친구를 추가하고 함께 물 마시기를 시작해보세요.'),
                SizedBox(height: 4),
                Text('4. 대시보드에서 일별 기록을 확인할 수 있습니다.'),
                SizedBox(height: 4),
                Text('5. 설정에서 목표 섭취량을 조절할 수 있습니다.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 로그아웃 로직 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃되었습니다')),
                );
              },
              child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// 알림 시간 설정 다이얼로그
class NotificationTimeDialog extends StatefulWidget {
  final List<String> currentTimes;
  final Function(List<String>) onTimesChanged;

  const NotificationTimeDialog({
    super.key,
    required this.currentTimes,
    required this.onTimesChanged,
  });

  @override
  State<NotificationTimeDialog> createState() => _NotificationTimeDialogState();
}

class _NotificationTimeDialogState extends State<NotificationTimeDialog> {
  late List<String> _times;
  final List<String> _presetTimes = [
    '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00'
  ];

  @override
  void initState() {
    super.initState();
    _times = List.from(widget.currentTimes);
  }

  void _addTime(String time) {
    if (!_times.contains(time)) {
      setState(() {
        _times.add(time);
        _times.sort();
      });
    }
  }

  void _removeTime(String time) {
    setState(() {
      _times.remove(time);
    });
  }

  void _saveTimes() {
    widget.onTimesChanged(_times);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('알림 시간 설정'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('선택된 알림 시간:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _times.map((time) => Chip(
                label: Text(time),
                onDeleted: () => _removeTime(time),
                deleteIcon: const Icon(Icons.close, size: 18),
              )).toList(),
            ),
            const SizedBox(height: 16),
            const Text('추가할 시간을 선택하세요:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetTimes.map((time) => FilterChip(
                label: Text(time),
                selected: _times.contains(time),
                onSelected: (selected) {
                  if (selected) {
                    _addTime(time);
                  } else {
                    _removeTime(time);
                  }
                },
              )).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _saveTimes,
          child: const Text('저장'),
        ),
      ],
    );
  }
}