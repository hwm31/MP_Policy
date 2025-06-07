import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/auth_service.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _postsCollection = _firestore.collection('posts');
  static final CollectionReference _commentsCollection = _firestore.collection('comments');
  static final CollectionReference _likesCollection = _firestore.collection('likes');

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

  // 댓글 관련 기능들

  // 특정 게시글의 댓글 목록 가져오기 (수정된 버전)
  static Stream<List<Comment>> getCommentsStream(String postId) {
    return _commentsCollection
        .where('postId', isEqualTo: postId)
    // orderBy 제거 - 인덱스 오류 해결
        .snapshots()
        .map((snapshot) {
      List<Comment> comments = snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();

      // 클라이언트에서 정렬 (최신순으로 변경)
      comments.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!); // 최신순 정렬
      });

      return comments;
    });
  }

  // 대안: 인덱스가 완성되면 사용할 수 있는 서버 정렬 버전
  static Stream<List<Comment>> getCommentsStreamWithServerSort(String postId) {
    // 인덱스가 완성되면 이 함수를 사용
    return _commentsCollection
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)  // 최신순
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    });
  }

  // 새 댓글 작성
  static Future<bool> createComment(Comment comment) async {
    try {
      // 댓글 추가
      await _commentsCollection.add(comment.toFirestore());

      // 게시글의 댓글 수 업데이트
      await _updatePostCommentCount(comment.postId);

      return true;
    } catch (e) {
      print('댓글 작성 에러: $e');
      return false;
    }
  }

  // 게시글의 댓글 수 업데이트
  static Future<void> _updatePostCommentCount(String postId) async {
    try {
      // 해당 게시글의 댓글 수 계산
      QuerySnapshot comments = await _commentsCollection
          .where('postId', isEqualTo: postId)
          .get();

      int commentCount = comments.docs.length;

      // 게시글의 댓글 수 업데이트
      await _postsCollection.doc(postId).update({'comments': commentCount});
    } catch (e) {
      print('댓글 수 업데이트 에러: $e');
    }
  }

  // 좋아요 관련 기능들

  // 좋아요 토글 (추가/제거)
  static Future<bool> toggleLike(String postId, String userId) async {
    try {
      String likeId = '${postId}_$userId';
      DocumentReference likeRef = _likesCollection.doc(likeId);

      DocumentSnapshot likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        // 좋아요가 이미 있으면 제거
        await likeRef.delete();
      } else {
        // 좋아요가 없으면 추가
        await likeRef.set({
          'postId': postId,
          'userId': userId,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      // 게시글의 좋아요 수 업데이트
      await _updatePostLikeCount(postId);

      return true;
    } catch (e) {
      print('좋아요 토글 에러: $e');
      return false;
    }
  }

  // 사용자가 특정 게시글에 좋아요를 했는지 확인
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
      // 해당 게시글의 좋아요 수 계산
      QuerySnapshot likes = await _likesCollection
          .where('postId', isEqualTo: postId)
          .get();

      int likeCount = likes.docs.length;

      // 게시글의 좋아요 수 업데이트
      await _postsCollection.doc(postId).update({'likes': likeCount});
    } catch (e) {
      print('좋아요 수 업데이트 에러: $e');
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

      // 관련 좋아요들 삭제
      QuerySnapshot likes = await _likesCollection
          .where('postId', isEqualTo: postId)
          .get();

      for (QueryDocumentSnapshot like in likes.docs) {
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

  // 댓글 삭제
  static Future<bool> deleteComment(String commentId, String postId) async {
    try {
      await _commentsCollection.doc(commentId).delete();
      await _updatePostCommentCount(postId);
      return true;
    } catch (e) {
      print('댓글 삭제 에러: $e');
      return false;
    }
  }

  // 내가 쓴 게시글 스트림
  static Stream<List<Post>> getMyPostsStream({
    required String userId,
    String? category,
  }) {
    try {
      // 기본 쿼리 - orderBy 제거하여 인덱스 오류 방지
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

  // 게시글 수정
  static Future<bool> updatePost(String postId, Post updatedPost) async {
    try {
      await _postsCollection.doc(postId).update({
        'title': updatedPost.title,
        'content': updatedPost.content,
        'category': updatedPost.category,
        'updatedAt': Timestamp.fromDate(DateTime.now()), // 수정 시간 추가
      });
      return true;
    } catch (e) {
      print('게시글 수정 에러: $e');
      return false;
    }
  }

  // 초기 더미 데이터 추가 (한 번만 실행)
  static Future<void> addInitialData() async {
    try {
      // 기존 데이터가 있는지 확인
      QuerySnapshot existing = await _postsCollection.limit(1).get();
      if (existing.docs.isNotEmpty) {
        print('데이터가 이미 존재합니다.');
        return;
      }

      // 더미 데이터 추가
      List<Post> dummyPosts = [
        Post(
          id: '',
          title: '2025 IT 인재 양성 프로그램 후기',
          content: '6개월 과정 끝나고 취업까지 성공했어요! 합격 꿀팁들도 프로그램 참여 노하우까지 공유합니다.',
          category: '후기',
          author: '성철남',
          createdAt: DateTime.now().subtract(Duration(hours: 8)),
          likes: 0, // Firebase에서 자동 계산
          comments: 0, // Firebase에서 자동 계산
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