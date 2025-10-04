// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plant _$PlantFromJson(Map<String, dynamic> json) => Plant(
      plantId: json['plantId'] as String,
      plantTypeId: json['plantTypeId'] as String,
      name: json['name'] as String,
      stage: (json['stage'] as num).toInt(),
      growthProgress: (json['growthProgress'] as num).toInt(),
      totalGrowthRequired: (json['totalGrowthRequired'] as num).toInt(),
      imagePath: json['imagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      totalWaterConsumed: (json['totalWaterConsumed'] as num).toInt(),
    );

Map<String, dynamic> _$PlantToJson(Plant instance) => <String, dynamic>{
      'plantId': instance.plantId,
      'plantTypeId': instance.plantTypeId,
      'name': instance.name,
      'stage': instance.stage,
      'growthProgress': instance.growthProgress,
      'totalGrowthRequired': instance.totalGrowthRequired,
      'imagePath': instance.imagePath,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'totalWaterConsumed': instance.totalWaterConsumed,
    };
