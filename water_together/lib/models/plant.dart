// lib/models/plant.dart
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

  // 식물에 물 주기
  Plant addWater(int waterAmount) {
    return copyWith(
      growthProgress: growthProgress + waterAmount,
    );
  }

  // 다음 단계로 성장 가능한지 확인
  bool canGrowToNextStage() {
    return growthProgress >= totalGrowthRequired && stage < 3;
  }

  // 다음 단계로 성장
  Plant growToNextStage() {
    if (!canGrowToNextStage()) return this;
    
    return copyWith(
      stage: stage + 1,
      growthProgress: 0,
      totalGrowthRequired: _getNextStageRequirement(stage + 1),
    );
  }

  // 다음 단계 성장 요구량 계산
  int _getNextStageRequirement(int nextStage) {
    switch (nextStage) {
      case 1: return 500;   // 줄기
      case 2: return 1000;   // 꽃
      case 3: return 2000;   // 열매
      default: return 0;
    }
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