import 'package:flutter/material.dart';
import '../models/plant.dart';

class PlantPot extends StatelessWidget {
  final Plant? plant;
  final double size;
  final bool showDetails;

  const PlantPot({
    super.key,
    this.plant,
    this.size = 120.0,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 식물 이미지 또는 이모지
            Text(
              plant?.getStageImagePath() ?? '🌱',
              style: TextStyle(fontSize: size * 0.4),
            ),
            
            // 식물 이름 (작은 크기일 때는 숨김)
            if (showDetails && size > 100)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  plant?.name ?? '기본 식물',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PlantPotWithDetails extends StatelessWidget {
  final Plant? plant;

  const PlantPotWithDetails({
    super.key,
    this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '내 화분',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 식물 표시
          PlantPot(
            plant: plant,
            size: 120,
            showDetails: false,
          ),
          
          const SizedBox(height: 12),
          
          // 식물 이름
          Text(
            plant?.name ?? '기본 식물',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 식물 단계 설명
          Text(
            _getPlantStageText(plant?.stage ?? 0),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // 성장 진행률
          if (plant != null) ...[
            LinearProgressIndicator(
              value: plant!.getGrowthProgressRate(),
              backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '성장률: ${(plant!.getGrowthProgressRate() * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            Text(
              '씨앗을 심어보세요!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getPlantStageText(int stage) {
    switch (stage) {
      case 0:
        return '씨앗 단계\n물을 주어 성장시켜보세요!';
      case 1:
        return '줄기 단계\n계속 물을 주세요!';
      case 2:
        return '꽃 단계\n거의 다 자랐어요!';
      case 3:
        return '열매 단계\n완전히 자랐습니다! 🎉';
      default:
        return '씨앗 단계';
    }
  }
}
