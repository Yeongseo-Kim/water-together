import 'dart:async';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import '../services/invite_service.dart';

class DeepLinkService {
  static const String _scheme = 'watertogether';
  
  final InviteService _inviteService = InviteService();
  
  StreamSubscription<String?>? _linkSubscription;
  
  // 딥링크 초기화
  Future<void> initialize() async {
    try {
      // 앱이 종료된 상태에서 딥링크로 실행된 경우
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(Uri.parse(initialLink));
      }
      
      // 앱이 실행 중일 때 딥링크 수신
      _linkSubscription = linkStream.listen(
        (String? link) {
          if (link != null) {
            _handleDeepLink(Uri.parse(link));
          }
        },
        onError: (err) {
          print('Deep link error: $err');
        },
      );
    } catch (e) {
      print('Error initializing deep links: $e');
    }
  }

  // 딥링크 처리
  void _handleDeepLink(Uri link) {
    try {
      print('Handling deep link: $link');
      
      if (link.scheme != _scheme) {
        print('Invalid scheme: ${link.scheme}');
        return;
      }
      
      final pathSegments = link.pathSegments;
      if (pathSegments.isEmpty) {
        print('Empty path segments');
        return;
      }
      
      final action = pathSegments[0];
      
      switch (action) {
        case 'friend':
          _handleFriendAction(pathSegments);
          break;
        case 'gift':
          _handleGiftAction(pathSegments);
          break;
        case 'plant':
          _handlePlantAction(pathSegments);
          break;
        default:
          print('Unknown action: $action');
      }
    } catch (e) {
      print('Error handling deep link: $e');
    }
  }

  // 친구 관련 액션 처리
  void _handleFriendAction(List<String> pathSegments) {
    if (pathSegments.length < 2) {
      print('Invalid friend action path');
      return;
    }
    
    final subAction = pathSegments[1];
    
    switch (subAction) {
      case 'invite':
        if (pathSegments.length >= 3) {
          final inviteCode = pathSegments[2];
          _handleInviteLink(inviteCode);
        }
        break;
      default:
        print('Unknown friend action: $subAction');
    }
  }

  // 선물 관련 액션 처리
  void _handleGiftAction(List<String> pathSegments) {
    if (pathSegments.length < 3) {
      print('Invalid gift action path');
      return;
    }
    
    final giftType = pathSegments[1];
    final giftId = pathSegments[2];
    
    switch (giftType) {
      case 'seed':
        _handleSeedGift(giftId);
        break;
      default:
        print('Unknown gift type: $giftType');
    }
  }

  // 식물 관련 액션 처리
  void _handlePlantAction(List<String> pathSegments) {
    if (pathSegments.length < 2) {
      print('Invalid plant action path');
      return;
    }
    
    final plantId = pathSegments[1];
    _handlePlantView(plantId);
  }

  // 초대 링크 처리
  Future<void> _handleInviteLink(String inviteCode) async {
    try {
      print('Processing invite link: $inviteCode');
      
      // 초대 링크 유효성 검증
      final isValid = await _inviteService.validateInviteLink(inviteCode);
      if (!isValid) {
        print('Invalid invite code: $inviteCode');
        return;
      }
      
      // 초대 링크 처리 (신규 유저 가입 시)
      // 실제로는 사용자 가입 플로우에서 호출되어야 함
      // final success = await _inviteService.processInviteLink(inviteCode, newUserId);
      
      print('Invite link processed successfully');
    } catch (e) {
      print('Error handling invite link: $e');
    }
  }

  // 씨앗 선물 처리
  void _handleSeedGift(String seedId) {
    try {
      print('Processing seed gift: $seedId');
      
      // 씨앗 선물 처리 로직
      // 실제로는 선물 수락 플로우에서 호출되어야 함
      
      print('Seed gift processed successfully');
    } catch (e) {
      print('Error handling seed gift: $e');
    }
  }

  // 식물 보기 처리
  void _handlePlantView(String plantId) {
    try {
      print('Processing plant view: $plantId');
      
      // 식물 상세 보기 화면으로 이동
      // 실제로는 네비게이션 로직에서 호출되어야 함
      
      print('Plant view processed successfully');
    } catch (e) {
      print('Error handling plant view: $e');
    }
  }

  // 딥링크 생성
  String createDeepLink(String action, List<String> parameters) {
    final pathSegments = [action, ...parameters];
    final path = pathSegments.join('/');
    return '$_scheme://$path';
  }

  // 친구 초대 딥링크 생성
  String createInviteLink(String inviteCode) {
    return createDeepLink('friend/invite', [inviteCode]);
  }

  // 씨앗 선물 딥링크 생성
  String createSeedGiftLink(String seedId) {
    return createDeepLink('gift/seed', [seedId]);
  }

  // 식물 보기 딥링크 생성
  String createPlantViewLink(String plantId) {
    return createDeepLink('plant', [plantId]);
  }

  // 딥링크 공유
  Future<void> shareDeepLink(String deepLink, String title, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: deepLink));
      print('Deep link copied to clipboard: $deepLink');
    } catch (e) {
      print('Error sharing deep link: $e');
    }
  }

  // 딥링크 정리
  void dispose() {
    _linkSubscription?.cancel();
  }
}
