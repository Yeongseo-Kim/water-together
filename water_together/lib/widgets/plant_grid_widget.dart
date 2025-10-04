import 'package:flutter/material.dart';

class PlantGridWidget extends StatefulWidget {
  const PlantGridWidget({super.key});

  @override
  State<PlantGridWidget> createState() => _PlantGridWidgetState();
}

class _PlantGridWidgetState extends State<PlantGridWidget> {
  // 임시 식물 데이터 (수집/미수집 구분)
  final List<PlantData> _plants = [
    PlantData(
      id: 'plant_001',
      name: '기본 식물',
      image: '🌱',
      description: '기본적인 식물입니다. 물을 주면 자라요!',
      isCollected: true,
      stage: 2,
    ),
    PlantData(
      id: 'plant_002',
      name: '튤립',
      image: '🌷',
      description: '아름다운 튤립입니다. 봄에 피어나요.',
      isCollected: true,
      stage: 3,
    ),
    PlantData(
      id: 'plant_003',
      name: '민들레',
      image: '🌼',
      description: '노란 민들레입니다. 바람에 날려가요.',
      isCollected: true,
      stage: 1,
    ),
    PlantData(
      id: 'plant_004',
      name: '장미',
      image: '🌹',
      description: '사랑의 꽃 장미입니다.',
      isCollected: false,
      stage: 0,
    ),
    PlantData(
      id: 'plant_005',
      name: '해바라기',
      image: '🌻',
      description: '태양을 따라 도는 해바라기입니다.',
      isCollected: false,
      stage: 0,
    ),
    PlantData(
      id: 'plant_006',
      name: '선인장',
      image: '🌵',
      description: '사막의 선인장입니다. 물을 적게 마셔요.',
      isCollected: true,
      stage: 2,
    ),
    PlantData(
      id: 'plant_007',
      name: '나무',
      image: '🌳',
      description: '큰 나무입니다. 많은 물이 필요해요.',
      isCollected: false,
      stage: 0,
    ),
    PlantData(
      id: 'plant_008',
      name: '버섯',
      image: '🍄',
      description: '빨간 버섯입니다. 조심해서 키우세요.',
      isCollected: false,
      stage: 0,
    ),
    PlantData(
      id: 'plant_009',
      name: '클로버',
      image: '🍀',
      description: '네잎 클로버입니다. 행운을 가져다줘요.',
      isCollected: true,
      stage: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 수집된 식물 수 계산
    final collectedCount = _plants.where((plant) => plant.isCollected).length;
    final totalCount = _plants.length;
    final completionRate = totalCount > 0 ? collectedCount / totalCount : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 도감 완성도 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
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
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '$collectedCount / $totalCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: completionRate,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(completionRate * 100).toInt()}% 완성',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 식물 그리드
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _plants.length,
              itemBuilder: (context, index) {
                final plant = _plants[index];
                return _buildPlantCard(plant);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(PlantData plant) {
    return GestureDetector(
      onTap: plant.isCollected ? () => _showPlantDetail(plant) : null,
      child: Container(
        decoration: BoxDecoration(
          color: plant.isCollected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: plant.isCollected ? Colors.green.shade200 : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: plant.isCollected ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 식물 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: plant.isCollected ? Colors.green.shade50 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: plant.isCollected ? Colors.green.shade200 : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  plant.isCollected ? plant.image : '?',
                  style: TextStyle(
                    fontSize: 30,
                    color: plant.isCollected ? null : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 식물 이름
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                plant.isCollected ? plant.name : '???',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: plant.isCollected ? Colors.black87 : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 수집 상태 표시
            if (plant.isCollected) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Stage ${plant.stage}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Icon(
                Icons.lock_outline,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPlantDetail(PlantData plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(plant.image, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                plant.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plant.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_florist, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '성장 단계: ${plant.stage}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
}

// 식물 데이터 모델
class PlantData {
  final String id;
  final String name;
  final String image;
  final String description;
  final bool isCollected;
  final int stage;

  PlantData({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.isCollected,
    required this.stage,
  });
}
