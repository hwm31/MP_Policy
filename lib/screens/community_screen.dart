import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedCategory = '전체';

  final List<String> categories = ['전체', '질문', '정보', '후기'];

  // 더미 데이터 (나중에 Firebase로 대체)
  List<Post> posts = [
    Post(
      id: '1',
      title: '2025 IT 인재 양성 프로그램 후기',
      content: '6개월 과정 끝나고 취업까지 성공했어요! 합격 꿀팁들도 프로그램 참여 노하우까지 공유합니다.\n\n시간디자인과 좋지 후 IT 개발로 취업을 하고 싶어 지원하게 되었고, 팀 디자인 프로젝트 3개 진행했습니다. 지금 비슷하게 IT 직무 야나 분들도 많이 협력하셨으면 좋을 인 허서도 대인 프로그램에는 핵심 적극적으로 질문하시는 게 중요합니다. 질문을 많이 할수록 더 좋은 기회들이 와이오답니다고요!',
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
      likes: 200,
      comments: 10,
    ),
    Post(
      id: '3',
      title: '창업 지원금 신청 자격 질문',
      content: '최근 창업에 관련해서 질문입니다. 사업자등록증을 하지 않은 상태에서도 신청 가능한지요?',
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
    Post(
      id: '5',
      title: '국민취업지원제도 후기',
      content: '국민취업지원제도 1유형으로 6개월간 참여했습니다. 월 50만원 지원받으면서 취업 성공했어요!',
      category: '후기',
      author: '취업성공자',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      likes: 189,
      comments: 25,
    ),
    Post(
      id: '6',
      title: '청년 주거급여 신청 방법 질문',
      content: '부모님과 따로 살고 있는데 청년 주거급여 신청이 가능한가요? 조건이 궁금합니다.',
      category: '질문',
      author: '주거고민청년',
      createdAt: DateTime.now().subtract(Duration(days: 4)),
      likes: 45,
      comments: 15,
    ),
    Post(
      id: '7',
      title: '2025년 청년 창업 지원 정책 총정리',
      content: '올해 달라진 청년 창업 지원 정책들을 정리해봤습니다. K-스타트업, 창업진흥원 등...',
      category: '정보',
      author: '정책연구원',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      likes: 267,
      comments: 42,
    ),
    Post(
      id: '8',
      title: '디지털 노마드 비자 신청 후기',
      content: '해외에서 원격근무하며 일하고 싶어서 디지털 노마드 비자를 신청했습니다. 과정 공유드려요.',
      category: '후기',
      author: '디지털노마드',
      createdAt: DateTime.now().subtract(Duration(days: 6)),
      likes: 156,
      comments: 28,
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
                    '총 ${filteredPosts.length}개',
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
    );
  }
}

  Stream<QuerySnapshot> _getPostsStream() {
    Query query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true);

    if (selectedCategory != '전체') {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return query.snapshots();
  }
}

class PostCard extends StatelessWidget {
  final String postId;
  final String title;
  final String content;
  final String category;
  final String authorName;
  final Timestamp? createdAt;
  final int likeCount;
  final int commentCount;

  const PostCard({
    Key? key,
    required this.postId,
    required this.title,
    required this.content,
    required this.category,
    required this.authorName,
    this.createdAt,
    required this.likeCount,
    required this.commentCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(postId: postId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리와 날짜
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // 제목
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 8),

              // 내용 미리보기
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 12),

              // 작성자, 좋아요, 댓글 수
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        authorName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text('$likeCount', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      SizedBox(width: 12),
                      Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text('$commentCount', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '일자리': return Colors.blue;
      case '교육': return Colors.orange;
      case '취업': return Colors.green;
      case '후기': return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

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