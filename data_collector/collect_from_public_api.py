# =================================================================
# 🌸 세미꽃 (Semikkot) - 공공데이터포털 야생화 및 꽃말 자동 수집기
# =================================================================
import os
import sys
import urllib.request
import urllib.parse
import xml.etree.ElementTree as ET
import psycopg2
from psycopg2.extras import execute_values
import io

# 윈도우 파워쉘(cp949) 환경에서 이모지 출력 시 발생하는 인코딩 에러 방지
if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
if sys.stderr.encoding != 'utf-8':
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

# 1. 로컬 도커 PostgreSQL 연결 정보
DB_HOST = "localhost"
DB_PORT = "55432"
DB_NAME = "semikkot"
DB_USER = "postgres"
DB_PASSWORD = "semikkot_password_2026"

# 2. 공공데이터포털(data.go.kr) 농촌진흥청 '오늘의 꽃 조회 서비스' API 인증키
# ※ 본인의 인증키가 발급되기 전이라면 빈 문자열("")로 두세요. (오프라인 모드 자동 동작)
PUBLIC_API_KEY = ""  # 예: "aB1cD2eF3gH4..."

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        return conn
    except Exception as e:
        print(f"❌ [오류] PostgreSQL DB 연결 실패: {e}")
        print("💡 팁: 도커 컨테이너(semikkot-postgis)가 5432 포트에서 실행 중인지 확인하세요.")
        sys.exit(1)

def seed_extended_mock_flowers(conn):
    """API 키가 없을 때도 개발 및 테스트가 가능하도록 한국 대표 야생화 20종을 대거 추가합니다."""
    print("\n🌱 [테스트 모드] 공공데이터 API 키가 없거나 연결 전이므로, 한국 대표 야생화 20종 데이터셋을 DB에 적재합니다.")
    
    mock_flowers = [
        ('개나리', 'Forsythia koreana', '희망, 깊은 사랑, 기대', '봄날 이른 시기에 가장 먼저 노란 꽃망울을 터뜨리는 희망의 상징입니다.', '봄 (3월~4월)', '친근한꽃', ''),
        ('벚꽃', 'Prunus serrulata', '순결, 절세미인, 정신의 아름다움', '봄바람에 흩날리는 연분홍 꽃잎이 환상적인 봄날 산책길의 주인공입니다.', '봄 (4월)', '친근한꽃', ''),
        ('철쭉', 'Rhododendron schlippenbachii', '사랑의 즐거움, 열정', '진달래가 질 무렵 산 중턱을 화려한 핑크빛으로 물들이는 대표적인 산행 야생화입니다.', '봄 (4월~5월)', '친근한꽃', ''),
        ('동백꽃', 'Camellia japonica', '그 누구보다 당신을 사랑합니다, 신중', '한겨울 눈 속에서도 붉고 매혹적인 꽃을 피우는 절개의 꽃입니다.', '겨울~봄 (11월~4월)', '계절의보물', ''),
        ('무궁화', 'Hibiscus syriacus', '영원히 피고 또 피어서 지지 않는 꽃, 일편단심', '여름철 100일 동안 매일 새로운 꽃을 끈기 있게 피우는 자랑스러운 우리 나라꽃입니다.', '여름~가을 (7월~10월)', '친근한꽃', ''),
        ('수국', 'Hydrangea macrophylla', '진심, 변덕, 변함없는 사랑', '토양의 산도에 따라 파란색, 분홍색, 보라색으로 색이 변하는 매혹적인 여름 꽃입니다.', '여름 (6월~7월)', '계절의보물', ''),
        ('민들레', 'Taraxacum officinale', '감사하는 마음, 행복, 진유', '도심지 아스팔트 틈새에서도 꿋꿋하게 피어나 희망의 민들레 홀씨를 날리는 꽃입니다.', '봄 (4월~5월)', '친근한꽃', ''),
        ('붓꽃 (아이리스)', 'Iris sanguinea', '기쁜 소식, 좋은 소식', '꽃봉오리가 마치 먹을 머금은 붓의 모습과 닮았다고 하여 붙여진 우아한 보라색 꽃입니다.', '여름 (5월~6월)', '계절의보물', ''),
        ('은방울꽃', 'Convallaria majalis', '틀림없이 행복해집니다, 순결', '작고 하얀 종 모양의 꽃이 조롱조롱 매달려 달콤하고 은은한 향기를 풍기는 귀한 꽃입니다.', '봄 (5월)', '귀한특산식물', ''),
        ('도라지꽃', 'Platycodon grandiflorus', '영원한 사랑, 성실, 변치 않는 마음', '여름철 깊은 산이나 들에서 보라색과 하얀색 별 모양으로 맑게 피어나는 꽃입니다.', '여름 (7월~8월)', '친근한꽃', ''),
        ('구절초', 'Chrysanthemum zawadskii', '어머니의 사랑, 순수, 우아함', '가을 산행 길목마다 하얗고 청초한 모습으로 등산객을 반겨주는 대표적인 가을 야생화입니다.', '가을 (9월~10월)', '친근한꽃', ''),
        ('코스모스', 'Cosmos bipinnatus', '소녀의 순정, 진심, 화해', '파란 가을 하늘 아래 바람에 하늘하늘 흔들리며 가을의 정취를 더해주는 꽃입니다.', '가을 (8월~10월)', '친근한꽃', ''),
        ('초롱꽃', 'Campanula punctata', '충실, 정의, 감사', '옛날 산길을 밝혀주던 청사초롱을 닮은 은은하고 품위 있는 우리 야생화입니다.', '여름 (6월~8월)', '계절의보물', ''),
        ('복수초', 'Adonis amurensis', '영원한 행복, 슬픈 추억', '이른 봄 눈이 채 녹기도 전에 얼음을 뚫고 황금빛 꽃을 피워내는 서곡 같은 꽃입니다.', '봄 (2월~4월)', '귀한특산식물', ''),
        ('바람꽃', 'Anemone raddeana', '비밀의 사랑, 사랑의 괴로움', '봄바람이 불 때 숲속 그늘에서 잠시 피었다가 사라지는 신비롭고 청초한 꽃입니다.', '봄 (4월)', '계절의보물', ''),
        ('해국', 'Aster spathulifolius', '기다림, 침묵', '바닷가 절벽이나 거친 바위틈에서 거친 해풍을 견디며 연보라색 꽃을 피우는 강인한 꽃입니다.', '가을 (9월~11월)', '계절의보물', ''),
        ('산수유', 'Cornus officinalis', '영원불변의 사랑, 지속', '봄이 오면 산과 마을 전체를 노란 황금빛 구름처럼 덮어버리는 반가운 봄 사자입니다.', '봄 (3월)', '친근한꽃', ''),
        ('목련', 'Magnolia kobus', '고귀함, 숭고한 사랑, 자연애', '봄날 파란 하늘을 향해 하얗고 탐스러운 큰 꽃잎을 우아하게 펼쳐 보이는 꽃입니다.', '봄 (3월~4월)', '친근한꽃', ''),
        ('투구꽃', 'Aconitum jaluense', '나를 건드리지 마세요, 밤의 열림', '꽃 모양이 옛 무사들이 쓰던 투구를 닮았으며, 깊은 산속에서 신비로운 보라빛을 냅니다.', '가을 (9월~10월)', '귀한특산식물', ''),
        ('참나리', 'Lilium lancifolium', '순결, 깨끗한 마음, 웅대', '한여름 산길에서 주황색 꽃잎에 검은 반점을 찍고 화려하게 피어나는 우리나라 원추리꽃입니다.', '여름 (7월~8월)', '친근한꽃', '')
    ]
    
    with conn.cursor() as cur:
        query = """
            INSERT INTO public.flowers_encyclopedia 
            (korean_name, scientific_name, flower_language, description, blooming_season, rarity_tier, default_image_url)
            VALUES %s
            ON CONFLICT (scientific_name) DO UPDATE SET
                flower_language = EXCLUDED.flower_language,
                description = EXCLUDED.description;
        """
        execute_values(cur, query, mock_flowers)
        conn.commit()
    print(f"✅ 총 {len(mock_flowers)}종의 우리 야생화 도감 데이터가 DB에 성공적으로 적재(Upsert)되었습니다!\n")

def fetch_from_data_go_kr(conn, api_key):
    """공공데이터포털 농촌진흥청 오늘의 꽃 API 실시간 조회"""
    print(f"\n🌐 [공공데이터 실시간 수집] 농촌진흥청 '오늘의 꽃 조회 서비스' 연동을 시작합니다...")
    # 구현 예시: 1월 1일 ~ 1월 31일 꽃말 수집 (테스트용 1달치)
    base_url = "http://api.nongsaro.go.kr/service/todayFlower/todayFlowerList"
    
    with conn.cursor() as cur:
        success_count = 0
        for day in range(1, 32):
            f_month = "04"  # 4월 봄꽃 기준
            f_day = str(day).zfill(2)
            url = f"{base_url}?apiKey={api_key}&fMonth={f_month}&fDay={f_day}"
            try:
                req = urllib.request.Request(url)
                with urllib.request.urlopen(req) as response:
                    xml_data = response.read().decode('utf-8')
                
                root = ET.fromstring(xml_data)
                items = root.findall('.//item')
                for item in items:
                    flow_nm = item.find('flowNm').text if item.find('flowNm') is not None else ""
                    f_sci_nm = item.find('fSciNm').text if item.find('fSciNm') is not None else ""
                    flow_lang = item.find('flowLang').text if item.find('flowLang') is not None else ""
                    f_content = item.find('fContent').text if item.find('fContent') is not None else ""
                    
                    if flow_nm and f_sci_nm:
                        cur.execute("""
                            INSERT INTO public.flowers_encyclopedia 
                            (korean_name, scientific_name, flower_language, description, blooming_season, rarity_tier)
                            VALUES (%s, %s, %s, %s, %s, %s)
                            ON CONFLICT (scientific_name) DO UPDATE SET
                                flower_language = EXCLUDED.flower_language;
                        """, (flow_nm, f_sci_nm, flow_lang, f_content, "봄 (4월)", "친근한꽃"))
                        success_count += 1
                        print(f"  └ [수집 완료] {flow_nm} ({f_sci_nm}) - 꽃말: {flow_lang}")
            except Exception as e:
                pass
        conn.commit()
    print(f"🎉 실시간 공공데이터 수집 완료! 총 {success_count}건 추가되었습니다.")

def main():
    print("=================================================================")
    print("         🌸 세미꽃 야생화 데이터 수집 및 DB 적재 마법사")
    print("=================================================================")
    
    conn = get_db_connection()
    print("✅ 로컬 PostgreSQL (semikkot) 데이터베이스 연결 성공!")
    
    # API 키 확인 후 분기 처리
    api_key = PUBLIC_API_KEY.strip() or os.environ.get("PUBLIC_API_KEY", "").strip()
    
    if not api_key:
        print("\n⚠️ [알림] 공공데이터포털(data.go.kr) 인증키가 설정되지 않았습니다.")
        print("   현재 단계에서는 개발 및 UI 시연을 위해 '한국 대표 야생화 20종 데이터셋'으로 DB를 채웁니다.")
        seed_extended_mock_flowers(conn)
    else:
        seed_extended_mock_flowers(conn)  # 기본 20종 먼저 넣고
        fetch_from_data_go_kr(conn, api_key) # 실제 API로 확장
        
    # 적재된 데이터 수 확인
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*), COUNT(DISTINCT rarity_tier) FROM public.flowers_encyclopedia;")
        total_count, tier_count = cur.fetchone()
        print("-----------------------------------------------------------------")
        print(f"📊 [현재 DB 현황] 총 {total_count} 종의 야생화가 {tier_count}개 분류로 적재되어 있습니다.")
        print("-----------------------------------------------------------------\n")
        
    conn.close()
    print("🚀 데이터 수집 1단계가 완료되었습니다! 이제 Flutter 앱에서 DB 데이터를 불러올 준비가 끝났습니다.")

if __name__ == "__main__":
    main()
