# Scoliscan Landing Page

AI-powered spinal health monitoring application의 랜딩 페이지입니다. 어린이 척추건강 스크리닝을 위한 서비스를 소개하며, 풀페이지 스크롤 경험과 다국어 지원을 제공합니다.

## 🚀 기술 스택

- **Next.js 14** - App Router 및 experimental appDir 사용
- **TypeScript** - 타입 안전성
- **Tailwind CSS** - 스타일링 및 광범위한 커스텀 설정
- **Framer Motion** - 애니메이션 및 전환 효과
- **Lucide React** - 아이콘

## 🎯 주요 기능

### 커스텀 풀페이지 스크롤 시스템
- `FullPageScroll` 컴포넌트로 세로 섹션 네비게이션 관리
- **데스크톱**: `transform: translateY()` 사용한 부드러운 전환
- **모바일**: 자동으로 표준 스크롤로 전환 (lg 브레이크포인트 이하)
- **네비게이션 방식**: 마우스 휠, 키보드 (방향키, PageUp/Down, Home/End), 터치 제스처

### 언어 시스템
- `LanguageContext` 기반 중앙 집중식 언어 상태 관리
- `useLanguage()` 훅을 통한 언어 컨텍스트 접근
- 모든 섹션 컴포넌트에 `language: 'ko' | 'en'` prop 전달
- 라우팅 없는 순수 컨텍스트 기반 상태 관리

## 📁 프로젝트 구조

```
components/
├── ui/                    # 재사용 가능한 UI 컴포넌트
│   ├── FullPageScroll.tsx # 핵심 스크롤 시스템
│   ├── Button.tsx         # 스타일된 버튼 variants
│   ├── Container.tsx      # 레이아웃 컨테이너
│   ├── ScrollIndicator.tsx# 우측 점 네비게이션
│   ├── ScrollToTop.tsx    # 상단 이동 버튼
│   └── SurveyModal.tsx    # 설문조사 팝업 모달
├── sections/              # 페이지 섹션들 (총 9개)
│   ├── Hero.tsx          # 히어로 섹션
│   ├── About.tsx         # 소개 섹션
│   ├── Features.tsx      # 기능 섹션
│   ├── Interactive.tsx   # 인터랙티브 섹션
│   ├── Solution.tsx      # 솔루션 섹션
│   ├── Monitoring.tsx    # 모니터링 섹션
│   ├── Services.tsx      # 서비스 섹션
│   ├── Reasons.tsx       # 선택 이유 섹션
│   └── Contact.tsx       # 연락처 섹션 (Footer 포함)
└── Navigation.tsx         # 고정 헤더 및 언어 토글
```

### 섹션 인덱스 매핑
풀페이지 스크롤 네비게이션을 위한 섹션 순서:
```
0. Hero
1. About
2. Features
3. Interactive
4. Solution
5. Monitoring
6. Services
7. Reasons
8. Contact
```

## 🎨 스타일링 시스템

### Tailwind 커스텀 설정
- **Primary Color Palette**: 50-900 음영의 teal/cyan 색상
- **Custom Font Stack**: Pretendard Variable 및 한국어/영어 fallback
- **Custom Animations**: `fade-in`, `slide-up` 키프레임
- **Gradient Primary**: `linear-gradient(135deg, rgba(2, 216, 194, 1) 0%, rgba(3, 152, 183, 1) 100%)`

### 유틸리티 함수
- `cn()` - clsx + tailwind-merge를 위한 클래스 병합
- `scrollToElement()` - 표준 스크롤 동작 (풀페이지 모드에서 미사용)

## 🚀 개발 명령어

```bash
# 개발 서버 실행
npm run dev

# 프로덕션 빌드
npm run build

# 프로덕션 서버 실행
npm start

# 코드 린트
npm run lint
```

## ⚠️ 개발 가이드라인

### 풀페이지 스크롤 시스템 규칙
- ❌ 전통적인 라우팅 사용 금지 - 단일 페이지 아키텍처 유지
- ✅ 프로그래매틱 네비게이션은 커스텀 이벤트 `scrollToSection` 사용
- ✅ 데스크톱 스크롤 동작과 모바일 fallback 모두 테스트
- ✅ 섹션 추가/제거 시 인덱스 일관성 유지
- ✅ 모바일 브레이크포인트: `lg` (1024px) 이하에서 일반 스크롤로 전환

### 컴포넌트 패턴
- ✅ 모든 섹션은 `language: 'ko' | 'en'` prop 허용
- ✅ 조건부 스타일링에는 `cn()` 유틸리티 사용
- ✅ 기존 TypeScript 인터페이스 준수
- ✅ Tailwind 브레이크포인트로 반응형 디자인 패턴 유지

### 네비게이션 시스템
- **헤더 로고**: Features 섹션(인덱스 2)부터 `logo-b.svg` 사용
- **특별 섹션**: Reasons(인덱스 7)와 Contact(인덱스 8)에서는 `logo.svg` 사용
- **언어/CTA 버튼**: 섹션별 다른 색상 테마 적용

## 📝 주요 기능 설명

### 애니메이션 시스템
- **AOS 효과**: Framer Motion `whileInView` 사용
- **Reasons 섹션**: 카드들이 순차적으로 부드럽게 올라오는 애니메이션
- **Contact 섹션**: 헤더와 폼 필드들의 순차적 페이드인
- **Services 섹션**: 인터랙티브한 스텝별 전환 애니메이션 유지

### Contact 폼 시스템
- **이메일 수집**: 유효성 검사 포함
- **대상 선택**: 자녀/본인/다른 가족들 옵션
- **동의 체크박스**: 서비스 정보 수신 동의
- **설문조사 모달**: 폼 제출 성공 시 팝업으로 구글 폼 연결

### 스크롤 인디케이터
- **동적 색상**: 섹션 배경에 따른 색상 자동 변경
- **밝은 섹션** (About~Services): 회색 테두리
- **어두운 섹션** (Hero, Reasons, Contact): 흰색 테두리

## 🔧 보안 및 베스트 프랙티스
- ✅ 보안 모범 사례 준수
- ❌ 시크릿 및 키 노출/로깅 금지
- ❌ 저장소에 시크릿 커밋 금지
- ✅ 다국어 지원을 위한 적절한 한글 폰트 스택

---

**License**: Private
**Version**: 1.0.0
**Author**: mBaas inc.