import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import '../services/firebase_service.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedCategory = '전체';

  final List<String> categories = ['전체', '질문', '정보', '후기'];

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 한 번만 더미 데이터 추가
    FirebaseService.addInitialData();
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

          // Firebase에서 실시간으로 게시글 목록 가져오기
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: FirebaseService.getPostsStream(
                category: _selectedCategory == '전체' ? null : _selectedCategory,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          '데이터를 불러오는 중 오류가 발생했습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Firebase 연결을 확인해주세요.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          '게시글을 불러오는 중...',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          _selectedCategory == '전체'
                              ? '아직 작성된 게시글이 없습니다.'
                              : '${_selectedCategory} 카테고리에 게시글이 없습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '첫 번째 글을 작성해보세요!',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // 필터 결과 표시
                    if (_selectedCategory != '전체')
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              '${_selectedCategory} 카테고리',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '총 ${posts.length}개',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 게시글 목록
                    Expanded(
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
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
            ).then((result) {
              if (result == true) {
                // 글 작성 성공 시 스낵바 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('게시글이 성공적으로 작성되었습니다!'),
                    backgroundColor: Colors.green,
                  ),
                );
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
    );
  }
}