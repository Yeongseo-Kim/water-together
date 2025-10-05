import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../services/plant_config_service.dart';
import '../models/plant_config.dart';

class PlantGridWidget extends StatefulWidget {
  const PlantGridWidget({super.key});

  @override
  State<PlantGridWidget> createState() => _PlantGridWidgetState();
}

class _PlantGridWidgetState extends State<PlantGridWidget> {
  @override
  void initState() {
    super.initState();
    // 식물 설정 로드
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PlantConfigService.instance.loadPlantConfigs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        final plantConfigsMap = PlantConfigService.instance.getAllPlantConfigs();
        final plantConfigs = plantConfigsMap.values.toList();
        final collectedPlants = _getCollectedPlants(waterProvider);
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 도감 완성도 표시
              _buildCollectionProgress(plantConfigs.length, collectedPlants.length),
              const SizedBox(height: 24),
              
              // 식물 그리드
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: plantConfigs.length,
                  itemBuilder: (context, index) {
                    final plantConfig = plantConfigs[index];
                    if (plantConfig == null) return const SizedBox.shrink();
                    
                    final isCollected = collectedPlants.contains(plantConfig.plantId);
                    
                    return _buildPlantCard(plantConfig, isCollected);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 도감 완성도 표시
  Widget _buildCollectionProgress(int totalPlants, int collectedPlants) {
    final progress = totalPlants > 0 ? collectedPlants / totalPlants : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '도감 완성도',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$collectedPlants / $totalPlants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            '${(progress * 100).toInt()}% 완성',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 식물 카드 위젯
  Widget _buildPlantCard(PlantConfig plantConfig, bool isCollected) {
    return GestureDetector(
      onTap: () => _showPlantDetail(plantConfig, isCollected),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isCollected ? Colors.green.shade300 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 식물 이미지 (이모티콘)
            Text(
              isCollected ? plantConfig.stageImages[3] : '❓',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            
            // 식물 이름
            Text(
              isCollected ? plantConfig.name : '???',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCollected ? Colors.black : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            
            // 희귀도 표시
            if (isCollected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRarityColor(plantConfig.rarity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRarityColor(plantConfig.rarity),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getRarityText(plantConfig.rarity),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getRarityColor(plantConfig.rarity),
                  ),
                ),
              ),
            
            // 수집 상태 표시
            if (isCollected)
              const SizedBox(height: 8),
            if (isCollected)
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // 희귀도별 색상
  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // 희귀도별 텍스트
  String _getRarityText(String rarity) {
    switch (rarity) {
      case 'common':
        return '일반';
      case 'rare':
        return '희귀';
      case 'epic':
        return '영웅';
      case 'legendary':
        return '전설';
      default:
        return '일반';
    }
  }

  // 수집된 식물 목록 가져오기
  List<String> _getCollectedPlants(WaterProvider waterProvider) {
    // WaterProvider에서 완성된 식물 목록 가져오기
    return waterProvider.completedPlants;
  }

  // 식물 상세 정보 다이얼로그
  void _showPlantDetail(PlantConfig plantConfig, bool isCollected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              isCollected ? plantConfig.stageImages[3] : '❓',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCollected ? plantConfig.name : '???',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCollected) ...[
                // 식물 설명
                Text(
                  plantConfig.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                // 성장 단계별 이미지
                const Text(
                  '성장 단계',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStageImage(plantConfig.stageImages[0], '씨앗'),
                    _buildStageImage(plantConfig.stageImages[1], '줄기'),
                    _buildStageImage(plantConfig.stageImages[2], '꽃'),
                    _buildStageImage(plantConfig.stageImages[3], '열매'),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 희귀도 정보
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getRarityColor(plantConfig.rarity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getRarityColor(plantConfig.rarity),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: _getRarityColor(plantConfig.rarity),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '희귀도: ${_getRarityText(plantConfig.rarity)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getRarityColor(plantConfig.rarity),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // 성장 요구사항
                const Text(
                  '성장 요구사항',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...plantConfig.stageRequirements.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(plantConfig.stageImages[entry.key + 1]),
                        const SizedBox(width: 8),
                        Text('${entry.value}ml'),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // 미수집 식물
                const Text(
                  '아직 수집하지 않은 식물입니다.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        '식물을 완성하면 도감에 추가됩니다!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  // 성장 단계 이미지 위젯
  Widget _buildStageImage(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}