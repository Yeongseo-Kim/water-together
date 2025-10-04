// lib/models/plant_config.dart
import 'package:json_annotation/json_annotation.dart';

part 'plant_config.g.dart';

@JsonSerializable()
class PlantConfig {
  final String plantId;
  final String name;
  final String category; // 'flower', 'tree', 'vegetable', 'cactus'
  final String rarity; // 'common', 'rare', 'epic', 'legendary'
  final List<int> stageRequirements; // [500, 1000, 2000]
  final List<String> stageImages; // ['🌱', '🌿', '🌸', '🍎']
  final PlantPersonality personality;
  final PlantStats stats;
  final String description;

  const PlantConfig({
    required this.plantId,
    required this.name,
    required this.category,
    required this.rarity,
    required this.stageRequirements,
    required this.stageImages,
    required this.personality,
    required this.stats,
    required this.description,
  });

  factory PlantConfig.fromJson(Map<String, dynamic> json) => _$PlantConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PlantConfigToJson(this);
}

@JsonSerializable()
class PlantPersonality {
  final String type; // 'cheerful', 'shy', 'energetic', 'calm', 'mysterious'
  final List<String> greetings; // 인사말들
  final List<String> encouragements; // 격려 메시지들
  final List<String> thanks; // 감사 메시지들
  final List<String> complaints; // 불만 메시지들
  final Map<String, String> stageComments; // 단계별 코멘트

  const PlantPersonality({
    required this.type,
    required this.greetings,
    required this.encouragements,
    required this.thanks,
    required this.complaints,
    required this.stageComments,
  });

  factory PlantPersonality.fromJson(Map<String, dynamic> json) => _$PlantPersonalityFromJson(json);
  Map<String, dynamic> toJson() => _$PlantPersonalityToJson(this);
}

@JsonSerializable()
class PlantStats {
  final int baseGrowthSpeed; // 기본 성장 속도 (1-10)
  final int waterEfficiency; // 물 효율성 (1-10)
  final int rewardMultiplier; // 보상 배수 (1-3)
  final List<String> specialAbilities; // 특수 능력들
  final Map<String, int> seasonalBonuses; // 계절별 보너스

  const PlantStats({
    required this.baseGrowthSpeed,
    required this.waterEfficiency,
    required this.rewardMultiplier,
    required this.specialAbilities,
    required this.seasonalBonuses,
  });

  factory PlantStats.fromJson(Map<String, dynamic> json) => _$PlantStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PlantStatsToJson(this);
}
