import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/policy_screen.dart';
import 'screens/community_screen.dart';
import 'screens/setting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '청년 일자리 커뮤니티',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'NotoSansKR',
      ),
      home: AuthWrapper(), // 인증 상태에 따라 화면 결정
      debugShowCheckedModeBanner: false,
    );
  }
}

// 인증 상태에 따라 로그인 화면 또는 메인 앱을 보여주는 위젯
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen(); // 로딩 중일 때 스플래시 화면
        }

        if (snapshot.hasData && AuthService.isLoggedIn) {
          return SplashToMainTransition(); // 로그인 되어 있으면 스플래시 후 메인 앱
        } else {
          return LoginScreen(); // 로그인 안 되어 있으면 로그인 화면
        }
      },
    );
  }
}

// 스플래시 화면 후 메인 앱으로 전환
class SplashToMainTransition extends StatefulWidget {
  @override
  _SplashToMainTransitionState createState() => _SplashToMainTransitionState();
}

class _SplashToMainTransitionState extends State<SplashToMainTransition> {
  @override
  void initState() {
    super.initState();
    // 3초 후 메인 앱으로 이동
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainNavigation()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

// 스플래시 화면 (토끼 캐릭터 3초 표시)
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 토끼 캐릭터
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: Text(
                  '🐰',
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),

            SizedBox(height: 24),

            // 앱 제목
            Text(
              '청년 일자리 정책 앱',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            SizedBox(height: 8),

            Text(
              '새로운 기회를 찾아보세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 40),

            // 로딩 인디케이터
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

// 메인 네비게이션 (로그인 후에만 표시)
class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),          // 홈 화면
    PolicyScreen(),        // 정책 화면
    CommunityScreen(),     // 커뮤니티 화면
    SettingScreen(),       // 설정 화면 (로그아웃 기능 포함)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.policy),
              label: 'Policy',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}