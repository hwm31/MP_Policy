import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart'; // 추가

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = '질문';
  bool _isLoading = false;

  final List<String> categories = ['질문', '정보', '후기'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '새 글 작성하기',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          // 현재 사용자 정보 표시 (디버깅용)
          Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AuthService.isLoggedIn
                  ? AuthService.currentUserName.isNotEmpty
                  ? AuthService.currentUserName
                  : '로그인필요'
                  : '미로그인',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
                : Text(
              '완료',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로그인 상태 확인 알림
            if (!AuthService.isLoggedIn)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '로그인이 필요합니다. 로그인 후 글을 작성해주세요.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 글 주제 선택
            Text(
              '글 주제 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 12),

            // 카테고리 드롭다운
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: _isLoading ? null : (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(height: 24),

            // 제목
            Text(
              '제목',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 12),

            TextField(
              controller: _titleController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),

            SizedBox(height: 24),

            // 글 내용 작성
            Text(
              '글 내용 작성',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 12),

            Text(
              '욕설, 비하, 허위사실 등의 내용을 작성할 경우 통보 없이 글이 삭제될 수 있습니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 12),

            Expanded(
              child: TextField(
                controller: _contentController,
                enabled: !_isLoading,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),

      // 글 등록하기 버튼
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _createPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLoading ? Colors.grey : Colors.green,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text(
                '업로드 중...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          )
              : Text(
            '글 등록하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createPost() async {
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

    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('제목과 내용을 모두 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 디버깅: 게시글 작성 전 사용자 정보 확인
      print('=== 게시글 작성 시 사용자 정보 ===');
      print('AuthService.isLoggedIn: ${AuthService.isLoggedIn}');
      print('AuthService.currentUserId: "${AuthService.currentUserId}"');
      print('AuthService.currentUserName: "${AuthService.currentUserName}"');
      print('AuthService.currentUser?.displayName: "${AuthService.currentUser?.displayName}"');
      print('AuthService.currentUser?.email: "${AuthService.currentUser?.email}"');
      print('================================');

      final newPost = Post(
        id: '', // Firestore에서 자동 생성
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        author: AuthService.currentUserName.isNotEmpty
            ? AuthService.currentUserName
            : '익명', // 이름이 없으면 익명으로
        authorId: AuthService.currentUserId, // 사용자 ID 추가 (Post 모델에 authorId 필드가 있다면)
        createdAt: DateTime.now(),
      );

      // 디버깅: 생성될 게시글 정보 확인
      print('=== 생성될 게시글 정보 ===');
      print('title: "${newPost.title}"');
      print('author: "${newPost.author}"');
      print('authorId: "${newPost.authorId ?? "없음"}"');
      print('category: "${newPost.category}"');
      print('========================');

      bool success = await FirebaseService.createPost(newPost);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글이 성공적으로 작성되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // 성공 시 true 반환
      } else {
        throw Exception('게시글 작성에 실패했습니다.');
      }
    } catch (e) {
      print('게시글 작성 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('게시글 작성 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}