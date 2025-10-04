import 'package:json_annotation/json_annotation.dart';

part 'inventory.g.dart';

@JsonSerializable()
class Inventory {
  final String userId;
  final String seedId;
  final int quantity;
  final String plantName;
  final String image;

  Inventory({
    required this.userId,
    required this.seedId,
    required this.quantity,
    required this.plantName,
    required this.image,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) => _$InventoryFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryToJson(this);

  // 씨앗 추가 메서드
  Inventory addSeeds(int amount) {
    return Inventory(
      userId: userId,
      seedId: seedId,
      quantity: quantity + amount,
      plantName: plantName,
      image: image,
    );
  }

  // 씨앗 사용 메서드
  Inventory useSeed() {
    if (quantity <= 0) return this;
    
    return Inventory(
      userId: userId,
      seedId: seedId,
      quantity: quantity - 1,
      plantName: plantName,
      image: image,
    );
  }

  // 씨앗 보유 여부 확인
  bool hasSeeds() {
    return quantity > 0;
  }

  // 씨앗 수량 확인
  int getSeedCount() {
    return quantity;
  }

  // 인벤토리 복사 (수정용)
  Inventory copyWith({
    String? userId,
    String? seedId,
    int? quantity,
    String? plantName,
    String? image,
  }) {
    return Inventory(
      userId: userId ?? this.userId,
      seedId: seedId ?? this.seedId,
      quantity: quantity ?? this.quantity,
      plantName: plantName ?? this.plantName,
      image: image ?? this.image,
    );
  }
}
