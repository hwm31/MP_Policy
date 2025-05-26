import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = '전체';

  final List<String> categories = ['전체', '질문', '정보', '후기'];

  // 더미 데이터 (나중에 Firebase로 대체)
  List<Post> posts = [
    Post(
      id: '1',
      title: '2025 IT 인재 양성 프로그램 후기',
      content: '6개월 과정 끝나고 취업까지 성공했어요! 합격 꿀팁들도 프로그램 참여 노하우까지 공유합니다.',
      category: '후기',
      author: '성철남',
      createdAt: DateTime.now().subtract(Duration(hours: 8)),
      likes: 345,
      comments: 30,
      isHot: true,
    ),
    Post(
      id: '2',
      title: '청년 정책 간담회 안내',
      content: '김태진 국회의원 · 1일 전\n경기도 성남시에서 다음 주 참여할 온라인으로 정부 정책 간담회를 개최합니다. 많은 참여...',
      category: '정보',
      author: '김태진',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      likes: 200,      comments: 10,
    ),
    Post(
      id: '3',
      title: '창업 지원금 신청 자격 질문',
      content: '창업 지원금 관련해서 질문입니다. 사업자등록증을 하지 않은 상태에서도 신청 가능한지요?',
      category: '질문',
      author: '김창업',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      likes: 6,
      comments: 8,
    ),
    Post(
      id: '4',
      title: '서울시 청년 일자리 카페 위치 정보',
      content: '서울시 각 지역별 청년 일자리 카페 위치 정보를 공유합니다. 근처에 시설이 있다면 방문...',
      category: '정보',
      author: '서울청년',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      likes: 125,
      comments: 20,
    ),
  ];

  List<Post> get filteredPosts {
    if (_selectedCategory == '전체') {
      return posts;
    }
    return posts.where((post) => post.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '청년 일자리 커뮤니티',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            // 토끼 아이콘 (이모지로 대체)
            Text('🐰', style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 카테고리 탭
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.shade100 : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.green : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 게시글 목록
          Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                  child: PostCard(post: post),
                );
              },
            ),
          ),
        ],
      ),

      // 새 글 작성 버튼
      floatingActionButton: Container(
        width: 120,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePostScreen(),
              ),
            ).then((newPost) {
              if (newPost != null) {
                setState(() {
                  posts.insert(0, newPost);
                });
              }
            });
          },
          label: Text('새 글 작성하기'),
          icon: Icon(Icons.edit),
          backgroundColor: Colors.green.shade100,
          foregroundColor: Colors.green.shade700,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // 하단 네비게이션
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.policy),
            label: 'Policy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}