// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plant _$PlantFromJson(Map<String, dynamic> json) => Plant(
      plantId: json['plantId'] as String,
      name: json['name'] as String,
      stage: (json['stage'] as num).toInt(),
      growthProgress: (json['growthProgress'] as num).toInt(),
      totalGrowthRequired: (json['totalGrowthRequired'] as num).toInt(),
      imagePath: json['imagePath'] as String,
    );

Map<String, dynamic> _$PlantToJson(Plant instance) => <String, dynamic>{
      'plantId': instance.plantId,
      'name': instance.name,
      'stage': instance.stage,
      'growthProgress': instance.growthProgress,
      'totalGrowthRequired': instance.totalGrowthRequired,
      'imagePath': instance.imagePath,
    };
