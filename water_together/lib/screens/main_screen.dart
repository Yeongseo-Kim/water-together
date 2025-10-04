import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'friends_ranking_screen.dart';
import 'settings_screen.dart';
import 'collection_screen.dart';

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
    const CollectionScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<WaterProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
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
                icon: Icon(Icons.collections_bookmark),
                label: '도감',
              ),
            ],
          ),
        );
      },
    );
  }
}
