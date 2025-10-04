import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';
  
  // 싱글톤 패턴
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();

  // 튜토리얼 완료 여부 확인
  Future<bool> isTutorialCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_tutorialCompletedKey) ?? false;
    } catch (e) {
      // SharedPreferences 오류 시 기본값 false 반환
      return false;
    }
  }

  // 튜토리얼 완료 처리
  Future<void> completeTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tutorialCompletedKey, true);
    } catch (e) {
      // SharedPreferences 오류 시 무시 (사용자 경험에 영향 없음)
    }
  }

  // 튜토리얼 리셋 (디버그용)
  Future<void> resetTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tutorialCompletedKey);
    } catch (e) {
      // SharedPreferences 오류 시 무시
    }
  }
}
