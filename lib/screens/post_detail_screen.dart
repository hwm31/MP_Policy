import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'edit_post_screen.dart';

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

  String get _currentUserId => AuthService.currentUserId;
  String get _currentUserName => AuthService.currentUserName;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _checkIfLiked();

    _commentController.addListener(() {
      setState(() {});
    });
  }

  // 내가 쓴 글인지 확인
  bool get _isMyPost {
    if (widget.post.authorId != null &&
        widget.post.authorId!.isNotEmpty &&
        widget.post.authorId == _currentUserId) {
      return true;
    }

    if (widget.post.author.trim() == _currentUserName.trim() &&
        _currentUserName.trim().isNotEmpty) {
      return true;
    }

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

  void _navigateToEditPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(post: widget.post),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

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

  Future<void> _deletePost() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      bool success = await FirebaseService.deletePost(widget.post.id);
      Navigator.of(context).pop();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 삭제에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
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
                            // 전체 댓글 수 (답글 포함)
                            StreamBuilder<List<Comment>>(
                              stream: FirebaseService.getAllCommentsStream(widget.post.id),
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

                  // 댓글 목록 (최상위 댓글만)
                  StreamBuilder<List<Comment>>(
                    stream: FirebaseService.getCommentsStream(widget.post.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
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
                    child: Icon(Icons.person, color: Colors.green, size: 18),
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
                      onSubmitted: (_) => _addComment(),
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
                          : Icon(Icons.send, color: Colors.white, size: 18),
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

  // 댓글 아이템 빌드
  Widget _buildCommentItem(Comment comment) {
    bool isMyComment = comment.authorId == _currentUserId;
    bool isPostAuthor = comment.author == widget.post.author;

    return Column(
      children: [
        // 메인 댓글
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
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
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 작성자 정보
                    Row(
                      children: [
                        Text(
                          comment.author,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        if (isPostAuthor)
                          Container(
                            margin: EdgeInsets.only(left: 6),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '작성자',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (isMyComment)
                          Container(
                            margin: EdgeInsets.only(left: 6),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '나',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
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
                    SizedBox(height: 6),

                    // 댓글 내용
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 8),

                    // 액션 버튼들
                    Row(
                      children: [
                        _buildCommentLikeButton(comment),
                        SizedBox(width: 20),
                        _buildReplyButton(comment),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 답글 목록
        StreamBuilder<List<Comment>>(
          stream: FirebaseService.getRepliesStream(comment.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox.shrink();
            }

            List<Comment> replies = snapshot.data!;

            return Container(
              margin: EdgeInsets.only(left: 50),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
              ),
              child: Column(
                children: replies.map((reply) => _buildReplyItem(reply)).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  // 답글 아이템 빌드
  Widget _buildReplyItem(Comment reply) {
    bool isMyReply = reply.authorId == _currentUserId;
    bool isPostAuthor = reply.author == widget.post.author;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isMyReply
                ? Colors.blue.shade100
                : isPostAuthor
                ? Colors.green.shade100
                : Colors.grey.shade200,
            child: Icon(
              Icons.person,
              color: isMyReply
                  ? Colors.blue
                  : isPostAuthor
                  ? Colors.green
                  : Colors.grey.shade600,
              size: 16,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.author,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    if (isPostAuthor)
                      Container(
                        margin: EdgeInsets.only(left: 4),
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '작성자',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (isMyReply)
                      Container(
                        margin: EdgeInsets.only(left: 4),
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '나',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Spacer(),
                    Text(
                      _getTimeAgo(reply.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  reply.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6),
                _buildCommentLikeButton(reply, isSmall: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 댓글 좋아요 버튼
  Widget _buildCommentLikeButton(Comment comment, {bool isSmall = false}) {
    return FutureBuilder<bool>(
      future: FirebaseService.isCommentLiked(comment.id, _currentUserId),
      builder: (context, snapshot) {
        bool isLiked = snapshot.data ?? false;

        return GestureDetector(
          onTap: () async {
            await FirebaseService.toggleCommentLike(comment.id, _currentUserId);
            setState(() {});
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: isSmall ? 14 : 16,
                color: isLiked ? Colors.red.shade400 : Colors.grey.shade500,
              ),
              if (comment.likes > 0) ...[
                SizedBox(width: 4),
                Text(
                  '${comment.likes}',
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12,
                    color: isLiked ? Colors.red.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // 답글 버튼
  Widget _buildReplyButton(Comment comment) {
    return GestureDetector(
      onTap: () => _showReplyDialog(comment),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 16,
            color: Colors.grey.shade500,
          ),
          SizedBox(width: 4),
          Text(
            '답글',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 답글 다이얼로그
  // PostDetailScreen의 _showReplyDialog 메서드를 이것으로 교체

  void _showReplyDialog(Comment parentComment) {
    final _replyController = TextEditingController();
    bool _isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7), // 배경 어둡게
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 헤더
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 20, 16, 0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(
                              Icons.reply,
                              color: Colors.grey.shade600,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${parentComment.author}님에게 답글',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '답글을 남겨보세요',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey.shade600,
                              size: 24,
                            ),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // 원댓글 미리보기
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.green.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parentComment.author,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  parentComment.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // 답글 입력창
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _replyController,
                        enabled: !_isSubmitting,
                        maxLines: 4,
                        minLines: 3,
                        autofocus: true,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: '정중하고 따뜻한 답글을 남겨보세요...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (text) {
                          setDialogState(() {}); // 버튼 상태 업데이트
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // 버튼들
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          // 취소 버튼
                          Expanded(
                            child: Container(
                              height: 48,
                              child: TextButton(
                                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  '취소',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // 답글 등록 버튼
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (_isSubmitting || _replyController.text.trim().isEmpty)
                                    ? null
                                    : () async {
                                  String replyText = _replyController.text.trim();

                                  setDialogState(() {
                                    _isSubmitting = true;
                                  });

                                  final newReply = Comment(
                                    id: '',
                                    postId: widget.post.id,
                                    author: AuthService.currentUserName,
                                    authorId: AuthService.currentUserId,
                                    content: replyText,
                                    createdAt: DateTime.now(),
                                    isAuthor: widget.post.author == AuthService.currentUserName,
                                    parentCommentId: parentComment.id,
                                  );

                                  bool success = await FirebaseService.createReply(newReply);

                                  Navigator.pop(context);

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text('답글이 등록되었습니다 ✨'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        margin: EdgeInsets.all(16),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text('답글 등록에 실패했습니다'),
                                          ],
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        margin: EdgeInsets.all(16),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _replyController.text.trim().isEmpty
                                      ? Colors.grey.shade300
                                      : Colors.green,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '답글 등록',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLoadingLike = true;
    });

    try {
      bool success = await FirebaseService.toggleLike(widget.post.id, _currentUserId);

      if (success) {
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
      final newComment = Comment(
        id: '',
        postId: widget.post.id,
        author: AuthService.currentUserName.isNotEmpty
            ? AuthService.currentUserName
            : '익명',
        authorId: AuthService.currentUserId,
        content: commentText,
        createdAt: DateTime.now(),
        isAuthor: widget.post.author == AuthService.currentUserName,
      );

      bool success = await FirebaseService.createComment(newComment);

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