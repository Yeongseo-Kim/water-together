import 'package:flutter/material.dart';

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final bool isFirstTime;
  final VoidCallback? onTutorialComplete;

  const TutorialOverlay({
    super.key,
    required this.child,
    this.isFirstTime = false,
    this.onTutorialComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: '물 기록하기',
      description: '물을 마셨을 때 이 버튼을 눌러서 기록해보세요!',
      targetKey: 'water_record_button',
      position: TutorialPosition.bottom,
    ),
    TutorialStep(
      title: '씨앗 심기',
      description: '씨앗을 심어서 새로운 식물을 키워보세요!',
      targetKey: 'inventory_button',
      position: TutorialPosition.bottom,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    if (widget.isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTutorial();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTutorial() {
    _animationController.forward();
  }

  void _nextStep() {
    if (_currentStep < _tutorialSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeTutorial();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _completeTutorial() {
    _animationController.reverse().then((_) {
      widget.onTutorialComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isFirstTime && _currentStep < _tutorialSteps.length)
          _buildTutorialOverlay(),
      ],
    );
  }

  Widget _buildTutorialOverlay() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Stack(
                  children: [
                    // 타겟 위젯 하이라이트
                    _buildTargetHighlight(),
                    // 튜토리얼 팝업
                    _buildTutorialPopup(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTargetHighlight() {
    final step = _tutorialSteps[_currentStep];
    
    return Positioned.fill(
      child: CustomPaint(
        painter: TutorialPainter(
          step: step,
          primaryColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTutorialPopup() {
    final step = _tutorialSteps[_currentStep];
    
    return Positioned(
      top: step.position == TutorialPosition.top ? 100 : null,
      bottom: step.position == TutorialPosition.bottom ? 200 : null,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 튜토리얼 아이콘
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getStepIcon(),
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // 제목
            Text(
              step.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // 설명
            Text(
              step.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // 진행 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _tutorialSteps.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index == _currentStep
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _skipTutorial,
                    child: Text(
                      '건너뛰기',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _currentStep == _tutorialSteps.length - 1 ? '완료' : '다음',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStepIcon() {
    switch (_currentStep) {
      case 0:
        return Icons.water_drop;
      case 1:
        return Icons.eco;
      default:
        return Icons.help_outline;
    }
  }
}

class TutorialStep {
  final String title;
  final String description;
  final String targetKey;
  final TutorialPosition position;

  TutorialStep({
    required this.title,
    required this.description,
    required this.targetKey,
    required this.position,
  });
}

enum TutorialPosition { top, bottom }

class TutorialPainter extends CustomPainter {
  final TutorialStep step;
  final Color primaryColor;

  TutorialPainter({
    required this.step,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // 전체 화면을 어둡게 칠하기
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 타겟 영역 주변에 하이라이트 효과 (동적으로 계산)
    final targetRect = _getTargetRect(size);
    if (targetRect != null) {
      final highlightPaint = Paint()
        ..color = primaryColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawRRect(
        RRect.fromRectAndRadius(targetRect, const Radius.circular(8)),
        highlightPaint,
      );
    }
  }

  Rect? _getTargetRect(Size size) {
    // 화면 크기에 따라 동적으로 타겟 영역 계산
    switch (step.targetKey) {
      case 'water_record_button':
        return Rect.fromLTWH(
          size.width * 0.1, // 화면 너비의 10% 위치
          size.height * 0.6, // 화면 높이의 60% 위치
          size.width * 0.8,  // 화면 너비의 80% 크기
          60,                // 고정 높이
        );
      case 'inventory_button':
        return Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.7,
          size.width * 0.35,
          50,
        );
      default:
        return null;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
