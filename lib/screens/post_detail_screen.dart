import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 추가
import '../models/post.dart';
import '../models/comment.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'edit_post_screen.dart'; // EditPostScreen import 추가

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

  // AuthService에서 실제 사용자 정보 가져오기
  String get _currentUserId => AuthService.currentUserId;
  String get _currentUserName => AuthService.currentUserName;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _checkIfLiked();

    // 강화된 디버깅 로그
    print('=== PostDetailScreen 상세 디버깅 ===');
    print('게시글 ID: "${widget.post.id}"');
    print('게시글 제목: "${widget.post.title}"');
    print('게시글 작성자 (원본): "${widget.post.author}"');
    print('게시글 작성자 길이: ${widget.post.author.length}');
    print('게시글 작성자 바이트: ${widget.post.author.codeUnits}');
    print('---');
    print('현재 로그인 상태: ${AuthService.isLoggedIn}');
    print('현재 사용자 ID: "${AuthService.currentUserId}"');
    print('현재 사용자 이름 (원본): "${AuthService.currentUserName}"');
    print('현재 사용자 이름 길이: ${AuthService.currentUserName.length}');
    print('현재 사용자 이름 바이트: ${AuthService.currentUserName.codeUnits}');
    print('---');
    print('문자열 비교 결과: ${widget.post.author == AuthService.currentUserName}');
    print('trim 후 비교: "${widget.post.author.trim()}" == "${AuthService.currentUserName.trim()}"');
    print('trim 비교 결과: ${widget.post.author.trim() == AuthService.currentUserName.trim()}');
    print('===================================');

    // Firebase에서 실제 저장된 데이터 확인
    _checkFirebaseData();

    // 댓글 입력 필드 변화 감지 (전송 버튼 활성화/비활성화)
    _commentController.addListener(() {
      setState(() {
        // 텍스트가 변경될 때마다 UI 업데이트
      });
    });
  }

  // Firebase 데이터 직접 확인
  Future<void> _checkFirebaseData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .get();

      if (doc.exists) {
        final data = doc.data();
        print('=== Firebase 실제 데이터 ===');
        print('전체 데이터: $data');
        print('author 필드: "${data?['author']}"');
        print('author 타입: ${data?['author'].runtimeType}');
        print('==========================');
      }
    } catch (e) {
      print('Firebase 데이터 확인 오류: $e');
    }
  }

  // 내가 쓴 글인지 확인하는 메서드 (이중 체크)
  bool get _isMyPost {
    // 1차: authorId로 비교 (가장 정확)
    if (widget.post.authorId != null &&
        widget.post.authorId!.isNotEmpty &&
        widget.post.authorId == _currentUserId) {
      print('authorId로 본인 글 확인됨');
      return true;
    }

    // 2차: author 이름으로 비교 (호환성)
    if (widget.post.author.trim() == _currentUserName.trim() &&
        _currentUserName.trim().isNotEmpty) {
      print('author 이름으로 본인 글 확인됨');
      return true;
    }

    print('본인 글이 아님');
    return false;
  }
  Future<void> _checkIfLiked() async {
    bool liked = await FirebaseService.isLiked(widget.post.id, _currentUserId);
    if (mounted) {
      setState(() {
        _isLiked = liked;
      });
    }
  }

  // 게시글 수정 화면으로 이동
  void _navigateToEditPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(post: widget.post),
      ),
    ).then((result) {
      if (result == true) {
        // 수정 성공 시 현재 화면도 새로고침
        setState(() {});
      }
    });
  }

  // 게시글 삭제 확인 다이얼로그
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('게시글 삭제'),
          content: Text('정말로 이 게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost();
              },
              child: Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // 게시글 삭제
  Future<void> _deletePost() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      bool success = await FirebaseService.deletePost(widget.post.id);

      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // 이전 화면으로 돌아가기
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 삭제에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
        actions: [
          // 내가 쓴 글인 경우만 수정/삭제 버튼 표시
          if (_isMyPost)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToEditPost();
                } else if (value == 'delete') {
                  _showDeleteDialog();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('수정하기', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('삭제하기', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              icon: Icon(Icons.more_vert, color: Colors.black),
            ),
        ],
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
                        Row(
                          children: [
                            Text(
                              widget.post.author,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // 내가 쓴 글인 경우 배지 표시
                            if (_isMyPost)
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
                            Text(
                              ' · ${_getTimeAgo(widget.post.createdAt)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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
                        print('댓글 스트림 에러: ${snapshot.error}');
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 48),
                              SizedBox(height: 8),
                              Text(
                                '댓글을 불러올 수 없습니다.',
                                style: TextStyle(color: Colors.red, fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '에러: ${snapshot.error}',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {}); // 화면 새로고침
                                },
                                child: Text('다시 시도'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: Colors.green),
                                SizedBox(height: 8),
                                Text('댓글을 불러오는 중...'),
                              ],
                            ),
                          ),
                        );
                      }

                      List<Comment> comments = snapshot.data ?? [];
                      print('댓글 개수: ${comments.length}');

                      if (comments.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    color: Colors.grey.shade400, size: 48),
                                SizedBox(height: 8),
                                Text(
                                  '첫 번째 댓글을 남겨보세요!',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
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
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: null,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _addComment(), // 엔터키로 전송
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: (_isLoadingComment || _commentController.text.trim().isEmpty)
                        ? null
                        : _addComment,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (_isLoadingComment || _commentController.text.trim().isEmpty)
                            ? Colors.grey.shade300
                            : Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: (_isLoadingComment || _commentController.text.trim().isEmpty)
                            ? []
                            : [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
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
          )
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    bool isMyComment = comment.authorId == _currentUserId;
    bool isPostAuthor = comment.author == widget.post.author;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isMyComment
                ? Colors.blue.shade100
                : isPostAuthor
                ? Colors.green.shade100
                : Colors.grey.shade200,
            child: Icon(
              Icons.person,
              color: isMyComment
                  ? Colors.blue
                  : isPostAuthor
                  ? Colors.green
                  : Colors.grey.shade600,
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
                    // 게시글 작성자 배지
                    if (isPostAuthor)
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
                    // 내 댓글 배지
                    if (isMyComment)
                      Container(
                        margin: EdgeInsets.only(left: 6),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '나',
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
    String commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('댓글을 입력해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 로그인 확인
    if (!AuthService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인이 필요합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingComment = true;
    });

    try {
      print('댓글 작성 시작: $commentText');
      print('현재 사용자: ${AuthService.currentUserName} (${AuthService.currentUserId})');

      final newComment = Comment(
        id: '', // Firestore에서 자동 생성
        postId: widget.post.id,
        author: AuthService.currentUserName.isNotEmpty
            ? AuthService.currentUserName
            : '익명',
        authorId: AuthService.currentUserId,
        content: commentText,
        createdAt: DateTime.now(),
        isAuthor: widget.post.author == AuthService.currentUserName,
      );

      print('댓글 데이터: ${newComment.toFirestore()}');

      bool success = await FirebaseService.createComment(newComment);
      print('댓글 작성 결과: $success');

      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('댓글이 등록되었습니다.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('댓글 작성에 실패했습니다.');
      }
    } catch (e) {
      print('댓글 작성 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('댓글 등록 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingComment = false;
        });
      }
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}