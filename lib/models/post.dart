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

  // JSON 변환용 (나중에 Firebase용)
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