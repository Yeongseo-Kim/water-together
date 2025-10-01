import 'package:flutter/material.dart';
import '../services/ranking_service.dart';

class RankingListItem extends StatelessWidget {
  final RankingItem rankingItem;
  final int rank;

  const RankingListItem({
    super.key,
    required this.rankingItem,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: rankingItem.isCurrentUser 
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: rankingItem.isCurrentUser 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: rankingItem.isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 순위 표시
          _buildRankBadge(context),
          const SizedBox(width: 12),
          
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rankingItem.nickname,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: rankingItem.isCurrentUser 
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    if (rankingItem.isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '나',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '섭취량: ${_formatIntake(rankingItem.todayIntake)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getAchievementColor(rankingItem.achievementRate),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${rankingItem.achievementPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (rankingItem.consecutiveDays > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${rankingItem.consecutiveDays}일 연속',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // 목표 달성 아이콘
          if (rankingItem.isGoalAchieved)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context) {
    Color badgeColor;
    IconData? icon;
    
    if (rank == 1) {
      badgeColor = Colors.amber;
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      badgeColor = Colors.grey[400]!;
      icon = Icons.emoji_events;
    } else if (rank == 3) {
      badgeColor = Colors.orange[300]!;
      icon = Icons.emoji_events;
    } else {
      badgeColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 20)
            : Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  String _formatIntake(int intake) {
    if (intake >= 1000) {
      return '${(intake / 1000).toStringAsFixed(1)}L';
    } else {
      return '${intake}ml';
    }
  }

  Color _getAchievementColor(double rate) {
    if (rate >= 1.0) return Colors.green;
    if (rate >= 0.7) return Colors.orange;
    if (rate >= 0.3) return Colors.yellow[700]!;
    return Colors.red;
  }
}
