import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotPasswordController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();
  final _signUpDisplayNameController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로그인 제목
                Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                SizedBox(height: 80),

                // 이메일 입력
                Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.grey.shade400, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Your Email',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          hintText: 'example@email.com',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // 비밀번호 입력
                Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock, color: Colors.grey.shade400, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          hintText: '••••••••',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 60),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Forgot Password 링크
                TextButton(
                  onPressed: _isLoading ? null : () {
                    _showForgotPasswordDialog();
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // 회원가입 안내
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an Account? ",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : () {
                        _showSignUpDialog();
                      },
                      child: Text(
                        'Create one',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 실제 Firebase 로그인 처리
  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    // 이메일 형식 간단 검증
    if (!_emailController.text.contains('@')) {
      _showErrorSnackBar('올바른 이메일 형식을 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? result = await AuthService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result != null) {
        // 로그인 성공 - AuthWrapper가 자동으로 메인 화면으로 전환
        _showSuccessSnackBar('로그인 성공!');
      } else {
        _showErrorSnackBar('로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e.code);
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar('로그인 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Firebase 에러 메시지 변환
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '비밀번호가 잘못되었습니다.';
      case 'invalid-email':
        return '올바른 이메일 형식을 입력해주세요.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'too-many-requests':
        return '너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      default:
        return '로그인에 실패했습니다. 다시 시도해주세요.';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 비밀번호 찾기 다이얼로그
  void _showForgotPasswordDialog() {
    _forgotPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('비밀번호 찾기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('등록된 이메일로 비밀번호 재설정 링크를 보내드립니다.'),
              SizedBox(height: 16),
              TextField(
                controller: _forgotPasswordController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: '이메일을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                if (_forgotPasswordController.text.trim().isNotEmpty) {
                  try {
                    await AuthService.sendPasswordResetEmail(
                        _forgotPasswordController.text.trim()
                    );
                    Navigator.of(context).pop();
                    _showSuccessSnackBar('비밀번호 재설정 이메일을 보냈습니다.');
                  } catch (e) {
                    _showErrorSnackBar('이메일 전송에 실패했습니다.');
                  }
                } else {
                  _showErrorSnackBar('이메일을 입력해주세요.');
                }
              },
              child: Text('전송'),
            ),
          ],
        );
      },
    );
  }

  // 회원가입 다이얼로그
  void _showSignUpDialog() {
    _signUpEmailController.clear();
    _signUpPasswordController.clear();
    _signUpConfirmPasswordController.clear();
    _signUpDisplayNameController.clear(); // 추가

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원가입'),
          content: SingleChildScrollView( // 스크롤 가능하게 변경
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이름 입력 필드 추가
                TextField(
                  controller: _signUpDisplayNameController,
                  decoration: InputDecoration(
                    hintText: '이름 (예: 홍길동)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _signUpEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: '이메일',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _signUpPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호 (6자 이상)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _signUpConfirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호 확인',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await _handleSignUp();
              },
              child: Text('가입'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignUp() async {
    String name = _signUpDisplayNameController.text.trim(); // 추가
    String email = _signUpEmailController.text.trim();
    String password = _signUpPasswordController.text;
    String confirmPassword = _signUpConfirmPasswordController.text;

    // 유효성 검사 수정
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar('모든 필드를 입력해주세요.');
      return;
    }

    if (!email.contains('@')) {
      _showErrorSnackBar('올바른 이메일 형식을 입력해주세요.');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar('비밀번호가 일치하지 않습니다.');
      return;
    }

    try {
      // displayName과 함께 회원가입
      UserCredential? result = await AuthService.signUpWithEmailAndPassword(
        email,
        password,
        displayName: name, // 이름 전달
      );

      if (result != null) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('회원가입이 완료되었습니다! 안녕하세요, $name님!');

        // 사용자 정보 출력 (디버깅용)
        print('=== 회원가입 완료 ===');
        print('사용자명: ${AuthService.currentUserName}');
        print('이메일: ${AuthService.currentUser?.email}');
        print('====================');
      } else {
        _showErrorSnackBar('회원가입에 실패했습니다.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getSignUpErrorMessage(e.code);
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  String _getSignUpErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '올바른 이메일 형식을 입력해주세요.';
      default:
        return '회원가입에 실패했습니다. 다시 시도해주세요.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotPasswordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    _signUpDisplayNameController.dispose(); // 추가
    super.dispose();
  }
}