import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String author;
  final String authorId;  // 추가
  final String content;
  final DateTime? createdAt;  // nullable로 변경
  final bool isAuthor;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.authorId,  // 추가
    required this.content,
    this.createdAt,  // nullable
    this.isAuthor = false,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    DateTime? createdAtDate;
    try {
      if (data['createdAt'] != null) {
        createdAtDate = (data['createdAt'] as Timestamp).toDate();
      }
    } catch (e) {
      print('createdAt 파싱 오류: $e');
      createdAtDate = DateTime.now();
    }

    return Comment(
      id: doc.id,
      postId: data['postId'] ?? '',
      author: data['author'] ?? '익명',
      authorId: data['authorId'] ?? '',  // 추가
      content: data['content'] ?? '',
      createdAt: createdAtDate,
      isAuthor: data['isAuthor'] ?? false,
    );
  }

  // Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'author': author,
      'authorId': authorId,  // 추가
      'content': content,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'isAuthor': isAuthor,
    };
  }

  @override
  String toString() {
    return 'Comment{id: $id, postId: $postId, author: $author, content: $content, createdAt: $createdAt}';
  }
}