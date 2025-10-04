import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'seed_preview_widget.dart';
import '../providers/water_provider.dart';

class InventoryPopup extends StatelessWidget {
  final List<Map<String, dynamic>> seeds;

  const InventoryPopup({
    super.key,
    required this.seeds,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '인벤토리 🌱',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 총 씨앗 수 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                '총 ${seeds.length}종의 씨앗 보유',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // UserFlow.md 요구사항: 씨앗 목록을 팝업으로 미리보기
            Expanded(
              child: seeds.isEmpty 
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '아직 씨앗이 없어요',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '물을 마시고 식물을 키워보세요!',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: seeds.length,
                    itemBuilder: (context, index) {
                      final seed = seeds[index];
                      return SeedPreviewWidget(
                        seed: seed,
                        onTap: () => _showSeedDetail(context, seed),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // UserFlow.md 요구사항: 씨앗 클릭 시 팝업(이름/설명, 심기 버튼, 미등록이면 '?' 표시)
  void _showSeedDetail(BuildContext context, Map<String, dynamic> seed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(seed['image'], style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                seed['name'],
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
              seed['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '보유 수량: ${seed['quantity']}개',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (seed['quantity'] == 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '씨앗이 부족합니다',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          Consumer<WaterProvider>(
            builder: (context, waterProvider, child) {
              // 이미 식물이 있고 완성되지 않은 경우 심기 불가
              final hasActivePlant = waterProvider.currentPlant != null && waterProvider.currentPlant!.completedAt == null;
              final hasCompletedPlant = waterProvider.currentPlant != null && waterProvider.currentPlant!.completedAt != null;
              final canPlant = seed['quantity'] > 0 && (!hasActivePlant || hasCompletedPlant);
              
              return ElevatedButton(
                onPressed: canPlant
                  ? () async {
                      // 완성된 식물이 있으면 먼저 제거
                      if (hasCompletedPlant) {
                        await waterProvider.removeCompletedPlant();
                      }
                      
                      // 실제 식물 심기 기능 호출
                      final success = await waterProvider.plantSeed(
                        seed['id'],
                        seed['name'],
                        seed['image'],
                      );
                      
                      if (success) {
                        Navigator.of(context).pop(); // 씨앗 상세 다이얼로그 닫기
                        Navigator.of(context).pop(); // 인벤토리 팝업 닫기
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${seed['name']}을(를) 심었습니다! 🌱'),
                            backgroundColor: Colors.green.shade600,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('씨앗 심기에 실패했습니다. 다시 시도해주세요.'),
                            backgroundColor: Colors.red.shade600,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canPlant ? Colors.green.shade600 : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  hasActivePlant 
                    ? '식물 있음 🌱' 
                    : seed['quantity'] > 0 
                      ? '심기 🌱' 
                      : '씨앗 부족'
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

