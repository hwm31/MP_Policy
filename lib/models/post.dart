import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String category;
  final String author;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final bool isHot;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isHot = false,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      author: data['author'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'comments': comments,
      'isHot': isHot,
    };
  }

  // JSON 변환용 (기존 호환성)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'isHot': isHot,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      author: json['author'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isHot: json['isHot'] ?? false,
    );
  }
}