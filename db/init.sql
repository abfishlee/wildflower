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
    identification_attempt_id UUID,
    identification_confidence NUMERIC(5,2) CHECK (identification_confidence >= 0 AND identification_confidence <= 100),
    confirmed_by_user BOOLEAN DEFAULT TRUE,
    training_ready BOOLEAN DEFAULT FALSE,
    
    -- ★ PostGIS 핵심: GPS 위도/경도 공간 좌표점 (SRID 4326 - WGS84 Standard)
    location_point GEOMETRY(Point, 4326) NOT NULL,
    location_name VARCHAR(100),              -- 장소명 (예: 북한산 둘레길 산책로)
    
    is_public BOOLEAN DEFAULT TRUE,          -- 공개 여부 (모두의 정원 vs 비밀 수첩)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.flower_discoveries
ADD COLUMN IF NOT EXISTS identification_attempt_id UUID,
ADD COLUMN IF NOT EXISTS identification_confidence NUMERIC(5,2) CHECK (identification_confidence >= 0 AND identification_confidence <= 100),
ADD COLUMN IF NOT EXISTS confirmed_by_user BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS training_ready BOOLEAN DEFAULT FALSE;

-- ★ 위치 기반 반경 검색 속도 100배 최적화를 위한 GIST 공간 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_flower_location_gist ON public.flower_discoveries USING GIST (location_point);
CREATE INDEX IF NOT EXISTS idx_flower_discoveries_training_ready ON public.flower_discoveries(training_ready);

-- 5. 사진 식별 시도 로그 테이블 (AI/API + 우리 도감 DB 매칭 파이프라인)
CREATE TABLE IF NOT EXISTS public.flower_identification_attempts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    source_type VARCHAR(20) CHECK (source_type IN ('CAMERA', 'GALLERY', 'MOCK')) NOT NULL,
    source_photo_url TEXT,
    location_point GEOMETRY(Point, 4326),
    region_name VARCHAR(50),
    model_provider VARCHAR(50),              -- 예: PlantNet, iNaturalist, 자체모델 등
    model_version VARCHAR(80),
    status VARCHAR(20) DEFAULT 'MATCHED' CHECK (status IN ('PENDING', 'MATCHED', 'FAILED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_identification_attempt_region ON public.flower_identification_attempts(region_name);
CREATE INDEX IF NOT EXISTS idx_identification_attempt_location_gist ON public.flower_identification_attempts USING GIST (location_point);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_flower_discoveries_identification_attempt'
    ) THEN
        ALTER TABLE public.flower_discoveries
        ADD CONSTRAINT fk_flower_discoveries_identification_attempt
        FOREIGN KEY (identification_attempt_id)
        REFERENCES public.flower_identification_attempts(id)
        ON DELETE SET NULL;
    END IF;
END $$;

-- 6. 식별 후보 테이블 (모델 후보 + 우리 DB 재랭킹 결과)
CREATE TABLE IF NOT EXISTS public.flower_identification_candidates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    attempt_id UUID REFERENCES public.flower_identification_attempts(id) ON DELETE CASCADE,
    flower_id INTEGER REFERENCES public.flowers_encyclopedia(id),
    candidate_rank INTEGER NOT NULL,
    confidence NUMERIC(5,2) CHECK (confidence >= 0 AND confidence <= 100),
    match_reason TEXT,                       -- 예: 지역/계절/희귀도 기반 재랭킹 근거
    selected_by_user BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uniq_attempt_rank UNIQUE(attempt_id, candidate_rank)
);

CREATE INDEX IF NOT EXISTS idx_identification_candidates_attempt ON public.flower_identification_candidates(attempt_id);
CREATE INDEX IF NOT EXISTS idx_identification_candidates_flower ON public.flower_identification_candidates(flower_id);

-- 7. 사용자 확정 라벨 기반 학습 데이터 후보 테이블
CREATE TABLE IF NOT EXISTS public.training_photo_candidates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    attempt_id UUID REFERENCES public.flower_identification_attempts(id) ON DELETE CASCADE,
    discovery_id UUID REFERENCES public.flower_discoveries(id) ON DELETE SET NULL,
    confirmed_flower_id INTEGER REFERENCES public.flowers_encyclopedia(id),
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    photo_url TEXT NOT NULL,
    confidence NUMERIC(5,2) CHECK (confidence >= 0 AND confidence <= 100),
    confirmed_by_user BOOLEAN DEFAULT TRUE,
    review_status VARCHAR(20) DEFAULT 'NEEDS_REVIEW' CHECK (review_status IN ('NEEDS_REVIEW', 'APPROVED', 'REJECTED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_training_photo_candidates_flower ON public.training_photo_candidates(confirmed_flower_id);
CREATE INDEX IF NOT EXISTS idx_training_photo_candidates_status ON public.training_photo_candidates(review_status);

-- 8. 감성 소셜 리액션 테이블 (🌸 따뜻해요, 🌿 예뻐요, ⭐ 신기해요)
CREATE TABLE IF NOT EXISTS public.social_reactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    discovery_id UUID REFERENCES public.flower_discoveries(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    reaction_type VARCHAR(20) CHECK (reaction_type IN ('WARM_FLOWER', 'PRETTY_LEAF', 'WONDER_STAR')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uniq_user_reaction UNIQUE(discovery_id, user_id, reaction_type)
);

-- 9. 꽃밭 댓글 테이블 (가벼운 소통)
CREATE TABLE IF NOT EXISTS public.flower_comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    discovery_id UUID REFERENCES public.flower_discoveries(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_flower_comments_discovery ON public.flower_comments(discovery_id);
CREATE INDEX IF NOT EXISTS idx_flower_comments_created_at ON public.flower_comments(created_at DESC);

-- 10. 운영/학습 파이프라인 조회 뷰
CREATE OR REPLACE VIEW public.vw_training_dataset_queue AS
SELECT
    t.id AS training_candidate_id,
    t.review_status,
    t.photo_url,
    t.confidence,
    t.confirmed_by_user,
    t.created_at,
    t.reviewed_at,
    f.id AS flower_id,
    f.korean_name,
    f.scientific_name,
    f.rarity_tier,
    d.id AS discovery_id,
    d.location_name,
    d.identification_confidence,
    u.id AS user_id,
    u.nickname
FROM public.training_photo_candidates t
LEFT JOIN public.flowers_encyclopedia f ON f.id = t.confirmed_flower_id
LEFT JOIN public.flower_discoveries d ON d.id = t.discovery_id
LEFT JOIN public.users u ON u.id = t.user_id
ORDER BY t.created_at DESC;

CREATE OR REPLACE VIEW public.vw_flower_collection_stats AS
SELECT
    f.id AS flower_id,
    f.korean_name,
    f.scientific_name,
    f.rarity_tier,
    COUNT(d.id) AS discovery_count,
    COUNT(d.id) FILTER (WHERE d.is_public = TRUE) AS public_discovery_count,
    COUNT(d.id) FILTER (WHERE d.training_ready = TRUE) AS training_ready_count,
    AVG(d.identification_confidence) AS avg_identification_confidence,
    COUNT(DISTINCT d.user_id) AS collector_count
FROM public.flowers_encyclopedia f
LEFT JOIN public.flower_discoveries d ON d.flower_id = f.id
GROUP BY f.id, f.korean_name, f.scientific_name, f.rarity_tier
ORDER BY discovery_count DESC, f.korean_name ASC;

CREATE OR REPLACE VIEW public.vw_region_collection_progress AS
SELECT
    COALESCE(NULLIF(TRIM(d.location_name), ''), '미지정') AS region_name,
    COUNT(d.id) AS collected_count,
    COUNT(DISTINCT d.flower_id) AS unique_flower_count,
    COUNT(d.id) FILTER (WHERE d.is_public = TRUE) AS public_card_count,
    COUNT(d.id) FILTER (WHERE d.training_ready = TRUE) AS training_ready_count,
    MAX(d.created_at) AS last_collected_at
FROM public.flower_discoveries d
GROUP BY COALESCE(NULLIF(TRIM(d.location_name), ''), '미지정')
ORDER BY collected_count DESC, region_name ASC;

CREATE OR REPLACE VIEW public.vw_public_flowerbed_cards AS
SELECT
    d.id AS discovery_id,
    d.photo_url,
    d.journal_title,
    d.journal_text,
    d.location_name,
    d.created_at,
    d.identification_confidence,
    f.id AS flower_id,
    f.korean_name,
    f.scientific_name,
    f.flower_language,
    f.blooming_season,
    f.rarity_tier,
    u.id AS user_id,
    u.nickname,
    COUNT(DISTINCT r.id) AS reaction_count,
    COUNT(DISTINCT c.id) AS comment_count
FROM public.flower_discoveries d
LEFT JOIN public.flowers_encyclopedia f ON f.id = d.flower_id
LEFT JOIN public.users u ON u.id = d.user_id
LEFT JOIN public.social_reactions r ON r.discovery_id = d.id
LEFT JOIN public.flower_comments c ON c.discovery_id = d.id
WHERE d.is_public = TRUE
GROUP BY
    d.id,
    f.id,
    f.korean_name,
    f.scientific_name,
    f.flower_language,
    f.blooming_season,
    f.rarity_tier,
    u.id,
    u.nickname
ORDER BY d.created_at DESC;

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
