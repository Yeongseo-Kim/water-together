// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inventory _$InventoryFromJson(Map<String, dynamic> json) => Inventory(
      userId: json['userId'] as String,
      seedId: json['seedId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      plantName: json['plantName'] as String,
    );

Map<String, dynamic> _$InventoryToJson(Inventory instance) => <String, dynamic>{
      'userId': instance.userId,
      'seedId': instance.seedId,
      'quantity': instance.quantity,
      'plantName': instance.plantName,
    };
