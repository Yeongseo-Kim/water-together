// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      password: json['password'] as String,
      dailyWaterGoal: (json['dailyWaterGoal'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'password': instance.password,
      'dailyWaterGoal': instance.dailyWaterGoal,
      'createdAt': instance.createdAt.toIso8601String(),
    };
