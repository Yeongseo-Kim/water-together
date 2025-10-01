# 물먹자 투게더 프로젝트 구조

## 📁 프로젝트 폴더 구조

```
water/
├── docs/                          # 📚 문서 폴더
│   ├── project/                   # 📋 프로젝트 기획 문서
│   │   ├── PRD.md                 # 제품 요구사항 정의서
│   │   ├── IA.md                  # 정보 아키텍처
│   │   └── UserFlow.md            # 사용자 플로우
│   ├── design/                    # 🎨 디자인 문서
│   │   └── UI_Design_Guide.md     # UI 디자인 가이드
│   └── development/               # 💻 개발 문서
│       ├── TechSpec.md            # 기술 사양서
│       └── Detailed_Task_List.md  # 상세 개발 태스크 리스트
├── prototypes/                    # 🔬 프로토타입
│   └── html/                      # HTML 프로토타입
│       ├── collection.html        # 도감 화면 프로토타입
│       ├── dashboard.html         # 대시보드 화면 프로토타입
│       ├── home.html              # 홈 화면 프로토타입
│       ├── login.html             # 로그인 화면 프로토타입
│       └── ranking.html           # 랭킹 화면 프로토타입
└── README.md                      # 프로젝트 개요 (이 파일)
```

## 📖 문서 설명

### 프로젝트 기획 문서 (`docs/project/`)
- **PRD.md**: 제품 요구사항 정의서 - 앱의 핵심 기능과 목표 정의
- **IA.md**: 정보 아키텍처 - 화면 구조와 네비게이션 설계
- **UserFlow.md**: 사용자 플로우 - 사용자 여정과 주요 액션 정의

### 디자인 문서 (`docs/design/`)
- **UI_Design_Guide.md**: UI 디자인 가이드 - 디자인 시스템과 컴포넌트 가이드

### 개발 문서 (`docs/development/`)
- **TechSpec.md**: 기술 사양서 - 데이터 구조와 API 설계
- **Detailed_Task_List.md**: 상세 개발 태스크 리스트 - 일별 개발 계획

### 프로토타입 (`prototypes/html/`)
- 각 화면별 HTML 프로토타입 파일들
- 실제 개발 전 UI/UX 검증용

## 🚀 개발 시작하기

1. **기획 이해**: `docs/project/` 폴더의 문서들을 먼저 읽어보세요
2. **디자인 확인**: `docs/design/UI_Design_Guide.md`로 디자인 가이드 확인
3. **기술 사양 파악**: `docs/development/TechSpec.md`로 기술적 요구사항 이해
4. **개발 계획**: `docs/development/Detailed_Task_List.md`로 단계별 개발 진행
5. **프로토타입 참고**: `prototypes/html/`의 HTML 파일들로 UI 구조 참고

## 📝 문서 업데이트 가이드

- **기획 변경 시**: `docs/project/` 폴더의 해당 문서 수정
- **디자인 변경 시**: `docs/design/UI_Design_Guide.md` 업데이트
- **기술 사양 변경 시**: `docs/development/TechSpec.md` 업데이트
- **개발 진행 상황**: `docs/development/Detailed_Task_List.md` 체크리스트 업데이트

---

*프로젝트 구조 정리 완료: 2025-01-27*
