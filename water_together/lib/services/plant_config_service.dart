// lib/services/plant_config_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/plant_config.dart';

class PlantConfigService {
  static PlantConfigService? _instance;
  static PlantConfigService get instance => _instance ??= PlantConfigService._();
  PlantConfigService._();

  Map<String, PlantConfig> _plantConfigs = {};
  bool _isLoaded = false;

  // JSON 파일에서 식물 설정 로드
  Future<void> loadPlantConfigs() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/plant_configs.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _plantConfigs.clear();
      for (final entry in jsonData['plants'].entries) {
        _plantConfigs[entry.key] = PlantConfig.fromJson(entry.value);
      }
      
      _isLoaded = true;
      print('식물 설정 로드 완료: ${_plantConfigs.length}개 식물');
    } catch (e) {
      print('식물 설정 로드 실패: $e');
      _loadDefaultConfigs();
    }
  }

  // 기본 설정 로드 (에러 시)
  void _loadDefaultConfigs() {
    _plantConfigs = {
      '민들레': PlantConfig(
        plantId: '민들레',
        name: '민들레',
        category: 'flower',
        rarity: 'common',
        stageRequirements: [500, 1000, 2000],
        stageImages: ['🌱', '🌿', '🌸', '🍎'],
        personality: PlantPersonality(
          type: 'cheerful',
          greetings: ['안녕하세요! 저는 밝은 민들레예요! 🌼'],
          encouragements: ['함께 성장해요! 물을 마시면 저도 기분이 좋아져요!'],
          thanks: ['고마워요! 덕분에 더 밝게 자랄 수 있을 것 같아요!'],
          complaints: ['목이 말라요... 물 좀 주세요 💧'],
          stageComments: {
            '0': '작은 씨앗이에요!',
            '1': '줄기가 나왔어요!',
            '2': '예쁜 꽃이 피었어요!',
            '3': '완성된 민들레예요!'
          },
        ),
        stats: PlantStats(
          baseGrowthSpeed: 5,
          waterEfficiency: 5,
          rewardMultiplier: 1,
          specialAbilities: ['기본성장'],
          seasonalBonuses: {
            'spring': 0,
            'summer': 0,
            'autumn': 0,
            'winter': 0
          },
        ),
        description: '기본적인 식물입니다.',
      ),
    };
    _isLoaded = true;
  }

  // 식물 설정 가져오기
  PlantConfig? getPlantConfig(String plantId) {
    if (!_isLoaded) {
      print('경고: 식물 설정이 로드되지 않았습니다. loadPlantConfigs()를 먼저 호출하세요.');
      return null;
    }
    return _plantConfigs[plantId];
  }

  // 모든 식물 설정 가져오기
  Map<String, PlantConfig> getAllPlantConfigs() {
    if (!_isLoaded) {
      print('경고: 식물 설정이 로드되지 않았습니다. loadPlantConfigs()를 먼저 호출하세요.');
      return {};
    }
    return Map.unmodifiable(_plantConfigs);
  }

  // 카테고리별 식물 필터링
  List<PlantConfig> getPlantsByCategory(String category) {
    if (!_isLoaded) return [];
    
    return _plantConfigs.values
        .where((config) => config.category == category)
        .toList();
  }

  // 희귀도별 식물 필터링
  List<PlantConfig> getPlantsByRarity(String rarity) {
    if (!_isLoaded) return [];
    
    return _plantConfigs.values
        .where((config) => config.rarity == rarity)
        .toList();
  }

  // 식물 이름으로 검색
  List<PlantConfig> searchPlants(String query) {
    if (!_isLoaded) return [];
    
    return _plantConfigs.values
        .where((config) => config.name.contains(query))
        .toList();
  }

  // 로드 상태 확인
  bool get isLoaded => _isLoaded;

  // 설정 개수 확인
  int get configCount => _plantConfigs.length;
}
