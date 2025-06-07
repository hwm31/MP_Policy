import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자 정보
  static User? get currentUser => _auth.currentUser;
  static String get currentUserId => _auth.currentUser?.uid ?? '';

  // displayName이 없으면 이메일의 @ 앞부분을 사용
  static String get currentUserName {
    final user = _auth.currentUser;
    if (user == null) return '';

    // displayName이 있으면 사용
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    // displayName이 없으면 이메일의 @ 앞부분 사용
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@')[0];
    }

    // 둘 다 없으면 UID의 앞 8자리 사용
    return 'user_${user.uid.substring(0, 8)}';
  }

  static bool get isLoggedIn => _auth.currentUser != null;

  // 인증 상태 변화 스트림
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/패스워드로 회원가입
  static Future<UserCredential?> signUpWithEmailAndPassword(
      String email,
      String password,
      {String? displayName} // displayName 매개변수 추가
      ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 회원가입 후 displayName 설정
      if (displayName != null && displayName.isNotEmpty) {
        await result.user?.updateDisplayName(displayName);
        await result.user?.reload(); // 사용자 정보 새로고침
      }

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

  // 디버깅용 메서드
  static void printUserInfo() {
    final user = _auth.currentUser;
    print('=== AuthService 사용자 정보 ===');
    print('로그인 상태: $isLoggedIn');
    print('UID: $currentUserId');
    print('이메일: ${user?.email}');
    print('DisplayName: ${user?.displayName}');
    print('계산된 사용자명: $currentUserName');
    print('===============================');
  }
}