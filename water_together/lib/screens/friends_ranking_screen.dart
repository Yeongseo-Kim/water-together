import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../models/friend.dart';

class FriendsRankingScreen extends StatelessWidget {
  const FriendsRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구·랭킹'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => _showAddFriendDialog(context),
            icon: const Icon(Icons.person_add),
            tooltip: '친구 추가',
          ),
        ],
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 일간 랭킹
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '일간 랭킹',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (waterProvider.friends.isEmpty)
                        const Text(
                          '아직 친구가 없어요.\n친구를 추가해보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...waterProvider.friends.asMap().entries.map((entry) {
                          final index = entry.key;
                          final friend = entry.value;
                          return _buildRankingItem(context, index + 1, friend);
                        }),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 친구 목록
                Text(
                  '친구 목록',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                if (waterProvider.friends.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          '아직 친구가 없어요',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '친구를 추가하고 함께 물 마시기를 시작해보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddFriendDialog(context),
                          icon: const Icon(Icons.person_add),
                          label: const Text('친구 추가하기'),
                        ),
                      ],
                    ),
                  )
                else
                  ...waterProvider.friends.map((friend) => _buildFriendItem(context, friend)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankingItem(BuildContext context, int rank, Friend friend) {
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
          // 순위
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.amber : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '오늘 섭취량: 0ml', // 실제로는 친구의 섭취량을 가져와야 함
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // 달성률
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '0%', // 실제로는 친구의 달성률을 계산해야 함
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(BuildContext context, Friend friend) {
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            friend.friendNickname.isNotEmpty ? friend.friendNickname[0] : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(friend.friendNickname),
        subtitle: Text('상태: ${friend.status}'),
        trailing: friend.isPending()
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<WaterProvider>().acceptFriend(friend.friendId);
                    },
                    child: const Text('수락'),
                  ),
                  TextButton(
                    onPressed: () {
                      // 거절 로직 구현
                    },
                    child: const Text('거절'),
                  ),
                ],
              )
            : const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController friendIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('친구 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('친구의 아이디를 입력하세요'),
              const SizedBox(height: 16),
              TextField(
                controller: friendIdController,
                decoration: const InputDecoration(
                  labelText: '친구 아이디',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final friendId = friendIdController.text.trim();
                if (friendId.isNotEmpty) {
                  // 친구 추가 로직
                  final newFriend = Friend(
                    userId: context.read<WaterProvider>().currentUser?.userId ?? 'user_001',
                    friendId: friendId,
                    friendNickname: friendId, // 실제로는 닉네임을 가져와야 함
                    status: Friend.statusPending,
                    addedAt: DateTime.now(),
                  );
                  
                  context.read<WaterProvider>().addFriend(newFriend);
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('친구 추가 요청을 보냈습니다')),
                  );
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }
}
