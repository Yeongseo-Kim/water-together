// 식물 메시지 데이터
class PlantMessage {
  final String message;
  final String category;
  final int priority;
  final List<String> conditions;

  const PlantMessage({
    required this.message,
    required this.category,
    this.priority = 1,
    this.conditions = const [],
  });
}

class PlantMessages {
  static const Map<String, List<PlantMessage>> messages = {
    'seed_001': [ // 기본 씨앗
      PlantMessage(
        message: '안녕하세요! 저는 아직 작은 씨앗이에요 🌱',
        category: 'greeting',
        priority: 1,
      ),
      PlantMessage(
        message: '함께 성장해요! 물을 마시면 저도 기분이 좋아져요!',
        category: 'encouragement',
        priority: 2,
      ),
      PlantMessage(
        message: '고마워요! 덕분에 조금 더 자랄 수 있을 것 같아요!',
        category: 'thanks',
        priority: 1,
      ),
      PlantMessage(
        message: '물을 마시니 저도 기분이 좋아져요!',
        category: 'happy',
        priority: 1,
      ),
      PlantMessage(
        message: '오늘도 함께 건강해져요!',
        category: 'motivation',
        priority: 2,
      ),
      PlantMessage(
        message: '목이 말라요... 물 좀 주세요 💧',
        category: 'thirsty',
        priority: 3,
        conditions: ['low_water'],
      ),
    ],
    'seed_002': [ // 튤립 씨앗
      PlantMessage(
        message: '봄이 오면 예쁘게 피어날게요! 🌷',
        category: 'greeting',
        priority: 1,
      ),
      PlantMessage(
        message: '감사합니다. 봄에 아름답게 피어날게요',
        category: 'thanks',
        priority: 1,
      ),
      PlantMessage(
        message: '당신의 건강을 위해 응원할게요',
        category: 'encouragement',
        priority: 2,
      ),
      PlantMessage(
        message: '우아하게 자라서 당신을 기쁘게 해드릴게요',
        category: 'promise',
        priority: 2,
      ),
      PlantMessage(
        message: '물을 마시면 저도 더 예쁘게 자라요',
        category: 'happy',
        priority: 1,
      ),
    ],
    'seed_003': [ // 민들레 씨앗
      PlantMessage(
        message: '바람에 날려가기 전에 함께 놀아요! 🌼',
        category: 'greeting',
        priority: 1,
      ),
      PlantMessage(
        message: '활발하게 자라서 노란 꽃을 피울게요!',
        category: 'encouragement',
        priority: 2,
      ),
      PlantMessage(
        message: '물을 마시면 저도 더 밝아져요!',
        category: 'happy',
        priority: 1,
      ),
      PlantMessage(
        message: '함께 춤추며 자라요!',
        category: 'playful',
        priority: 2,
      ),
    ],
    'seed_004': [ // 장미 씨앗
      PlantMessage(
        message: '사랑으로 키워주셔서 고마워요 🌹',
        category: 'greeting',
        priority: 1,
      ),
      PlantMessage(
        message: '당신의 마음처럼 아름답게 자랄게요',
        category: 'romantic',
        priority: 2,
      ),
      PlantMessage(
        message: '사랑의 꽃으로 피어나서 당신을 기쁘게 해드릴게요',
        category: 'promise',
        priority: 2,
      ),
      PlantMessage(
        message: '물을 마시면 저도 더 사랑스럽게 자라요',
        category: 'happy',
        priority: 1,
      ),
    ],
    'seed_005': [ // 해바라기 씨앗
      PlantMessage(
        message: '태양을 따라 도는 해바라기가 될게요! 🌻',
        category: 'greeting',
        priority: 1,
      ),
      PlantMessage(
        message: '큰 꽃으로 피어나서 당신을 응원할게요!',
        category: 'encouragement',
        priority: 2,
      ),
      PlantMessage(
        message: '물을 마시면 저도 더 밝게 자라요!',
        category: 'happy',
        priority: 1,
      ),
      PlantMessage(
        message: '태양처럼 밝은 마음으로 자라요!',
        category: 'motivation',
        priority: 2,
      ),
    ],
    'seed_006': [ // 선인장 씨앗
      PlantMessage(
        message: '저는 물을 적게 마셔도 돼요! 🌵',
        category: 'greeting',
        priority: 1,
      ),
      PlantMessage(
        message: '사막에서 온 친구니까요!',
        category: 'unique',
        priority: 2,
      ),
      PlantMessage(
        message: '물을 적게 마셔도 저는 괜찮아요!',
        category: 'understanding',
        priority: 1,
      ),
      PlantMessage(
        message: '저는 강인하게 자랄 수 있어요!',
        category: 'tough',
        priority: 2,
      ),
    ],
  };

  // 상황별 메시지 선택
  static String getMessage({
    required String plantId,
    required String category,
    Map<String, dynamic>? context,
  }) {
    final plantMessages = messages[plantId] ?? messages['seed_001']!;
    
    // 카테고리별 메시지 필터링
    var filteredMessages = plantMessages.where((msg) => msg.category == category).toList();
    
    // 조건이 있는 경우 필터링
    if (context != null) {
      filteredMessages = filteredMessages.where((msg) {
        for (String condition in msg.conditions) {
          if (!context.containsKey(condition) || !context[condition]) {
            return false;
          }
        }
        return true;
      }).toList();
    }
    
    // 메시지가 없으면 기본 메시지 반환
    if (filteredMessages.isEmpty) {
      return '안녕하세요! 함께 성장해요! 🌱';
    }
    
    // 우선순위별로 정렬하고 랜덤 선택
    filteredMessages.sort((a, b) => a.priority.compareTo(b.priority));
    final highPriorityMessages = filteredMessages.where((msg) => msg.priority == filteredMessages.first.priority).toList();
    
    return highPriorityMessages[DateTime.now().millisecondsSinceEpoch % highPriorityMessages.length].message;
  }

  // 시간대별 메시지
  static String getTimeBasedMessage(String plantId) {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      return getMessage(plantId: plantId, category: 'morning');
    } else if (hour >= 12 && hour < 18) {
      return getMessage(plantId: plantId, category: 'afternoon');
    } else if (hour >= 18 && hour < 22) {
      return getMessage(plantId: plantId, category: 'evening');
    } else {
      return getMessage(plantId: plantId, category: 'night');
    }
  }

  // 물 마신 후 메시지
  static String getWaterMessage(String plantId, int waterAmount) {
    if (waterAmount >= 200) {
      return getMessage(plantId: plantId, category: 'thanks');
    } else if (waterAmount >= 100) {
      return getMessage(plantId: plantId, category: 'happy');
    } else {
      return getMessage(plantId: plantId, category: 'encouragement');
    }
  }
}
