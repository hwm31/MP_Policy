// home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/policy_status.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _zoom = 1.0; //지도 확대 기본 배율(100%)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '청년정책 히트맵',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<String>(
        future: loadColoredSvg(regionStatsMap),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return Stack(
            children: [
              // 지도 렌더링, 드래그 가능, 확대는 버튼을 통해 2,4배 확대 가능
              InteractiveViewer(
                panEnabled: true,
                scaleEnabled: false, // 마우스로 확대는 막고 버튼만 허용
                boundaryMargin: EdgeInsets.all(double.infinity), //이동가능범위 확장
                child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 150),
                      child: Transform.scale(
                        scale: _zoom,
                        child: SvgPicture.string(
                          snapshot.data!,
                          width: 800,
                          height: 1000,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                ),
              ),

              // 확대 버튼들
              Positioned(
                bottom: 40,
                right: 20,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'zoom1',
                      mini: true,
                      onPressed: () {
                        setState(() {
                          _zoom = 2.0; // 200%
                        });
                      },
                      child: Text('2x'),
                    ),
                    SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'zoom2',
                      mini: true,
                      onPressed: () {
                        setState(() {
                          _zoom = 4.0; // 400%
                        });
                      },
                      child: Text('4x'),
                    ),
                    SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'reset',
                      mini: true,
                      onPressed: () {
                        setState(() {
                          _zoom = 1.0; // 기본 배율로 돌아가기
                        });
                      },
                      child: Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              // 관심지역 세부정보 표시 (현재 서울특별시로 고정됨)
              Positioned(
                bottom: 60,
                left: 20,
                child: Container(
                    width: 400,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(blurRadius: 8, spreadRadius:1, offset: Offset(0, 4), color: Colors.black.withOpacity(0.25))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '관심 지역: 서울특별시',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('총 정책 수: ${regionStatsMap["서울특별시"]!.total}'),
                        Text('모집 중: ${regionStatsMap["서울특별시"]!.open}'),
                        Text('모집 마감: ${regionStatsMap["서울특별시"]!.closed}'),
                      ],
                    )
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final Map<String, PolicyStats> regionStatsMap = {
  '서울특별시': PolicyStats(total: 100, open: 60, closed: 40),
  '부산광역시': PolicyStats(total: 1, open: 0, closed: 1),
  '대구광역시': PolicyStats(total: 2, open: 1, closed: 1),
  '인천광역시': PolicyStats(total: 3, open: 3, closed: 0),
  '광주광역시': PolicyStats(total: 4, open: 2, closed: 2),
  '대전광역시': PolicyStats(total: 5, open: 3, closed: 2),
  '울산광역시': PolicyStats(total: 6, open: 4, closed: 2),
  '세종특별자치시': PolicyStats(total: 7, open: 5, closed: 2),
  '경기도': PolicyStats(total: 8, open: 4, closed: 4),
  '충청북도': PolicyStats(total: 9, open: 6, closed: 3),
  '충청남도': PolicyStats(total: 10, open: 5, closed: 5),
  '전라남도': PolicyStats(total: 5, open: 2, closed: 3),
  '경상북도': PolicyStats(total: 6, open: 1, closed: 5),
  '경상남도': PolicyStats(total: 7, open: 0, closed: 7),
  '제주특별자치도': PolicyStats(total: 8, open: 8, closed: 0),
  '강원특별자치도': PolicyStats(total: 9, open: 3, closed: 6),
  '전북특별자치도': PolicyStats(total: 10, open: 10, closed: 0),
};

const Color lightGreen = Color(0xFFE6F4EA); // 연한 초록
const Color darkGreen  = Color(0xFF012E02); // 진한 초록

Color getGreenColorForValue(int value) {
  final t = ((value.clamp(1, 100)) - 1) / 99.0;
  return Color.lerp(lightGreen, darkGreen, t)!;
}

// ✅ SVG 문자열 로드 + 색상 치환
Future<String> loadColoredSvg(Map<String, PolicyStats> values) async {

  String rawSvg = await rootBundle.loadString('assets/Licensed_Map.svg');

  for (var entry in values.entries) {
    final id = entry.key;
    final total = entry.value.total;

    final color = getGreenColorForValue(total);
    final hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';

    rawSvg = rawSvg.replaceAllMapped(
      RegExp(r'(<path[^>]*id="' + id + r'"[^>]*?)fill="[^"]*"'),
          (match) => '${match[1]}fill="$hex"',
    );
  }

  return rawSvg;
}

void _showRegionDialog(BuildContext context, String regionId) {
  final stats = regionStatsMap[regionId];
  final regionName = regionId;

  if (stats == null) return;

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(regionName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('총 정책 수: ${stats.total}'),
            Text('모집 중: ${stats.open}'),
            Text('마감됨: ${stats.closed}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('닫기'),
          ),
        ],
      );
    },
  );
}