import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                        value: true, // 실제로는 설정에서 가져와야 함
                        onChanged: (value) {
                          // 알림 설정 변경 로직
                        },
                      ),
                      SwitchListTile(
                        title: const Text('목표 달성 알림'),
                        subtitle: const Text('목표 달성 시 알림을 받습니다'),
                        value: true, // 실제로는 설정에서 가져와야 함
                        onChanged: (value) {
                          // 알림 설정 변경 로직
                        },
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
