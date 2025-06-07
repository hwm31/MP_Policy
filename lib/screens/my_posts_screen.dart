import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import '../models/comment.dart';

class MyPostsScreen extends StatefulWidget {
  @override
  _MyPostsScreenState createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  String _selectedFilter = '전체';
  final List<String> filters = ['전체', '질문', '정보', '후기'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '내가 쓴 글',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 필터 탭
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = filter == _selectedFilter;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
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
                      filter,
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

          // 내가 쓴 게시글 목록
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: FirebaseService.getMyPostsStream(
                userId: AuthService.currentUserId,
                category: _selectedFilter == '전체' ? null : _selectedFilter,
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
                          '${snapshot.error}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // 새로고침
                          },
                          child: Text('다시 시도'),
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
                          '내가 쓴 글을 불러오는 중...',
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
                        Icon(
                            Icons.edit_note_outlined,
                            size: 80,
                            color: Colors.grey.shade400
                        ),
                        SizedBox(height: 16),
                        Text(
                          _selectedFilter == '전체'
                              ? '아직 작성한 게시글이 없습니다.'
                              : '${_selectedFilter} 카테고리에 작성한 글이 없습니다.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '새로운 글을 작성해보세요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // 이전 화면으로
                          },
                          icon: Icon(Icons.edit),
                          label: Text('글 작성하러 가기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade100,
                            foregroundColor: Colors.green.shade700,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // 게시글 개수 표시
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.article, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            _selectedFilter == '전체'
                                ? '총 ${posts.length}개의 글'
                                : '${_selectedFilter} ${posts.length}개',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '최신순',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(color: Colors.grey.shade200),

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
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 카테고리와 HOT 배지
                                      Row(
                                        children: [
                                          if (post.isHot)
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'HOT',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          if (post.isHot) SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _getCategoryColor(post.category),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              post.category,
                                              style: TextStyle(
                                                color: _getCategoryTextColor(post.category),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '내 글',
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 12),

                                      // 제목
                                      Text(
                                        post.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      SizedBox(height: 8),

                                      // 내용 미리보기
                                      Text(
                                        post.content,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      SizedBox(height: 12),

                                      // 작성 시간과 통계
                                      Row(
                                        children: [
                                          Text(
                                            _getTimeAgo(post.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          Spacer(),
                                          Row(
                                            children: [
                                              Icon(Icons.favorite,
                                                  color: Colors.red.shade300, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                '${post.likes}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Icon(Icons.chat_bubble_outline,
                                                  color: Colors.grey.shade400, size: 16),
                                              SizedBox(width: 4),
                                              // 전체 댓글 수 (답글 포함)
                                              StreamBuilder<List<Comment>>(
                                                stream: FirebaseService.getAllCommentsStream(post.id),
                                                builder: (context, snapshot) {
                                                  int commentCount = snapshot.hasData ? snapshot.data!.length : post.comments;
                                                  return Text(
                                                    '$commentCount',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '후기':
        return Colors.orange.shade100;
      case '정보':
        return Colors.blue.shade100;
      case '질문':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category) {
      case '후기':
        return Colors.orange.shade700;
      case '정보':
        return Colors.blue.shade700;
      case '질문':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '알 수 없음';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}