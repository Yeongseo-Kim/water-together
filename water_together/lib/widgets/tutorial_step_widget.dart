// lib/widgets/tutorial_step_widget.dart
import 'package:flutter/material.dart';

class TutorialStepWidget extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final bool isLastStep;

  const TutorialStepWidget({
    super.key,
    required this.title,
    required this.description,
    this.onNext,
    this.onSkip,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  child: const Text('건너뛰기'),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton(
                onPressed: onNext,
                child: Text(isLastStep ? '완료' : '다음'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}