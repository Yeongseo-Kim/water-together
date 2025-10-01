import 'package:json_annotation/json_annotation.dart';

part 'friend.g.dart';

@JsonSerializable()
class Friend {
  final String userId;
  final String friendId;
  final String friendNickname;
  final String status; // 'pending', 'accepted'
  final DateTime addedAt;

  Friend({
    required this.userId,
    required this.friendId,
    required this.friendNickname,
    required this.status,
    required this.addedAt,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
  Map<String, dynamic> toJson() => _$FriendToJson(this);

  // 친구 상태 상수
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';

  // 친구 상태 관리 메서드
  Friend acceptFriend() {
    return Friend(
      userId: userId,
      friendId: friendId,
      friendNickname: friendNickname,
      status: statusAccepted,
      addedAt: addedAt,
    );
  }

  Friend rejectFriend() {
    return Friend(
      userId: userId,
      friendId: friendId,
      friendNickname: friendNickname,
      status: 'rejected',
      addedAt: addedAt,
    );
  }

  // 친구 상태 확인
  bool isPending() {
    return status == statusPending;
  }

  bool isAccepted() {
    return status == statusAccepted;
  }

  bool isRejected() {
    return status == 'rejected';
  }

  // 친구 복사 (수정용)
  Friend copyWith({
    String? userId,
    String? friendId,
    String? friendNickname,
    String? status,
    DateTime? addedAt,
  }) {
    return Friend(
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friendNickname: friendNickname ?? this.friendNickname,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
