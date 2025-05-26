import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 더미 데이터 - 최신 정책 정보들
  List<Post> recentPolicies = [
    Post(
      id: '1',
      title: '2025 청년 창업 지원 사업 공고',
      content: '중소벤처기업부에서 청년 창업가를 위한 최대 5천만원 지원 사업을 시작합니다. 신청 기간은 6월 1일부터...',
      category: '정보',
      author: '정책담당자',
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      likes: 156,
      comments: 23,
      isHot: true,
    ),
    Post(
      id: '2',
      title: '청년 주거 지원 정책 확대',
      content: '전세자금대출 한도 상향 및 청년 전용 임대주택 공급이 확대됩니다.',
      category: '정보',
      author: '국토부',
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
      likes: 89,
      comments: 12,
    ),
    Post(
      id: '3',
      title: 'K-디지털 트레이닝 과정 모집',
      content: 'AI, 빅데이터, 클라우드 등 디지털 기술 교육과정 참가자를 모집합니다.',
      category: '정보',
      author: '고용부',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      likes: 234,
      comments: 45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '홈',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            Text('🏠', style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 환영 메시지
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '청년 여러분, 안녕하세요! 👋',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '새로운 기회와 정보를 확인해보세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // 빠른 메뉴
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '빠른 메뉴',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            SizedBox(height: 12),

            Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildQuickMenu('일자리 찾기', Icons.work, Colors.blue),
                  _buildQuickMenu('정책 정보', Icons.policy, Colors.orange),
                  _buildQuickMenu('교육 과정', Icons.school, Colors.purple),
                  _buildQuickMenu('창업 지원', Icons.business, Colors.red),
                  _buildQuickMenu('주거 지원', Icons.home, Colors.green),
                ],
              ),
            ),

            SizedBox(height: 24),

            // 최신 정책 정보
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최신 정책 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Policy 탭으로 이동
                    },
                    child: Text(
                      '더보기',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // 최신 정책 목록
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recentPolicies.length,
              itemBuilder: (context, index) {
                final post = recentPolicies[index];
                return PostCard(post: post);
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenu(String title, IconData icon, Color color) {
    return Container(
      width: 80,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}