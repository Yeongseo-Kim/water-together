import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';
import '../models/user.dart';
import '../models/water_log.dart';

class FriendService {
  static const String _friendsKey = 'friends';
  static const String _usersKey = 'users';
  static const String _waterLogsKey = 'water_logs';

  // 친구 목록 조회
  Future<List<Friend>> getFriends(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getStringList('${_friendsKey}_$userId') ?? [];
      
      return friendsJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return Friend.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting friends: $e');
      return [];
    }
  }

  // 친구 추가 요청 전송
  Future<bool> sendFriendRequest(String userId, String friendId) async {
    try {
      // 자기 자신에게 친구 요청하는 것 방지
      if (userId == friendId) {
        return false;
      }

      // 친구가 존재하는지 확인
      final friendExists = await _checkUserExists(friendId);
      if (!friendExists) {
        return false;
      }

      // 이미 친구인지 확인
      final existingFriends = await getFriends(userId);
      final alreadyFriends = existingFriends.any((friend) => 
        friend.friendId == friendId && friend.status == Friend.statusAccepted);
      
      if (alreadyFriends) {
        return false;
      }

      // 이미 요청을 보냈는지 확인
      final pendingRequest = existingFriends.any((friend) => 
        friend.friendId == friendId && friend.status == Friend.statusPending);
      
      if (pendingRequest) {
        return false;
      }

      // 친구 요청 생성
      final friendRequest = Friend(
        userId: userId,
        friendId: friendId,
        friendNickname: await _getUserNickname(friendId) ?? friendId,
        status: Friend.statusPending,
        addedAt: DateTime.now(),
      );

      // 로컬에 저장
      await _saveFriend(userId, friendRequest);
      
      // 상대방에게도 요청 저장 (양방향)
      final reverseRequest = Friend(
        userId: friendId,
        friendId: userId,
        friendNickname: await _getUserNickname(userId) ?? userId,
        status: Friend.statusPending,
        addedAt: DateTime.now(),
      );
      
      await _saveFriend(friendId, reverseRequest);

      return true;
    } catch (e) {
      print('Error sending friend request: $e');
      return false;
    }
  }

  // 친구 요청 수락
  Future<bool> acceptFriendRequest(String userId, String friendId) async {
    try {
      final friends = await getFriends(userId);
      final friendIndex = friends.indexWhere((friend) => 
        friend.friendId == friendId && friend.status == Friend.statusPending);
      
      if (friendIndex == -1) {
        return false;
      }

      // 요청 수락
      friends[friendIndex] = friends[friendIndex].acceptFriend();
      await _saveFriends(userId, friends);

      // 상대방의 요청도 수락
      final friendFriends = await getFriends(friendId);
      final friendFriendIndex = friendFriends.indexWhere((friend) => 
        friend.friendId == userId && friend.status == Friend.statusPending);
      
      if (friendFriendIndex != -1) {
        friendFriends[friendFriendIndex] = friendFriends[friendFriendIndex].acceptFriend();
        await _saveFriends(friendId, friendFriends);
      }

      return true;
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  // 친구 요청 거절
  Future<bool> rejectFriendRequest(String userId, String friendId) async {
    try {
      final friends = await getFriends(userId);
      final friendIndex = friends.indexWhere((friend) => 
        friend.friendId == friendId && friend.status == Friend.statusPending);
      
      if (friendIndex == -1) {
        return false;
      }

      // 요청 거절
      friends[friendIndex] = friends[friendIndex].rejectFriend();
      await _saveFriends(userId, friends);

      return true;
    } catch (e) {
      print('Error rejecting friend request: $e');
      return false;
    }
  }

  // 친구 삭제
  Future<bool> removeFriend(String userId, String friendId) async {
    try {
      final friends = await getFriends(userId);
      friends.removeWhere((friend) => friend.friendId == friendId);
      await _saveFriends(userId, friends);

      // 상대방 목록에서도 삭제
      final friendFriends = await getFriends(friendId);
      friendFriends.removeWhere((friend) => friend.friendId == userId);
      await _saveFriends(friendId, friendFriends);

      return true;
    } catch (e) {
      print('Error removing friend: $e');
      return false;
    }
  }

  // 친구의 오늘 섭취량 조회
  Future<int> getFriendTodayIntake(String friendId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      
      final waterLogsJson = prefs.getStringList('${_waterLogsKey}_$friendId') ?? [];
      final waterLogs = waterLogsJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return WaterLog.fromJson(data);
      }).toList();

      int totalIntake = 0;
      for (final log in waterLogs) {
        final logDate = log.date;
        if (logDate.year == today.year && 
            logDate.month == today.month && 
            logDate.day == today.day) {
          totalIntake += log.amount;
        }
      }

      return totalIntake;
    } catch (e) {
      print('Error getting friend today intake: $e');
      return 0;
    }
  }

  // 친구의 목표 달성률 계산
  Future<double> getFriendAchievementRate(String friendId) async {
    try {
      final todayIntake = await getFriendTodayIntake(friendId);
      final userGoal = await _getUserDailyGoal(friendId);
      
      if (userGoal == 0) return 0.0;
      return (todayIntake / userGoal).clamp(0.0, 1.0);
    } catch (e) {
      print('Error getting friend achievement rate: $e');
      return 0.0;
    }
  }

  // 친구 목록을 섭취량 기준으로 정렬
  Future<List<Friend>> getFriendsSortedByIntake(String userId) async {
    try {
      final friends = await getFriends(userId);
      final acceptedFriends = friends.where((friend) => 
        friend.status == Friend.statusAccepted).toList();

      // 각 친구의 오늘 섭취량 조회
      final friendsWithIntake = <Map<String, dynamic>>[];
      for (final friend in acceptedFriends) {
        final intake = await getFriendTodayIntake(friend.friendId);
        friendsWithIntake.add({
          'friend': friend,
          'intake': intake,
        });
      }

      // 섭취량 기준으로 정렬 (내림차순)
      friendsWithIntake.sort((a, b) => b['intake'].compareTo(a['intake']));

      return friendsWithIntake.map((item) => item['friend'] as Friend).toList();
    } catch (e) {
      print('Error getting friends sorted by intake: $e');
      return [];
    }
  }

  // 친구 검색 (아이디 기반)
  Future<List<User>> searchUsers(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      final allUsers = usersJson.map((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return User.fromJson(data);
      }).toList();

      // 검색어와 일치하는 사용자 필터링
      return allUsers.where((user) => 
        user.userId.toLowerCase().contains(query.toLowerCase()) ||
        user.nickname.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // 사용자 존재 여부 확인
  Future<bool> _checkUserExists(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      return usersJson.any((json) {
        final Map<String, dynamic> data = jsonDecode(json);
        return data['userId'] == userId;
      });
    } catch (e) {
      print('Error checking user exists: $e');
      return false;
    }
  }

  // 사용자 닉네임 조회
  Future<String?> _getUserNickname(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      for (final json in usersJson) {
        final Map<String, dynamic> data = jsonDecode(json);
        if (data['userId'] == userId) {
          return data['nickname'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting user nickname: $e');
      return null;
    }
  }

  // 사용자 일일 목표 조회
  Future<int> _getUserDailyGoal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      for (final json in usersJson) {
        final Map<String, dynamic> data = jsonDecode(json);
        if (data['userId'] == userId) {
          return data['dailyWaterGoal'] ?? 1000;
        }
      }
      return 1000; // 기본값
    } catch (e) {
      print('Error getting user daily goal: $e');
      return 1000;
    }
  }

  // 친구 저장
  Future<void> _saveFriend(String userId, Friend friend) async {
    try {
      final friends = await getFriends(userId);
      friends.add(friend);
      await _saveFriends(userId, friends);
    } catch (e) {
      print('Error saving friend: $e');
    }
  }

  // 친구 목록 저장
  Future<void> _saveFriends(String userId, List<Friend> friends) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = friends.map((friend) => jsonEncode(friend.toJson())).toList();
      await prefs.setStringList('${_friendsKey}_$userId', friendsJson);
    } catch (e) {
      print('Error saving friends: $e');
    }
  }

  // 데모 친구 데이터 생성 (테스트용)
  Future<void> createDemoFriends(String userId) async {
    try {
      final demoFriends = [
        Friend(
          userId: userId,
          friendId: 'friend_001',
          friendNickname: '물마시는친구1',
          status: Friend.statusAccepted,
          addedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Friend(
          userId: userId,
          friendId: 'friend_002',
          friendNickname: '물마시는친구2',
          status: Friend.statusAccepted,
          addedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Friend(
          userId: userId,
          friendId: 'friend_003',
          friendNickname: '물마시는친구3',
          status: Friend.statusPending,
          addedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];

      await _saveFriends(userId, demoFriends);
    } catch (e) {
      print('Error creating demo friends: $e');
    }
  }
}
