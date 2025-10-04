import 'package:json_annotation/json_annotation.dart';
import 'plant.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String userId;
  final String nickname;
  final String password;
  final int dailyWaterGoal; // ml 단위
  final DateTime createdAt;
  final Plant? plant; // 사용자의 식물

  User({
    required this.userId,
    required this.nickname,
    required this.password,
    required this.dailyWaterGoal,
    required this.createdAt,
    this.plant,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // 유효성 검사 메서드
  bool isValid() {
    return userId.isNotEmpty && 
           nickname.isNotEmpty && 
           password.isNotEmpty && 
           dailyWaterGoal > 0;
  }

  // 사용자 정보 복사 (수정용)
  User copyWith({
    String? userId,
    String? nickname,
    String? password,
    int? dailyWaterGoal,
    DateTime? createdAt,
    Plant? plant,
  }) {
    return User(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      password: password ?? this.password,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      createdAt: createdAt ?? this.createdAt,
      plant: plant ?? this.plant,
    );
  }
}
