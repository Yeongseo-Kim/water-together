import 'package:json_annotation/json_annotation.dart';

part 'water_log.g.dart';

@JsonSerializable()
class WaterLog {
  final String logId;
  final String userId;
  final DateTime date;
  final int amount; // ml 단위
  final String type; // '한모금', '반컵', '한컵'

  WaterLog({
    required this.logId,
    required this.userId,
    required this.date,
    required this.amount,
    required this.type,
  });

  factory WaterLog.fromJson(Map<String, dynamic> json) => _$WaterLogFromJson(json);
  Map<String, dynamic> toJson() => _$WaterLogToJson(this);

  // 물 타입별 기본 섭취량 정의
  static const Map<String, int> waterTypeAmounts = {
    '한모금': 50,   // 50ml
    '반컵': 150,    // 150ml
    '한컵': 300,    // 300ml
  };

  // 물 타입으로부터 섭취량 계산
  static int getAmountFromType(String type) {
    return waterTypeAmounts[type] ?? 0;
  }

  // 날짜별 기록 집계를 위한 날짜 키 생성
  String getDateKey() {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 목표 달성 여부 확인 (목표량과 비교)
  bool isGoalAchieved(int dailyGoal) {
    return amount >= dailyGoal;
  }

  // 물 기록 복사 (수정용)
  WaterLog copyWith({
    String? logId,
    String? userId,
    DateTime? date,
    int? amount,
    String? type,
  }) {
    return WaterLog(
      logId: logId ?? this.logId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
    );
  }
}
