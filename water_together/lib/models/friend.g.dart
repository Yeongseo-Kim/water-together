// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Friend _$FriendFromJson(Map<String, dynamic> json) => Friend(
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      friendNickname: json['friendNickname'] as String,
      status: json['status'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$FriendToJson(Friend instance) => <String, dynamic>{
      'userId': instance.userId,
      'friendId': instance.friendId,
      'friendNickname': instance.friendNickname,
      'status': instance.status,
      'addedAt': instance.addedAt.toIso8601String(),
    };
