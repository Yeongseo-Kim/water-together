/// 식물 데이터베이스
/// 모든 식물 종류와 성장 조건을 관리하는 중앙 데이터베이스
class PlantDatabase {
  // 식물 데이터베이스 (확장된 버전)
  static const Map<String, Map<String, dynamic>> plantDatabase = {
    // 일반 등급 식물들
    'seed_001': {
      'name': '기본 씨앗',
      'description': '물을 마시면 자라는 기본 식물입니다.',
      'stages': ['🌱', '🌿', '🌸', '🌰'],
      'growthRequirements': [500, 1000, 2000], // 각 단계별 필요 물량 (ml)
      'rarity': 'common',
      'rarityWeight': 40, // 가중치 (높을수록 희귀)
      'category': 'flower',
      'season': 'spring',
    },
    'seed_002': {
      'name': '튤립 씨앗',
      'description': '봄을 알리는 아름다운 튤립입니다.',
      'stages': ['🌱', '🌿', '🌷', '🌷'],
      'growthRequirements': [400, 800, 1800],
      'rarity': 'common',
      'rarityWeight': 35,
      'category': 'flower',
      'season': 'spring',
    },
    'seed_003': {
      'name': '민들레 씨앗',
      'description': '바람에 날리는 민들레 씨앗입니다.',
      'stages': ['🌱', '🌿', '🌼', '🌼'],
      'growthRequirements': [300, 600, 1500],
      'rarity': 'common',
      'rarityWeight': 30,
      'category': 'flower',
      'season': 'spring',
    },
    'seed_004': {
      'name': '해바라기 씨앗',
      'description': '태양을 향해 자라는 큰 해바라기입니다.',
      'stages': ['🌱', '🌿', '🌻', '🌻'],
      'growthRequirements': [800, 1500, 3000],
      'rarity': 'common',
      'rarityWeight': 25,
      'category': 'flower',
      'season': 'summer',
    },
    'seed_005': {
      'name': '코스모스 씨앗',
      'description': '가을을 대표하는 코스모스 씨앗입니다.',
      'stages': ['🌱', '🌿', '🌸', '🌸'],
      'growthRequirements': [350, 700, 1600],
      'rarity': 'common',
      'rarityWeight': 30,
      'category': 'flower',
      'season': 'autumn',
    },

    // 희귀 등급 식물들
    'seed_006': {
      'name': '장미 씨앗',
      'description': '사랑의 상징인 아름다운 장미입니다.',
      'stages': ['🌱', '🌿', '🌹', '🌹'],
      'growthRequirements': [600, 1200, 2500],
      'rarity': 'uncommon',
      'rarityWeight': 15,
      'category': 'flower',
      'season': 'spring',
    },
    'seed_007': {
      'name': '선인장 씨앗',
      'description': '건조한 환경에서도 잘 자라는 선인장입니다.',
      'stages': ['🌱', '🌵', '🌵', '🌵'],
      'growthRequirements': [300, 600, 1200],
      'rarity': 'uncommon',
      'rarityWeight': 20,
      'category': 'succulent',
      'season': 'summer',
    },
    'seed_008': {
      'name': '라벤더 씨앗',
      'description': '향기로운 라벤더 씨앗입니다.',
      'stages': ['🌱', '🌿', '💜', '💜'],
      'growthRequirements': [450, 900, 2000],
      'rarity': 'uncommon',
      'rarityWeight': 18,
      'category': 'herb',
      'season': 'spring',
    },
    'seed_009': {
      'name': '벚꽃 씨앗',
      'description': '봄의 아름다운 벚꽃 씨앗입니다.',
      'stages': ['🌱', '🌿', '🌸', '🌸'],
      'growthRequirements': [700, 1400, 2800],
      'rarity': 'uncommon',
      'rarityWeight': 12,
      'category': 'tree',
      'season': 'spring',
    },
    'seed_010': {
      'name': '단풍 씨앗',
      'description': '가을의 아름다운 단풍나무 씨앗입니다.',
      'stages': ['🌱', '🌿', '🍁', '🍁'],
      'growthRequirements': [1000, 2000, 4000],
      'rarity': 'uncommon',
      'rarityWeight': 10,
      'category': 'tree',
      'season': 'autumn',
    },

    // 매우 희귀 등급 식물들
    'seed_011': {
      'name': '금강초롱 씨앗',
      'description': '매우 희귀한 금강초롱꽃 씨앗입니다.',
      'stages': ['🌱', '🌿', '🔔', '🔔'],
      'growthRequirements': [1200, 2400, 5000],
      'rarity': 'rare',
      'rarityWeight': 5,
      'category': 'flower',
      'season': 'summer',
    },
    'seed_012': {
      'name': '용설란 씨앗',
      'description': '100년에 한 번 피는 용설란 씨앗입니다.',
      'stages': ['🌱', '🌿', '🌵', '🌵'],
      'growthRequirements': [2000, 4000, 8000],
      'rarity': 'rare',
      'rarityWeight': 3,
      'category': 'succulent',
      'season': 'summer',
    },
    'seed_013': {
      'name': '연꽃 씨앗',
      'description': '연못에서 자라는 신성한 연꽃 씨앗입니다.',
      'stages': ['🌱', '🌿', '🪷', '🪷'],
      'growthRequirements': [1500, 3000, 6000],
      'rarity': 'rare',
      'rarityWeight': 4,
      'category': 'aquatic',
      'season': 'summer',
    },
    'seed_014': {
      'name': '동백 씨앗',
      'description': '겨울에도 피는 아름다운 동백 씨앗입니다.',
      'stages': ['🌱', '🌿', '🌺', '🌺'],
      'growthRequirements': [800, 1600, 3200],
      'rarity': 'rare',
      'rarityWeight': 6,
      'category': 'flower',
      'season': 'winter',
    },
    'seed_015': {
      'name': '매화 씨앗',
      'description': '추위를 이기고 피는 고귀한 매화 씨앗입니다.',
      'stages': ['🌱', '🌿', '🌸', '🌸'],
      'growthRequirements': [900, 1800, 3600],
      'rarity': 'rare',
      'rarityWeight': 5,
      'category': 'tree',
      'season': 'winter',
    },

    // 전설 등급 식물들
    'seed_016': {
      'name': '불사조 꽃 씨앗',
      'description': '전설 속에서만 존재한다는 불사조 꽃 씨앗입니다.',
      'stages': ['🌱', '🌿', '🔥', '🔥'],
      'growthRequirements': [3000, 6000, 12000],
      'rarity': 'legendary',
      'rarityWeight': 1,
      'category': 'mythical',
      'season': 'all',
    },
    'seed_017': {
      'name': '달빛 꽃 씨앗',
      'description': '달빛 아래에서만 자라는 신비로운 꽃 씨앗입니다.',
      'stages': ['🌱', '🌿', '🌙', '🌙'],
      'growthRequirements': [2500, 5000, 10000],
      'rarity': 'legendary',
      'rarityWeight': 1,
      'category': 'mythical',
      'season': 'all',
    },
    'seed_018': {
      'name': '무지개 나무 씨앗',
      'description': '모든 색깔을 가진 신비로운 나무 씨앗입니다.',
      'stages': ['🌱', '🌿', '🌈', '🌈'],
      'growthRequirements': [4000, 8000, 16000],
      'rarity': 'legendary',
      'rarityWeight': 1,
      'category': 'mythical',
      'season': 'all',
    },
  };

  // 희귀도별 가중치 합계
  static const Map<String, int> rarityWeights = {
    'common': 160,    // 40+35+30+25+30 = 160
    'uncommon': 75,   // 15+20+18+12+10 = 75
    'rare': 23,       // 5+3+4+6+5 = 23
    'legendary': 3,   // 1+1+1 = 3
  };

  // 계절별 식물 필터링
  static List<String> getPlantsBySeason(String season) {
    return plantDatabase.entries
        .where((entry) => entry.value['season'] == season || entry.value['season'] == 'all')
        .map((entry) => entry.key)
        .toList();
  }

  // 카테고리별 식물 필터링
  static List<String> getPlantsByCategory(String category) {
    return plantDatabase.entries
        .where((entry) => entry.value['category'] == category)
        .map((entry) => entry.key)
        .toList();
  }

  // 희귀도별 식물 필터링
  static List<String> getPlantsByRarity(String rarity) {
    return plantDatabase.entries
        .where((entry) => entry.value['rarity'] == rarity)
        .map((entry) => entry.key)
        .toList();
  }

  // 특정 희귀도 이하의 식물들만 필터링 (일반~희귀 등급)
  static List<String> getPlantsUpToRarity(String maxRarity) {
    final rarityOrder = ['common', 'uncommon', 'rare', 'legendary'];
    final maxIndex = rarityOrder.indexOf(maxRarity);
    
    return plantDatabase.entries
        .where((entry) {
          final rarity = entry.value['rarity'] as String;
          final rarityIndex = rarityOrder.indexOf(rarity);
          return rarityIndex <= maxIndex;
        })
        .map((entry) => entry.key)
        .toList();
  }

  // 가중치 기반 랜덤 씨앗 선택
  static String getRandomSeedByRarity(String rarity) {
    final seedsOfRarity = getPlantsByRarity(rarity);
    if (seedsOfRarity.isEmpty) return 'seed_001'; // 기본값

    // 해당 희귀도의 모든 씨앗 중에서 가중치 기반 선택
    final weights = <String, int>{};
    int totalWeight = 0;

    for (final seedId in seedsOfRarity) {
      final weight = plantDatabase[seedId]!['rarityWeight'] as int;
      weights[seedId] = weight;
      totalWeight += weight;
    }

    // 랜덤 선택
    final random = DateTime.now().millisecondsSinceEpoch % totalWeight;
    int currentWeight = 0;

    for (final entry in weights.entries) {
      currentWeight += entry.value;
      if (random < currentWeight) {
        return entry.key;
      }
    }

    return seedsOfRarity.first; // 기본값
  }

  // 전체 가중치 기반 랜덤 씨앗 선택
  static String getRandomSeed() {
    final allSeeds = plantDatabase.keys.toList();
    final weights = <String, int>{};
    int totalWeight = 0;

    for (final seedId in allSeeds) {
      final weight = plantDatabase[seedId]!['rarityWeight'] as int;
      weights[seedId] = weight;
      totalWeight += weight;
    }

    // 랜덤 선택
    final random = DateTime.now().millisecondsSinceEpoch % totalWeight;
    int currentWeight = 0;

    for (final entry in weights.entries) {
      currentWeight += entry.value;
      if (random < currentWeight) {
        return entry.key;
      }
    }

    return 'seed_001'; // 기본값
  }

  // 식물 데이터 조회
  static Map<String, dynamic>? getPlantData(String seedId) {
    return plantDatabase[seedId];
  }

  // 모든 식물 데이터 조회
  static Map<String, Map<String, dynamic>> getAllPlantData() {
    return plantDatabase;
  }

  // 식물 이름으로 씨앗 ID 찾기
  static String? getSeedIdByName(String plantName) {
    for (final entry in plantDatabase.entries) {
      if (entry.value['name'] == plantName) {
        return entry.key;
      }
    }
    return null;
  }

  // 희귀도별 색상 반환
  static String getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return '#4CAF50'; // 녹색
      case 'uncommon':
        return '#2196F3'; // 파란색
      case 'rare':
        return '#9C27B0'; // 보라색
      case 'legendary':
        return '#FF9800'; // 주황색
      default:
        return '#757575'; // 회색
    }
  }

  // 희귀도별 한글명 반환
  static String getRarityName(String rarity) {
    switch (rarity) {
      case 'common':
        return '일반';
      case 'uncommon':
        return '희귀';
      case 'rare':
        return '매우 희귀';
      case 'legendary':
        return '전설';
      default:
        return '알 수 없음';
    }
  }

  // 계절별 한글명 반환
  static String getSeasonName(String season) {
    switch (season) {
      case 'spring':
        return '봄';
      case 'summer':
        return '여름';
      case 'autumn':
        return '가을';
      case 'winter':
        return '겨울';
      case 'all':
        return '사계절';
      default:
        return '알 수 없음';
    }
  }

  // 카테고리별 한글명 반환
  static String getCategoryName(String category) {
    switch (category) {
      case 'flower':
        return '꽃';
      case 'tree':
        return '나무';
      case 'succulent':
        return '다육식물';
      case 'herb':
        return '허브';
      case 'aquatic':
        return '수생식물';
      case 'mythical':
        return '신화';
      default:
        return '기타';
    }
  }

  // 식물 성장 난이도 계산 (총 필요 물량 기준)
  static String getDifficultyLevel(String seedId) {
    final plantData = plantDatabase[seedId];
    if (plantData == null) return '보통';

    final totalWater = plantData['growthRequirements'].last as int;
    
    if (totalWater <= 2000) return '쉬움';
    if (totalWater <= 4000) return '보통';
    if (totalWater <= 8000) return '어려움';
    return '매우 어려움';
  }

  // 식물 수집 가치 계산 (희귀도와 난이도 기반)
  static int getCollectionValue(String seedId) {
    final plantData = plantDatabase[seedId];
    if (plantData == null) return 1;

    final rarity = plantData['rarity'] as String;
    final totalWater = plantData['growthRequirements'].last as int;
    
    int baseValue = 1;
    switch (rarity) {
      case 'common':
        baseValue = 10;
        break;
      case 'uncommon':
        baseValue = 25;
        break;
      case 'rare':
        baseValue = 50;
        break;
      case 'legendary':
        baseValue = 100;
        break;
    }
    
    // 난이도 보너스
    if (totalWater > 5000) baseValue = (baseValue * 1.5).round();
    if (totalWater > 10000) baseValue = (baseValue * 2).round();
    
    return baseValue;
  }
}
