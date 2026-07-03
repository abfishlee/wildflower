import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const SemikkotApp());
}

class AppColors {
  static const paper = Color(0xFFF8F5EF);
  static const surface = Color(0xFFFFFCF7);
  static const line = Color(0xFFE1D8CB);
  static const ink = Color(0xFF2F332E);
  static const muted = Color(0xFF74796E);
  static const leaf = Color(0xFF4F6F52);
  static const sage = Color(0xFF8EA58A);
  static const moss = Color(0xFFCED9C6);
  static const petal = Color(0xFFD8A39B);
  static const soil = Color(0xFF8B735F);
}

class RegionProgress {
  const RegionProgress({
    required this.name,
    required this.collected,
    required this.total,
    required this.mountain,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final int collected;
  final int total;
  final String mountain;
  final double latitude;
  final double longitude;

  int get remaining => total - collected;
  double get rate => total == 0 ? 0 : collected / total;

  RegionProgress copyWith({int? collected}) {
    return RegionProgress(
      name: name,
      collected: collected ?? this.collected,
      total: total,
      mountain: mountain,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class Wildflower {
  const Wildflower({
    required this.name,
    required this.scientificName,
    required this.season,
    required this.region,
    required this.rarity,
    required this.language,
    required this.description,
    required this.collected,
    required this.imageColor,
    this.memoryTitle,
    this.memoryNote,
    this.collectedDate,
    this.isPublic = false,
    this.waters = 0,
    this.comments = 0,
    this.latestComment,
    this.confirmedByUser = false,
    this.identificationConfidence,
    this.trainingReady = false,
  });

  final String name;
  final String scientificName;
  final String season;
  final String region;
  final int rarity;
  final String language;
  final String description;
  final bool collected;
  final Color imageColor;
  final String? memoryTitle;
  final String? memoryNote;
  final String? collectedDate;
  final bool isPublic;
  final int waters;
  final int comments;
  final String? latestComment;
  final bool confirmedByUser;
  final int? identificationConfidence;
  final bool trainingReady;

  Wildflower copyWith({
    bool? collected,
    String? memoryTitle,
    String? memoryNote,
    String? collectedDate,
    bool? isPublic,
    int? waters,
    int? comments,
    String? latestComment,
    bool? confirmedByUser,
    int? identificationConfidence,
    bool? trainingReady,
  }) {
    return Wildflower(
      name: name,
      scientificName: scientificName,
      season: season,
      region: region,
      rarity: rarity,
      language: language,
      description: description,
      collected: collected ?? this.collected,
      imageColor: imageColor,
      memoryTitle: memoryTitle ?? this.memoryTitle,
      memoryNote: memoryNote ?? this.memoryNote,
      collectedDate: collectedDate ?? this.collectedDate,
      isPublic: isPublic ?? this.isPublic,
      waters: waters ?? this.waters,
      comments: comments ?? this.comments,
      latestComment: latestComment ?? this.latestComment,
      confirmedByUser: confirmedByUser ?? this.confirmedByUser,
      identificationConfidence:
          identificationConfidence ?? this.identificationConfidence,
      trainingReady: trainingReady ?? this.trainingReady,
    );
  }
}

class GardenFilters {
  const GardenFilters({
    this.region = '전체 지역',
    this.season = '전체 계절',
    this.rarity = '전체 희귀도',
    this.query = '',
  });

  final String region;
  final String season;
  final String rarity;
  final String query;

  GardenFilters copyWith({
    String? region,
    String? season,
    String? rarity,
    String? query,
  }) {
    return GardenFilters(
      region: region ?? this.region,
      season: season ?? this.season,
      rarity: rarity ?? this.rarity,
      query: query ?? this.query,
    );
  }
}

class IdentificationCandidate {
  const IdentificationCandidate({
    required this.flower,
    required this.confidence,
    required this.matchReason,
  });

  final Wildflower flower;
  final int confidence;
  final String matchReason;
}

class WildflowerRepository {
  const WildflowerRepository();

  List<RegionProgress> loadRegions() {
    return const [
      RegionProgress(
        name: '강원',
        collected: 12,
        total: 38,
        mountain: '설악산',
        latitude: 37.82,
        longitude: 128.15,
      ),
      RegionProgress(
        name: '경기',
        collected: 9,
        total: 30,
        mountain: '북한산',
        latitude: 37.41,
        longitude: 127.52,
      ),
      RegionProgress(
        name: '충북',
        collected: 5,
        total: 22,
        mountain: '속리산',
        latitude: 36.80,
        longitude: 127.70,
      ),
      RegionProgress(
        name: '경북',
        collected: 8,
        total: 34,
        mountain: '주왕산',
        latitude: 36.58,
        longitude: 128.75,
      ),
      RegionProgress(
        name: '전북',
        collected: 4,
        total: 21,
        mountain: '덕유산',
        latitude: 35.72,
        longitude: 127.15,
      ),
      RegionProgress(
        name: '전남',
        collected: 7,
        total: 29,
        mountain: '무등산',
        latitude: 34.95,
        longitude: 126.99,
      ),
      RegionProgress(
        name: '제주',
        collected: 3,
        total: 18,
        mountain: '한라산',
        latitude: 33.38,
        longitude: 126.53,
      ),
    ];
  }

  List<Wildflower> loadFlowers() {
    return const [
      Wildflower(
        name: '진달래',
        scientificName: 'Rhododendron mucronulatum',
        season: '봄',
        region: '강원',
        rarity: 2,
        language: '사랑의 기쁨, 절제된 아름다움',
        description: '봄철 산길을 연한 분홍빛으로 물들이는 친근한 우리 꽃입니다.',
        collected: true,
        imageColor: Color(0xFFD8A39B),
        memoryTitle: '설악산에서',
        memoryNote: '맑은 바람이 부는 능선에서 조용히 만난 첫 봄꽃.',
        collectedDate: '2026.07.02',
        isPublic: true,
        waters: 24,
        comments: 3,
      ),
      Wildflower(
        name: '금강초롱꽃',
        scientificName: 'Hanabusaya asiatica',
        season: '여름',
        region: '강원',
        rarity: 5,
        language: '각별한 사랑, 든든한 마음',
        description: '한국 고산지대에서 만날 수 있는 귀한 특산 야생화입니다.',
        collected: false,
        imageColor: Color(0xFF8EA58A),
      ),
      Wildflower(
        name: '노랑매미꽃',
        scientificName: 'Hylomecon vernalis',
        season: '봄',
        region: '충북',
        rarity: 3,
        language: '봄날의 희망, 따뜻한 서정',
        description: '깊은 산 계곡가에서 맑은 노란빛으로 피어나는 봄꽃입니다.',
        collected: true,
        imageColor: Color(0xFFD6B969),
        memoryTitle: '속리산에서',
        memoryNote: '새해를 맞이하는 길에 만난 작은 친구.',
        collectedDate: '2026.06.28',
        isPublic: false,
        waters: 8,
        comments: 1,
      ),
      Wildflower(
        name: '솜다리',
        scientificName: 'Leontopodium coreanum',
        season: '여름',
        region: '강원',
        rarity: 5,
        language: '소중한 추억, 고결한 용기',
        description: '높은 산 바위틈에서 피어나는 흰빛의 귀한 야생화입니다.',
        collected: false,
        imageColor: Color(0xFFC7C4B8),
      ),
    ];
  }

  List<IdentificationCandidate> matchPhotoToFlowers({
    required List<Wildflower> flowers,
    required String region,
  }) {
    return flowers
        .where((flower) => !flower.collected && flower.region == region)
        .take(3)
        .map(
          (flower) => IdentificationCandidate(
            flower: flower,
            confidence: flower.rarity >= 5 ? 87 : 94,
            matchReason: '${flower.region} · ${flower.season} · 도감 후보',
          ),
        )
        .toList();
  }
}

class SemikkotApp extends StatelessWidget {
  const SemikkotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '세미꽃',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.leaf,
          primary: AppColors.leaf,
          secondary: AppColors.petal,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.paper,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.line),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.leaf,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.leaf,
            side: const BorderSide(color: AppColors.sage),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
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
  String _selectedRegion = '강원';
  final WildflowerRepository _repository = const WildflowerRepository();
  final ImagePicker _imagePicker = ImagePicker();

  late List<RegionProgress> _regions;
  late List<Wildflower> _flowers;

  @override
  void initState() {
    super.initState();
    _regions = _repository.loadRegions();
    _flowers = _repository.loadFlowers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '세미꽃',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            Text(
              '산길에서 만난 야생화 수집 정원',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _CollectionTab(
            regions: _regions,
            flowers: _flowers,
            selectedRegion: _selectedRegion,
            onRegionSelected:
                (region) => setState(() => _selectedRegion = region),
            onCollect: _pickImageForIdentification,
          ),
          _MyGardenTab(
            flowers: _flowers.where((flower) => flower.collected).toList(),
            onPublish: _confirmPublishFlower,
            onShare: _showShareSheet,
          ),
          _PublicGardenTab(
            flowers: _flowers.where((flower) => flower.isPublic).toList(),
            onWater: _waterFlower,
            onComment: _showCommentDialog,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.moss,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            selectedIcon: Icon(Icons.travel_explore),
            label: '야생화 수집',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: '나의 정원',
          ),
          NavigationDestination(
            icon: Icon(Icons.yard_outlined),
            selectedIcon: Icon(Icons.yard),
            label: '꽃밭',
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageForIdentification(ImageSource source) async {
    final sourceLabel = source == ImageSource.camera ? '촬영한' : '올린';

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 88,
      );

      if (!mounted) return;

      _showIdentificationSheet(
        sourceLabel: sourceLabel,
        imageName: image?.name,
        usedMockFallback: image == null,
      );
    } catch (_) {
      if (!mounted) return;
      _showIdentificationSheet(
        sourceLabel: sourceLabel,
        usedMockFallback: true,
      );
    }
  }

  void _showIdentificationSheet({
    required String sourceLabel,
    String? imageName,
    bool usedMockFallback = false,
  }) {
    final matchCandidates = _repository.matchPhotoToFlowers(
      flowers: _flowers,
      region: _selectedRegion,
    );

    if (matchCandidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_selectedRegion에서 남은 미수집 꽃이 아직 준비되지 않았어요.')),
      );
      return;
    }

    var selectedCandidate = matchCandidates.first;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사진 분석 결과',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$sourceLabel 사진을 앱 도감 DB의 야생화 후보와 대조했어요. 실제 식별 모델/API와 제공처 데이터는 이후 단계에서 연결합니다.',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: AppColors.muted,
                      ),
                    ),
                    if (imageName != null || usedMockFallback) ...[
                      const SizedBox(height: 10),
                      _ImageSourceNotice(
                        imageName: imageName,
                        usedMockFallback: usedMockFallback,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _AnalysisPreview(
                      confidence: selectedCandidate.confidence,
                      sourceLabel: sourceLabel,
                    ),
                    const SizedBox(height: 12),
                    _FlowerCard(
                      flower: selectedCandidate.flower,
                      compact: true,
                      forceCollectedLook: true,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'DB 매칭 후보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...matchCandidates.map(
                      (candidate) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _IdentificationCandidateTile(
                          candidate: candidate,
                          selected:
                              candidate.flower.name ==
                              selectedCandidate.flower.name,
                          onTap:
                              () => setSheetState(
                                () => selectedCandidate = candidate,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            label: const Text('다시 선택'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCollectSheet(selectedCandidate);
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('수집하기'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCollectSheet(IdentificationCandidate candidate) {
    final matchedFlower = candidate.flower;
    final titleController = TextEditingController(
      text: '${matchedFlower.region}에서',
    );
    final noteController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '수집 완료',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${matchedFlower.name}로 보이는 꽃을 찾았어요. 추억을 남기면 나의 정원에 보관됩니다.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              _FlowerCard(
                flower: matchedFlower,
                compact: true,
                forceCollectedLook: true,
              ),
              const SizedBox(height: 12),
              _TrainingDataNotice(candidate: candidate),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '카드 제목',
                  hintText: '예: 속리산에서',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '추억 메모',
                  hintText: '예: 새해를 맞이하는 길에 만난 작은 친구',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  _collectFlower(
                    candidate,
                    titleController.text.trim(),
                    noteController.text.trim(),
                  );
                  Navigator.pop(context);
                  setState(() => _currentIndex = 1);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('나의 정원에 담기'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      noteController.dispose();
    });
  }

  void _updateFlower(Wildflower target, Wildflower updated) {
    setState(() {
      _flowers =
          _flowers
              .map((flower) => flower.name == target.name ? updated : flower)
              .toList();
    });
  }

  void _collectFlower(
    IdentificationCandidate candidate,
    String title,
    String note,
  ) {
    final flower = candidate.flower;
    final now = DateTime.now();
    final formattedDate =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    _updateFlower(
      flower,
      flower.copyWith(
        collected: true,
        memoryTitle:
            title.isEmpty ? '${flower.region}에서 만난 ${flower.name}' : title,
        memoryNote: note.isEmpty ? flower.description : note,
        collectedDate: formattedDate,
        confirmedByUser: true,
        identificationConfidence: candidate.confidence,
        trainingReady: true,
      ),
    );

    setState(() {
      _regions =
          _regions
              .map(
                (region) =>
                    region.name == flower.region
                        ? region.copyWith(
                          collected:
                              region.collected < region.total
                                  ? region.collected + 1
                                  : region.collected,
                        )
                        : region,
              )
              .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${flower.name} 카드가 나의 정원에 담겼고 학습 데이터 후보로 표시됐어요.'),
      ),
    );
  }

  void _publishFlower(Wildflower flower) {
    _updateFlower(flower, flower.copyWith(isPublic: true));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${flower.name} 카드가 꽃밭에 공개되었어요.')));
  }

  void _confirmPublishFlower(Wildflower flower) {
    if (flower.isPublic) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${flower.name} 카드는 이미 꽃밭에 공개되어 있어요.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('꽃밭에 공개할까요?'),
          content: Text(
            '${flower.name} 카드의 사진, 제목, 추억 메모가 꽃밭에 공개됩니다. 정확한 위치는 공개하지 않고 지역만 보여줄 예정이에요.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _publishFlower(flower);
              },
              child: const Text('공개하기'),
            ),
          ],
        );
      },
    );
  }

  void _waterFlower(Wildflower flower) {
    _updateFlower(flower, flower.copyWith(waters: flower.waters + 1));
  }

  void _addComment(Wildflower flower, String comment) {
    _updateFlower(
      flower,
      flower.copyWith(comments: flower.comments + 1, latestComment: comment),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${flower.name} 카드에 따뜻한 댓글을 남겼어요.')));
  }

  void _showCommentDialog(Wildflower flower) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('${flower.name}에 댓글 남기기'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '예: 사진이 참 곱네요.',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                final comment = controller.text.trim();
                if (comment.isNotEmpty) {
                  _addComment(flower, comment);
                }
                Navigator.pop(context);
              },
              child: const Text('남기기'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showShareSheet(Wildflower flower) {
    final postcardKey = GlobalKey();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '꽃말 엽서 공유',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '카카오톡에는 이미지와 버튼이 있는 메시지로 보내고, 필요하면 한 장짜리 이미지 엽서로도 공유할 수 있게 준비합니다.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 16),
                RepaintBoundary(
                  key: postcardKey,
                  child: _SharePostcardPreview(flower: flower),
                ),
                const SizedBox(height: 12),
                const _ShareFormatNote(),
                const SizedBox(height: 16),
                _ShareOptionTile(
                  icon: Icons.chat_bubble_outline,
                  title: '카카오톡 템플릿으로 보내기',
                  description: '이미지 미리보기와 앱/웹으로 여는 버튼을 함께 보냅니다.',
                  onTap: () {
                    Navigator.pop(context);
                    _showPendingShareSnack(flower, '카카오톡 템플릿');
                  },
                ),
                const SizedBox(height: 10),
                _ShareOptionTile(
                  icon: Icons.image_outlined,
                  title: '이미지 엽서로 공유하기',
                  description: '워터마크가 포함된 한 장짜리 엽서를 만들어 카톡에 보냅니다.',
                  onTap: () async {
                    await _generateImagePostcard(postcardKey, flower);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPendingShareSnack(Wildflower flower, String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${flower.name} $method 공유는 카카오/이미지 생성 연동 단계에서 연결할게요.'),
      ),
    );
  }

  Future<void> _generateImagePostcard(
    GlobalKey postcardKey,
    Wildflower flower,
  ) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final boundary =
          postcardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw StateError('postcard render boundary not found');
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null || pngBytes.isEmpty) {
        throw StateError('postcard png bytes are empty');
      }

      if (!mounted) return;
      await _shareImagePostcard(flower, pngBytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${flower.name} 이미지 엽서를 만들지 못했어요. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _shareImagePostcard(
    Wildflower flower,
    Uint8List pngBytes,
  ) async {
    final fileName = 'semikkot-postcard-${flower.name}.png';
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(pngBytes, mimeType: 'image/png', name: fileName),
        ],
        fileNameOverrides: [fileName],
        subject: '${flower.name} 꽃말 엽서',
        text: '${flower.name} 꽃말 엽서를 보냅니다.\n세미꽃 - 산길에서 만난 야생화 수집 정원',
        downloadFallbackEnabled: true,
      ),
    );

    if (!mounted) return;

    final message =
        result.status == ShareResultStatus.dismissed
            ? '${flower.name} 이미지 엽서 공유를 취소했어요.'
            : '${flower.name} 이미지 엽서 공유를 열었어요.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CollectionTab extends StatelessWidget {
  const _CollectionTab({
    required this.regions,
    required this.flowers,
    required this.selectedRegion,
    required this.onRegionSelected,
    required this.onCollect,
  });

  final List<RegionProgress> regions;
  final List<Wildflower> flowers;
  final String selectedRegion;
  final ValueChanged<String> onRegionSelected;
  final ValueChanged<ImageSource> onCollect;

  @override
  Widget build(BuildContext context) {
    final regionFlowers =
        flowers.where((flower) => flower.region == selectedRegion).toList();
    final selectedProgress = regions.firstWhere(
      (region) => region.name == selectedRegion,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _SectionHeader(
          title: '야생화 수집',
          subtitle: '지도는 오픈소스 또는 카카오맵으로 교체할 수 있는 영역입니다.',
          trailing: Icons.map_outlined,
        ),
        const SizedBox(height: 12),
        _MapPlaceholder(
          regions: regions,
          selectedRegion: selectedRegion,
          onRegionSelected: onRegionSelected,
        ),
        const SizedBox(height: 12),
        _RegionSummaryCard(progress: selectedProgress, flowers: regionFlowers),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => onCollect(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('야생화 찍기'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onCollect(ImageSource.gallery),
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('사진 올리기'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _SectionHeader(
          title: '$selectedRegion에서 만날 수 있는 꽃',
          subtitle: '발견 전 카드는 차분한 회색 톤으로 표시됩니다.',
        ),
        const SizedBox(height: 12),
        ...regionFlowers.map(
          (flower) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FlowerCard(flower: flower),
          ),
        ),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({
    required this.regions,
    required this.selectedRegion,
    required this.onRegionSelected,
  });

  final List<RegionProgress> regions;
  final String selectedRegion;
  final ValueChanged<String> onRegionSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(36.35, 127.85),
                    initialZoom: 6.0,
                    minZoom: 5.2,
                    maxZoom: 10,
                    interactionOptions: const InteractionOptions(
                      flags:
                          InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'kr.co.semikkot.semikkot_app',
                    ),
                    MarkerLayer(
                      markers:
                          regions.map((region) {
                            final selected = region.name == selectedRegion;
                            return Marker(
                              width: selected ? 92 : 78,
                              height: selected ? 68 : 58,
                              point: LatLng(region.latitude, region.longitude),
                              child: _RegionMapMarker(
                                region: region,
                                selected: selected,
                                onTap: () => onRegionSelected(region.name),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.line),
            Row(
              children: [
                const Icon(Icons.terrain_outlined, color: AppColors.soil),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$selectedRegion 주요 산지와 수집 현황을 오픈소스 지도에 표시 중입니다.',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionSummaryCard extends StatelessWidget {
  const _RegionSummaryCard({required this.progress, required this.flowers});

  final RegionProgress progress;
  final List<Wildflower> flowers;

  @override
  Widget build(BuildContext context) {
    final collectedInList = flowers.where((flower) => flower.collected).length;
    final remainingInList = flowers.length - collectedInList;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${progress.name} 수집 현황',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Text(
                  '${(progress.rate * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.leaf,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress.rate,
              minHeight: 9,
              borderRadius: BorderRadius.circular(9),
              backgroundColor: AppColors.moss.withValues(alpha: 0.42),
              color: AppColors.leaf,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricPill(
                  icon: Icons.local_florist_outlined,
                  label: '수집 ${progress.collected}',
                ),
                const SizedBox(width: 8),
                _MetricPill(
                  icon: Icons.hourglass_empty_outlined,
                  label: '미수집 ${progress.remaining}',
                ),
                const SizedBox(width: 8),
                _MetricPill(
                  icon: Icons.terrain_outlined,
                  label: progress.mountain,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '현재 도감 후보 ${flowers.length}종 중 수집 완료 $collectedInList종, 미수집 $remainingInList종을 화면에서 확인할 수 있어요.',
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionMapMarker extends StatelessWidget {
  const _RegionMapMarker({
    required this.region,
    required this.selected,
    required this.onTap,
  });

  final RegionProgress region;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.leaf : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.leaf : AppColors.sage,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.18 : 0.10),
              blurRadius: selected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              region.name,
              style: TextStyle(
                fontSize: selected ? 14 : 12,
                color: selected ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${region.collected}/${region.total}',
              style: TextStyle(
                fontSize: selected ? 12 : 11,
                color: selected ? Colors.white : AppColors.leaf,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyGardenTab extends StatefulWidget {
  const _MyGardenTab({
    required this.flowers,
    required this.onPublish,
    required this.onShare,
  });

  final List<Wildflower> flowers;
  final ValueChanged<Wildflower> onPublish;
  final ValueChanged<Wildflower> onShare;

  @override
  State<_MyGardenTab> createState() => _MyGardenTabState();
}

class _MyGardenTabState extends State<_MyGardenTab> {
  GardenFilters _filters = const GardenFilters();

  List<Wildflower> get _filteredFlowers {
    return widget.flowers.where((flower) {
      final query = _filters.query.trim().toLowerCase();
      final regionMatch =
          _filters.region == '전체 지역' || flower.region == _filters.region;
      final seasonMatch =
          _filters.season == '전체 계절' || flower.season == _filters.season;
      final rarityMatch =
          _filters.rarity == '전체 희귀도' ||
          (_filters.rarity == '희귀도 높음' && flower.rarity >= 4) ||
          (_filters.rarity == '희귀도 보통' &&
              flower.rarity >= 2 &&
              flower.rarity <= 3);
      final queryMatch =
          query.isEmpty ||
          flower.name.toLowerCase().contains(query) ||
          (flower.memoryTitle ?? '').toLowerCase().contains(query) ||
          (flower.memoryNote ?? '').toLowerCase().contains(query);

      return regionMatch && seasonMatch && rarityMatch && queryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFlowers = _filteredFlowers;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _SectionHeader(
          title: '나의 정원',
          subtitle: '수집한 꽃 카드를 날짜순으로 모아봅니다.',
          trailing: Icons.filter_list,
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged:
              (value) =>
                  setState(() => _filters = _filters.copyWith(query: value)),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: '꽃명, 제목, 추억 메모 검색',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.line),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _FilterRow(
          filters: [_filters.region, _filters.season, _filters.rarity],
          onFilterTap: _showFilterPicker,
        ),
        const SizedBox(height: 14),
        if (filteredFlowers.isEmpty)
          const _EmptyState(
            icon: Icons.search_off_outlined,
            title: '조건에 맞는 꽃 카드가 없어요',
            message: '필터를 조금 넓혀서 다시 찾아보세요.',
          )
        else
          ...filteredFlowers.map(
            (flower) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GardenCard(
                flower: flower,
                privateGarden: true,
                onPrimaryAction: () => widget.onPublish(flower),
                onSecondaryAction: () => widget.onShare(flower),
              ),
            ),
          ),
      ],
    );
  }

  void _showFilterPicker(int filterIndex) {
    final options =
        filterIndex == 0
            ? [
              '전체 지역',
              ...widget.flowers.map((flower) => flower.region).toSet(),
            ]
            : filterIndex == 1
            ? [
              '전체 계절',
              ...widget.flowers.map((flower) => flower.season).toSet(),
            ]
            : ['전체 희귀도', '희귀도 높음', '희귀도 보통'];
    final currentFilter =
        filterIndex == 0
            ? _filters.region
            : filterIndex == 1
            ? _filters.season
            : _filters.rarity;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  options.map((option) {
                    return ListTile(
                      title: Text(option),
                      trailing:
                          option == currentFilter
                              ? const Icon(Icons.check, color: AppColors.leaf)
                              : null,
                      onTap: () {
                        setState(() {
                          if (filterIndex == 0) {
                            _filters = _filters.copyWith(region: option);
                          } else if (filterIndex == 1) {
                            _filters = _filters.copyWith(season: option);
                          } else {
                            _filters = _filters.copyWith(rarity: option);
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _PublicGardenTab extends StatelessWidget {
  const _PublicGardenTab({
    required this.flowers,
    required this.onWater,
    required this.onComment,
  });

  final List<Wildflower> flowers;
  final ValueChanged<Wildflower> onWater;
  final ValueChanged<Wildflower> onComment;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _SectionHeader(
          title: '꽃밭',
          subtitle: '함께 공개한 꽃 카드에 물주기와 댓글로 가볍게 인사합니다.',
          trailing: Icons.insights_outlined,
        ),
        const SizedBox(height: 12),
        _GardenStatsCard(flowers: flowers),
        const SizedBox(height: 14),
        if (flowers.isEmpty)
          const _EmptyState(
            icon: Icons.yard_outlined,
            title: '아직 공개된 꽃 카드가 없어요',
            message: '나의 정원에서 꽃밭으로 이동하면 이곳에 함께 전시됩니다.',
          )
        else
          ...flowers.map(
            (flower) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GardenCard(
                flower: flower,
                privateGarden: false,
                onPrimaryAction: () => onWater(flower),
                onSecondaryAction: () => onComment(flower),
              ),
            ),
          ),
      ],
    );
  }
}

class _FlowerCard extends StatelessWidget {
  const _FlowerCard({
    required this.flower,
    this.compact = false,
    this.forceCollectedLook = false,
  });

  final Wildflower flower;
  final bool compact;
  final bool forceCollectedLook;

  @override
  Widget build(BuildContext context) {
    final collectedLook = flower.collected || forceCollectedLook;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowerImage(color: flower.imageColor, faded: !collectedLook),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          flower.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      _StatusPill(done: collectedLook),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    flower.scientificName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${flower.region} · ${flower.season} · ${_rarityText(flower.rarity)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.soil,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    Text(
                      flower.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisPreview extends StatelessWidget {
  const _AnalysisPreview({required this.confidence, required this.sourceLabel});

  final int confidence;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.moss.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.image_search_outlined,
                size: 36,
                color: AppColors.leaf,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$sourceLabel 사진 분석',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                    value: confidence / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: AppColors.moss.withValues(alpha: 0.42),
                    color: AppColors.leaf,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '일치 가능성 $confidence%',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceNotice extends StatelessWidget {
  const _ImageSourceNotice({
    required this.imageName,
    required this.usedMockFallback,
  });

  final String? imageName;
  final bool usedMockFallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            usedMockFallback
                ? AppColors.petal.withValues(alpha: 0.16)
                : AppColors.moss.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: usedMockFallback ? AppColors.petal : AppColors.moss,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            usedMockFallback ? Icons.science_outlined : Icons.image_outlined,
            size: 20,
            color: usedMockFallback ? AppColors.soil : AppColors.leaf,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              usedMockFallback
                  ? '사진 선택이 취소되었거나 현재 환경에서 제한되어 데모 사진으로 분석 흐름을 이어갑니다.'
                  : '선택한 사진: $imageName',
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingDataNotice extends StatelessWidget {
  const _TrainingDataNotice({required this.candidate});

  final IdentificationCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.moss.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.moss),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_outlined, size: 20, color: AppColors.leaf),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '사용자가 ${candidate.flower.name}로 확정하면 이 기록은 향후 식별 정확도 개선을 위한 학습 데이터 후보가 됩니다. 현재 신뢰도 ${candidate.confidence}%',
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentificationCandidateTile extends StatelessWidget {
  const _IdentificationCandidateTile({
    required this.candidate,
    required this.selected,
    required this.onTap,
  });

  final IdentificationCandidate candidate;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          selected ? AppColors.moss.withValues(alpha: 0.38) : AppColors.paper,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.leaf : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.flower.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      candidate.matchReason,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${candidate.confidence}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.leaf,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? AppColors.leaf : AppColors.sage,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GardenCard extends StatelessWidget {
  const _GardenCard({
    required this.flower,
    required this.privateGarden,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  final Wildflower flower;
  final bool privateGarden;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _FlowerImage(color: flower.imageColor, faded: false),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flower.memoryTitle ?? flower.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${flower.name} · ${flower.region} · ${flower.collectedDate ?? '오늘'}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          flower.memoryNote ?? flower.language,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: AppColors.ink,
                          ),
                        ),
                        if (!privateGarden && flower.latestComment != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '최근 댓글: ${flower.latestComment}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.soil,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (privateGarden && flower.trainingReady) ...[
                          const SizedBox(height: 8),
                          Text(
                            '사용자 확인 완료 · 학습 후보 ${flower.identificationConfidence ?? '-'}%',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.leaf,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _SmallAction(
                    icon: Icons.water_drop_outlined,
                    label: '물주기 ${flower.waters}',
                  ),
                  const SizedBox(width: 8),
                  _SmallAction(
                    icon: Icons.mode_comment_outlined,
                    label: '댓글 ${flower.comments}',
                  ),
                  const Spacer(),
                  Text(
                    privateGarden
                        ? (flower.isPublic ? '꽃밭 공개중' : '나만 보기')
                        : _rarityText(flower.rarity),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                flower.memoryTitle ?? flower.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${flower.name} · ${flower.scientificName}',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              _FlowerCard(flower: flower, compact: true),
              const SizedBox(height: 14),
              Text(
                flower.memoryNote ?? flower.description,
                style: const TextStyle(fontSize: 15, height: 1.45),
              ),
              const SizedBox(height: 14),
              _InfoPanel(
                rows: [
                  _InfoRow(label: '꽃말', value: flower.language),
                  _InfoRow(label: '계절', value: flower.season),
                  _InfoRow(label: '희귀도', value: _rarityText(flower.rarity)),
                  _InfoRow(label: '설명', value: flower.description),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        onSecondaryAction();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.ios_share_outlined),
                      label: Text(privateGarden ? '공유' : '댓글'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        onPrimaryAction();
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        privateGarden
                            ? Icons.yard_outlined
                            : Icons.water_drop_outlined,
                      ),
                      label: Text(privateGarden ? '꽃밭으로 이동' : '물주기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FlowerImage extends StatelessWidget {
  const _FlowerImage({required this.color, required this.faded});

  final Color color;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: faded ? const Color(0xFFE0DDD5) : color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Icon(
        Icons.local_florist,
        size: 42,
        color: faded ? const Color(0xFF9C998F) : color,
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            rows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(
                        row.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.soil,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _SharePostcardPreview extends StatelessWidget {
  const _SharePostcardPreview({required this.flower});

  final Wildflower flower;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FlowerImage(color: flower.imageColor, faded: false),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flower.memoryTitle ??
                          '${flower.region}에서 만난 ${flower.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      flower.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.leaf,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '꽃말: ${flower.language}',
            style: const TextStyle(
              fontSize: 15,
              height: 1.35,
              color: AppColors.soil,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            flower.memoryNote ?? flower.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_florist, size: 17, color: AppColors.leaf),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '세미꽃 - 산길에서 만난 야생화 수집 정원',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  'semikkot.app',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.soil,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareFormatNote extends StatelessWidget {
  const _ShareFormatNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.moss.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.moss),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: AppColors.leaf),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '이미지 엽서는 앱을 설치하지 않은 사람도 카톡방에서 바로 볼 수 있도록 PNG로 생성할 예정입니다.',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  const _ShareOptionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.leaf, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.sage),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) Icon(trailing, color: AppColors.leaf),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.filters, required this.onFilterTap});

  final List<String> filters;
  final ValueChanged<int> onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          filters.indexed
              .map(
                (entry) => ActionChip(
                  label: Text(entry.$2),
                  avatar: const Icon(Icons.tune, size: 16),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.line),
                  onPressed: () => onFilterTap(entry.$1),
                ),
              )
              .toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, size: 42, color: AppColors.sage),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GardenStatsCard extends StatelessWidget {
  const _GardenStatsCard({required this.flowers});

  final List<Wildflower> flowers;

  int get _totalWaters => flowers.fold(0, (sum, flower) => sum + flower.waters);

  int get _rareCount => flowers.where((flower) => flower.rarity >= 4).length;

  String get _topRegion {
    if (flowers.isEmpty) return '아직 없음';

    final counts = <String, int>{};
    for (final flower in flowers) {
      counts[flower.region] = (counts[flower.region] ?? 0) + 1;
    }

    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final total = flowers.isEmpty ? 1 : flowers.length;
    final rareRatio = flowers.isEmpty ? 0.0 : _rareCount / total;
    final wateredRatio = (_totalWaters / 40).clamp(0.0, 1.0);
    final regionRatio =
        flowers.isEmpty
            ? 0.0
            : flowers.where((flower) => flower.region == _topRegion).length /
                total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '꽃밭 현황',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            _StatBar(
              label: '공개된 꽃 카드 ${flowers.length}장',
              value: flowers.isEmpty ? 0 : 1,
            ),
            _StatBar(label: '희귀 꽃 발견 $_rareCount장', value: rareRatio),
            _StatBar(label: '물주기 총 $_totalWaters번', value: wateredRatio),
            _StatBar(label: '가장 활발한 지역 $_topRegion', value: regionRatio),
          ],
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: value,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: AppColors.moss.withValues(alpha: 0.45),
            color: AppColors.leaf,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: done ? AppColors.moss : const Color(0xFFE8E4DC),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        done ? '수집 완료' : '미수집',
        style: TextStyle(
          fontSize: 12,
          color: done ? AppColors.leaf : AppColors.muted,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.leaf),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.leaf),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _rarityText(int rarity) {
  return '희귀도 ${List.filled(rarity, '★').join()}';
}
