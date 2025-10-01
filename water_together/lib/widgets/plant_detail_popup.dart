import 'package:flutter/material.dart';
import '../data/plant_database.dart';

/// 식물 상세 정보 팝업
/// 도감에서 식물을 클릭했을 때 보여지는 상세 정보 팝업
class PlantDetailPopup extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantDetailPopup({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    final seedId = plant['seedId'] as String;
    final plantData = plant['plantData'] as Map<String, dynamic>;
    final collectionDate = plant['collectionDate'] as DateTime?;
    final collectionValue = plant['collectionValue'] as int;
    
    final name = plantData['name'] as String;
    final description = plantData['description'] as String;
    final rarity = plantData['rarity'] as String;
    final stages = plantData['stages'] as List<String>;
    final growthRequirements = plantData['growthRequirements'] as List<int>;
    final category = plantData['category'] as String;
    final season = plantData['season'] as String;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, name, rarity, collectionValue),
              _buildPlantImage(stages),
              _buildPlantInfo(context, plantData, collectionDate),
              _buildGrowthStages(context, stages, growthRequirements),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String rarity, int collectionValue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getRarityColor(rarity).withOpacity(0.2),
            _getRarityColor(rarity).withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRarityColor(rarity),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        PlantDatabase.getRarityName(rarity),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.stars, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '$collectionValue',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantImage(List<String> stages) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 최종 단계 이미지
          Text(
            stages.last,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),
          // 성장 단계들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: stages.map((stage) {
              return Column(
                children: [
                  Text(
                    stage,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStageName(stages.indexOf(stage)),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantInfo(BuildContext context, Map<String, dynamic> plantData, DateTime? collectionDate) {
    final description = plantData['description'] as String;
    final category = plantData['category'] as String;
    final season = plantData['season'] as String;
    final difficulty = PlantDatabase.getDifficultyLevel(plantData['name'] as String);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '식물 정보',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // 설명
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 상세 정보
          _buildInfoRow(context, '카테고리', PlantDatabase.getCategoryName(category)),
          _buildInfoRow(context, '계절', PlantDatabase.getSeasonName(season)),
          _buildInfoRow(context, '난이도', difficulty),
          if (collectionDate != null)
            _buildInfoRow(context, '수집일', _formatDate(collectionDate)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthStages(BuildContext context, List<String> stages, List<int> growthRequirements) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '성장 단계',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ...stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final requiredWater = index == 0 ? 0 : growthRequirements[index - 1];
            final isCompleted = index < stages.length - 1;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: isCompleted ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    stage,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStageName(index),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (index > 0)
                          Text(
                            '필요 물량: ${requiredWater}ml',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('닫기'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // 공유 기능 (추후 구현)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공유 기능은 준비 중입니다!')),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('공유'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.green;
      case 'uncommon':
        return Colors.blue;
      case 'rare':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStageName(int stageIndex) {
    switch (stageIndex) {
      case 0:
        return '씨앗';
      case 1:
        return '줄기';
      case 2:
        return '꽃';
      case 3:
        return '열매';
      default:
        return '알 수 없음';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
