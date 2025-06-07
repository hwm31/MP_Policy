import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import 'my_posts_screen.dart';

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
        actions: [
          // 현재 사용자 정보 표시
          if (AuthService.isLoggedIn)
            Container(
              margin: EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 사용자명 표시
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AuthService.currentUserName.isEmpty
                          ? '익명'
                          : AuthService.currentUserName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 프로필 설정 버튼 (displayName이 없는 경우)
                  if (AuthService.currentUserName.isEmpty ||
                      AuthService.currentUserName.startsWith('user_'))
                    IconButton(
                      onPressed: () {
                        _showProfileSetupDialog();
                      },
                      icon: Icon(Icons.edit, size: 16, color: Colors.orange),
                      tooltip: '이름 설정',
                    ),
                ],
              ),
            ),
          // 내가 쓴 글 보기 버튼
          IconButton(
            onPressed: () {
              if (!AuthService.isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('로그인이 필요합니다.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyPostsScreen(),
                ),
              );
            },
            icon: Icon(Icons.person, color: Colors.green.shade700),
            tooltip: '내가 쓴 글',
          ),
          // 메뉴 버튼
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'my_posts') {
                if (!AuthService.isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('로그인이 필요합니다.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPostsScreen(),
                  ),
                );
              } else if (value == 'logout') {
                _handleLogout();
              } else if (value == 'profile') {
                _showProfileSetupDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              if (AuthService.isLoggedIn) ...[
                PopupMenuItem<String>(
                  value: 'my_posts',
                  child: Row(
                    children: [
                      Icon(Icons.article, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('내가 쓴 글'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('이름 변경'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('로그아웃'),
                    ],
                  ),
                ),
              ],
            ],
            icon: Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
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

  // 프로필 설정 다이얼로그
  void _showProfileSetupDialog() {
    final _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이름 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('커뮤니티에서 사용할 이름을 설정해주세요.'),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '이름 (예: 홍길동)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                String name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  bool success = await AuthService.updateProfile(displayName: name);
                  if (success) {
                    Navigator.of(context).pop();
                    setState(() {}); // UI 새로고침
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('이름이 설정되었습니다: $name'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('이름 설정에 실패했습니다.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('이름을 입력해주세요.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 로그아웃 처리
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                bool success = await AuthService.signOut();
                Navigator.of(context).pop();
                if (success) {
                  setState(() {}); // UI 새로고침
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('로그아웃되었습니다.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text('로그아웃', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}