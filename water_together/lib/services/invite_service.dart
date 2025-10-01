import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory.dart';
import '../services/plant_growth_service.dart';

class InviteService {
  static const String _inviteRewardsKey = 'invite_rewards';
  static const String _inviteLinksKey = 'invite_links';

  final PlantGrowthService _plantGrowthService = PlantGrowthService();

  // 초대 링크 생성
  Future<String> generateInviteLink(String userId) async {
    try {
      final inviteCode = _generateInviteCode();
      final inviteLink = 'watertogether://friend/invite/$inviteCode';
      
      // 초대 링크 정보 저장
      final inviteData = {
        'inviteCode': inviteCode,
        'inviterId': userId,
        'createdAt': DateTime.now().toIso8601String(),
        'isUsed': false,
        'usedAt': null,
      };

      final prefs = await SharedPreferences.getInstance();
      final existingLinks = prefs.getStringList(_inviteLinksKey) ?? [];
      existingLinks.add(jsonEncode(inviteData));
      await prefs.setStringList(_inviteLinksKey, existingLinks);

      return inviteLink;
    } catch (e) {
      print('Error generating invite link: $e');
      return '';
    }
  }

  // 초대 링크 처리 (신규 유저 가입 시)
  Future<bool> processInviteLink(String inviteCode, String newUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inviteLinks = prefs.getStringList(_inviteLinksKey) ?? [];
      
      for (int i = 0; i < inviteLinks.length; i++) {
        final inviteData = jsonDecode(inviteLinks[i]) as Map<String, dynamic>;
        
        if (inviteData['inviteCode'] == inviteCode && 
            inviteData['isUsed'] == false) {
          
          // 초대 링크 사용 처리
          inviteData['isUsed'] = true;
          inviteData['usedAt'] = DateTime.now().toIso8601String();
          inviteData['newUserId'] = newUserId;
          inviteLinks[i] = jsonEncode(inviteData);
          
          await prefs.setStringList(_inviteLinksKey, inviteLinks);
          
          // 초대자에게 보상 지급
          final inviterId = inviteData['inviterId'] as String;
          await _giveInviteReward(inviterId);
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error processing invite link: $e');
      return false;
    }
  }

  // 초대자 보상 지급
  Future<void> _giveInviteReward(String inviterId) async {
    try {
      // 랜덤 씨앗 선택
      final randomSeed = _getRandomRewardSeed();
      
      // 인벤토리에 씨앗 추가
      await _plantGrowthService.addSeedToInventoryForUser(inviterId, randomSeed, 1);
      
      // 보상 기록 저장
      await _recordInviteReward(inviterId, randomSeed);
      
    } catch (e) {
      print('Error giving invite reward: $e');
    }
  }

  // 랜덤 보상 씨앗 선택
  String _getRandomRewardSeed() {
    final rewardSeeds = [
      'rose_seed',      // 장미 씨앗
      'sunflower_seed', // 해바라기 씨앗
      'cherry_seed',    // 벚꽃 씨앗
      'lavender_seed',  // 라벤더 씨앗
      'tulip_seed',     // 튤립 씨앗
    ];
    
    final random = Random();
    return rewardSeeds[random.nextInt(rewardSeeds.length)];
  }

  // 초대 보상 기록 저장
  Future<void> _recordInviteReward(String inviterId, String seedId) async {
    try {
      final rewardData = {
        'inviterId': inviterId,
        'seedId': seedId,
        'rewardedAt': DateTime.now().toIso8601String(),
        'type': 'invite_reward',
      };

      final prefs = await SharedPreferences.getInstance();
      final existingRewards = prefs.getStringList('${_inviteRewardsKey}_$inviterId') ?? [];
      existingRewards.add(jsonEncode(rewardData));
      await prefs.setStringList('${_inviteRewardsKey}_$inviterId', existingRewards);
      
    } catch (e) {
      print('Error recording invite reward: $e');
    }
  }

  // 초대 코드 생성
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  // 초대 링크 유효성 검증
  Future<bool> validateInviteLink(String inviteCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inviteLinks = prefs.getStringList(_inviteLinksKey) ?? [];
      
      for (final linkJson in inviteLinks) {
        final inviteData = jsonDecode(linkJson) as Map<String, dynamic>;
        
        if (inviteData['inviteCode'] == inviteCode && 
            inviteData['isUsed'] == false) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error validating invite link: $e');
      return false;
    }
  }

  // 사용자의 초대 통계 조회
  Future<InviteStats> getInviteStats(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inviteLinks = prefs.getStringList(_inviteLinksKey) ?? [];
      final rewards = prefs.getStringList('${_inviteRewardsKey}_$userId') ?? [];
      
      int totalInvites = 0;
      int successfulInvites = 0;
      int totalRewards = 0;
      
      // 초대 링크 통계
      for (final linkJson in inviteLinks) {
        final inviteData = jsonDecode(linkJson) as Map<String, dynamic>;
        
        if (inviteData['inviterId'] == userId) {
          totalInvites++;
          if (inviteData['isUsed'] == true) {
            successfulInvites++;
          }
        }
      }
      
      // 보상 통계
      totalRewards = rewards.length;
      
      return InviteStats(
        totalInvites: totalInvites,
        successfulInvites: successfulInvites,
        totalRewards: totalRewards,
        successRate: totalInvites > 0 ? (successfulInvites / totalInvites) : 0.0,
      );
      
    } catch (e) {
      print('Error getting invite stats: $e');
      return InviteStats(
        totalInvites: 0,
        successfulInvites: 0,
        totalRewards: 0,
        successRate: 0.0,
      );
    }
  }

  // 초대 링크 공유 텍스트 생성
  String generateShareText(String inviteLink) {
    return '''
💧 물먹자 투게더에 초대합니다! 💧

함께 물 마시기 습관을 만들어보세요!
식물을 키우고 친구들과 경쟁하며 건강한 습관을 만들어가요.

초대 링크: $inviteLink

#물먹자투게더 #건강습관 #친구와함께
''';
  }

  // 초대 링크 만료 처리 (30일 후)
  Future<void> expireOldInviteLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inviteLinks = prefs.getStringList(_inviteLinksKey) ?? [];
      final now = DateTime.now();
      
      final validLinks = <String>[];
      
      for (final linkJson in inviteLinks) {
        final inviteData = jsonDecode(linkJson) as Map<String, dynamic>;
        final createdAt = DateTime.parse(inviteData['createdAt']);
        
        // 30일 이내의 링크만 유지
        if (now.difference(createdAt).inDays <= 30) {
          validLinks.add(linkJson);
        }
      }
      
      await prefs.setStringList(_inviteLinksKey, validLinks);
      
    } catch (e) {
      print('Error expiring old invite links: $e');
    }
  }
}

// 초대 통계 클래스
class InviteStats {
  final int totalInvites;
  final int successfulInvites;
  final int totalRewards;
  final double successRate;

  InviteStats({
    required this.totalInvites,
    required this.successfulInvites,
    required this.totalRewards,
    required this.successRate,
  });

  // 성공률을 퍼센트로 반환
  int get successRatePercentage => (successRate * 100).round();
}
