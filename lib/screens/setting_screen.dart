import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 계정 섹션
          _buildSectionHeader('계정'),
          _buildMenuItem(
            icon: Icons.person,
            title: '프로필 수정',
            onTap: () => _showProfileDialog(),
          ),
          _buildMenuItem(
            icon: Icons.lock,
            title: '비밀번호 변경',
            onTap: () => _showPasswordDialog(),
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: '로그아웃',
            onTap: () => _showLogoutDialog(),
            isDestructive: true,
          ),

          SizedBox(height: 24),

          // 알림 섹션
          _buildSectionHeader('알림'),
          _buildMenuItem(
            icon: Icons.notifications,
            title: '푸시 알림',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: Colors.green,
            ),
          ),
          _buildMenuItem(
            icon: Icons.email,
            title: '이메일 알림',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: Colors.green,
            ),
          ),

          SizedBox(height: 24),

          // 앱 정보 섹션
          _buildSectionHeader('앱 정보'),
          _buildMenuItem(
            icon: Icons.help,
            title: '도움말',
            onTap: () => _showHelpDialog(),
          ),
          _buildMenuItem(
            icon: Icons.info,
            title: '앱 버전',
            trailing: Text(
              'v1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          _buildMenuItem(
            icon: Icons.contact_support,
            title: '문의하기',
            onTap: () => _showContactDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, top: 8),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.green,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: trailing ?? (onTap != null ? Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ) : null),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: Colors.grey.shade50,
      ),
    );
  }

  void _showProfileDialog() {
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

  void _showPasswordDialog() {
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('도움말'),
          content: Text('청년 일자리 정책 앱 사용법:\n\n1. 프로필을 설정하세요\n2. 맞춤 정책을 확인하세요\n3. 관심있는 정책에 신청하세요'),
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
          content: Text('이메일: support@youth-policy.com\n전화: 1588-0000\n\n문의사항이 있으시면 언제든 연락해주세요.'),
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
}