import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자 정보
  static User? get currentUser => _auth.currentUser;
  static String get currentUserId => _auth.currentUser?.uid ?? '';
  static String get currentUserName => _auth.currentUser?.displayName ?? '';
  static bool get isLoggedIn => _auth.currentUser != null;

  // 인증 상태 변화 스트림
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/패스워드로 회원가입
  static Future<UserCredential?> signUpWithEmailAndPassword(
      String email,
      String password
      ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('회원가입 오류: $e');
      return null;
    }
  }

  // 이메일/패스워드로 로그인
  static Future<UserCredential?> signInWithEmailAndPassword(
      String email,
      String password
      ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('로그인 오류: $e');
      return null;
    }
  }

  // 로그아웃
  static Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print('로그아웃 오류: $e');
      return false;
    }
  }

  // 패스워드 재설정 이메일 전송
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('패스워드 재설정 오류: $e');
      return false;
    }
  }

  // 사용자 프로필 업데이트
  static Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
      return true;
    } catch (e) {
      print('프로필 업데이트 오류: $e');
      return false;
    }
  }

  // 이메일 인증 전송
  static Future<bool> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return true;
    } catch (e) {
      print('이메일 인증 전송 오류: $e');
      return false;
    }
  }

  // 계정 삭제
  static Future<bool> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      return true;
    } catch (e) {
      print('계정 삭제 오류: $e');
      return false;
    }
  }
}