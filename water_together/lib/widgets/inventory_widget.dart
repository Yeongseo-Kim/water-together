import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../models/inventory.dart';

class InventoryWidget extends StatelessWidget {
  final bool showAsDialog;
  final VoidCallback? onSeedPlanted;

  const InventoryWidget({
    super.key,
    this.showAsDialog = false,
    this.onSeedPlanted,
  });

  @override
  Widget build(BuildContext context) {
    if (showAsDialog) {
      return _buildDialog(context);
    }
    
    return _buildWidget(context);
  }

  Widget _buildWidget(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '인벤토리',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (waterProvider.inventory.isEmpty)
                _buildEmptyInventory(context)
              else
                _buildInventoryList(context, waterProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyInventory(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '🌱',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            '아직 씨앗이 없어요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '식물을 키워서 씨앗을 얻어보세요!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(BuildContext context, WaterProvider waterProvider) {
    return Column(
      children: waterProvider.inventory.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              // 씨앗 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              
              // 씨앗 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.plantName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '수량: ${item.quantity}개',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 심기 버튼
              if (item.hasSeeds())
                ElevatedButton(
                  onPressed: () => _plantSeed(context, item),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('심기'),
                )
              else
                Text(
                  '없음',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDialog(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.inventory),
              const SizedBox(width: 8),
              const Text('인벤토리'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: waterProvider.inventory.isEmpty
                ? _buildEmptyInventory(context)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: waterProvider.inventory.length,
                    itemBuilder: (context, index) {
                      final item = waterProvider.inventory[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text('🌱', style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          title: Text(item.plantName),
                          subtitle: Text('수량: ${item.quantity}개'),
                          trailing: item.hasSeeds()
                              ? ElevatedButton(
                                  onPressed: () {
                                    _plantSeed(context, item);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('심기'),
                                )
                              : const Text('없음'),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void _plantSeed(BuildContext context, Inventory item) {
    final waterProvider = context.read<WaterProvider>();
    
    // 씨앗 심기 로직
    waterProvider.useSeed(item.seedId);
    
    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${item.plantName} 씨앗을 심었습니다!'),
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
    
    // 콜백 실행
    onSeedPlanted?.call();
  }
}

class InventoryButton extends StatelessWidget {
  const InventoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showInventoryDialog(context),
      icon: const Icon(Icons.inventory),
      label: const Text('인벤토리'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  void _showInventoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InventoryWidget(showAsDialog: true);
      },
    );
  }
}
