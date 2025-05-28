import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String author;
  final String content;
  final DateTime createdAt;
  final bool isAuthor;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
    this.isAuthor = false,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      postId: data['postId'] ?? '',
      author: data['author'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAuthor: data['isAuthor'] ?? false,
    );
  }

  // Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'author': author,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAuthor': isAuthor,
    };
  }
}