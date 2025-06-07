import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String category;
  final String author;
  final String? authorId; // 추가: 사용자 ID로 더 정확한 본인 글 판별
  final DateTime? createdAt;
  final int likes;
  final int comments;
  final bool isHot;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    this.authorId, // 추가
    this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isHot = false,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory Post.fromFirestore(DocumentSnapshot doc) {
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

    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      author: data['author'] ?? '익명',
      authorId: data['authorId'], // 추가
      createdAt: createdAtDate,
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      isHot: data['isHot'] ?? false,
    );
  }

  // Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'author': author,
      'authorId': authorId, // 추가
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'likes': likes,
      'comments': comments,
      'isHot': isHot,
    };
  }

  @override
  String toString() {
    return 'Post{id: $id, title: $title, author: $author, authorId: $authorId}';
  }
}