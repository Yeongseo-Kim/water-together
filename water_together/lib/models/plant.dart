import 'package:json_annotation/json_annotation.dart';

part 'plant.g.dart';

@JsonSerializable()
class Plant {
  final String plantId;
  final String name;
  final int stage; // 0: 씨앗, 1: 줄기, 2: 꽃, 3: 열매
  final int growthProgress; // 현재 성장 진행도
  final int totalGrowthRequired; // 완전 성장까지 필요한 총 섭취량
  final String imagePath;

  Plant({
    required this.plantId,
    required this.name,
    required this.stage,
    required this.growthProgress,
    required this.totalGrowthRequired,
    required this.imagePath,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
  Map<String, dynamic> toJson() => _$PlantToJson(this);

  // 성장 단계별 이미지 경로 관리
  String getStageImagePath() {
    switch (stage) {
      case 0:
        return '🌱'; // 씨앗
      case 1:
        return '🌿'; // 줄기
      case 2:
        return '🌸'; // 꽃
      case 3:
        return '🌰'; // 열매
      default:
        return '🌱';
    }
  }

  // 성장 조건 검증 메서드
  bool canGrowToNextStage() {
    switch (stage) {
      case 0: // 씨앗 → 줄기
        return growthProgress >= 500; // 500ml
      case 1: // 줄기 → 꽃
        return growthProgress >= 1000; // 1L
      case 2: // 꽃 → 열매
        return growthProgress >= 2000; // 2L
      default:
        return false;
    }
  }

  // 성장 진행률 계산 (0.0 ~ 1.0)
  double getGrowthProgressRate() {
    if (totalGrowthRequired == 0) return 0.0;
    return (growthProgress / totalGrowthRequired).clamp(0.0, 1.0);
  }

  // 다음 성장 단계로 진행
  Plant growToNextStage() {
    if (!canGrowToNextStage()) return this;
    
    return Plant(
      plantId: plantId,
      name: name,
      stage: stage + 1,
      growthProgress: growthProgress,
      totalGrowthRequired: totalGrowthRequired,
      imagePath: imagePath,
    );
  }

  // 물 섭취량 추가
  Plant addWater(int amount) {
    return Plant(
      plantId: plantId,
      name: name,
      stage: stage,
      growthProgress: growthProgress + amount,
      totalGrowthRequired: totalGrowthRequired,
      imagePath: imagePath,
    );
  }

  // 식물 복사 (수정용)
  Plant copyWith({
    String? plantId,
    String? name,
    int? stage,
    int? growthProgress,
    int? totalGrowthRequired,
    String? imagePath,
  }) {
    return Plant(
      plantId: plantId ?? this.plantId,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      growthProgress: growthProgress ?? this.growthProgress,
      totalGrowthRequired: totalGrowthRequired ?? this.totalGrowthRequired,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
