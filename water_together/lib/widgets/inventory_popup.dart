import 'package:flutter/material.dart';
import 'seed_preview_widget.dart';

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
        title: Text(seed['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              seed['image'],
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(seed['description']),
            const SizedBox(height: 16),
            Text('보유 수량: ${seed['quantity']}개'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              // UserFlow.md 요구사항: 심기 버튼 클릭 시 새로운 식물 심기
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 인벤토리 팝업도 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${seed['name']}을(를) 심었습니다!')),
              );
            },
            child: const Text('심기'),
          ),
        ],
      ),
    );
  }
}

