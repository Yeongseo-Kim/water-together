import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../models/water_log.dart';

class WaterRecordButton extends StatelessWidget {
  final bool isExpanded;
  final double? width;

  const WaterRecordButton({
    super.key,
    this.isExpanded = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isExpanded ? double.infinity : width,
      child: ElevatedButton.icon(
        onPressed: () => _showWaterRecordDialog(context),
        icon: const Icon(Icons.water_drop, size: 24),
        label: const Text(
          '물 기록하기',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  void _showWaterRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.water_drop,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('물 기록하기'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '얼마나 마셨나요?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              // 물 기록 옵션들
              _buildWaterOption(
                context,
                '한모금',
                50,
                '💧',
                '작은 한 모금',
              ),
              const SizedBox(height: 8),
              _buildWaterOption(
                context,
                '반컵',
                150,
                '🥤',
                '작은 컵의 절반',
              ),
              const SizedBox(height: 8),
              _buildWaterOption(
                context,
                '한컵',
                300,
                '🍶',
                '일반 컵 한 잔',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWaterOption(
    BuildContext context,
    String type,
    int amount,
    String emoji,
    String description,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _recordWater(context, type, amount);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$type (${amount}ml)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  void _recordWater(BuildContext context, String type, int amount) {
    final waterProvider = context.read<WaterProvider>();
    final now = DateTime.now();
    
    final waterLog = WaterLog(
      logId: 'log_${now.millisecondsSinceEpoch}',
      userId: waterProvider.currentUser?.userId ?? 'user_001',
      date: now,
      amount: amount,
      type: type,
    );
    
    waterProvider.addWaterLog(waterLog);
    
    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('$type (${amount}ml) 기록되었습니다!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class WaterRecordQuickButtons extends StatelessWidget {
  const WaterRecordQuickButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickButton(
            context,
            '한모금',
            50,
            '💧',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickButton(
            context,
            '반컵',
            150,
            '🥤',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickButton(
            context,
            '한컵',
            300,
            '🍶',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    String type,
    int amount,
    String emoji,
  ) {
    return OutlinedButton(
      onPressed: () => _recordWater(context, type, amount),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            type,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${amount}ml',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _recordWater(BuildContext context, String type, int amount) {
    final waterProvider = context.read<WaterProvider>();
    final now = DateTime.now();
    
    final waterLog = WaterLog(
      logId: 'log_${now.millisecondsSinceEpoch}',
      userId: waterProvider.currentUser?.userId ?? 'user_001',
      date: now,
      amount: amount,
      type: type,
    );
    
    waterProvider.addWaterLog(waterLog);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type (${amount}ml) 기록되었습니다!'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
