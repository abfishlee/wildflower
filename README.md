# 🌸 세미꽃 (이 세상에 미운 꽃은 없다) - 프로젝트 마스터 가이드

> **"등산길, 산책길에 만난 야생화에게 따뜻한 이름을 불러주는 4060 맞춤형 AI 산행 꽃 수첩"**  
> 본 디렉토리(`E:\dev\wildflower`)는 '세미꽃' 모바일 앱/웹 서비스 개발을 위한 기획, UX 설계, 데이터 입수, 인프라 및 DB 아키텍처(Supabase + PostGIS) 문서와 디자인 시안을 모두 담고 있는 마스터 저장소입니다.

---

## 📂 폴더 및 문서 구조 (Directory Structure)

```
E:\dev\wildflower\
├── 📄 README.md (프로젝트 마스터 가이드 - 현 문서)
├── 📄 01_service_planning.md (4060 맞춤형 서비스 기획서)
├── 📄 02_ux_storyboard.md (5대 핵심 화면 UX 스토리보드 및 카톡 아침인사 명세)
├── 📄 03_architecture_and_infra_guide.md (Supabase + PostGIS + 카카오 연동 인프라 및 DB 명세)
├── 📄 04_data_acquisition_and_ai_pipeline.md (공공데이터 API 입수 및 AI 식별 엔진 파이프라인 가이드)
└── 📁 images\
    ├── 🖼️ 01_warm_hiking_ui.png (4060 등산객 맞춤 웜톤/민트/분홍 UI 시안)
    ├── 🖼️ 02_radar_and_feed_ui.png (꽃 지도 레이더 및 소셜 피드 UI 시안)
    └── 🖼️ 03_app_concept_ui.png (초기 글래스모피즘 앱 콘셉트 시안)
```

---

## 🎯 프로젝트 핵심 요약

* **서비스명**: 세미꽃 (이 세상에 미운 꽃은 없다)
* **타겟 유저**: 등산, 트레킹, 숲길 산책을 즐기며 카카오톡 아침 인사를 나누는 **40대~60대 액티브 시니어 및 중장년층**
* **핵심 기능**:
  1. **따뜻한 AI 꽃 돋보기**: 카메라를 꽃에 비추면 이름과 감성 꽃말이 1초 만에 짠!
  2. **나의 산행 꽃 수첩**: "언제, 어느 산길에서 만났는지" 날짜와 GPS 위치 일기장 자동 박제
  3. **카카오톡 아침 인사 엽서**: 내가 찍은 꽃 사진 + 꽃말 + 안부 글귀를 카톡 1초 원클릭 전송 (강력한 무료 바이럴 엔진!)
  4. **화사한 둘레길 산책 지도**: 눈이 편안한 밝은 모드의 카카오맵 위에 꽃잎 마커 표시

---

## 🛠️ 핵심 개발 스택 및 인프라 요약

```mermaid
flowchart LR
    subgraph Client [Frontend App]
        Direction[React Native / Flutter / Next.js PWA]
    end

    subgraph Backend [Backend Infra - Serverless]
        Supabase[Supabase Platform]
        Auth[Supabase Auth + Kakao OAuth]
        DB[(PostgreSQL + PostGIS Ext)]
        Storage[Supabase Storage]
    end

    subgraph External [External APIs & Data]
        Kakao[Kakao Login / Map / Talk Share API]
        DataPortal[공공데이터포털 꽃말/도감 API]
        PlantNet[PlantNet AI Vision API]
    end

    Direction <--> Auth
    Direction <--> DB
    Direction <--> Storage
    Direction <--> Kakao
    Direction <--> PlantNet
    DB <-- 배치 동기화 --- DataPortal
```

* **Frontend**: React Native (Expo) 또는 Flutter (iOS/Android 동시 대응 및 카메라/위치 정보 제어 최적화)
* **Backend & DB**: **Supabase (PostgreSQL + PostGIS)**
  * 위치 기반(반경 내 꽃 검색) 최적화를 위한 **PostGIS 공간 데이터베이스**
  * 카카오 소셜 간편로그인(OAuth) 원클릭 연동
  * 유저 고화질 꽃 사진 저장을 위한 Supabase Storage 및 RLS(행 수준 보안)
* **AI & Data**: 농촌진흥청 '오늘의 꽃말' API + 산림청 야생화 DB + PlantNet 식물 식별 API 연동

---

## 🚀 다음 단계 (How to Start Development)

1. `03_architecture_and_infra_guide.md`를 열어 Supabase 프로젝트 생성 및 PostGIS 테이블 생성 SQL 스크립트를 실행합니다.
2. `04_data_acquisition_and_ai_pipeline.md`를 참고하여 공공데이터포털의 꽃말 데이터를 Supabase DB로 시딩(Seeding)합니다.
3. React Native 또는 Flutter 프로젝트를 초기화하여 카카오 간편로그인과 돋보기 카메라 스캔 화면을 개발합니다.
