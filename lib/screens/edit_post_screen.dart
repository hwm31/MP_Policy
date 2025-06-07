import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  EditPostScreen({required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = '질문';
  bool _isLoading = false;

  final List<String> categories = ['질문', '정보', '후기'];

  @override
  void initState() {
    super.initState();
    // 기존 게시글 데이터로 초기화
    _titleController.text = widget.post.title;
    _contentController.text = widget.post.content;
    _selectedCategory = widget.post.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '게시글 수정',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updatePost,
            child: Text(
              '완료',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 선택
            Text(
              '카테고리',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
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
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green.shade100 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.green.shade700 : Colors.grey.shade600,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // 제목 입력
            Text(
              '제목',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 1,
            ),

            SizedBox(height: 24),

            // 내용 입력
            Text(
              '내용',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 10,
              minLines: 5,
            ),

            SizedBox(height: 32),

            // 수정 버튼
            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      '수정 중...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updatePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '수정 완료',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePost() async {
    // 유효성 검사
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('제목을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('내용을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 수정된 게시글 객체 생성
      final updatedPost = Post(
        id: widget.post.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        author: widget.post.author,
        createdAt: widget.post.createdAt,
        likes: widget.post.likes,
        comments: widget.post.comments,
        isHot: widget.post.isHot,
      );

      bool success = await FirebaseService.updatePost(widget.post.id, updatedPost);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글이 수정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // 수정 성공 결과 반환
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 수정에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: ${e.toString()}'),
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