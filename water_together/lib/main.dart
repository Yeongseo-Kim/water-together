import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/water_provider.dart';
import 'services/notification_service.dart';
import 'services/tutorial_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 서비스들 초기화 (에러 처리 추가)
  try {
    final notificationService = NotificationService();
    await notificationService.init();
  } catch (e) {
    print('Notification service initialization failed: $e');
  }
  
  try {
    await TutorialService.instance.init();
  } catch (e) {
    print('Tutorial service initialization failed: $e');
  }
  
  runApp(const WaterTogetherApp());
}

class WaterTogetherApp extends StatelessWidget {
  const WaterTogetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WaterProvider()),
      ],
      child: MaterialApp(
        title: '물먹자 투게더',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
