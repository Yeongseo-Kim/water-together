import 'package:flutter/material.dart';

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    super.key,
    required this.child,
    required this.steps,
    this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int currentStep = 0;
  bool isVisible = true; // 앱 첫 실행 시 바로 표시

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (isVisible && currentStep < widget.steps.length)
          _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    final step = widget.steps[currentStep];
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                step.description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // UserFlow.md 요구사항: 스킵/재보기 없음 (강제 2단계)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(currentStep == widget.steps.length - 1 ? '완료' : '다음'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (currentStep < widget.steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      _completeTutorial();
    }
  }

  // UserFlow.md 요구사항: 스킵 기능 제거 (강제 2단계 완료)
  void _completeTutorial() {
    setState(() {
      isVisible = false;
    });
    widget.onComplete?.call();
  }
}

// 튜토리얼 단계 모델
class TutorialStep {
  final String title;
  final String description;
  final GlobalKey targetKey;
  final String? imagePath;

  TutorialStep({
    required this.title,
    required this.description,
    required this.targetKey,
    this.imagePath,
  });
}


