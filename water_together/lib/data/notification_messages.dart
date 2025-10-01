/// 알림 메시지 데이터베이스
/// 물먹자 투게더 앱에서 사용할 다양한 알림 메시지들을 정의합니다.
class NotificationMessages {
  // 물 마시기 알림 메시지
  static const List<String> waterReminders = [
    "💧 물 마실 시간이에요! 건강한 하루를 위해 물을 마셔보세요.",
    "🌱 식물이 목말라하고 있어요! 물을 주어주세요.",
    "⏰ 잠깐! 물 마시고 계속하세요.",
    "🎯 목표까지 조금만 더! 물을 마셔보세요.",
    "💦 하루 물 섭취량을 채워보세요!",
    "🌿 식물이 물을 기다리고 있어요.",
    "⏳ 물 마시는 시간이에요!",
    "🎪 물 마시고 새로운 씨앗을 얻어보세요!",
    "💧 건강한 습관을 위해 물을 마셔보세요.",
    "🌱 식물이 성장할 수 있도록 물을 주세요.",
  ];

  // 목표 달성 축하 메시지
  static const List<String> goalAchievementMessages = [
    "🎉 축하해요! 오늘 목표를 달성했어요!",
    "🌟 대단해요! 물 섭취 목표를 완성했어요!",
    "🎊 훌륭해요! 식물이 기뻐하고 있어요!",
    "🏆 목표 달성! 새로운 씨앗을 획득했어요!",
    "✨ 멋져요! 꾸준한 노력의 결과예요!",
    "🎈 축하합니다! 건강한 습관을 만들어가고 있어요!",
    "🎁 목표 달성! 특별한 보상이 기다려요!",
    "🌟 훌륭한 성취예요! 계속 이어가세요!",
  ];

  // 친구 활동 알림 메시지
  static const List<String> friendActivityMessages = [
    "👥 친구가 오늘 목표를 달성했어요!",
    "🌱 친구의 식물이 성장했어요!",
    "🏆 친구가 새로운 챌린지를 완료했어요!",
    "💧 친구가 물을 마셨어요!",
    "🎯 친구가 목표에 가까워지고 있어요!",
    "🌟 친구가 새로운 씨앗을 얻었어요!",
  ];

  // 격려 메시지
  static const List<String> encouragementMessages = [
    "💪 조금씩 꾸준히! 오늘도 화이팅!",
    "🌱 작은 습관이 큰 변화를 만들어요!",
    "💧 건강한 몸을 위해 오늘도 물을 마셔보세요!",
    "🌟 당신의 노력이 식물을 키우고 있어요!",
    "🎯 목표까지 조금만 더! 할 수 있어요!",
    "💦 물 마시는 습관이 건강한 삶의 시작이에요!",
    "🌿 식물과 함께 성장해보세요!",
    "⏰ 작은 시간이 모여 큰 성취가 돼요!",
  ];

  // 챌린지 관련 메시지
  static const List<String> challengeMessages = [
    "🎪 새로운 챌린지가 시작되었어요!",
    "🏆 챌린지 완료! 특별한 보상을 받았어요!",
    "⏳ 챌린지 마감까지 얼마 남지 않았어요!",
    "🎯 챌린지 목표에 가까워지고 있어요!",
    "🌟 챌린지 성공! 새로운 도전을 시작해보세요!",
  ];

  // 랜덤 메시지 선택
  static String getRandomWaterReminder() {
    final random = DateTime.now().millisecondsSinceEpoch % waterReminders.length;
    return waterReminders[random];
  }

  static String getRandomGoalAchievement() {
    final random = DateTime.now().millisecondsSinceEpoch % goalAchievementMessages.length;
    return goalAchievementMessages[random];
  }

  static String getRandomFriendActivity() {
    final random = DateTime.now().millisecondsSinceEpoch % friendActivityMessages.length;
    return friendActivityMessages[random];
  }

  static String getRandomEncouragement() {
    final random = DateTime.now().millisecondsSinceEpoch % encouragementMessages.length;
    return encouragementMessages[random];
  }

  static String getRandomChallenge() {
    final random = DateTime.now().millisecondsSinceEpoch % challengeMessages.length;
    return challengeMessages[random];
  }

  // 시간대별 맞춤 메시지
  static String getTimeBasedMessage() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 9) {
      return "🌅 좋은 아침이에요! 하루를 시작하며 물을 마셔보세요.";
    } else if (hour >= 9 && hour < 12) {
      return "☀️ 오전 시간! 물을 마시고 활기찬 하루를 보내세요.";
    } else if (hour >= 12 && hour < 14) {
      return "🍽️ 점심 시간! 식사 전후로 물을 마셔보세요.";
    } else if (hour >= 14 && hour < 18) {
      return "🌤️ 오후 시간! 물을 마시고 집중력을 유지해보세요.";
    } else if (hour >= 18 && hour < 21) {
      return "🌆 저녁 시간! 하루 마무리하며 물을 마셔보세요.";
    } else {
      return "🌙 밤 시간! 잠들기 전 물을 마시고 건강한 수면을 취하세요.";
    }
  }

  // 목표 달성률에 따른 메시지
  static String getProgressBasedMessage(double progress) {
    if (progress >= 1.0) {
      return getRandomGoalAchievement();
    } else if (progress >= 0.8) {
      return "🎯 목표까지 조금만 더! 거의 다 왔어요!";
    } else if (progress >= 0.5) {
      return "💧 절반 이상 달성! 계속 이어가세요!";
    } else if (progress >= 0.2) {
      return "🌱 시작이 반이에요! 꾸준히 물을 마셔보세요!";
    } else {
      return "💦 오늘도 물 마시는 습관을 시작해보세요!";
    }
  }
}
