import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../data/notification_messages.dart';

/// 알림 설정 위젯
/// 사용자가 알림 설정을 관리할 수 있는 UI를 제공합니다.
class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  final NotificationService _notificationService = NotificationService();
  
  bool _waterRemindersEnabled = true;
  bool _goalAchievementEnabled = true;
  bool _friendActivityEnabled = true;
  bool _encouragementEnabled = true;
  bool _challengeEnabled = true;
  
  List<int> _reminderHours = [9, 12, 15, 18];
  int _encouragementHour = 20;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 설정 로드
  void _loadSettings() {
    setState(() {
      _waterRemindersEnabled = _notificationService.waterRemindersEnabled;
      _goalAchievementEnabled = _notificationService.goalAchievementEnabled;
      _friendActivityEnabled = _notificationService.friendActivityEnabled;
      _encouragementEnabled = _notificationService.encouragementEnabled;
      _challengeEnabled = _notificationService.challengeEnabled;
      _reminderHours = List.from(_notificationService.reminderHours);
      _encouragementHour = _notificationService.encouragementHour;
    });
  }

  /// 물 마시기 알림 시간 설정 다이얼로그
  Future<void> _showReminderTimeDialog() async {
    final result = await showDialog<List<int>>(
      context: context,
      builder: (context) => ReminderTimeDialog(
        currentHours: _reminderHours,
      ),
    );
    
    if (result != null) {
      setState(() {
        _reminderHours = result;
      });
      _notificationService.setReminderHours(result);
    }
  }

  /// 격려 메시지 시간 설정 다이얼로그
  Future<void> _showEncouragementTimeDialog() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _encouragementHour, minute: 0),
    );
    
    if (result != null) {
      setState(() {
        _encouragementHour = result.hour;
      });
      _notificationService.setEncouragementHour(result.hour);
    }
  }

  /// 알림 테스트
  Future<void> _testNotification(String type) async {
    setState(() {
      _isLoading = true;
    });

    try {
      switch (type) {
        case 'water':
          await _notificationService.showInstantNotification(
            title: '💧 물 마실 시간이에요!',
            body: NotificationMessages.getRandomWaterReminder(),
          );
          break;
        case 'goal':
          await _notificationService.showGoalAchievementNotification();
          break;
        case 'friend':
          await _notificationService.showFriendActivityNotification('친구');
          break;
        case 'encouragement':
          await _notificationService.showInstantNotification(
            title: '💪 격려 메시지',
            body: NotificationMessages.getRandomEncouragement(),
          );
          break;
        case 'challenge':
          await _notificationService.showChallengeNotification('일일 챌린지');
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('테스트 알림을 전송했습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 전송 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 알림 미리보기 다이얼로그
  void _showPreviewDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 알림 종류별 설정
                  _buildSectionTitle('알림 종류'),
                  const SizedBox(height: 16),
                  
                  _buildNotificationToggle(
                    title: '물 마시기 알림',
                    subtitle: '정기적으로 물 마시기를 알려드려요',
                    value: _waterRemindersEnabled,
                    onChanged: (value) {
                      setState(() {
                        _waterRemindersEnabled = value;
                      });
                      _notificationService.setWaterRemindersEnabled(value);
                    },
                    onTest: () => _testNotification('water'),
                    onPreview: () => _showPreviewDialog(
                      '물 마시기 알림',
                      NotificationMessages.getRandomWaterReminder(),
                    ),
                  ),
                  
                  _buildNotificationToggle(
                    title: '목표 달성 알림',
                    subtitle: '목표를 달성했을 때 축하 메시지를 보내드려요',
                    value: _goalAchievementEnabled,
                    onChanged: (value) {
                      setState(() {
                        _goalAchievementEnabled = value;
                      });
                      _notificationService.setGoalAchievementEnabled(value);
                    },
                    onTest: () => _testNotification('goal'),
                    onPreview: () => _showPreviewDialog(
                      '목표 달성 알림',
                      NotificationMessages.getRandomGoalAchievement(),
                    ),
                  ),
                  
                  _buildNotificationToggle(
                    title: '친구 활동 알림',
                    subtitle: '친구의 활동을 알려드려요',
                    value: _friendActivityEnabled,
                    onChanged: (value) {
                      setState(() {
                        _friendActivityEnabled = value;
                      });
                      _notificationService.setFriendActivityEnabled(value);
                    },
                    onTest: () => _testNotification('friend'),
                    onPreview: () => _showPreviewDialog(
                      '친구 활동 알림',
                      NotificationMessages.getRandomFriendActivity(),
                    ),
                  ),
                  
                  _buildNotificationToggle(
                    title: '격려 메시지',
                    subtitle: '일일 격려 메시지를 보내드려요',
                    value: _encouragementEnabled,
                    onChanged: (value) {
                      setState(() {
                        _encouragementEnabled = value;
                      });
                      _notificationService.setEncouragementEnabled(value);
                    },
                    onTest: () => _testNotification('encouragement'),
                    onPreview: () => _showPreviewDialog(
                      '격려 메시지',
                      NotificationMessages.getRandomEncouragement(),
                    ),
                  ),
                  
                  _buildNotificationToggle(
                    title: '챌린지 알림',
                    subtitle: '챌린지 관련 알림을 보내드려요',
                    value: _challengeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _challengeEnabled = value;
                      });
                      _notificationService.setChallengeEnabled(value);
                    },
                    onTest: () => _testNotification('challenge'),
                    onPreview: () => _showPreviewDialog(
                      '챌린지 알림',
                      NotificationMessages.getRandomChallenge(),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 알림 시간 설정
                  _buildSectionTitle('알림 시간 설정'),
                  const SizedBox(height: 16),
                  
                  _buildTimeSetting(
                    title: '물 마시기 알림 시간',
                    subtitle: _reminderHours.map((h) => '${h}시').join(', '),
                    onTap: _showReminderTimeDialog,
                  ),
                  
                  _buildTimeSetting(
                    title: '격려 메시지 시간',
                    subtitle: '${_encouragementHour}시',
                    onTap: _showEncouragementTimeDialog,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 전체 설정
                  _buildSectionTitle('전체 설정'),
                  const SizedBox(height: 16),
                  
                  _buildActionButton(
                    title: '모든 알림 테스트',
                    subtitle: '모든 종류의 알림을 테스트해보세요',
                    icon: Icons.notifications_active,
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      try {
                        await Future.wait([
                          _testNotification('water'),
                          Future.delayed(const Duration(milliseconds: 500)),
                          _testNotification('goal'),
                          Future.delayed(const Duration(milliseconds: 500)),
                          _testNotification('encouragement'),
                        ]);
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                  ),
                  
                  _buildActionButton(
                    title: '모든 알림 취소',
                    subtitle: '예정된 모든 알림을 취소합니다',
                    icon: Icons.notifications_off,
                    onTap: () async {
                      await _notificationService.cancelAllNotifications();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('모든 알림을 취소했습니다'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required VoidCallback onTest,
    required VoidCallback onPreview,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.blue,
                ),
              ],
            ),
            if (value) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPreview,
                      icon: const Icon(Icons.preview, size: 18),
                      label: const Text('미리보기'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTest,
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('테스트'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSetting({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

/// 물 마시기 알림 시간 설정 다이얼로그
class ReminderTimeDialog extends StatefulWidget {
  final List<int> currentHours;

  const ReminderTimeDialog({
    super.key,
    required this.currentHours,
  });

  @override
  State<ReminderTimeDialog> createState() => _ReminderTimeDialogState();
}

class _ReminderTimeDialogState extends State<ReminderTimeDialog> {
  late List<bool> selectedHours;

  @override
  void initState() {
    super.initState();
    selectedHours = List.generate(24, (index) => widget.currentHours.contains(index));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('물 마시기 알림 시간'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.5,
          ),
          itemCount: 24,
          itemBuilder: (context, index) {
            return FilterChip(
              label: Text('${index}시'),
              selected: selectedHours[index],
              onSelected: (selected) {
                setState(() {
                  selectedHours[index] = selected;
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final selectedTimes = <int>[];
            for (int i = 0; i < selectedHours.length; i++) {
              if (selectedHours[i]) {
                selectedTimes.add(i);
              }
            }
            Navigator.of(context).pop(selectedTimes);
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}
