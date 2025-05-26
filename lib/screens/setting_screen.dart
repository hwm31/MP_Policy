import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '설정',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            Text('⚙️', style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green.shade200,
                    child: Icon(
                      Icons.person,
                      color: Colors.green.shade700,
                      size: 35,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '청년 사용자',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'youth@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                ],
              ),
            ),

            // 알림 설정
            _buildSectionTitle('알림 설정'),
            _buildSwitchTile(
              '푸시 알림',
              '새로운 게시글과 댓글 알림을 받습니다',
              Icons.notifications,
              _pushNotifications,
                  (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            _buildSwitchTile(
              '이메일 알림',
              '중요한 정책 업데이트를 이메일로 받습니다',
              Icons.email,
              _emailNotifications,
                  (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),

            _buildDivider(),

            // 앱 설정
            _buildSectionTitle('앱 설정'),
            _buildSwitchTile(
              '다크 모드',
              '어두운 테마를 사용합니다',
              Icons.dark_mode,
              _darkMode,
                  (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
            _buildMenuTile(
              '언어 설정',
              '한국어',
              Icons.language,
                  () {
                _showLanguageDialog();
              },
            ),
            _buildMenuTile(
              '폰트 크기',
              '보통',
              Icons.text_fields,
                  () {
                _showFontSizeDialog();
              },
            ),

            _buildDivider(),

            // 계정 설정
            _buildSectionTitle('계정'),
            _buildMenuTile(
              '프로필 수정',
              '',
              Icons.edit,
                  () {
                _showEditProfileDialog();
              },
            ),
            _buildMenuTile(
              '비밀번호 변경',
              '',
              Icons.lock,
                  () {
                _showChangePasswordDialog();
              },
            ),
            _buildMenuTile(
              '계정 연동',
              '',
              Icons.link,
                  () {
                _showAccountLinkDialog();
              },
            ),

            _buildDivider(),

            // 지원
            _buildSectionTitle('지원'),
            _buildMenuTile(
              '공지사항',
              '',
              Icons.announcement,
                  () {
                _showNoticeDialog();
              },
            ),
            _buildMenuTile(
              '자주 묻는 질문',
              '',
              Icons.help,
                  () {
                _showFAQDialog();
              },
            ),
            _buildMenuTile(
              '문의하기',
              '',
              Icons.contact_support,
                  () {
                _showContactDialog();
              },
            ),
            _buildMenuTile(
              '앱 버전',
              'v1.0.0',
              Icons.info,
                  () {
                _showVersionDialog();
              },
            ),

            _buildDivider(),

            // 로그아웃
            _buildMenuTile(
              '로그아웃',
              '',
              Icons.logout,
                  () {
                _showLogoutDialog();
              },
              isDestructive: true,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildMenuTile(String title, String trailing, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.green,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 8,
      color: Colors.grey.shade100,
      height: 24,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('언어 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('한국어'),
                trailing: Icon(Icons.check, color: Colors.green),
              ),
              ListTile(
                title: Text('English'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('폰트 크기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text('작게')),
              ListTile(
                title: Text('보통'),
                trailing: Icon(Icons.check, color: Colors.green),
              ),
              ListTile(title: Text('크게')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('프로필 수정'),
          content: Text('프로필 수정 기능은 준비 중입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('비밀번호 변경'),
          content: Text('비밀번호 변경 기능은 준비 중입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountLinkDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('계정 연동'),
          content: Text('소셜 계정 연동 기능은 준비 중입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showNoticeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('공지사항'),
          content: Text('새로운 공지사항이 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showFAQDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('자주 묻는 질문'),
          content: Text('FAQ 페이지는 준비 중입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('문의하기'),
          content: Text('이메일: support@youthcommunity.com\n전화: 1588-0000'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('앱 정보'),
          content: Text('청년 일자리 커뮤니티\n버전: 1.0.0\n\n개발: 청년 정책팀'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 로그아웃 로직
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그아웃되었습니다.')),
                );
              },
              child: Text('로그아웃', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}