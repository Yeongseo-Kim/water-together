import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _tutorialStepKey = 'tutorial_step';

  static TutorialService? _instance;
  static TutorialService get instance => _instance ??= TutorialService._();
  
  TutorialService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 튜토리얼이 완료되었는지 확인
  Future<bool> isTutorialCompleted() async {
    await _ensureInitialized();
    return _prefs!.getBool(_tutorialCompletedKey) ?? false;
  }

  /// 첫 방문자인지 확인
  Future<bool> isFirstTime() async {
    await _ensureInitialized();
    return _prefs!.getBool(_isFirstTimeKey) ?? true;
  }

  /// 현재 튜토리얼 단계 가져오기
  Future<int> getCurrentTutorialStep() async {
    await _ensureInitialized();
    return _prefs!.getInt(_tutorialStepKey) ?? 0;
  }

  /// 튜토리얼 완료 상태 저장
  Future<void> setTutorialCompleted(bool completed) async {
    await _ensureInitialized();
    await _prefs!.setBool(_tutorialCompletedKey, completed);
    
    if (completed) {
      // 튜토리얼 완료 시 첫 방문자 상태도 false로 변경
      await _prefs!.setBool(_isFirstTimeKey, false);
    }
  }

  /// 첫 방문자 상태 저장
  Future<void> setFirstTime(bool isFirstTime) async {
    await _ensureInitialized();
    await _prefs!.setBool(_isFirstTimeKey, isFirstTime);
  }

  /// 튜토리얼 단계 저장
  Future<void> setTutorialStep(int step) async {
    await _ensureInitialized();
    await _prefs!.setInt(_tutorialStepKey, step);
  }

  /// 튜토리얼 재시작 (설정에서 호출)
  Future<void> restartTutorial() async {
    await _ensureInitialized();
    await _prefs!.setBool(_tutorialCompletedKey, false);
    await _prefs!.setBool(_isFirstTimeKey, true);
    await _prefs!.setInt(_tutorialStepKey, 0);
  }

  /// 튜토리얼 스킵 방지 (강제 완료만 가능)
  Future<void> skipTutorial() async {
    await setTutorialCompleted(true);
  }

  /// 튜토리얼 데이터 초기화 (앱 재설치 시나리오)
  Future<void> resetTutorialData() async {
    await _ensureInitialized();
    await _prefs!.remove(_tutorialCompletedKey);
    await _prefs!.remove(_isFirstTimeKey);
    await _prefs!.remove(_tutorialStepKey);
  }

  /// 튜토리얼 진행률 계산
  Future<double> getTutorialProgress() async {
    await _ensureInitialized();
    final currentStep = await getCurrentTutorialStep();
    const totalSteps = 2; // 물 기록하기, 씨앗 심기
    return currentStep / totalSteps;
  }

  /// 튜토리얼 상태 정보 가져오기
  Future<TutorialStatus> getTutorialStatus() async {
    await _ensureInitialized();
    final isCompleted = await isTutorialCompleted();
    final isFirstTimeUser = await isFirstTime();
    final currentStep = await getCurrentTutorialStep();
    final progress = await getTutorialProgress();

    return TutorialStatus(
      isCompleted: isCompleted,
      isFirstTime: isFirstTimeUser,
      currentStep: currentStep,
      progress: progress,
    );
  }

  /// 튜토리얼 완료 시 보상 지급
  Future<void> giveTutorialReward() async {
    // 튜토리얼 완료 시 특별 보상 로직
    // 예: 특별 씨앗 지급, 경험치 지급 등
    await setTutorialCompleted(true);
  }

  /// 튜토리얼 관련 설정 변경 감지
  Future<void> onTutorialSettingsChanged() async {
    // 설정에서 튜토리얼 관련 옵션이 변경되었을 때 호출
    // 예: 튜토리얼 재시작 요청 등
  }

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
}

/// 튜토리얼 상태 정보를 담는 클래스
class TutorialStatus {
  final bool isCompleted;
  final bool isFirstTime;
  final int currentStep;
  final double progress;

  TutorialStatus({
    required this.isCompleted,
    required this.isFirstTime,
    required this.currentStep,
    required this.progress,
  });

  @override
  String toString() {
    return 'TutorialStatus(isCompleted: $isCompleted, isFirstTime: $isFirstTime, currentStep: $currentStep, progress: $progress)';
  }
}
