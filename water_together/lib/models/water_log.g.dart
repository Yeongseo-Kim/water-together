// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterLog _$WaterLogFromJson(Map<String, dynamic> json) => WaterLog(
      logId: json['logId'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toInt(),
      type: json['type'] as String,
    );

Map<String, dynamic> _$WaterLogToJson(WaterLog instance) => <String, dynamic>{
      'logId': instance.logId,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'type': instance.type,
    };
