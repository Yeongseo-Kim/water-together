// lib/models/plant.dart
import 'package:json_annotation/json_annotation.dart';
import 'plant_config.dart';
import '../services/plant_config_service.dart';

part 'plant.g.dart';

@JsonSerializable()
class Plant {
  final String plantId;
  final String plantTypeId; // PlantConfig의 plantId 참조
  final String name;
  final int stage; // 0: 씨앗, 1: 줄기, 2: 꽃, 3: 열매
  final int growthProgress; // 현재 성장 진행도
  final int totalGrowthRequired; // 완전 성장까지 필요한 총 섭취량
  final String imagePath;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int totalWaterConsumed;

  Plant({
    required this.plantId,
    required this.plantTypeId,
    required this.name,
    required this.stage,
    required this.growthProgress,
    required this.totalGrowthRequired,
    required this.imagePath,
    required this.createdAt,
    this.completedAt,
    required this.totalWaterConsumed,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
  Map<String, dynamic> toJson() => _$PlantToJson(this);

  // PlantConfig를 참조하여 동적 데이터 가져오기
  PlantConfig? get config => PlantConfigService.instance.getPlantConfig(plantTypeId);

  // 현재 단계 이미지 가져오기
  String get currentStageImage {
    final config = this.config;
    print('🔍 currentStageImage 호출:');
    print('  - plantName: $name');
    print('  - plantTypeId: $plantTypeId');
    print('  - stage: $stage');
    print('  - config: ${config != null ? "로드됨" : "null"}');
    if (config != null) {
      print('  - stageImages: ${config.stageImages}');
      print('  - stageImages.length: ${config.stageImages.length}');
    }
    
    if (config != null && stage < config.stageImages.length) {
      final image = config.stageImages[stage];
      print('🌱 Plant $name - Stage $stage: $image');
      return image;
    }
    print('🌱 Plant $name - Stage $stage: fallback to $imagePath');
    return imagePath;
  }

  // 다음 단계 요구량 가져오기
  int getNextStageRequirement() {
    final config = this.config;
    if (config != null && stage < config.stageRequirements.length) {
      return config.stageRequirements[stage];
    }
    return 500; // 기본값
  }

  // 성격 기반 메시지 가져오기
  String getPersonalityMessage(String messageType) {
    final config = this.config;
    if (config != null) {
      final personality = config.personality;
      switch (messageType) {
        case 'greeting':
          return personality.greetings.isNotEmpty 
              ? personality.greetings[DateTime.now().millisecondsSinceEpoch % personality.greetings.length]
              : '안녕하세요!';
        case 'encouragement':
          return personality.encouragements.isNotEmpty
              ? personality.encouragements[DateTime.now().millisecondsSinceEpoch % personality.encouragements.length]
              : '함께 성장해요!';
        case 'thanks':
          return personality.thanks.isNotEmpty
              ? personality.thanks[DateTime.now().millisecondsSinceEpoch % personality.thanks.length]
              : '고마워요!';
        case 'complaint':
          return personality.complaints.isNotEmpty
              ? personality.complaints[DateTime.now().millisecondsSinceEpoch % personality.complaints.length]
              : '물이 필요해요...';
        default:
          return '안녕하세요!';
      }
    }
    return '안녕하세요!';
  }

  // 단계별 코멘트 가져오기
  String getStageComment() {
    final config = this.config;
    if (config != null) {
      return config.personality.stageComments[stage.toString()] ?? '성장 중이에요!';
    }
    return '성장 중이에요!';
  }

  // 식물에 물 주기
  Plant addWater(int waterAmount) {
    return copyWith(
      growthProgress: growthProgress + waterAmount,
      totalWaterConsumed: totalWaterConsumed + waterAmount,
    );
  }

  // 다음 단계로 성장 가능한지 확인
  bool canGrowToNextStage() {
    return growthProgress >= totalGrowthRequired && stage < 3;
  }

  // 최종 단계(열매)에 도달했는지 확인
  bool isFullyGrown() {
    return stage == 3 && growthProgress >= totalGrowthRequired;
  }

  // 다음 단계로 성장
  Plant growToNextStage() {
    if (!canGrowToNextStage()) return this;
    
    final nextStage = stage + 1;
    final nextRequirement = getNextStageRequirement();
    
    print('🌿 성장! Stage $stage → Stage $nextStage, 다음 요구량: $nextRequirement');
    
    return copyWith(
      stage: nextStage,
      growthProgress: 0,
      totalGrowthRequired: nextRequirement,
    );
  }

  // 식물 복사 (수정용)
  Plant copyWith({
    String? plantId,
    String? plantTypeId,
    String? name,
    int? stage,
    int? growthProgress,
    int? totalGrowthRequired,
    String? imagePath,
    DateTime? createdAt,
    DateTime? completedAt,
    int? totalWaterConsumed,
  }) {
    return Plant(
      plantId: plantId ?? this.plantId,
      plantTypeId: plantTypeId ?? this.plantTypeId,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      growthProgress: growthProgress ?? this.growthProgress,
      totalGrowthRequired: totalGrowthRequired ?? this.totalGrowthRequired,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      totalWaterConsumed: totalWaterConsumed ?? this.totalWaterConsumed,
    );
  }
}