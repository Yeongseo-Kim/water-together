import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'friends_ranking_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const DashboardScreen(),
    const FriendsRankingScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드 (에러 처리 추가)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<WaterProvider>().loadInitialData();
      } catch (e) {
        print('Error loading initial data: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        // Provider가 초기화되지 않았을 때 로딩 화면 표시
        if (waterProvider.currentUser == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('앱을 초기화하는 중...'),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: _screens[waterProvider.currentTabIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: waterProvider.currentTabIndex,
            onTap: (index) {
              waterProvider.changeTab(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: '대시보드',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: '친구·랭킹',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: '설정',
              ),
            ],
          ),
        );
      },
    );
  }
}
