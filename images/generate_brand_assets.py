import os
import sys
from PIL import Image

def create_transparent_and_icons():
    print("🎨 [NatureCode] 브랜드 디자인 에셋 변환 및 생성을 시작합니다...")
    
    src_path = r"E:\dev\wildflower\images\naturecode_logo_sketch_2.png"
    out_dir = r"E:\dev\wildflower\images\brand_assets"
    
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
        
    if not os.path.exists(src_path):
        print(f"❌ 원본 이미지 파일을 찾을 수 없습니다: {src_path}")
        return

    # 1. 원본 이미지 로드
    img = Image.open(src_path).convert("RGBA")
    w, h = img.size
    
    # 2. 배경 투명화 처리 (흰색/밝은 배경을 투명 채널로 변환)
    print("🌟 1. 배경 투명 PNG (Transparent PNG) 변환 중...")
    datas = img.getdata()
    newData = []
    for item in datas:
        # RGB가 모두 240 이상(흰색 바탕)이면 투명도(Alpha)를 0으로 설정
        if item[0] > 235 and item[1] > 235 and item[2] > 235:
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)
    
    transparent_img = Image.new("RGBA", (w, h))
    transparent_img.putdata(newData)
    
    transparent_path = os.path.join(out_dir, "naturecode_logo_transparent.png")
    transparent_img.save(transparent_path, "PNG")
    print(f"  └ ✅ 투명 로고 저장 완료: {transparent_path}")
    
    # 3. 앱 및 웹용 다양한 크기 아이콘 생성
    icon_sizes = [
        (512, 512, "app_icon_512x512.png", "안드로이드 / 구글 플레이스토어 원본 아이콘"),
        (192, 192, "app_icon_192x192.png", "PWA 및 안드로이드 홈 화면 아이콘"),
        (180, 180, "apple_touch_icon_180x180.png", "iOS 아이폰 홈 화면 아이콘"),
        (64, 64,   "favicon_64x64.png",       "웹사이트 탭 고화질 파비콘"),
        (32, 32,   "favicon_32x32.png",       "웹사이트 기본 파비콘")
    ]
    
    print("\n📱 2. 모바일 앱 & 웹 파비콘 해상도별 리사이징 중...")
    for width, height, filename, desc in icon_sizes:
        resized = img.resize((width, height), Image.Resampling.LANCZOS)
        out_path = os.path.join(out_dir, filename)
        resized.save(out_path, "PNG")
        print(f"  └ ✅ [{width}x{height}] {filename} ({desc})")
        
    # 4. 웹 표준 벡터 SVG 파일 생성 (확대해도 절대 깨지지 않는 XML 코드 기반 로고)
    print("\n📐 3. 웹 및 인쇄용 무한 확대 SVG 벡터 파일 생성 중...")
    svg_content = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500" width="100%" height="100%">
  <defs>
    <style>
      .text-hello { font-family: 'Pretendard', 'Arial', sans-serif; font-size: 38px; font-weight: 700; fill: #2D6A4F; text-anchor: middle; }
      .text-sub { font-family: 'Pretendard', 'Arial', sans-serif; font-size: 18px; font-weight: 500; fill: #6BB392; text-anchor: middle; letter-spacing: 2px; }
      .leaf-stroke { fill: none; stroke: #2D6A4F; stroke-width: 24; stroke-linecap: round; }
      .leaf-accent { fill: none; stroke: #6BB392; stroke-width: 18; stroke-linecap: round; }
    </style>
  </defs>
  
  <!-- 배경 (투명 또는 흰색) -->
  <rect width="100%" height="100%" fill="transparent"/>
  
  <!-- 코딩 소괄호 ( ) 모양의 두 잎사귀 실루엣 (NatureCode 철학) -->
  <g transform="translate(0, -30)">
    <!-- 왼쪽 괄호 잎사귀 ( -->
    <path d="M 210 140 C 130 200, 130 300, 210 360" class="leaf-stroke"/>
    <!-- 오른쪽 괄호 잎사귀 ) -->
    <path d="M 290 140 C 370 200, 370 300, 290 360" class="leaf-stroke"/>
    
    <!-- 안쪽 성장하는 새싹 포인트 -->
    <path d="M 250 320 Q 250 240, 220 200" class="leaf-accent"/>
    <path d="M 250 320 Q 250 260, 280 230" class="leaf-accent"/>
    <circle cx="250" cy="325" r="8" fill="#2D6A4F"/>
  </g>
  
  <!-- 하단 Hello World 타이포그래피 -->
  <text x="250" y="420" class="text-hello">Hello World</text>
  <text x="250" y="450" class="text-sub">N A T U R E C O D E</text>
</svg>'''
    
    svg_path = os.path.join(out_dir, "naturecode_logo_master.svg")
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg_content)
    print(f"  └ ✅ SVG 벡터 파일 저장 완료: {svg_path}")
    
    print("\n🎉 모든 브랜드 디자인 에셋이 E:\\dev\\wildflower\\images\\brand_assets 폴더에 완벽 생성되었습니다!")

if __name__ == "__main__":
    create_transparent_and_icons()
