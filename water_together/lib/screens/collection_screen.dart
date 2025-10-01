import 'package:flutter/material.dart';
import '../services/collection_service.dart';
import '../data/plant_database.dart';
import '../widgets/plant_detail_popup.dart';

/// 도감 화면
/// 수집한 식물들을 확인할 수 있는 화면
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<Map<String, dynamic>> collectedPlants = [];
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollectionData();
  }

  Future<void> _loadCollectionData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final plants = await CollectionService.getSortedCollectedPlants();
      final collectionStats = await CollectionService.getCollectionStats();
      
      setState(() {
        collectedPlants = plants;
        stats = collectionStats;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading collection data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 도감'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadCollectionData,
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : collectedPlants.isEmpty
              ? _buildEmptyState()
              : _buildCollectionContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🌱',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              '아직 수집된 식물이 없어요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '물을 마시고 식물을 키워보세요!\n식물이 완전히 자라면 도감에 추가됩니다.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('홈으로 돌아가기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            // 개발용 데모 버튼
            TextButton(
              onPressed: () async {
                await CollectionService.addDemoPlants();
                _loadCollectionData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('데모 식물이 추가되었습니다!')),
                  );
                }
              },
              child: const Text('데모 식물 추가 (개발용)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionContent() {
    return Column(
      children: [
        _buildStatsHeader(),
        Expanded(
          child: _buildPlantGrid(),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '수집률',
                '${stats['completionRate']?.toStringAsFixed(1) ?? '0.0'}%',
                Icons.percent,
              ),
              _buildStatItem(
                '수집 식물',
                '${stats['collectedCount'] ?? 0}/${stats['totalCount'] ?? 0}',
                Icons.local_florist,
              ),
              _buildStatItem(
                '총 가치',
                '${stats['totalValue'] ?? 0}',
                Icons.stars,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRarityStats(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildRarityStats() {
    final rarityCount = stats['rarityCount'] as Map<String, int>? ?? {};
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildRarityItem('일반', rarityCount['common'] ?? 0, Colors.green),
        _buildRarityItem('희귀', rarityCount['uncommon'] ?? 0, Colors.blue),
        _buildRarityItem('매우 희귀', rarityCount['rare'] ?? 0, Colors.purple),
        _buildRarityItem('전설', rarityCount['legendary'] ?? 0, Colors.orange),
      ],
    );
  }

  Widget _buildRarityItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPlantGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: collectedPlants.length,
      itemBuilder: (context, index) {
        final plant = collectedPlants[index];
        return _buildPlantCard(plant);
      },
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    final seedId = plant['seedId'] as String;
    final plantData = plant['plantData'] as Map<String, dynamic>;
    final collectionDate = plant['collectionDate'] as DateTime?;
    final collectionValue = plant['collectionValue'] as int;
    
    final name = plantData['name'] as String;
    final rarity = plantData['rarity'] as String;
    final stages = plantData['stages'] as List<String>;
    final finalStage = stages.last;
    
    return GestureDetector(
      onTap: () => _showPlantDetail(plant),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getRarityColor(rarity).withOpacity(0.1),
                _getRarityColor(rarity).withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 희귀도 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRarityColor(rarity),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        PlantDatabase.getRarityName(rarity),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.stars, size: 16, color: Colors.amber),
                        Text(
                          '$collectionValue',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 식물 이미지
                Expanded(
                  child: Center(
                    child: Text(
                      finalStage,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 식물 이름
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // 수집 날짜
                if (collectionDate != null)
                  Text(
                    '수집: ${_formatDate(collectionDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
        ),
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

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showPlantDetail(Map<String, dynamic> plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlantDetailPopup(plant: plant);
      },
    );
  }
}
