import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/plant_database.dart';

/// 도감 서비스
/// 수집된 식물 목록을 관리하고 도감 완성도를 계산하는 서비스
class CollectionService {
  static const String _collectionKey = 'collected_plants';
  static const String _collectionDatesKey = 'collection_dates';

  /// 수집된 식물 목록을 가져옵니다
  static Future<List<String>> getCollectedPlants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final collectedJson = prefs.getString(_collectionKey);
      
      if (collectedJson == null) {
        return [];
      }
      
      final List<dynamic> collectedList = jsonDecode(collectedJson);
      return collectedList.cast<String>();
    } catch (e) {
      print('Error getting collected plants: $e');
      return [];
    }
  }

  /// 식물을 도감에 추가합니다
  static Future<bool> addToCollection(String seedId) async {
    try {
      final collectedPlants = await getCollectedPlants();
      
      // 이미 수집된 식물인지 확인
      if (collectedPlants.contains(seedId)) {
        return false;
      }
      
      // 새로운 식물 추가
      collectedPlants.add(seedId);
      
      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_collectionKey, jsonEncode(collectedPlants));
      
      // 수집 날짜 기록
      await _recordCollectionDate(seedId);
      
      return true;
    } catch (e) {
      print('Error adding to collection: $e');
      return false;
    }
  }

  /// 수집 날짜를 기록합니다
  static Future<void> _recordCollectionDate(String seedId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final datesJson = prefs.getString(_collectionDatesKey);
      
      Map<String, String> collectionDates = {};
      if (datesJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(datesJson);
        collectionDates = decoded.map((key, value) => MapEntry(key, value.toString()));
      }
      
      collectionDates[seedId] = DateTime.now().toIso8601String();
      await prefs.setString(_collectionDatesKey, jsonEncode(collectionDates));
    } catch (e) {
      print('Error recording collection date: $e');
    }
  }

  /// 식물의 수집 날짜를 가져옵니다
  static Future<DateTime?> getCollectionDate(String seedId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final datesJson = prefs.getString(_collectionDatesKey);
      
      if (datesJson == null) return null;
      
      final Map<String, dynamic> decoded = jsonDecode(datesJson);
      final dateString = decoded[seedId] as String?;
      
      if (dateString == null) return null;
      
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error getting collection date: $e');
      return null;
    }
  }

  /// 도감 완성도를 계산합니다 (백분율)
  static Future<double> getCollectionCompletionRate() async {
    try {
      final collectedPlants = await getCollectedPlants();
      final totalPlants = PlantDatabase.getAllPlantData().keys.length;
      
      if (totalPlants == 0) return 0.0;
      
      return (collectedPlants.length / totalPlants) * 100;
    } catch (e) {
      print('Error calculating completion rate: $e');
      return 0.0;
    }
  }

  /// 수집된 식물의 총 가치를 계산합니다
  static Future<int> getTotalCollectionValue() async {
    try {
      final collectedPlants = await getCollectedPlants();
      int totalValue = 0;
      
      for (final seedId in collectedPlants) {
        totalValue += PlantDatabase.getCollectionValue(seedId);
      }
      
      return totalValue;
    } catch (e) {
      print('Error calculating total value: $e');
      return 0;
    }
  }

  /// 희귀도별 수집 현황을 가져옵니다
  static Future<Map<String, int>> getCollectionByRarity() async {
    try {
      final collectedPlants = await getCollectedPlants();
      final Map<String, int> rarityCount = {
        'common': 0,
        'uncommon': 0,
        'rare': 0,
        'legendary': 0,
      };
      
      for (final seedId in collectedPlants) {
        final plantData = PlantDatabase.getPlantData(seedId);
        if (plantData != null) {
          final rarity = plantData['rarity'] as String;
          rarityCount[rarity] = (rarityCount[rarity] ?? 0) + 1;
        }
      }
      
      return rarityCount;
    } catch (e) {
      print('Error getting collection by rarity: $e');
      return {'common': 0, 'uncommon': 0, 'rare': 0, 'legendary': 0};
    }
  }

  /// 카테고리별 수집 현황을 가져옵니다
  static Future<Map<String, int>> getCollectionByCategory() async {
    try {
      final collectedPlants = await getCollectedPlants();
      final Map<String, int> categoryCount = {};
      
      for (final seedId in collectedPlants) {
        final plantData = PlantDatabase.getPlantData(seedId);
        if (plantData != null) {
          final category = plantData['category'] as String;
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
      }
      
      return categoryCount;
    } catch (e) {
      print('Error getting collection by category: $e');
      return {};
    }
  }

  /// 수집된 식물들을 희귀도별로 정렬하여 반환합니다
  static Future<List<Map<String, dynamic>>> getSortedCollectedPlants() async {
    try {
      final collectedPlants = await getCollectedPlants();
      final List<Map<String, dynamic>> sortedPlants = [];
      
      for (final seedId in collectedPlants) {
        final plantData = PlantDatabase.getPlantData(seedId);
        if (plantData != null) {
          final collectionDate = await getCollectionDate(seedId);
          sortedPlants.add({
            'seedId': seedId,
            'plantData': plantData,
            'collectionDate': collectionDate,
            'collectionValue': PlantDatabase.getCollectionValue(seedId),
          });
        }
      }
      
      // 희귀도별로 정렬 (전설 > 매우 희귀 > 희귀 > 일반)
      final rarityOrder = {'legendary': 4, 'rare': 3, 'uncommon': 2, 'common': 1};
      sortedPlants.sort((a, b) {
        final rarityA = a['plantData']['rarity'] as String;
        final rarityB = b['plantData']['rarity'] as String;
        final orderA = rarityOrder[rarityA] ?? 0;
        final orderB = rarityOrder[rarityB] ?? 0;
        
        if (orderA != orderB) {
          return orderB.compareTo(orderA); // 높은 등급이 먼저
        }
        
        // 같은 희귀도면 수집 가치로 정렬
        final valueA = a['collectionValue'] as int;
        final valueB = b['collectionValue'] as int;
        return valueB.compareTo(valueA);
      });
      
      return sortedPlants;
    } catch (e) {
      print('Error getting sorted collected plants: $e');
      return [];
    }
  }

  /// 특정 식물이 수집되었는지 확인합니다
  static Future<bool> isPlantCollected(String seedId) async {
    try {
      final collectedPlants = await getCollectedPlants();
      return collectedPlants.contains(seedId);
    } catch (e) {
      print('Error checking if plant is collected: $e');
      return false;
    }
  }

  /// 도감 통계 정보를 가져옵니다
  static Future<Map<String, dynamic>> getCollectionStats() async {
    try {
      final collectedPlants = await getCollectedPlants();
      final totalPlants = PlantDatabase.getAllPlantData().keys.length;
      final completionRate = await getCollectionCompletionRate();
      final totalValue = await getTotalCollectionValue();
      final rarityCount = await getCollectionByRarity();
      final categoryCount = await getCollectionByCategory();
      
      return {
        'collectedCount': collectedPlants.length,
        'totalCount': totalPlants,
        'completionRate': completionRate,
        'totalValue': totalValue,
        'rarityCount': rarityCount,
        'categoryCount': categoryCount,
      };
    } catch (e) {
      print('Error getting collection stats: $e');
      return {
        'collectedCount': 0,
        'totalCount': 0,
        'completionRate': 0.0,
        'totalValue': 0,
        'rarityCount': {'common': 0, 'uncommon': 0, 'rare': 0, 'legendary': 0},
        'categoryCount': {},
      };
    }
  }

  /// 도감을 초기화합니다 (개발/테스트용)
  static Future<void> clearCollection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_collectionKey);
      await prefs.remove(_collectionDatesKey);
    } catch (e) {
      print('Error clearing collection: $e');
    }
  }

  /// 데모용 수집된 식물을 추가합니다 (개발/테스트용)
  static Future<void> addDemoPlants() async {
    try {
      // 일반 등급 식물 몇 개 추가
      await addToCollection('seed_001'); // 기본 씨앗
      await addToCollection('seed_002'); // 튤립 씨앗
      await addToCollection('seed_003'); // 민들레 씨앗
      
      // 희귀 등급 식물 하나 추가
      await addToCollection('seed_006'); // 장미 씨앗
    } catch (e) {
      print('Error adding demo plants: $e');
    }
  }
}
