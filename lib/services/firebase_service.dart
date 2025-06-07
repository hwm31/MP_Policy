import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/auth_service.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _postsCollection = _firestore.collection('posts');
  static final CollectionReference _commentsCollection = _firestore.collection('comments');
  static final CollectionReference _likesCollection = _firestore.collection('likes');

  // ========== 게시글 관련 메서드들 ==========

  // 게시글 목록 스트림으로 가져오기
  static Stream<List<Post>> getPostsStream({String? category}) {
    Query query = _postsCollection.orderBy('createdAt', descending: true);

    if (category != null && category != '전체') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  // 새 게시글 작성
  static Future<bool> createPost(Post post) async {
    try {
      await _postsCollection.add(post.toFirestore());
      return true;
    } catch (e) {
      print('게시글 작성 에러: $e');
      return false;
    }
  }

  // 특정 게시글 가져오기
  static Future<Post?> getPost(String postId) async {
    try {
      DocumentSnapshot doc = await _postsCollection.doc(postId).get();
      if (doc.exists) {
        return Post.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('게시글 가져오기 에러: $e');
      return null;
    }
  }

  // 게시글 수정
  static Future<bool> updatePost(String postId, Post updatedPost) async {
    try {
      await _postsCollection.doc(postId).update({
        'title': updatedPost.title,
        'content': updatedPost.content,
        'category': updatedPost.category,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('게시글 수정 에러: $e');
      return false;
    }
  }

  // 게시글 삭제
  static Future<bool> deletePost(String postId) async {
    try {
      // 관련 댓글들 삭제
      QuerySnapshot comments = await _commentsCollection
          .where('postId', isEqualTo: postId)
          .get();

      for (QueryDocumentSnapshot comment in comments.docs) {
        await comment.reference.delete();
      }

      // 관련 댓글 좋아요들 삭제
      QuerySnapshot commentLikes = await _firestore
          .collection('comment_likes')
          .where('commentId', whereIn: comments.docs.map((doc) => doc.id).toList())
          .get();

      for (QueryDocumentSnapshot like in commentLikes.docs) {
        await like.reference.delete();
      }

      // 관련 게시글 좋아요들 삭제
      QuerySnapshot postLikes = await _likesCollection
          .where('postId', isEqualTo: postId)
          .get();

      for (QueryDocumentSnapshot like in postLikes.docs) {
        await like.reference.delete();
      }

      // 게시글 삭제
      await _postsCollection.doc(postId).delete();

      return true;
    } catch (e) {
      print('게시글 삭제 에러: $e');
      return false;
    }
  }

  // 내가 쓴 게시글 스트림
  static Stream<List<Post>> getMyPostsStream({
    required String userId,
    String? category,
  }) {
    try {
      Query query = _postsCollection.where('author', isEqualTo: AuthService.currentUserName);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      return query.snapshots().map((snapshot) {
        List<Post> posts = snapshot.docs.map((doc) {
          return Post.fromFirestore(doc);
        }).toList();

        // 클라이언트 측에서 정렬 (최신순)
        posts.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });

        return posts;
      });
    } catch (e) {
      print('내 게시글 스트림 에러: $e');
      return Stream.value([]);
    }
  }

  // ========== 댓글 관련 메서드들 ==========

  // 최상위 댓글만 가져오기 (UI 표시용)
  static Stream<List<Comment>> getCommentsStream(String postId) {
    return _commentsCollection
        .where('postId', isEqualTo: postId)
        .where('parentCommentId', isNull: true) // 최상위 댓글만
        .snapshots()
        .map((snapshot) {
      List<Comment> comments = snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();

      // 클라이언트에서 정렬 (최신순)
      comments.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return comments;
    });
  }

  // 모든 댓글 가져오기 (답글 포함 - 댓글 수 계산용)
  static Stream<List<Comment>> getAllCommentsStream(String postId) {
    return _commentsCollection
        .where('postId', isEqualTo: postId)
    // parentCommentId 조건 없음 = 모든 댓글과 답글 포함
        .snapshots()
        .map((snapshot) {
      List<Comment> allComments = snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
      return allComments;
    });
  }

  // 특정 댓글의 답글들 가져오기
  static Stream<List<Comment>> getRepliesStream(String parentCommentId) {
    return _commentsCollection
        .where('parentCommentId', isEqualTo: parentCommentId)
        .snapshots()
        .map((snapshot) {
      List<Comment> replies = snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();

      // 클라이언트에서 시간순 정렬 (답글은 오래된 순)
      replies.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return a.createdAt!.compareTo(b.createdAt!);
      });

      return replies;
    });
  }

  // 새 댓글 작성
  static Future<bool> createComment(Comment comment) async {
    try {
      await _commentsCollection.add(comment.toFirestore());
      await _updatePostCommentCount(comment.postId);
      return true;
    } catch (e) {
      print('댓글 작성 에러: $e');
      return false;
    }
  }

  // 답글 작성
  static Future<bool> createReply(Comment reply) async {
    try {
      await _commentsCollection.add(reply.toFirestore());
      await _updatePostCommentCount(reply.postId);
      return true;
    } catch (e) {
      print('답글 작성 오류: $e');
      return false;
    }
  }

  // 댓글 삭제
  static Future<bool> deleteComment(String commentId, String postId) async {
    try {
      // 해당 댓글의 모든 답글도 삭제
      QuerySnapshot replies = await _commentsCollection
          .where('parentCommentId', isEqualTo: commentId)
          .get();

      for (QueryDocumentSnapshot reply in replies.docs) {
        await reply.reference.delete();
      }

      // 댓글 삭제
      await _commentsCollection.doc(commentId).delete();

      // 댓글 수 업데이트
      await _updatePostCommentCount(postId);
      return true;
    } catch (e) {
      print('댓글 삭제 에러: $e');
      return false;
    }
  }

  // 게시글의 댓글 수 업데이트 (답글 포함)
  static Future<void> _updatePostCommentCount(String postId) async {
    try {
      QuerySnapshot comments = await _commentsCollection
          .where('postId', isEqualTo: postId)
          .get(); // 모든 댓글과 답글 포함

      int commentCount = comments.docs.length;
      await _postsCollection.doc(postId).update({'comments': commentCount});

      print('댓글 수 업데이트: $postId -> $commentCount개 (답글 포함)');
    } catch (e) {
      print('댓글 수 업데이트 에러: $e');
    }
  }

  // ========== 좋아요 관련 메서드들 ==========

  // 게시글 좋아요 토글
  static Future<bool> toggleLike(String postId, String userId) async {
    try {
      String likeId = '${postId}_$userId';
      DocumentReference likeRef = _likesCollection.doc(likeId);

      DocumentSnapshot likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        await likeRef.delete();
      } else {
        await likeRef.set({
          'postId': postId,
          'userId': userId,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await _updatePostLikeCount(postId);
      return true;
    } catch (e) {
      print('좋아요 토글 에러: $e');
      return false;
    }
  }

  // 게시글 좋아요 상태 확인
  static Future<bool> isLiked(String postId, String userId) async {
    try {
      String likeId = '${postId}_$userId';
      DocumentSnapshot likeDoc = await _likesCollection.doc(likeId).get();
      return likeDoc.exists;
    } catch (e) {
      print('좋아요 확인 에러: $e');
      return false;
    }
  }

  // 게시글의 좋아요 수 업데이트
  static Future<void> _updatePostLikeCount(String postId) async {
    try {
      QuerySnapshot likes = await _likesCollection
          .where('postId', isEqualTo: postId)
          .get();

      int likeCount = likes.docs.length;
      await _postsCollection.doc(postId).update({'likes': likeCount});
    } catch (e) {
      print('좋아요 수 업데이트 에러: $e');
    }
  }

  // 댓글 좋아요 토글
  static Future<bool> toggleCommentLike(String commentId, String userId) async {
    try {
      String likeId = 'comment_${commentId}_$userId';
      DocumentReference likeRef = _firestore.collection('comment_likes').doc(likeId);

      DocumentSnapshot likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        await likeRef.delete();
      } else {
        await likeRef.set({
          'commentId': commentId,
          'userId': userId,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await _updateCommentLikeCount(commentId);
      return true;
    } catch (e) {
      print('댓글 좋아요 토글 오류: $e');
      return false;
    }
  }

  // 댓글 좋아요 상태 확인
  static Future<bool> isCommentLiked(String commentId, String userId) async {
    try {
      String likeId = 'comment_${commentId}_$userId';
      DocumentSnapshot likeDoc = await _firestore.collection('comment_likes').doc(likeId).get();
      return likeDoc.exists;
    } catch (e) {
      print('댓글 좋아요 확인 오류: $e');
      return false;
    }
  }

  // 댓글의 좋아요 수 업데이트
  static Future<void> _updateCommentLikeCount(String commentId) async {
    try {
      QuerySnapshot likes = await _firestore
          .collection('comment_likes')
          .where('commentId', isEqualTo: commentId)
          .get();

      int likeCount = likes.docs.length;
      await _commentsCollection.doc(commentId).update({'likes': likeCount});
    } catch (e) {
      print('댓글 좋아요 수 업데이트 오류: $e');
    }
  }

  // ========== 초기 데이터 관련 ==========

  // 초기 더미 데이터 추가 (한 번만 실행)
  static Future<void> addInitialData() async {
    try {
      QuerySnapshot existing = await _postsCollection.limit(1).get();
      if (existing.docs.isNotEmpty) {
        print('데이터가 이미 존재합니다.');
        return;
      }

      List<Post> dummyPosts = [
        Post(
          id: '',
          title: '2025 IT 인재 양성 프로그램 후기',
          content: '6개월 과정 끝나고 취업까지 성공했어요! 합격 꿀팁들도 프로그램 참여 노하우까지 공유합니다.',
          category: '후기',
          author: '성철남',
          createdAt: DateTime.now().subtract(Duration(hours: 8)),
          likes: 0,
          comments: 0,
          isHot: true,
        ),
        Post(
          id: '',
          title: '청년 정책 간담회 안내',
          content: '경기도 성남시에서 다음 주 참여할 온라인으로 정부 정책 간담회를 개최합니다.',
          category: '정보',
          author: '김태진',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          likes: 0,
          comments: 0,
        ),
        Post(
          id: '',
          title: '창업 지원금 신청 자격 질문',
          content: '최근 창업에 관련해서 질문입니다. 사업자등록증을 하지 않은 상태에서도 신청 가능한지요?',
          category: '질문',
          author: '김창업',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          likes: 0,
          comments: 0,
        ),
      ];

      for (Post post in dummyPosts) {
        await createPost(post);
      }

      print('초기 더미 데이터가 추가되었습니다.');
    } catch (e) {
      print('초기 데이터 추가 에러: $e');
    }
  }
}