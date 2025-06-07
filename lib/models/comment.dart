import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String author;
  final String authorId;
  final String content;
  final DateTime? createdAt;
  final bool isAuthor;
  final int likes; // 좋아요 수
  final String? parentCommentId; // 답글인 경우 부모 댓글 ID
  final bool isReply; // 답글 여부

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.authorId,
    required this.content,
    this.createdAt,
    this.isAuthor = false,
    this.likes = 0,
    this.parentCommentId,
    this.isReply = false,
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
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      createdAt: createdAtDate,
      isAuthor: data['isAuthor'] ?? false,
      likes: data['likes'] ?? 0,
      parentCommentId: data['parentCommentId'],
      isReply: data['parentCommentId'] != null,
    );
  }

  // Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'author': author,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'isAuthor': isAuthor,
      'likes': likes,
      'parentCommentId': parentCommentId,
    };
  }

  @override
  String toString() {
    return 'Comment{id: $id, author: $author, content: $content, isReply: $isReply}';
  }
}