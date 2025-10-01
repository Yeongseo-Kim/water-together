import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant.dart';
import '../models/inventory.dart';
import '../data/plant_database.dart';
import 'collection_service.dart';

class PlantGrowthService {
  static const String _plantsKey = 'user_plants';
  static const String _collectedPlantsKey = 'collected_plants';

  // 싱글톤 패턴
  static final PlantGrowthService _instance = PlantGrowthService._internal();
  factory PlantGrowthService() => _instance;
  PlantGrowthService._internal();

  // 식물 데이터베이스는 이제 PlantDatabase 클래스에서 관리

  // 현재 식물 저장
  Future<bool> saveCurrentPlant(String userId, Plant plant) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plantKey = '${_plantsKey}_${userId}';
      
      await prefs.setString(plantKey, jsonEncode(plant.toJson()));
      return true;
    } catch (e) {
      print('Error saving current plant: $e');
      return false;
    }
  }

  // 현재 식물 불러오기
  Future<Plant?> getCurrentPlant(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plantKey = '${_plantsKey}_${userId}';
      
      final plantJson = prefs.getString(plantKey);
      if (plantJson != null) {
        return Plant.fromJson(jsonDecode(plantJson));
      }
      return null;
    } catch (e) {
      print('Error loading current plant: $e');
      return null;
    }
  }

  // 식물에 물 주기
  Future<Plant?> waterPlant(String userId, int waterAmount) async {
    try {
      Plant? currentPlant = await getCurrentPlant(userId);
      if (currentPlant == null) return null;

      // 물 추가
      Plant wateredPlant = currentPlant.addWater(waterAmount);
      
      // 성장 단계 확인
      Plant? grownPlant = await checkAndGrowPlant(wateredPlant);
      
      // 저장
      await saveCurrentPlant(userId, grownPlant ?? wateredPlant);
      
      return grownPlant ?? wateredPlant;
    } catch (e) {
      print('Error watering plant: $e');
      return null;
    }
  }

  // 식물 성장 확인 및 처리
  Future<Plant?> checkAndGrowPlant(Plant plant) async {
    try {
      if (!plant.canGrowToNextStage()) {
        return null; // 성장할 수 없음
      }

      // 다음 단계로 성장
      Plant grownPlant = plant.growToNextStage();
      
      // 완전 성장 시 보상 지급
      if (grownPlant.stage >= 3) { // 열매 단계 (완전 성장)
        await giveGrowthReward(grownPlant);
      }
      
      return grownPlant;
    } catch (e) {
      print('Error checking plant growth: $e');
      return null;
    }
  }

  // 성장 보상 지급 (강화된 버전)
  Future<void> giveGrowthReward(Plant plant) async {
    try {
      // 식물 이름으로 씨앗 ID 찾기
      final seedId = PlantDatabase.getSeedIdByName(plant.name) ?? 'seed_001';
      final plantData = PlantDatabase.getPlantData(seedId);
      
      if (plantData == null) return;

      // 해당 식물 씨앗 지급 (희귀도에 따라 수량 조정)
      int seedQuantity = 1;
      final rarity = plantData['rarity'] as String;
      
      switch (rarity) {
        case 'common':
          seedQuantity = 2; // 일반 등급은 2개
          break;
        case 'uncommon':
          seedQuantity = 2; // 희귀 등급은 2개
          break;
        case 'rare':
          seedQuantity = 3; // 매우 희귀 등급은 3개
          break;
        case 'legendary':
          seedQuantity = 5; // 전설 등급은 5개
          break;
      }
      
      await addSeedToInventory(seedId, seedQuantity);
      
      // 추가 보상: 희귀도에 따른 랜덤 씨앗 지급
      String bonusSeedId;
      switch (rarity) {
        case 'common':
          // 일반 등급 이하의 씨앗만 지급
          bonusSeedId = PlantDatabase.getRandomSeedByRarity('common');
          break;
        case 'uncommon':
          // 희귀 등급 이하의 씨앗만 지급
          final uncommonSeeds = PlantDatabase.getPlantsUpToRarity('uncommon');
          bonusSeedId = uncommonSeeds.isNotEmpty 
              ? uncommonSeeds[Random().nextInt(uncommonSeeds.length)]
              : 'seed_001';
          break;
        case 'rare':
          // 매우 희귀 등급 이하의 씨앗만 지급
          final rareSeeds = PlantDatabase.getPlantsUpToRarity('rare');
          bonusSeedId = rareSeeds.isNotEmpty 
              ? rareSeeds[Random().nextInt(rareSeeds.length)]
              : 'seed_001';
          break;
        case 'legendary':
          // 모든 등급의 씨앗 지급 가능
          bonusSeedId = PlantDatabase.getRandomSeed();
          break;
        default:
          bonusSeedId = 'seed_001';
      }
      
      await addSeedToInventory(bonusSeedId, 1);
      
      // 도감에 추가
      await CollectionService.addToCollection(seedId);
      
      // 특별 보상: 전설 등급 완성 시 추가 보너스
      if (rarity == 'legendary') {
        // 전설 등급 씨앗 1개 추가 지급
        final legendarySeeds = PlantDatabase.getPlantsByRarity('legendary');
        if (legendarySeeds.isNotEmpty) {
          final bonusLegendarySeed = legendarySeeds[Random().nextInt(legendarySeeds.length)];
          await addSeedToInventory(bonusLegendarySeed, 1);
        }
      }
      
    } catch (e) {
      print('Error giving growth reward: $e');
    }
  }

  // 씨앗을 인벤토리에 추가 (기본 사용자용)
  Future<void> addSeedToInventory(String seedId, int quantity) async {
    // 기본 사용자 ID 사용 (기존 호환성 유지)
    await addSeedToInventoryForUser('default_user', seedId, quantity);
  }

  // 랜덤 씨앗 ID 선택 (가중치 기반)
  String getRandomSeedId() {
    return PlantDatabase.getRandomSeed();
  }

  // 도감 조회 (CollectionService 사용)
  Future<List<Plant>> getCollectionFromService(String userId) async {
    try {
      final collectedSeeds = await CollectionService.getCollectedPlants();
      final List<Plant> collection = [];

      for (final seedId in collectedSeeds) {
        final plantData = PlantDatabase.getPlantData(seedId);
        if (plantData != null) {
          final plant = Plant(
            plantId: seedId,
            name: plantData['name'],
            stage: 3, // 완전 성장된 상태로 표시
            growthProgress: plantData['growthRequirements'].last,
            totalGrowthRequired: plantData['growthRequirements'].last,
            imagePath: plantData['stages'].last,
          );
          collection.add(plant);
        }
      }

      return collection;
    } catch (e) {
      print('Error loading collection: $e');
      return [];
    }
  }

  // 새로운 식물 심기
  Future<Plant?> plantNewSeed(String userId, String seedId) async {
    try {
      // 씨앗이 인벤토리에 있는지 확인
      final hasSeed = await hasSeedInInventory(userId, seedId);
      if (!hasSeed) return null;

      // 씨앗 사용
      await useSeedFromInventory(userId, seedId);

      // 새 식물 생성
      final seedData = PlantDatabase.getPlantData(seedId);
      if (seedData == null) return null;

      final newPlant = Plant(
        plantId: 'plant_${DateTime.now().millisecondsSinceEpoch}',
        name: seedData['name'],
        stage: 0,
        growthProgress: 0,
        totalGrowthRequired: seedData['growthRequirements'].last,
        imagePath: seedData['stages'][0],
      );

      // 저장
      await saveCurrentPlant(userId, newPlant);
      
      return newPlant;
    } catch (e) {
      print('Error planting new seed: $e');
      return null;
    }
  }

  // 인벤토리에 씨앗이 있는지 확인 (사용자별)
  Future<bool> hasSeedInInventory(String userId, String seedId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryKey = 'inventory_${userId}_${seedId}';
      
      final quantity = prefs.getInt(inventoryKey) ?? 0;
      return quantity > 0;
    } catch (e) {
      print('Error checking seed inventory: $e');
      return false;
    }
  }

  // 인벤토리에서 씨앗 사용 (사용자별)
  Future<void> useSeedFromInventory(String userId, String seedId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryKey = 'inventory_${userId}_${seedId}';
      
      final currentQuantity = prefs.getInt(inventoryKey) ?? 0;
      if (currentQuantity > 0) {
        await prefs.setInt(inventoryKey, currentQuantity - 1);
      }
    } catch (e) {
      print('Error using seed from inventory: $e');
    }
  }

  // 인벤토리 조회 (기존 호환성 유지)
  Future<List<Inventory>> getInventory(String userId) async {
    return getUserInventory(userId);
  }

  // 도감 조회
  Future<List<Plant>> getCollection(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Plant> collection = [];

      for (final seedId in PlantDatabase.getAllPlantData().keys) {
        final collectionKey = '${_collectedPlantsKey}_${seedId}';
        final plantJson = prefs.getString(collectionKey);
        
        if (plantJson != null) {
          collection.add(Plant.fromJson(jsonDecode(plantJson)));
        }
      }

      return collection;
    } catch (e) {
      print('Error loading collection: $e');
      return [];
    }
  }

  // 식물 성장 애니메이션 효과를 위한 성장 단계별 정보
  Map<String, dynamic> getGrowthStageInfo(Plant plant) {
    // 식물 이름으로 씨앗 ID 찾기
    final seedId = PlantDatabase.getSeedIdByName(plant.name) ?? 'seed_001';
    final seedData = PlantDatabase.getPlantData(seedId) ?? PlantDatabase.getPlantData('seed_001')!;

    return {
      'currentStage': plant.stage,
      'maxStage': seedData['stages'].length - 1,
      'currentImage': seedData['stages'][plant.stage],
      'nextStageImage': plant.stage < seedData['stages'].length - 1 
          ? seedData['stages'][plant.stage + 1] 
          : seedData['stages'][plant.stage],
      'progressToNext': plant.stage < seedData['growthRequirements'].length 
          ? plant.growthProgress / seedData['growthRequirements'][plant.stage]
          : 1.0,
      'isFullyGrown': plant.stage >= seedData['stages'].length - 1,
    };
  }

  // 식물 성장 조건 검증
  Future<bool> canPlantNewSeed(String userId) async {
    try {
      final currentPlant = await getCurrentPlant(userId);
      return currentPlant == null || currentPlant.stage >= 3; // 현재 식물이 없거나 완전 성장한 경우
    } catch (e) {
      print('Error checking if can plant new seed: $e');
      return false;
    }
  }

  // 식물 성장 통계
  Future<Map<String, dynamic>> getGrowthStats(String userId) async {
    try {
      final collection = await getCollection(userId);
      final inventory = await getInventory(userId);
      
      return {
        'collectedPlants': collection.length,
        'totalSeeds': inventory.fold(0, (sum, item) => sum + item.quantity),
        'fullyGrownPlants': collection.where((plant) => plant.stage >= 3).length,
        'collectionRate': collection.length / PlantDatabase.getAllPlantData().length,
      };
    } catch (e) {
      print('Error getting growth stats: $e');
      return {
        'collectedPlants': 0,
        'totalSeeds': 0,
        'fullyGrownPlants': 0,
        'collectionRate': 0.0,
      };
    }
  }

  // 식물 데이터베이스 조회
  Map<String, dynamic>? getPlantData(String seedId) {
    return PlantDatabase.getPlantData(seedId);
  }

  // 모든 식물 데이터베이스 조회
  Map<String, Map<String, dynamic>> getAllPlantData() {
    return PlantDatabase.getAllPlantData();
  }

  // 희귀도별 씨앗 필터링
  List<String> getSeedsByRarity(String rarity) {
    return PlantDatabase.getPlantsByRarity(rarity);
  }

  // 계절별 씨앗 필터링
  List<String> getSeedsBySeason(String season) {
    return PlantDatabase.getPlantsBySeason(season);
  }

  // 카테고리별 씨앗 필터링
  List<String> getSeedsByCategory(String category) {
    return PlantDatabase.getPlantsByCategory(category);
  }

  // 초기 씨앗 지급 (신규 사용자용)
  Future<void> giveInitialSeeds(String userId) async {
    try {
      // 기본 씨앗 3개 지급
      await addSeedToInventory('seed_001', 3);
      
      // 일반 등급 씨앗 2개 추가 지급
      final commonSeeds = PlantDatabase.getPlantsByRarity('common');
      for (int i = 0; i < 2 && i < commonSeeds.length; i++) {
        await addSeedToInventory(commonSeeds[i], 1);
      }
      
      // 랜덤 씨앗 1개 지급 (희귀도 제한: 희귀 등급 이하)
      final availableSeeds = PlantDatabase.getPlantsUpToRarity('uncommon');
      if (availableSeeds.isNotEmpty) {
        final randomSeedId = availableSeeds[Random().nextInt(availableSeeds.length)];
        await addSeedToInventory(randomSeedId, 1);
      }
    } catch (e) {
      print('Error giving initial seeds: $e');
    }
  }

  // 씨앗 선물 기능
  Future<bool> giftSeedToFriend(String fromUserId, String toUserId, String seedId, int quantity) async {
    try {
      // 보내는 사람이 해당 씨앗을 충분히 가지고 있는지 확인
      final hasEnoughSeeds = await hasEnoughSeedsInInventory(fromUserId, seedId, quantity);
      if (!hasEnoughSeeds) return false;

      // 보내는 사람의 인벤토리에서 씨앗 차감
      await removeSeedsFromInventory(fromUserId, seedId, quantity);
      
      // 받는 사람의 인벤토리에 씨앗 추가
      await addSeedToInventoryForUser(toUserId, seedId, quantity);
      
      // 선물 기록 저장
      await saveGiftRecord(fromUserId, toUserId, seedId, quantity);
      
      return true;
    } catch (e) {
      print('Error gifting seed: $e');
      return false;
    }
  }

  // 특정 수량의 씨앗을 가지고 있는지 확인
  Future<bool> hasEnoughSeedsInInventory(String userId, String seedId, int requiredQuantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryKey = 'inventory_${userId}_${seedId}';
      
      final currentQuantity = prefs.getInt(inventoryKey) ?? 0;
      return currentQuantity >= requiredQuantity;
    } catch (e) {
      print('Error checking seed quantity: $e');
      return false;
    }
  }

  // 인벤토리에서 씨앗 제거
  Future<void> removeSeedsFromInventory(String userId, String seedId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryKey = 'inventory_${userId}_${seedId}';
      
      final currentQuantity = prefs.getInt(inventoryKey) ?? 0;
      final newQuantity = (currentQuantity - quantity).clamp(0, currentQuantity);
      await prefs.setInt(inventoryKey, newQuantity);
    } catch (e) {
      print('Error removing seeds from inventory: $e');
    }
  }

  // 특정 사용자에게 씨앗 추가
  Future<void> addSeedToInventoryForUser(String userId, String seedId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryKey = 'inventory_${userId}_${seedId}';
      
      final currentQuantity = prefs.getInt(inventoryKey) ?? 0;
      await prefs.setInt(inventoryKey, currentQuantity + quantity);
    } catch (e) {
      print('Error adding seed to user inventory: $e');
    }
  }

  // 선물 기록 저장
  Future<void> saveGiftRecord(String fromUserId, String toUserId, String seedId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final giftKey = 'gift_record_${DateTime.now().millisecondsSinceEpoch}';
      
      final giftRecord = {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'seedId': seedId,
        'quantity': quantity,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(giftKey, jsonEncode(giftRecord));
    } catch (e) {
      print('Error saving gift record: $e');
    }
  }

  // 특정 사용자의 인벤토리 조회
  Future<List<Inventory>> getUserInventory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Inventory> inventory = [];

      for (final seedId in PlantDatabase.getAllPlantData().keys) {
        final inventoryKey = 'inventory_${userId}_${seedId}';
        final quantity = prefs.getInt(inventoryKey) ?? 0;
        
        if (quantity > 0) {
          final seedData = PlantDatabase.getPlantData(seedId);
          inventory.add(Inventory(
            userId: userId,
            seedId: seedId,
            quantity: quantity,
            plantName: seedData?['name'] ?? '알 수 없는 식물',
          ));
        }
      }

      return inventory;
    } catch (e) {
      print('Error loading user inventory: $e');
      return [];
    }
  }

  // 씨앗 교환 기능 (희귀도 기반)
  Future<bool> exchangeSeeds(String userId, String fromSeedId, int fromQuantity, String toSeedId) async {
    try {
      // 교환 가능한지 확인 (같은 희귀도끼리만 교환 가능)
      final fromSeedData = PlantDatabase.getPlantData(fromSeedId);
      final toSeedData = PlantDatabase.getPlantData(toSeedId);
      
      if (fromSeedData == null || toSeedData == null) return false;
      if (fromSeedData['rarity'] != toSeedData['rarity']) return false;
      
      // 충분한 씨앗을 가지고 있는지 확인
      final hasEnoughSeeds = await hasEnoughSeedsInInventory(userId, fromSeedId, fromQuantity);
      if (!hasEnoughSeeds) return false;
      
      // 교환 비율 계산 (희귀도에 따라)
      int exchangeRate = 1;
      switch (fromSeedData['rarity']) {
        case 'common':
          exchangeRate = 3; // 일반 등급: 3:1
          break;
        case 'uncommon':
          exchangeRate = 2; // 희귀 등급: 2:1
          break;
        case 'rare':
          exchangeRate = 1; // 매우 희귀 등급: 1:1
          break;
        case 'legendary':
          exchangeRate = 1; // 전설 등급: 1:1
          break;
      }
      
      final exchangeQuantity = (fromQuantity / exchangeRate).floor();
      if (exchangeQuantity <= 0) return false;
      
      // 씨앗 교환 실행
      await removeSeedsFromInventory(userId, fromSeedId, fromQuantity);
      await addSeedToInventoryForUser(userId, toSeedId, exchangeQuantity);
      
      return true;
    } catch (e) {
      print('Error exchanging seeds: $e');
      return false;
    }
  }

  // 일일 씨앗 보상 지급 (매일 로그인 시)
  Future<void> giveDailySeedReward(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRewardKey = 'last_daily_reward_$userId';
      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      
      final lastRewardDate = prefs.getString(lastRewardKey);
      
      // 오늘 이미 보상을 받았는지 확인
      if (lastRewardDate == today) return;
      
      // 연속 로그인 일수 확인
      final consecutiveDays = await getConsecutiveLoginDays(userId);
      
      // 연속 로그인에 따른 보상 지급
      if (consecutiveDays >= 7) {
        // 7일 연속: 희귀 등급 씨앗 1개
        final uncommonSeeds = PlantDatabase.getPlantsByRarity('uncommon');
        if (uncommonSeeds.isNotEmpty) {
          final randomSeed = uncommonSeeds[Random().nextInt(uncommonSeeds.length)];
          await addSeedToInventoryForUser(userId, randomSeed, 1);
        }
      } else if (consecutiveDays >= 3) {
        // 3일 연속: 일반 등급 씨앗 2개
        final commonSeeds = PlantDatabase.getPlantsByRarity('common');
        if (commonSeeds.isNotEmpty) {
          final randomSeed = commonSeeds[Random().nextInt(commonSeeds.length)];
          await addSeedToInventoryForUser(userId, randomSeed, 2);
        }
      } else {
        // 기본: 일반 등급 씨앗 1개
        final commonSeeds = PlantDatabase.getPlantsByRarity('common');
        if (commonSeeds.isNotEmpty) {
          final randomSeed = commonSeeds[Random().nextInt(commonSeeds.length)];
          await addSeedToInventoryForUser(userId, randomSeed, 1);
        }
      }
      
      // 보상 지급 기록 업데이트
      await prefs.setString(lastRewardKey, today);
      
    } catch (e) {
      print('Error giving daily seed reward: $e');
    }
  }

  // 연속 로그인 일수 조회
  Future<int> getConsecutiveLoginDays(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginRecordKey = 'login_record_$userId';
      
      final loginRecord = prefs.getString(loginRecordKey);
      if (loginRecord == null) return 1;
      
      final loginDates = List<String>.from(jsonDecode(loginRecord));
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // 오늘 로그인 기록 추가
      if (!loginDates.contains(today)) {
        loginDates.add(today);
        await prefs.setString(loginRecordKey, jsonEncode(loginDates));
      }
      
      // 연속 일수 계산
      int consecutiveDays = 1;
      final todayDate = DateTime.parse(today);
      
      for (int i = loginDates.length - 2; i >= 0; i--) {
        final loginDate = DateTime.parse(loginDates[i]);
        final daysDiff = todayDate.difference(loginDate).inDays;
        
        if (daysDiff == consecutiveDays) {
          consecutiveDays++;
        } else {
          break;
        }
      }
      
      return consecutiveDays;
    } catch (e) {
      print('Error getting consecutive login days: $e');
      return 1;
    }
  }
}
