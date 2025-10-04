# 물먹자 투게더 - 통합 우선순위 구현 가이드

## 📋 문서 개요
- **문서명**: Integrated Priority Implementation Guide
- **생성일**: 2025-01-27
- **버전**: 3.0 (Task_List_3.md + Task_List_4.md 통합)
- **목적**: 우선순위 높은 작업부터 단계별로 구현하는 통합 가이드

---

## 🎯 현재 상황 분석

### 📊 완성도 평가
| 기능 영역 | 문서 요구사항 | 현재 구현도 | 우선순위 |
|-----------|---------------|--------------|----------|
| 네비게이션 | 100% | 75% | 🔴 높음 |
| 튜토리얼 | 100% | 0% | 🔴 높음 |
| 도감 시스템 | 100% | 20% | 🔴 높음 |
| 친구 시스템 | 100% | 60% | 🟠 중간 |
| 인벤토리 | 100% | 70% | 🟠 중간 |
| 홈 화면 | 100% | 80% | 🟠 중간 |
| 애니메이션 | 100% | 10% | 🟡 낮음 |
| 효과음 | 100% | 0% | 🟡 낮음 |

**전체 완성도: 약 40%** (문서 요구사항 대비)

---

## 🎯 개발 시작 전 준비사항

### 필수 지식
- **Flutter 기본**: 위젯, 상태 관리, 네비게이션
- **Dart 언어**: 클래스, 함수, 비동기 처리
- **Provider 패턴**: 상태 관리 기본 개념
- **SharedPreferences**: 로컬 데이터 저장

### 개발 환경 설정
```bash
# 1. Flutter 프로젝트 디렉토리로 이동
cd /Users/eldrac/Desktop/water/water_together

# 2. 패키지 설치
flutter pub get

# 3. 앱 실행 (테스트용)
flutter run
```

### 개발 원칙
- **단계별 구현**: 한 번에 하나씩 기능 구현
- **테스트 우선**: 각 단계마다 앱 실행하여 확인
- **에러 해결**: 컴파일 에러부터 차근차근 해결
- **문서 참조**: 기존 코드와 문서를 참고하여 구현

---

## 🔴 Week 1: 핵심 구조 수정 (높은 우선순위)

### Day 1: 네비게이션 구조 변경

#### Task 1.1: 하단 네비게이션 수정
**목표**: 설정 탭 제거, 도감 탭 추가

**파일 수정**:
- `lib/screens/main_screen.dart`

**구체적 작업**:
- BottomNavigationBar items에서 설정 탭 제거
- 도감 탭 추가 (Icons.collections_bookmark)
- 탭 전환 로직에서 SettingsScreen → CollectionScreen 변경

**✅ 확인사항**:
1. 하단 네비게이션에서 설정 탭이 제거되었는지 확인
2. 도감 탭이 추가되었는지 확인
3. 도감 탭 클릭 시 CollectionScreen이 표시되는지 확인

#### Task 1.2: 홈 화면 상단 네비게이션에 설정 아이콘 추가
**목표**: 설정을 상단 네비게이션으로 이동

**파일 수정**:
- `lib/screens/home_screen.dart`

**구체적 작업**:
- AppBar actions에 설정 아이콘 추가
- _showSettings 메서드 구현
- Navigator.push로 SettingsScreen 이동

**✅ 확인사항**:
1. 홈 화면 상단에 설정 아이콘이 표시되는지 확인
2. 설정 아이콘 클릭 시 설정 화면이 표시되는지 확인

### Day 2: 도감 시스템 기본 구현

#### Task 2.1: CollectionScreen 생성
**목표**: 기본 도감 화면 구현

**파일 생성**:
- `lib/screens/collection_screen.dart`

**구체적 작업**:
- 기본 Scaffold 구조 생성
- AppBar에 '도감' 타이틀 추가
- 임시 플레이스홀더 UI 구현

**✅ 확인사항**:
1. CollectionScreen 파일이 생성되었는지 확인
2. 도감 탭 클릭 시 기본 화면이 표시되는지 확인

#### Task 2.2: main_screen.dart에 CollectionScreen import 추가
**목표**: CollectionScreen을 main_screen에서 사용할 수 있도록 import

**파일 수정**:
- `lib/screens/main_screen.dart`

**구체적 작업**:
- import 'collection_screen.dart' 추가

**✅ 확인사항**:
1. import 에러가 없는지 확인
2. 앱이 정상 실행되는지 확인

### Day 3: 튜토리얼 시스템 구현

#### Task 3.1: 튜토리얼 시스템 간략 구현
**목표**: 기본 튜토리얼 오버레이 구현

**파일 생성**:
- `lib/widgets/tutorial_overlay.dart`
- `lib/services/tutorial_service.dart`

**구체적 작업**:
- TutorialOverlay StatefulWidget 생성
- 2단계 강제 오버레이 구현 (물 기록 + 씨앗 심기)
- 스킵 기능 제거 (UserFlow.md 요구사항)
- 완료 후 콜백 처리

**✅ 확인사항**:
1. 튜토리얼 오버레이가 표시되는지 확인
2. 2단계 튜토리얼이 순서대로 진행되는지 확인
3. 완료 후 오버레이가 사라지는지 확인

#### Task 3.2: 홈 화면에 튜토리얼 통합
**목표**: 홈 화면에 튜토리얼 오버레이 적용

**파일 수정**:
- `lib/screens/home_screen.dart`

**구체적 작업**:
- HomeScreen을 StatefulWidget으로 변경
- TutorialOverlay로 body 감싸기
- 웰컴 메시지 상태 관리 추가
- 튜토리얼 완료 후 "같이 마셔요" 메시지 표시

**✅ 확인사항**:
1. 홈 화면에서 튜토리얼이 정상 작동하는지 확인
2. 튜토리얼 완료 후 "같이 마셔요" 웰컴 메시지가 표시되는지 확인
3. 웰컴 메시지가 3초 후 자동으로 사라지는지 확인

### Day 4: 튜토리얼 서비스 구현

#### Task 4.1: TutorialService 클래스 생성
**목표**: 튜토리얼 완료 상태 관리

**파일 생성**:
- `lib/services/tutorial_service.dart`

**구체적 작업**:
- 싱글톤 패턴으로 TutorialService 구현
- SharedPreferences로 완료 상태 저장
- isTutorialCompleted() 메서드 구현
- completeTutorial() 메서드 구현
- resetTutorial() 메서드 구현 (디버그용)

**✅ 확인사항**:
1. SharedPreferences가 정상 작동하는지 확인
2. 튜토리얼 완료 상태가 저장되는지 확인

#### Task 4.2: 데이터 저장 시스템 구현
**목표**: 사용자 데이터 저장 및 관리

**파일 생성**:
- `lib/services/storage_service.dart`
- `lib/services/user_data_service.dart`

**구체적 작업**:
- StorageService 싱글톤 패턴 구현
- SharedPreferences 래퍼 메서드들
- 사용자 데이터 저장/불러오기
- 물 기록 저장/불러오기
- 설정 저장/불러오기
- UserDataService로 모델 변환 처리

**✅ 확인사항**:
1. 사용자 데이터가 정상 저장/불러오기 되는지 확인
2. 물 기록 데이터가 정상 관리되는지 확인

### Day 5: 식물 성장 시스템 구현

#### Task 5.1: PlantGrowthService 구현
**목표**: 식물 성장 로직 구현

**파일 생성**:
- `lib/services/plant_growth_service.dart`
- `lib/services/reward_service.dart`

**구체적 작업**:
- 식물 성장 조건 정의 (씨앗→줄기→꽃→열매)
- waterPlant() 메서드 구현
- 성장 가능 여부 확인 로직
- 다음 성장까지 필요한 물의 양 계산
- 성장 완료 시 보상 계산

**✅ 확인사항**:
1. 식물 성장 로직이 정상 작동하는지 확인
2. 성장 단계별 조건이 올바르게 적용되는지 확인

#### Task 5.2: RewardService 구현
**목표**: 보상 시스템 구현

**구체적 작업**:
- 성장 완료 보상 지급
- 챌린지 완료 보상
- 친구 초대 보상
- 인벤토리에 아이템 추가 로직

**✅ 확인사항**:
1. 보상 시스템이 정상 작동하는지 확인
2. 다양한 보상 타입이 올바르게 처리되는지 확인

---

## 🟠 Week 2: 도감 시스템 완성 (중간 우선순위)

### Day 6: 도감 화면 상세 구현

#### Task 6.1: PlantGridWidget 생성
**목표**: 식물 그리드 위젯 구현

**파일 생성**:
- `lib/widgets/plant_grid_widget.dart`

**구체적 작업**:
- 임시 식물 데이터 생성 (수집/미수집 구분)
- 도감 완성도 표시 (LinearProgressIndicator)
- GridView로 식물 그리드 구현
- 수집된 식물만 클릭 가능하도록 처리
- 식물 상세 정보 다이얼로그 구현

**✅ 확인사항**:
1. 식물 그리드가 정상 표시되는지 확인
2. 수집된 식물과 미수집 식물이 구분되어 표시되는지 확인
3. 식물 클릭 시 상세 정보가 표시되는지 확인

#### Task 6.2: CollectionScreen에 PlantGridWidget 적용
**목표**: CollectionScreen에 PlantGridWidget 통합

**파일 수정**:
- `lib/screens/collection_screen.dart`

**구체적 작업**:
- PlantGridWidget import 추가
- body에 PlantGridWidget 적용

**✅ 확인사항**:
1. 도감 화면에 식물 그리드가 표시되는지 확인
2. 도감 완성도가 정상 계산되어 표시되는지 확인

### Day 7: 식물 성장 시스템 완성

#### Task 7.1: 최종 단계 보상 시스템 구현
**목표**: 식물이 최종 단계(열매)에 도달했을 때 보상 지급

**파일 수정**:
- `lib/models/plant.dart`
- `lib/providers/water_provider.dart`

**구체적 작업**:
- Plant 모델에 `isFullyGrown()` 메서드 추가
- WaterProvider에 최종 단계 보상 로직 추가
- 식물 완성 시 해당 식물 씨앗 1개 지급
- 식물 완성 시 랜덤 씨앗 1개 지급
- 도감에 완성된 식물 추가
- 축하 메시지 표시

**✅ 확인사항**:
1. 식물이 열매 단계에 도달했을 때 보상이 지급되는지 확인
2. 인벤토리에 씨앗이 정상적으로 추가되는지 확인
3. 축하 메시지가 표시되는지 확인

#### Task 7.2: 성장 시스템 설계 결정사항 문서화
**목표**: 성장 진행률 시각화 및 애니메이션 관련 설계 결정사항 반영

**설계 결정사항**:
- **성장 진행률 시각화**: 의도적으로 제외
  - 사용자가 성장 과정을 자연스럽게 경험하도록 함
  - 다음 단계까지 얼마나 남았는지 미리 알려주지 않음
  - 단계별 성장의 놀라움과 기대감 유지

- **성장 애니메이션**: 추후 구현 예정
  - 현재는 기본 기능 구현에 집중
  - 물 마시기 시 식물 애니메이션은 향후 개선사항으로 분류
  - 단계 업그레이드 시 축하 애니메이션도 추후 구현

**✅ 확인사항**:
1. 설계 결정사항이 문서에 명확히 기록되었는지 확인
2. 향후 개발 방향이 명확해졌는지 확인

### Day 8: 인벤토리 팝업 시스템 개선

#### Task 8.1: InventoryPopup 위젯 생성
**목표**: 개선된 인벤토리 팝업 구현

**파일 생성**:
- `lib/widgets/inventory_popup.dart`

**구체적 작업**:
- Dialog 형태의 인벤토리 팝업 구현
- 씨앗 그리드 표시 (GridView)
- 씨앗 클릭 시 상세 정보 팝업
- 심기 버튼 기능 구현
- 보유 수량 표시

**✅ 확인사항**:
1. 인벤토리 팝업이 정상 표시되는지 확인
2. 씨앗 클릭 시 상세 정보가 표시되는지 확인
3. 심기 버튼이 정상 작동하는지 확인

#### Task 8.2: SeedPreviewWidget 생성
**목표**: 씨앗 미리보기 위젯 구현

**파일 생성**:
- `lib/widgets/seed_preview_widget.dart`

**구체적 작업**:
- 씨앗 정보 표시 위젯 구현
- 씨앗 이미지, 이름, 수량 표시
- 클릭 이벤트 처리
- 테마 색상 적용

**✅ 확인사항**:
1. 씨앗 미리보기 위젯이 정상 표시되는지 확인
2. 씨앗 정보가 올바르게 표시되는지 확인

#### Task 8.3: 홈 화면 인벤토리 버튼 수정
**목표**: 홈 화면의 인벤토리 버튼을 새로운 팝업과 연동

**파일 수정**:
- `lib/screens/home_screen.dart`

**구체적 작업**:
- _showInventoryDialog 메서드 수정
- InventoryPopup 사용하도록 변경
- 임시 씨앗 데이터 생성

**✅ 확인사항**:
1. 인벤토리 버튼 클릭 시 새로운 팝업이 표시되는지 확인
2. 씨앗 미리보기 기능이 정상 작동하는지 확인

---

## 🟡 Week 3: 친구 시스템 강화 (중간 우선순위)

### Day 8: 친구 초대 시스템 구현

#### Task 8.1: InviteDialog 위젯 생성
**목표**: 친구 초대 다이얼로그 구현

**파일 생성**:
- `lib/widgets/invite_dialog.dart`

**구체적 작업**:
- AlertDialog 형태의 초대 다이얼로그 구현
- 초대 메시지 템플릿 생성
- 공유 기능 구현 (share_plus 패키지 사용)
- 초대 보상 안내 메시지

**✅ 확인사항**:
1. 친구 초대 다이얼로그가 정상 표시되는지 확인
2. 초대하기 버튼 클릭 시 스낵바가 표시되는지 확인

#### Task 8.2: InviteService 구현
**목표**: 친구 초대 서비스 구현

**파일 생성**:
- `lib/services/invite_service.dart`

**구체적 작업**:
- 싱글톤 패턴으로 InviteService 구현
- 초대 링크 생성 메서드
- 딥링크 생성 메서드
- 초대 보상 지급 로직
- 초대 성공 처리 메서드

**✅ 확인사항**:
1. 초대 링크가 정상 생성되는지 확인
2. 초대 보상 시스템이 작동하는지 확인

#### Task 8.3: 홈 화면에 친구 초대 버튼 추가
**목표**: 홈 화면에 친구 초대 기능 추가

**파일 수정**:
- `lib/screens/home_screen.dart`

**구체적 작업**:
- 친구 초대 버튼 추가 (ElevatedButton.icon)
- _showInviteDialog 메서드 구현
- InviteDialog import 추가

**✅ 확인사항**:
1. 친구 초대 버튼이 홈 화면에 표시되는지 확인
2. 친구 초대 버튼 클릭 시 다이얼로그가 표시되는지 확인

---

## 🟢 Week 4: 사용자 경험 개선 (낮은 우선순위)

### Day 9: 설정 시스템 구현 (상단 네비게이션으로 이동)

#### Task 9.1: 설정 화면을 상단 네비게이션으로 이동
**목표**: 설정을 상단 네비게이션으로 이동

**파일 수정**:
- `lib/screens/settings_screen.dart`

**구체적 작업**:
- 설정 화면을 상단 네비게이션에서 접근하도록 수정
- 목표 섭취량 설정 다이얼로그
- 알림 설정 토글
- 계정 정보 표시
- 로그아웃 다이얼로그

**✅ 확인사항**:
1. 설정 화면의 모든 기능이 정상 작동하는지 확인
2. 목표 섭취량 설정이 정상 작동하는지 확인

### Day 10: 애니메이션 시스템 준비

#### Task 10.1: pubspec.yaml에 애니메이션 패키지 추가
**목표**: Lottie 애니메이션 패키지 추가

**파일 수정**:
- `water_together/pubspec.yaml`

**구체적 작업**:
- lottie: ^2.7.0 추가
- audioplayers: ^5.2.1 추가
- flutter pub get 실행

**✅ 확인사항**:
1. 패키지가 정상 설치되었는지 확인
2. 앱이 정상 실행되는지 확인

#### Task 10.2: 기본 애니메이션 위젯 생성
**목표**: 기본 애니메이션 위젯 구조 생성

**파일 생성**:
- `lib/widgets/water_drop_animation.dart`

**구체적 작업**:
- WaterDropAnimation StatefulWidget 생성
- AnimationController 구현
- 물방울 이모지 애니메이션 효과
- 완료 콜백 처리

**✅ 확인사항**:
1. 애니메이션 위젯이 정상 생성되었는지 확인
2. 애니메이션이 정상 작동하는지 확인

### Day 11: 효과음 시스템 준비

#### Task 11.1: AudioService 생성
**목표**: 효과음 재생 서비스 구현

**파일 생성**:
- `lib/services/audio_service.dart`

**구체적 작업**:
- AudioService 싱글톤 패턴 구현
- 물 기록 효과음 메서드
- 식물 성장 효과음 메서드
- 목표 달성 효과음 메서드
- 에러 처리 구현

**✅ 확인사항**:
1. AudioService가 정상 생성되었는지 확인
2. 효과음 재생 메서드가 정상 작동하는지 확인

---

## 📋 전체 작업 체크리스트

### Week 1 체크리스트 (핵심 구조)
- [ ] 네비게이션 구조 수정 (설정→도감 탭 변경)
- [ ] CollectionScreen 기본 구현
- [ ] TutorialOverlay 및 TutorialService 구현
- [ ] StorageService 및 UserDataService 구현
- [ ] PlantGrowthService 및 RewardService 구현

### Week 2 체크리스트 (도감 시스템)
- [ ] PlantGridWidget 구현
- [ ] InventoryPopup 및 SeedPreviewWidget 구현
- [ ] 홈 화면 인벤토리 연동

### Week 3 체크리스트 (친구 시스템)
- [ ] InviteDialog 및 InviteService 구현
- [ ] 홈 화면 친구 초대 기능 추가

### Week 4 체크리스트 (사용자 경험)
- [ ] 설정 시스템 상단 네비게이션 이동
- [ ] 애니메이션 및 효과음 시스템 준비

---

## 🎯 성공 기준

### Week 1 완료 기준
- [ ] 네비게이션 구조가 문서 요구사항과 일치
- [ ] 튜토리얼 시스템이 정상 작동
- [ ] 데이터 저장 및 식물 성장 시스템이 구현됨

### Week 2 완료 기준
- [ ] 도감 시스템이 완전히 구현됨
- [ ] 인벤토리 팝업이 개선됨

### Week 3 완료 기준
- [ ] 친구 초대 시스템이 구현됨

### Week 4 완료 기준
- [ ] 설정 시스템이 상단 네비게이션으로 이동됨
- [ ] 애니메이션 및 효과음 시스템이 준비됨

---

## 📞 문제 해결 가이드

### 자주 발생하는 에러
1. **import 에러**: 파일 경로 확인
2. **컴파일 에러**: `flutter pub get` 실행
3. **위젯 에러**: Scaffold, MaterialApp 확인
4. **상태 관리 에러**: Provider 사용법 확인

### 유용한 명령어
```bash
# 앱 실행
flutter run

# 패키지 설치
flutter pub get

# 빌드 정리
flutter clean

# 의존성 확인
flutter doctor
```

### 질문할 때 포함할 내용
1. **에러 메시지**: 정확한 에러 메시지 복사
2. **코드**: 문제가 발생한 코드 부분
3. **단계**: 어떤 Task에서 문제가 발생했는지
4. **시도한 해결법**: 이미 시도해본 해결 방법

---

## 📚 참고 문서

- **파일 구조 가이드**: `docs/design/File_Structure_Guide.md`
- **UI 디자인 가이드**: `docs/design/UI_Design_Guide.md`
- **기술 사양서**: `docs/development/TechSpec.md`
- **사용자 플로우**: `docs/project/UserFlow.md`

---

## 🎉 결론

이 가이드는 신입 개발자도 쉽게 따라할 수 있도록 단계별로 구성되었습니다.

**개발 순서**:
1. **Week 1**: 핵심 구조 수정 (네비게이션, 튜토리얼, 데이터 저장, 식물 성장)
2. **Week 2**: 도감 시스템 완성 (식물 그리드, 인벤토리 개선)
3. **Week 3**: 친구 초대 시스템 구현
4. **Week 4**: 사용자 경험 개선 (설정 이동, 애니메이션, 효과음)

**핵심 원칙**:
- **단계별 구현**: 한 번에 하나씩 기능 구현
- **테스트 우선**: 각 단계마다 앱 실행하여 확인
- **에러 해결**: 컴파일 에러부터 차근차근 해결

**예상 완성 시점**: 4주 후 (Week 1-4 완료)
**최종 목표**: 실제 사용 가능한 완전한 MVP 앱 완성

---

*문서 생성일: 2025-01-27*  
*마지막 업데이트: 통합 우선순위 구현 가이드 완성*  
*다음 검토 예정일: 2025-02-03*
