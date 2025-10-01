import 'package:flutter/material.dart';

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int currentStep = 0;
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (isVisible && currentStep < 2)
          _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    final steps = [
      '물 기록 버튼 💧',
      '씨앗 심기 🌱',
    ];
    
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                steps[currentStep],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                currentStep == 0 
                  ? '한모금 버튼을 눌러 기록하는 방법 안내'
                  : '인벤토리에서 씨앗 선택 후 심기 버튼 안내',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextStep,
                child: Text(currentStep == 1 ? '완료' : '다음'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (currentStep < 1) {
      setState(() {
        currentStep++;
      });
    } else {
      setState(() {
        isVisible = false;
      });
      widget.onComplete?.call();
    }
  }
}


