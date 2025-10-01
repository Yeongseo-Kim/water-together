import 'package:flutter_test/flutter_test.dart';
import 'package:water_together/models/user.dart';
import 'package:water_together/models/plant.dart';
import 'package:water_together/models/water_log.dart';
import 'package:water_together/models/inventory.dart';
import 'package:water_together/models/friend.dart';

void main() {
  group('User Model Tests', () {
    test('User 생성 및 유효성 검사', () {
      final user = User(
        userId: 'user123',
        nickname: '테스트유저',
        password: 'password123',
        dailyWaterGoal: 2000,
        createdAt: DateTime.now(),
      );

      expect(user.isValid(), isTrue);
      expect(user.userId, equals('user123'));
      expect(user.nickname, equals('테스트유저'));
      expect(user.dailyWaterGoal, equals(2000));
    });

    test('User JSON 직렬화/역직렬화', () {
      final user = User(
        userId: 'user123',
        nickname: '테스트유저',
        password: 'password123',
        dailyWaterGoal: 2000,
        createdAt: DateTime.now(),
      );

      final json = user.toJson();
      final restoredUser = User.fromJson(json);

      expect(restoredUser.userId, equals(user.userId));
      expect(restoredUser.nickname, equals(user.nickname));
      expect(restoredUser.dailyWaterGoal, equals(user.dailyWaterGoal));
    });
  });

  group('Plant Model Tests', () {
    test('Plant 생성 및 성장 단계 관리', () {
      final plant = Plant(
        plantId: 'plant123',
        name: '토마토',
        stage: 0,
        growthProgress: 0,
        totalGrowthRequired: 2000,
        imagePath: 'tomato.png',
      );

      expect(plant.stage, equals(0));
      expect(plant.canGrowToNextStage(), isFalse);

      // 물 추가 후 성장 확인
      final wateredPlant = plant.addWater(500);
      expect(wateredPlant.growthProgress, equals(500));
      expect(wateredPlant.canGrowToNextStage(), isTrue);
    });

    test('Plant 성장 진행률 계산', () {
      final plant = Plant(
        plantId: 'plant123',
        name: '토마토',
        stage: 0,
        growthProgress: 1000,
        totalGrowthRequired: 2000,
        imagePath: 'tomato.png',
      );

      expect(plant.getGrowthProgressRate(), equals(0.5));
    });
  });

  group('WaterLog Model Tests', () {
    test('WaterLog 생성 및 타입별 섭취량', () {
      final waterLog = WaterLog(
        logId: 'log123',
        userId: 'user123',
        date: DateTime.now(),
        amount: 300,
        type: '한컵',
      );

      expect(waterLog.type, equals('한컵'));
      expect(WaterLog.getAmountFromType('한컵'), equals(300));
      expect(WaterLog.getAmountFromType('반컵'), equals(150));
      expect(WaterLog.getAmountFromType('한모금'), equals(50));
    });

    test('목표 달성 여부 확인', () {
      final waterLog = WaterLog(
        logId: 'log123',
        userId: 'user123',
        date: DateTime.now(),
        amount: 2000,
        type: '한컵',
      );

      expect(waterLog.isGoalAchieved(2000), isTrue);
      expect(waterLog.isGoalAchieved(2500), isFalse);
    });
  });

  group('Inventory Model Tests', () {
    test('Inventory 씨앗 관리', () {
      final inventory = Inventory(
        userId: 'user123',
        seedId: 'seed123',
        quantity: 5,
        plantName: '토마토',
      );

      expect(inventory.hasSeeds(), isTrue);
      expect(inventory.getSeedCount(), equals(5));

      // 씨앗 사용
      final usedInventory = inventory.useSeed();
      expect(usedInventory.getSeedCount(), equals(4));

      // 씨앗 추가
      final addedInventory = inventory.addSeeds(3);
      expect(addedInventory.getSeedCount(), equals(8));
    });
  });

  group('Friend Model Tests', () {
    test('Friend 상태 관리', () {
      final friend = Friend(
        userId: 'user123',
        friendId: 'friend123',
        friendNickname: '친구닉네임',
        status: Friend.statusPending,
        addedAt: DateTime.now(),
      );

      expect(friend.isPending(), isTrue);
      expect(friend.isAccepted(), isFalse);

      // 친구 승인
      final acceptedFriend = friend.acceptFriend();
      expect(acceptedFriend.isAccepted(), isTrue);
      expect(acceptedFriend.isPending(), isFalse);
    });
  });
}
