import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../models/user.dart';

class FriendAddDialog extends StatefulWidget {
  final Function(String friendId) onAddFriend;

  const FriendAddDialog({
    super.key,
    required this.onAddFriend,
  });

  @override
  State<FriendAddDialog> createState() => _FriendAddDialogState();
}

class _FriendAddDialogState extends State<FriendAddDialog> {
  final TextEditingController _friendIdController = TextEditingController();
  bool _isLoading = false;
  List<User> _searchResults = [];
  String _searchQuery = '';

  @override
  void dispose() {
    _friendIdController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      // 실제로는 FriendService를 통해 검색
      // 임시로 데모 데이터 사용
      await Future.delayed(const Duration(milliseconds: 500));
      
      final demoResults = [
        User(
          userId: 'demo_user_1',
          nickname: '물마시는친구1',
          password: 'password',
          dailyWaterGoal: 1000,
          createdAt: DateTime.now(),
        ),
        User(
          userId: 'demo_user_2',
          nickname: '물마시는친구2',
          password: 'password',
          dailyWaterGoal: 1200,
          createdAt: DateTime.now(),
        ),
      ];

      setState(() {
        _searchResults = demoResults.where((user) => 
          user.userId.toLowerCase().contains(query.toLowerCase()) ||
          user.nickname.toLowerCase().contains(query.toLowerCase())
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('친구 추가'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '친구의 아이디나 닉네임을 입력하세요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _friendIdController,
              decoration: InputDecoration(
                labelText: '친구 아이디 또는 닉네임',
                hintText: '예: water_friend123',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _friendIdController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _friendIdController.clear();
                          _searchUsers('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchUsers,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_searchResults.isNotEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.nickname.isNotEmpty ? user.nickname[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.nickname),
                      subtitle: Text('ID: ${user.userId}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          widget.onAddFriend(user.userId);
                          Navigator.of(context).pop();
                        },
                        child: const Text('추가'),
                      ),
                    );
                  },
                ),
              )
            else if (_searchQuery.isNotEmpty && !_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '검색 결과가 없습니다',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        if (_friendIdController.text.isNotEmpty && _searchResults.isEmpty)
          ElevatedButton(
            onPressed: () {
              widget.onAddFriend(_friendIdController.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('직접 추가'),
          ),
      ],
    );
  }
}
