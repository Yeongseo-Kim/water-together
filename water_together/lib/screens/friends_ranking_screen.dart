import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../models/friend.dart';
import '../services/friend_service.dart';
import '../services/ranking_service.dart';
import '../services/invite_service.dart';
import '../widgets/friend_add_dialog.dart';
import '../widgets/friend_list_item.dart';
import '../widgets/ranking_list_item.dart';
import '../widgets/ranking_header.dart';

class FriendsRankingScreen extends StatefulWidget {
  const FriendsRankingScreen({super.key});

  @override
  State<FriendsRankingScreen> createState() => _FriendsRankingScreenState();
}

class _FriendsRankingScreenState extends State<FriendsRankingScreen> {
  final FriendService _friendService = FriendService();
  final RankingService _rankingService = RankingService();
  final InviteService _inviteService = InviteService();
  
  List<RankingItem> _rankingItems = [];
  List<Friend> _friends = [];
  bool _isLoading = false;
  String _selectedPeriod = 'daily'; // daily, weekly, monthly

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final waterProvider = context.read<WaterProvider>();
      final userId = waterProvider.currentUser?.userId ?? 'user_001';
      
      // 친구 목록 로드
      _friends = await _friendService.getFriends(userId);
      
      // 랭킹 데이터 로드
      await _loadRankingData();
      
      setState(() {});
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRankingData() async {
    try {
      final waterProvider = context.read<WaterProvider>();
      final userId = waterProvider.currentUser?.userId ?? 'user_001';
      
      switch (_selectedPeriod) {
        case 'daily':
          _rankingItems = await _rankingService.getDailyRanking(userId);
          break;
        case 'weekly':
          _rankingItems = await _rankingService.getWeeklyRanking(userId);
          break;
        case 'monthly':
          final now = DateTime.now();
          _rankingItems = await _rankingService.getMonthlyRanking(userId, now);
          break;
      }
    } catch (e) {
      print('Error loading ranking data: $e');
      _rankingItems = [];
    }
  }

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
          IconButton(
            onPressed: () => _showInviteDialog(context),
            icon: const Icon(Icons.share),
            tooltip: '친구 초대',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 랭킹 헤더
                  RankingHeader(
                    title: _getRankingTitle(),
                    subtitle: _getRankingSubtitle(),
                    onRefresh: _loadData,
                    isRefreshing: _isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 기간 선택 탭
                  _buildPeriodSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // 랭킹 목록
                  if (_rankingItems.isEmpty)
                    _buildEmptyRanking()
                  else
                    ..._rankingItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final rankingItem = entry.value;
                      return RankingListItem(
                        rankingItem: rankingItem,
                        rank: index + 1,
                      );
                    }),
                  
                  const SizedBox(height: 24),
                  
                  // 친구 목록
                  Text(
                    '친구 목록',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_friends.isEmpty)
                    _buildEmptyFriends()
                  else
                    ..._friends.map((friend) => _buildFriendItemSync(friend)),
                ],
              ),
            ),
    );
  }


  String _getRankingTitle() {
    switch (_selectedPeriod) {
      case 'daily':
        return '일간 랭킹';
      case 'weekly':
        return '주간 랭킹';
      case 'monthly':
        return '월간 랭킹';
      default:
        return '랭킹';
    }
  }

  String _getRankingSubtitle() {
    switch (_selectedPeriod) {
      case 'daily':
        return '오늘의 물 섭취량을 기준으로 정렬됩니다';
      case 'weekly':
        return '이번 주 물 섭취량을 기준으로 정렬됩니다';
      case 'monthly':
        return '이번 달 물 섭취량을 기준으로 정렬됩니다';
      default:
        return '물 섭취량을 기준으로 정렬됩니다';
    }
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildPeriodTab('daily', '일간'),
          _buildPeriodTab('weekly', '주간'),
          _buildPeriodTab('monthly', '월간'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            _selectedPeriod = period;
          });
          await _loadRankingData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRanking() {
    return Container(
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
          const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '랭킹 데이터가 없어요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '친구를 추가하고 함께 경쟁해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFriends() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddFriendDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('친구 추가하기'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showInviteDialog(context),
                icon: const Icon(Icons.share),
                label: const Text('친구 초대하기'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItemSync(Friend friend) {
    return FutureBuilder<int>(
      future: _friendService.getFriendTodayIntake(friend.friendId),
      builder: (context, intakeSnapshot) {
        return FutureBuilder<double>(
          future: _friendService.getFriendAchievementRate(friend.friendId),
          builder: (context, rateSnapshot) {
            return FriendListItem(
              friend: friend,
              todayIntake: intakeSnapshot.data ?? 0,
              achievementRate: rateSnapshot.data ?? 0.0,
              onAccept: () async {
                final success = await _friendService.acceptFriendRequest(
                  context.read<WaterProvider>().currentUser?.userId ?? 'user_001',
                  friend.friendId,
                );
                if (success) {
                  await _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('친구 요청을 수락했습니다')),
                    );
                  }
                }
              },
              onReject: () async {
                final success = await _friendService.rejectFriendRequest(
                  context.read<WaterProvider>().currentUser?.userId ?? 'user_001',
                  friend.friendId,
                );
                if (success) {
                  await _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('친구 요청을 거절했습니다')),
                    );
                  }
                }
              },
              onRemove: () async {
                final success = await _friendService.removeFriend(
                  context.read<WaterProvider>().currentUser?.userId ?? 'user_001',
                  friend.friendId,
                );
                if (success) {
                  await _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('친구를 삭제했습니다')),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FriendAddDialog(
        onAddFriend: (friendId) async {
          final success = await _friendService.sendFriendRequest(
            context.read<WaterProvider>().currentUser?.userId ?? 'user_001',
            friendId,
          );
          
          if (success) {
            await _loadData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('친구 추가 요청을 보냈습니다')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('친구 추가에 실패했습니다')),
            );
          }
        },
      ),
    );
  }

  void _showInviteDialog(BuildContext context) async {
    try {
      final userId = context.read<WaterProvider>().currentUser?.userId ?? 'user_001';
      final inviteLink = await _inviteService.generateInviteLink(userId);
      final shareText = _inviteService.generateShareText(inviteLink);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('친구 초대'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('친구에게 초대 링크를 공유하세요!'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  inviteLink,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
            ElevatedButton(
              onPressed: () {
                // 실제로는 share_plus 패키지를 사용하여 공유
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('초대 링크가 클립보드에 복사되었습니다')),
                );
              },
              child: const Text('공유하기'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 링크 생성에 실패했습니다')),
      );
    }
  }
}
