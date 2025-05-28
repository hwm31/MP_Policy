import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자 가져오기
  static User? get currentUser => _auth.currentUser;

  // 현재 사용자 ID 가져오기
  static String get currentUserId => _auth.currentUser?.uid ?? 'anonymous';

  // 현재 사용자 이름 가져오기
  static String get currentUserName => _auth.currentUser?.displayName ?? '익명';

  // 현재 사용자 이메일 가져오기
  static String get currentUserEmail => _auth.currentUser?.email ?? '';

  // 로그인 상태 확인
  static bool get isLoggedIn => _auth.currentUser != null;

  // 인증 상태 스트림
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일로 회원가입
  static Future<bool> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 이름 설정
      await result.user?.updateDisplayName(name);

      return true;
    } catch (e) {
      print('회원가입 에러: $e');
      return false;
    }
  }

  // 이메일로 로그인
  static Future<bool> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print('로그인 에러: $e');
      return false;
    }
  }

  // 익명 로그인 (테스트용)
  static Future<bool> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();

      // 익명 사용자에게 임시 이름 설정
      await result.user?.updateDisplayName('익명사용자${DateTime.now().millisecondsSinceEpoch % 1000}');

      return true;
    } catch (e) {
      print('익명 로그인 에러: $e');
      return false;
    }
  }

  // 로그아웃
  static Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print('로그아웃 에러: $e');
      return false;
    }
  }

  // 비밀번호 재설정
  static Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('비밀번호 재설정 에러: $e');
      return false;
    }
  }
}