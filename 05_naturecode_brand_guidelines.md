# 🏛️ 네이처코드 (NatureCode) - 브랜드 아이덴티티 및 디자인 에셋 가이드

> **"사람과 자연을 코드로 연결하는 기업, NatureCode"**  
> 본 문서(`05_naturecode_brand_guidelines.md`)는 네이처코드의 공식 심벌 로고 활용법, 핵심 컬러 파레트, 모바일 앱 및 웹서비스 개발 시 필요한 디자인 파일 규격을 정의합니다.

---

## 1. 브랜드 철학 및 심벌 의미 (Brand Philosophy)

```text
    (        🌱        )
[왼쪽 잎사귀]  [자연/사람]  [오른쪽 잎사귀]
      └─── 코딩 소괄호 ( ) ───┘
            Hello World
```

* **공식 로고 선정작**: `naturecode_logo_sketch_2.png` (두 잎사귀 소괄호 심벌)
* **상징 의미**: 단 두 번의 둥근 곡선 펜 터치로 누구나 쉽게 그릴 수 있는 잎사귀가 코딩 함수 소괄호 `( )` 형태로 성장하는 새싹(자연과 인간)을 따뜻하게 보호하고 연결하는 형상입니다.
* **코어 슬로건**: *"자연에 사람이 친숙하고 더 즐겁게 다가설 수 있는 서비스를 만듭니다."*

---

## 2. 공식 컬러 파레트 (Color Palette)

모바일 앱(`RideKorea`, `세미꽃`, `ArtBob`), 웹사이트, 텀블벅 굿즈, 명함 인쇄 시 아래의 공식 컬러 코드(HEX / RGB)를 엄격히 적용합니다.

| 컬러명 | HEX 코드 | RGB 코드 | 주 용도 |
| :--- | :--- | :--- | :--- |
| **에메랄드 포레스트 그린 (Main)** | `#2D6A4F` | `45, 106, 79` | 로고 심벌 메인, 앱바, 텍스트 강조, 메인 버튼 |
| **세이지 산들바람 민트 (Sub)** | `#6BB392` | `107, 179, 146` | 새싹 포인트, 보조 버튼, 배경 그라데이션, 배지 |
| **크림 웜 화이트 (Background)** | `#FDFBF7` | `253, 251, 247` | 4060 맞춤 눈 편한 배경, 명함 배경, 앱 기본 화면 |
| **차콜 딥 블랙 (Text)** | `#222222` | `34, 34, 34` | 본문 타이포그래피, 가독성 높은 텍스트 |

---

## 3. 브랜드 디자인 파일 패키지 구성 (`brand_assets` 폴더)

`E:\dev\wildflower\images\brand_assets\` 디렉토리에 용도별 최적화된 디자인 파일이 생성되어 있습니다.

### ① 웹 및 인쇄용 원본 벡터 파일 (무한 확대 가능)
* **📄 `naturecode_logo_master.svg`**
  * **설명**: 픽셀이 아닌 수학적 좌표 기반의 표준 XML 벡터 파일입니다.
  * **활용처**: 웹사이트 헤더, 명함/티셔츠/텀블벅 굿즈 실크스크린 고해상도 인쇄, 대형 현수막 제작.

### ② 배경 투명 로고 파일 (합성 및 앱 상단용)
* **🖼️ `naturecode_logo_transparent.png`**
  * **설명**: 흰색 바탕이 제거되고 심벌과 글자만 남은 투명 배경 파일입니다.
  * **활용처**: 앱 헤더바(App Bar), 다크 모드 화면, PPT 발표 자료 합성.

### ③ 모바일 앱 스토어 및 웹 파비콘 해상도별 아이콘
| 파일명 | 해상도 | 공식 용도 및 적용처 |
| :--- | :--- | :--- |
| `app_icon_512x512.png` | 512 x 512 px | 구글 플레이스토어 앱 등록용 원본 아이콘 |
| `app_icon_192x192.png` | 192 x 192 px | 안드로이드 PWA 홈 화면 바로가기 아이콘 |
| `apple_touch_icon_180x180.png` | 180 x 180 px | iOS 아이폰/아이패드 홈 화면 원클릭 아이콘 |
| `favicon_64x64.png` | 64 x 64 px | 웹사이트 브라우저 탭 고화질 파비콘 |
| `favicon_32x32.png` | 32 x 32 px | 웹사이트 브라우저 탭 일반 파비콘 |

---

## 4. 모바일 앱(Flutter / React Native) 적용 예시

Flutter 코드에서 우리 로고 에셋과 컬러를 적용하는 표준 코드입니다:

```dart
// 1. 네이처코드 메인 브랜드 컬러 적용
const Color natureCodeGreen = Color(0xFF2D6A4F);
const Color natureCodeMint = Color(0xFF6BB392);

// 2. 투명 배경 로고를 앱 상단바에 표시
AppBar(
  backgroundColor: const Color(0xFFFDFBF7),
  title: Row(
    children: [
      Image.asset('assets/images/brand_assets/naturecode_logo_transparent.png', height: 32),
      const SizedBox(width: 8),
      const Text('NatureCode', style: TextStyle(color: natureCodeGreen, fontWeight: FontWeight.bold)),
    ],
  ),
);
```
