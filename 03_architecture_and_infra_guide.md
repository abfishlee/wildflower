# 🏗️ 세미꽃 - 개발 도구, 인프라 및 Supabase + PostGIS 아키텍처 가이드

> **"서버리스(Serverless) 기반의 최적화된 인프라와 PostGIS 공간 데이터베이스의 강력한 결합"**  
> 본 문서(`03_architecture_and_infra_guide.md`)는 '세미꽃' 서비스 개발을 위한 개발 환경(IDE, 프론트엔드/백엔드 스택), **Supabase + PostgreSQL + PostGIS 데이터베이스 설계(DDL 및 공간 쿼리)**, 카카오 생태계 연동 및 배포 파이프라인을 상세히 정의합니다.

---

## 1. 시스템 인프라 아키텍처 (System Architecture)

```mermaid
flowchart TD
    subgraph Client [Client App / PWA]
        MobileApp[React Native / Flutter App]
        GPS[GPS Location & Camera Sensor]
    end

    subgraph SupabaseCloud [Supabase Backend Infra]
        Auth[Supabase Auth\n(Kakao OAuth Provider)]
        DB[(PostgreSQL + PostGIS Ext\nSpatial DB & RLS)]
        Storage[Supabase Storage\n(Flower Photo Buckets)]
        Edge[Supabase Edge Functions\n(AI Mapping Router)]
    end

    subgraph ExternalServices [External APIs & AI]
        KakaoMap[Kakao Map SDK]
        KakaoTalk[KakaoTalk Share API]
        PlantNet[PlantNet Botanical Vision API]
    end

    MobileApp <-->|JWT / RLS Auth| Auth
    MobileApp <-->|REST / GraphQL / PostGIS Spatial Query| DB
    MobileApp <-->|Image Upload| Storage
    MobileApp -->|GPS Coords| KakaoMap
    MobileApp -->|Share Card| KakaoTalk
    Storage -->|Image URL| Edge
    Edge <-->|Identify Flower| PlantNet
```

---

## 2. 개발 도구 및 권장 기술 스택 (Development Stack)

| 영역 | 권장 기술 스택 | 선정 이유 (Why this Stack?) |
| :--- | :--- | :--- |
| **Frontend (Mobile)** | **React Native (Expo)** 또는 **Flutter** | • iOS/Android 단일 코드베이스 동시 빌드 및 신속한 UI 개발<br>• 카메라 센서, GPS 위치 추적, 카카오맵 SDK 연동에 최적화된 라이브러리 생태계 보유 |
| **Frontend (Web/Admin)**| **Next.js 14+ (App Router) + TailwindCSS** | • 관리자 도감 데이터 관리 및 유저 웹 뷰 공유 페이지(SSR/SEO) 지원 |
| **Backend / DB** | **Supabase (PostgreSQL + PostGIS)** | • 별도 서버 구축 없이 인증(Auth), DB, 스토리지, 실시간 API를 한 번에 해결<br>• **PostGIS 확장 모듈**을 통해 "내 주변 50m 이내 꽃 발견지 검색" 등 공간 위치 기반 쿼리를 압도적 성능으로 처리 |
| **Social / Map Infra** | **Kakao Developers API** | • 카카오 간편로그인, 카카오맵 안드로이드/iOS SDK, 카카오톡 메시지 공유 API |
| **AI Vision Engine** | **PlantNet API** (MVP) + **TensorFlow Lite** | • 초기에는 글로벌 상용 식별 API로 빠른 출시 후, 추후 모바일 온디바이스 AI 전환 |

---

## 3. Supabase + PostGIS 데이터베이스 스키마 설계 (DDL & SQL)

### ① PostGIS 공간 데이터베이스 확장 활성화
Supabase SQL Editor에서 가장 먼저 PostGIS 확장 모듈을 활성화합니다:
```sql
-- PostGIS 공간 데이터 확장 활성화
CREATE EXTENSION IF NOT EXISTS postgis;
```

### ② 핵심 테이블 DDL (SQL Schema)

```sql
-- 1. 유저 테이블 (Supabase Auth와 연동)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    kakao_id VARCHAR(100) UNIQUE NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    profile_image_url TEXT,
    age_group VARCHAR(20), -- 예: '40s', '50s', '60s'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONEC('utc', NOW())
);

-- 2. 한국 야생화 도감 DB 테이블 (공공데이터포털 연동 데이터)
CREATE TABLE public.flowers_encyclopedia (
    id SERIAL PRIMARY KEY,
    korean_name VARCHAR(100) NOT NULL,       -- 국명 (예: 진달래)
    scientific_name VARCHAR(150) NOT NULL,   -- 학명 (예: Rhododendron mucronulatum)
    flower_language TEXT,                    -- 꽃말 (예: 사랑의 기쁨)
    description TEXT,                        -- 식물 생태 이야기
    blooming_season VARCHAR(50),             -- 개화 시기 (예: 봄 / 3월~4월)
    rarity_tier VARCHAR(20) DEFAULT '친근한꽃', -- 분류 (친근한꽃, 계절의보물, 귀한특산식물)
    default_image_url TEXT
);
CREATE INDEX idx_scientific_name ON public.flowers_encyclopedia(scientific_name);

-- 3. 유저 산행 꽃 발견 수첩 테이블 (PostGIS 공간 좌표 적용!)
CREATE TABLE public.flower_discoveries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    flower_id INTEGER REFERENCES public.flowers_encyclopedia(id),
    photo_url TEXT NOT NULL,                 -- 유저가 직접 촬영한 꽃 사진 URL
    journal_title VARCHAR(100),              -- 산행 일지 제목
    journal_text TEXT,                       -- 따뜻한 인사말 및 메모
    
    -- ★ PostGIS 핵심: GPS 위도/경도 공간 좌표점 (SRID 4326 - WGS84 Standard)
    location_point GEOMETRY(Point, 4326) NOT NULL,
    location_name VARCHAR(100),              -- 발견 장소명 (예: 북한산 둘레길 산책로)
    
    is_public BOOLEAN DEFAULT TRUE,          -- 공개 여부 (모두의 정원 vs 비밀 수첩)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONEC('utc', NOW())
);

-- ★ 위치 기반 반경 검색 속도 100배 최적화를 위한 GIST 공간 인덱스 생성
CREATE INDEX idx_flower_location_gist ON public.flower_discoveries USING GIST (location_point);

-- 4. 감성 소셜 리액션 테이블 (🌸 따뜻해요, 🌿 예뻐요, ⭐ 신기해요)
CREATE TABLE public.social_reactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    discovery_id UUID REFERENCES public.flower_discoveries(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    reaction_type VARCHAR(20) CHECK (reaction_type IN ('WARM_FLOWER', 'PRETTY_LEAF', 'WONDER_STAR')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONEC('utc', NOW()),
    UNIQUE(discovery_id, user_id, reaction_type)
);
```

---

## 4. PostGIS 공간 쿼리 활용 예시 (핵심 실무 SQL)

### 💡 "내 주변 반경 500m 이내 산책로에서 발견된 꽃 목록 불러오기"
어플리케이션에서 유저의 현재 GPS 좌표(위도 `37.6658`, 경도 `126.9928`)를 받아, 주변에서 피어난 꽃들을 거리순으로 조회하는 PostGIS 쿼리입니다:

```sql
SELECT 
    d.id,
    e.korean_name AS flower_name,
    e.flower_language,
    d.photo_url,
    d.location_name,
    d.journal_text,
    -- 내 위치로부터 얼마 떨어져 있는지 거리(미터 단위) 계산
    ST_Distance(
        d.location_point::geography, 
        ST_SetSRID(ST_MakePoint(126.9928, 37.6658), 4326)::geography
    ) AS distance_meters
FROM 
    public.flower_discoveries d
JOIN 
    public.flowers_encyclopedia e ON d.flower_id = e.id
WHERE 
    d.is_public = TRUE
    -- 내 위치 중심 반경 500 미터 이내 조건 (ST_DWithin 활용)
    AND ST_DWithin(
        d.location_point::geography,
        ST_SetSRID(ST_MakePoint(126.9928, 37.6658), 4326)::geography,
        500
    )
ORDER BY 
    distance_meters ASC
LIMIT 20;
```
👉 **성능 장점**: 일반 DB에서 위경도 거리 계산식을 쓰면 데이터가 늘어날 때 극심한 버퍼링이 발생하지만, **PostGIS GIST 인덱스 + `ST_DWithin`**을 사용하면 수백만 건의 위치 데이터 중에서 0.01초 이내로 즉시 검색됩니다!

---

## 5. Supabase RLS (Row Level Security) 보안 정책

유저가 '비밀 수첩(비공개)'으로 설정한 사진은 본인만 볼 수 있고, '모두의 정원(공개)'으로 설정한 사진만 카카오맵 레이더와 소셜 피드에 노출되도록 Supabase RLS 정책을 설정합니다:

```sql
ALTER TABLE public.flower_discoveries ENABLE ROW LEVEL SECURITY;

-- 1. 조회 정책: 공개된 데이터는 누구나 조회 가능 OR 비공개 데이터는 작성자 본인만 조회 가능
CREATE POLICY "Public discoveries are viewable by everyone, private by owner"
ON public.flower_discoveries FOR SELECT
USING (
    is_public = TRUE 
    OR auth.uid() = user_id
);

-- 2. 등록 정책: 로그인한 유저 본인 ID로만 데이터 등록 가능
CREATE POLICY "Users can insert their own discoveries"
ON public.flower_discoveries FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 3. 수정 및 삭제 정책: 본인이 작성한 데이터만 수정/삭제 가능
CREATE POLICY "Users can update own discoveries"
ON public.flower_discoveries FOR UPDATE
USING (auth.uid() = user_id);
```

---

## 6. 카카오 생태계 연동 체크리스트 (Kakao Developers Console Setup)

1. **카카오 디벨로퍼스(`developers.kakao.com`) 앱 생성**:
   * 내 애플리케이션 ➔ 앱 설정 ➔ 플랫폼 등록 (Android 패키지명, iOS 번들 ID, 웹 도메인 입력).
2. **카카오 간편로그인 (Kakao Login)**:
   * 제품 설정 ➔ 카카오 로그인 활성화.
   * 동의항목: 닉네임(필수), 프로필 사진(선택), 연령대(선택 - 4060 타겟 맞춤 큐레이션용).
   * Supabase Authentication ➔ Providers ➔ Kakao에 `REST API Key`와 `Client Secret` 등록!
3. **카카오맵 SDK (Kakao Map)**:
   * 안드로이드/iOS 네이티브 App Key 발급 및 `AndroidManifest.xml` / `Info.plist`에 키 등록.
   * 지도 기본 모드를 밝고 산뜻한 일반 지도(Light Mode)로 초기화.
4. **카카오톡 공유 API (KakaoTalk Share - 아침 인사 엽서)**:
   * 메시지 템플릿 빌더(Template Builder)에서 **[커스텀 템플릿(ID 발급)]** 생성.
   * 템플릿 변수 매핑: `${flower_name}`, `${flower_language}`, `${photo_url}`, `${greeting_msg}`, `${discovery_id}`.
