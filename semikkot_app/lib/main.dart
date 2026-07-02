import 'package:flutter/material.dart';

void main() {
  runApp(const SemikkotApp());
}

class SemikkotApp extends StatelessWidget {
  const SemikkotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '세미꽃 (이 세상에 미운 꽃은 없다)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 4060 맞춤 눈 편한 크림 웜톤 배경 및 살구분홍/산들민트 포인트 컬러
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        primaryColor: const Color(0xFFFF8896), // 살구분홍 (Peach Pink)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8896),
          primary: const Color(0xFFFF8896),
          secondary: const Color(0xFF6BB392), // 산들바람 민트 (Sage Mint)
          surface: const Color(0xFFFDFBF7),
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const SemikkotHome(),
    );
  }
}

class SemikkotHome extends StatefulWidget {
  const SemikkotHome({super.key});

  @override
  State<SemikkotHome> createState() => _SemikkotHomeState();
}

class _SemikkotHomeState extends State<SemikkotHome> {
  int _currentIndex = 0;

  // 도커 DB에서 적재된 우리 야생화 시드 데이터 예시 (4060 맞춤 큰 글씨 표현)
  final List<Map<String, String>> _flowers = [
    {
      'name': '진달래',
      'sciName': 'Rhododendron mucronulatum',
      'lang': '💌 사랑의 기쁨, 절제된 아름다움',
      'desc': '봄철 온 산을 분홍빛으로 물들이는 우리와 가장 친숙한 봄꽃입니다.',
      'season': '봄 (3월~4월)',
      'place': '📍 북한산 둘레길 산책로에서 만남',
      'date': '🗓️ 2026년 7월 2일 기록',
    },
    {
      'name': '노랑매미꽃',
      'sciName': 'Hylomecon vernalis',
      'lang': '💌 봄날의 희망, 따뜻한 서정',
      'desc': '깊은 산 속 계곡가 주변에서 맑은 노란빛으로 피어나는 매력적인 봄꽃입니다.',
      'season': '봄 (4월~5월)',
      'place': '📍 청계산 계곡 산책로 옆',
      'date': '🗓️ 2026년 6월 28일 기록',
    },
    {
      'name': '금강초롱꽃',
      'sciName': 'Hanabusaya asiatica',
      'lang': '💌 각별한 사랑, 든든한 마음',
      'desc': '오직 한국의 고산지대에서만 피어나는 매우 자랑스럽고 귀한 특산 야생화입니다.',
      'season': '여름~가을 (8월~9월)',
      'place': '📍 설악산 대청봉 숲길',
      'date': '🗓️ 2026년 6월 15일 기록',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Text(
              '🌸 세미꽃',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6BB392).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '4060 산행 수첩',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D6A4F),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 28, color: Color(0xFF555555)),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFF8896),
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded, size: 28), label: '나의 수첩'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded, size: 32), label: '꽃 돋보기'),
            BottomNavigationBarItem(icon: Icon(Icons.share_rounded, size: 28), label: '카톡 아침인사'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) return _buildJournalTab();
    if (_currentIndex == 1) return _buildScannerTab();
    return _buildKakaoCardTab();
  }

  // 1. 나의 야생화 수첩 탭
  Widget _buildJournalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8896), Color(0xFFFFB3BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0xFFFF8896).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌿 이번 주말 산행 발자취',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '총 25종의 우리 꽃과\n따뜻한 인사를 나눴어요!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildBadge('🌸 진달래 마스터'),
                  const SizedBox(width: 8),
                  _buildBadge('🏔️ 둘레길 단골'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '📖 최근 만난 꽃 일지',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 12),
        ..._flowers.map((f) => _buildFlowerCard(f)),
      ],
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFlowerCard(Map<String, String> f) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  f['name']!,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6BB392).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    f['season']!,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D6A4F)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              f['sciName']!,
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFF8896).withValues(alpha: 0.3)),
              ),
              child: Text(
                f['lang']!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE56B78)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              f['desc']!,
              style: const TextStyle(fontSize: 15, color: Color(0xFF555555), height: 1.4),
            ),
            const Divider(height: 24, color: Color(0xFFEEEEEE)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(f['place']!, style: const TextStyle(fontSize: 13, color: Color(0xFF777777), fontWeight: FontWeight.w500)),
                Text(f['date']!, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. 따뜻한 AI 꽃 돋보기 탭
  Widget _buildScannerTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF6BB392).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded, size: 80, color: Color(0xFF6BB392)),
            ),
            const SizedBox(height: 24),
            const Text(
              '🔍 따뜻한 AI 꽃 돋보기',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 12),
            const Text(
              '산책이나 등산길에서 만난 꽃에\n카메라를 비추면 이름과 꽃말이 1초 만에 짠!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🌸 [데모] 카메라가 열리고 1초 만에 "진달래"를 인식합니다!'),
                      backgroundColor: Color(0xFF6BB392),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt_rounded, size: 28, color: Colors.white),
                label: const Text(
                  '꽃 사진 찍고 이름 찾기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8896),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. 카카오톡 아침 인사 엽서 탭
  Widget _buildKakaoCardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '💌 카카오톡 아침 인사 엽서',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 8),
        const Text(
          '내가 산에서 찍은 꽃 사진과 꽃말을 담아\n지인들에게 따뜻한 아침 안부를 보내보세요!',
          style: TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.4),
        ),
        const SizedBox(height: 20),
        // 엽서 미리보기 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFE066), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Color(0xFFFEE500), shape: BoxShape.circle),
                    child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF381E1F), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '카카오톡 안부 메시지 템플릿',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF381E1F)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB3BA), Color(0xFFFFDFDF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🌸\n[ 북한산에서 만난 진달래 ]', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '💌 오늘의 꽃말 선물: "사랑의 기쁨"',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE56B78)),
              ),
              const SizedBox(height: 8),
              const Text(
                '"좋은 아침입니다! 오늘 아침 산길에서 만난 예쁜 진달래와 따뜻한 꽃말을 선물합니다. 오늘도 환하고 행복한 하루 되세요~! 🌸"\n- 북한산에서 지훈님이 보냄 -',
                style: TextStyle(fontSize: 15, color: Color(0xFF444444), height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                child: const Center(
                  child: Text('🌸 나도 예쁜 꽃 수첩 만들러 가기 (앱 시작)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('💛 [카카오톡 공유] 단톡방 및 친구에게 예쁜 꽃말 엽서가 전송되었습니다!'),
                  backgroundColor: Color(0xFF381E1F),
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 24, color: Color(0xFF381E1F)),
            label: const Text(
              '카카오톡으로 꽃말 엽서 보내기 (1초)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF381E1F)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
