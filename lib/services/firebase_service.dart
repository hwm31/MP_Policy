import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _postsCollection = _firestore.collection('posts');

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

  // 게시글 좋아요 업데이트
  static Future<bool> updateLikes(String postId, int newLikes) async {
    try {
      await _postsCollection.doc(postId).update({'likes': newLikes});
      return true;
    } catch (e) {
      print('좋아요 업데이트 에러: $e');
      return false;
    }
  }

  // 게시글 댓글 수 업데이트
  static Future<bool> updateComments(String postId, int newComments) async {
    try {
      await _postsCollection.doc(postId).update({'comments': newComments});
      return true;
    } catch (e) {
      print('댓글 수 업데이트 에러: $e');
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

  // 게시글 삭제
  static Future<bool> deletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).delete();
      return true;
    } catch (e) {
      print('게시글 삭제 에러: $e');
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
          author: '성청년',
          createdAt: DateTime.now().subtract(Duration(hours: 8)),
          likes: 345,
          comments: 30,
          isHot: true,
        ),
        Post(
          id: '',
          title: '청년 정책 간담회 안내',
          content: '경기도 성남시에서 다음 주 참여할 온라인으로 정부 정책 간담회를 개최합니다.',
          category: '정보',
          author: '김태년 국회의원',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          likes: 200,
          comments: 10,
        ),
        Post(
          id: '',
          title: '창업 지원금 신청 자격 질문',
          content: '최근 창업에 관련해서 질문입니다. 사업자등록증을 하지 않은 상태에서도 신청 가능한지요?',
          category: '질문',
          author: '김창업',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          likes: 6,
          comments: 8,
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