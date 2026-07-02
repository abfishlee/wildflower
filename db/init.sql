-- =================================================================
-- 🌸 세미꽃 (Semikkot) - PostgreSQL + PostGIS 초기화 스크립트
-- =================================================================

-- 1. PostGIS 공간 데이터 확장 활성화
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. 유저 테이블 (카카오 3초 간편로그인 연동)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    kakao_id VARCHAR(100) UNIQUE NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    profile_image_url TEXT,
    age_group VARCHAR(20), -- '40s', '50s', '60s' 등
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. 한국 야생화 도감 DB 테이블 (공공데이터포털 연동 대상)
CREATE TABLE IF NOT EXISTS public.flowers_encyclopedia (
    id SERIAL PRIMARY KEY,
    korean_name VARCHAR(100) NOT NULL,       -- 국명 (예: 진달래)
    scientific_name VARCHAR(150) NOT NULL,   -- 학명 (예: Rhododendron mucronulatum)
    flower_language TEXT,                    -- 꽃말 (예: 사랑의 기쁨)
    description TEXT,                        -- 식물 생태 이야기
    blooming_season VARCHAR(50),             -- 개화 시기 (예: 봄 / 3월~4월)
    rarity_tier VARCHAR(20) DEFAULT '친근한꽃', -- 분류 (친근한꽃, 계절의보물, 귀한특산식물)
    default_image_url TEXT,
    CONSTRAINT uniq_scientific_name UNIQUE (scientific_name)
);

CREATE INDEX IF NOT EXISTS idx_scientific_name ON public.flowers_encyclopedia(scientific_name);

-- 4. 유저 산행 꽃 발견 수첩 테이블 (PostGIS 공간 좌표 적용!)
CREATE TABLE IF NOT EXISTS public.flower_discoveries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    flower_id INTEGER REFERENCES public.flowers_encyclopedia(id),
    photo_url TEXT NOT NULL,                 -- 유저 촬영 사진
    journal_title VARCHAR(100),              -- 산행 일지 제목
    journal_text TEXT,                       -- 따뜻한 인사말 및 메모
    
    -- ★ PostGIS 핵심: GPS 위도/경도 공간 좌표점 (SRID 4326 - WGS84 Standard)
    location_point GEOMETRY(Point, 4326) NOT NULL,
    location_name VARCHAR(100),              -- 장소명 (예: 북한산 둘레길 산책로)
    
    is_public BOOLEAN DEFAULT TRUE,          -- 공개 여부 (모두의 정원 vs 비밀 수첩)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ★ 위치 기반 반경 검색 속도 100배 최적화를 위한 GIST 공간 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_flower_location_gist ON public.flower_discoveries USING GIST (location_point);

-- 5. 감성 소셜 리액션 테이블 (🌸 따뜻해요, 🌿 예뻐요, ⭐ 신기해요)
CREATE TABLE IF NOT EXISTS public.social_reactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    discovery_id UUID REFERENCES public.flower_discoveries(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    reaction_type VARCHAR(20) CHECK (reaction_type IN ('WARM_FLOWER', 'PRETTY_LEAF', 'WONDER_STAR')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uniq_user_reaction UNIQUE(discovery_id, user_id, reaction_type)
);

-- =================================================================
-- 🌱 초기 시드 데이터 (테스트 및 검증용 우리 야생화 5종 기본 삽입)
-- =================================================================
INSERT INTO public.flowers_encyclopedia (korean_name, scientific_name, flower_language, description, blooming_season, rarity_tier)
VALUES 
('진달래', 'Rhododendron mucronulatum', '사랑의 기쁨, 절제된 아름다움', '봄철 온 산을 분홍빛으로 물들이는 우리와 가장 친숙한 봄꽃입니다.', '봄 (3월~4월)', '친근한꽃'),
('개망초', 'Erigeron annuus', '화해, 맑은 마음', '길가나 산책로 어디서든 계란프라이 모양으로 예쁘게 피어나는 흰 꽃입니다.', '여름 (6월~8월)', '친근한꽃'),
('금강초롱꽃', 'Hanabusaya asiatica', '각별한 사랑, 든든한 마음', '세계에서 오직 한국의 고산지대에서만 피어나는 매우 자랑스럽고 귀한 특산 야생화입니다.', '여름~가을 (8월~9월)', '귀한특산식물'),
('노랑매미꽃', 'Hylomecon vernalis', '봄날의 희망, 서정', '깊은 산 속 계곡가 주변에서 맑은 노란빛으로 피어나는 매력적인 봄꽃입니다.', '봄 (4월~5월)', '계절의보물'),
('솜다리 (에델바이스)', 'Leontopodium coreanum', '소중한 추억, 고결한 용기', '한라산과 설악산 등 높고 깊은 산 정상 부근 바위틈에서 피어나는 전설적인 흰꽃입니다.', '여름 (7월~8월)', '귀한특산식물')
ON CONFLICT (scientific_name) DO NOTHING;
