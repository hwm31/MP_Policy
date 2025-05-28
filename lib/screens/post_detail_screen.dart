import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/firebase_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  PostDetailScreen({required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLiked = false;
  int _likeCount = 0;
  final _commentController = TextEditingController();
  bool _isLoadingLike = false;
  bool _isLoadingComment = false;

  // 임시 사용자 ID (실제로는 Firebase Auth에서 가져와야 함)
  final String _currentUserId = 'temp_user_123';
  final String _currentUserName = '익명';

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _checkIfLiked();
  }

  // 사용자가 이미 좋아요를 했는지 확인
  Future<void> _checkIfLiked() async {
    bool liked = await FirebaseService.isLiked(widget.post.id, _currentUserId);
    if (mounted) {
      setState(() {
        _isLiked = liked;
      });
    }
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
                              onTap: _isLoadingLike ? null : _toggleLike,
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
                                    if (_isLoadingLike)
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _isLiked ? Colors.red : Colors.grey.shade600,
                                          ),
                                        ),
                                      )
                                    else
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
                            StreamBuilder<List<Comment>>(
                              stream: FirebaseService.getCommentsStream(widget.post.id),
                              builder: (context, snapshot) {
                                int commentCount = snapshot.hasData ? snapshot.data!.length : 0;
                                return Text(
                                  '댓글 $commentCount',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(thickness: 8, color: Colors.grey.shade100),

                  // 댓글 목록 (실시간)
                  StreamBuilder<List<Comment>>(
                    stream: FirebaseService.getCommentsStream(widget.post.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            '댓글을 불러오는 중 오류가 발생했습니다.',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.green),
                          ),
                        );
                      }

                      List<Comment> comments = snapshot.data ?? [];

                      if (comments.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              '첫 번째 댓글을 남겨보세요!',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _buildCommentItem(comment);
                        },
                      );
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
                    enabled: !_isLoadingComment,
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
                  onTap: (_isLoadingComment || _commentController.text.trim().isEmpty)
                      ? null
                      : _addComment,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (_isLoadingComment || _commentController.text.trim().isEmpty)
                          ? Colors.grey.shade300
                          : Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: _isLoadingComment
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Icon(
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
    bool isMyComment = comment.author == _currentUserName;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isMyComment ? Colors.blue.shade100 : Colors.grey.shade200,
            child: Icon(
              Icons.person,
              color: isMyComment ? Colors.blue : Colors.grey.shade600,
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
                    if (isMyComment)
                      Container(
                        margin: EdgeInsets.only(left: 6),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '내 댓글',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
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

  Future<void> _toggleLike() async {
    setState(() {
      _isLoadingLike = true;
    });

    try {
      bool success = await FirebaseService.toggleLike(widget.post.id, _currentUserId);

      if (success) {
        // 좋아요 상태 토글
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('좋아요 처리 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLike = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isLoadingComment = true;
    });

    try {
      final newComment = Comment(
        id: '', // Firestore에서 자동 생성
        postId: widget.post.id,
        author: _currentUserName,
        content: _commentController.text.trim(),
        createdAt: DateTime.now(),
        isAuthor: widget.post.author == _currentUserName,
      );

      bool success = await FirebaseService.createComment(newComment);

      if (success) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('댓글이 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('댓글 등록 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingComment = false;
      });
    }
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