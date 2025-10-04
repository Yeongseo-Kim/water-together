// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantConfig _$PlantConfigFromJson(Map<String, dynamic> json) => PlantConfig(
      plantId: json['plantId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      rarity: json['rarity'] as String,
      stageRequirements: (json['stageRequirements'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      stageImages: (json['stageImages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      personality: PlantPersonality.fromJson(
          json['personality'] as Map<String, dynamic>),
      stats: PlantStats.fromJson(json['stats'] as Map<String, dynamic>),
      description: json['description'] as String,
    );

Map<String, dynamic> _$PlantConfigToJson(PlantConfig instance) =>
    <String, dynamic>{
      'plantId': instance.plantId,
      'name': instance.name,
      'category': instance.category,
      'rarity': instance.rarity,
      'stageRequirements': instance.stageRequirements,
      'stageImages': instance.stageImages,
      'personality': instance.personality,
      'stats': instance.stats,
      'description': instance.description,
    };

PlantPersonality _$PlantPersonalityFromJson(Map<String, dynamic> json) =>
    PlantPersonality(
      type: json['type'] as String,
      greetings:
          (json['greetings'] as List<dynamic>).map((e) => e as String).toList(),
      encouragements: (json['encouragements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      thanks:
          (json['thanks'] as List<dynamic>).map((e) => e as String).toList(),
      complaints: (json['complaints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      stageComments: Map<String, String>.from(json['stageComments'] as Map),
    );

Map<String, dynamic> _$PlantPersonalityToJson(PlantPersonality instance) =>
    <String, dynamic>{
      'type': instance.type,
      'greetings': instance.greetings,
      'encouragements': instance.encouragements,
      'thanks': instance.thanks,
      'complaints': instance.complaints,
      'stageComments': instance.stageComments,
    };

PlantStats _$PlantStatsFromJson(Map<String, dynamic> json) => PlantStats(
      baseGrowthSpeed: (json['baseGrowthSpeed'] as num).toInt(),
      waterEfficiency: (json['waterEfficiency'] as num).toInt(),
      rewardMultiplier: (json['rewardMultiplier'] as num).toInt(),
      specialAbilities: (json['specialAbilities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      seasonalBonuses: Map<String, int>.from(json['seasonalBonuses'] as Map),
    );

Map<String, dynamic> _$PlantStatsToJson(PlantStats instance) =>
    <String, dynamic>{
      'baseGrowthSpeed': instance.baseGrowthSpeed,
      'waterEfficiency': instance.waterEfficiency,
      'rewardMultiplier': instance.rewardMultiplier,
      'specialAbilities': instance.specialAbilities,
      'seasonalBonuses': instance.seasonalBonuses,
    };
