import 'package:flutter/material.dart';
import '../models/post.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  PostDetailScreen({required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLiked = false;
  int _likeCount = 0;
  final List<Comment> _comments = [];
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;

    // 더미 댓글 데이터
    _comments.addAll([
      Comment(
        id: '1',
        author: '방청년',
        content: '너무 멋져요! 지도 2026년도에 열리나 신청해봐야겠어요 취업 축하해요!!',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        isAuthor: false,
      ),
      Comment(
        id: '2',
        author: '성철남',
        content: '꽤 신청해보세요! 먼저 자격증명 주고 좋은 프로그램입니다',
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        isAuthor: true,
      ),
      Comment(
        id: '3',
        author: '손청년',
        content: '지도 IT 관련 진로에 이니어 고민했는데, 후기 너무 감사합니다! 취업 축하드려요!!',
        createdAt: DateTime.now().subtract(Duration(minutes: 30)),
        isAuthor: false,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '커뮤니티',
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 게시글 내용
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카테고리와 HOT 배지
                        Row(
                          children: [
                            if (widget.post.isHot)
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
                            if (widget.post.isHot) SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(widget.post.category),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.post.category,
                                style: TextStyle(
                                  color: _getCategoryTextColor(widget.post.category),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // 제목
                        Text(
                          widget.post.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 8),

                        // 작성자와 시간
                        Text(
                          '${widget.post.author} · ${_getTimeAgo(widget.post.createdAt)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        SizedBox(height: 20),

                        // 게시글 내용
                        Text(
                          widget.post.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),

                        SizedBox(height: 20),

                        // 좋아요 버튼
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleLike,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isLiked ? Colors.red.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _isLiked ? Colors.red.shade200 : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: _isLiked ? Colors.red : Colors.grey.shade600,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '$_likeCount',
                                      style: TextStyle(
                                        color: _isLiked ? Colors.red : Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '댓글 ${_comments.length}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(thickness: 8, color: Colors.grey.shade100),

                  // 댓글 목록
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return _buildCommentItem(comment);
                    },
                  ),
                ],
              ),
            ),
          ),

          // 댓글 입력란
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: comment.isAuthor ? Colors.green.shade100 : Colors.grey.shade200,
            child: Icon(
              Icons.person,
              color: comment.isAuthor ? Colors.green : Colors.grey.shade600,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    if (comment.isAuthor)
                      Container(
                        margin: EdgeInsets.only(left: 6),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '작성자',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Spacer(),
                    Text(
                      _getTimeAgo(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.add(
        Comment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          author: '나',
          content: _commentController.text.trim(),
          createdAt: DateTime.now(),
          isAuthor: false,
        ),
      );
      _commentController.clear();
    });
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

  String _getTimeAgo(DateTime dateTime) {
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

// 댓글 모델
class Comment {
  final String id;
  final String author;
  final String content;
  final DateTime createdAt;
  final bool isAuthor;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.isAuthor = false,
  });
}