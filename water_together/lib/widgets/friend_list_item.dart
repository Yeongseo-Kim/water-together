import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendListItem extends StatelessWidget {
  final Friend friend;
  final int todayIntake;
  final double achievementRate;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onRemove;

  const FriendListItem({
    super.key,
    required this.friend,
    required this.todayIntake,
    required this.achievementRate,
    this.onAccept,
    this.onReject,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // 프로필 아바타
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            radius: 24,
            child: Text(
              friend.friendNickname.isNotEmpty ? friend.friendNickname[0] : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 친구 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.friendNickname,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '오늘 섭취량: ${_formatIntake(todayIntake)}',
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
                        color: _getAchievementColor(achievementRate),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(achievementRate * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 액션 버튼들
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (friend.isPending()) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onAccept,
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('수락', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: onReject,
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('거절', style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    } else if (friend.isAccepted()) {
      return PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'remove':
              onRemove?.call();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.person_remove, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text('친구 삭제', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        child: Container(
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
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.cancel,
          color: Colors.red,
          size: 20,
        ),
      );
    }
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

  String _getStatusText() {
    if (friend.isPending()) return '요청 대기중';
    if (friend.isAccepted()) return '친구';
    if (friend.isRejected()) return '거절됨';
    return '알 수 없음';
  }

  Color _getStatusColor() {
    if (friend.isPending()) return Colors.orange;
    if (friend.isAccepted()) return Colors.green;
    if (friend.isRejected()) return Colors.red;
    return Colors.grey;
  }
}
