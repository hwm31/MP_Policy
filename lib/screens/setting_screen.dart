import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _selectedJob = '구직중';
  String _selectedEducation = '대학 졸업';
  String _selectedLocation = '서울특별시';
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 프로필 섹션
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // 프로필 이미지
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Colors.green,
                        size: 35,
                      ),
                    ),
                    SizedBox(width: 16),
                    // 사용자 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hojun*****',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '10시 28분',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 프로필 수정 버튼
                    IconButton(
                      onPressed: () {
                        _showProfileEditDialog();
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // 일자리 정보 수정
              Text(
                '일자리 정보 수정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 20),

              // 희망 직무 분야
              _buildSectionTitle('희망 직무 분야'),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: '예: 개발, 디자인, 마케팅 등',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),

              SizedBox(height: 20),

              // 취업 상황
              _buildSectionTitle('취업 상황'),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton('구직중', _selectedJob == '구직중', () {
                      setState(() {
                        _selectedJob = '구직중';
                      });
                    }),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildOptionButton('재직중', _selectedJob == '재직중', () {
                      setState(() {
                        _selectedJob = '재직중';
                      });
                    }),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildOptionButton('창업', _selectedJob == '창업', () {
                      setState(() {
                        _selectedJob = '창업';
                      });
                    }),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // 거주 지역
              _buildSectionTitle('거주 지역'),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedLocation,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 학력
              _buildSectionTitle('학력'),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton('고등학교 졸업', _selectedEducation == '고등학교 졸업', () {
                      setState(() {
                        _selectedEducation = '고등학교 졸업';
                      });
                    }),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildOptionButton('대학 재학', _selectedEducation == '대학 재학', () {
                      setState(() {
                        _selectedEducation = '대학 재학';
                      });
                    }),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildOptionButton('대학 졸업', _selectedEducation == '대학 졸업', () {
                      setState(() {
                        _selectedEducation = '대학 졸업';
                      });
                    }),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // 추천 정책 알림 받기 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _showRecommendationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '추천 정책 알림 받기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // 구분선
              Divider(thickness: 1, color: Colors.grey.shade300),

              SizedBox(height: 20),

              // 앱 설정 섹션
              Text(
                '앱 설정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 16),

              // 알림 설정
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

              SizedBox(height: 16),

              // 기타 설정
              _buildMenuTile(
                '도움말',
                '',
                Icons.help,
                    () => _showHelpDialog(),
              ),

              _buildMenuTile(
                '앱 버전',
                'v1.0.0',
                Icons.info,
                    () => _showVersionDialog(),
              ),

              _buildMenuTile(
                '문의하기',
                '',
                Icons.contact_support,
                    () => _showContactDialog(),
              ),

              _buildMenuTile(
                '로그아웃',
                '',
                Icons.logout,
                    () => _showLogoutDialog(),
                isDestructive: true,
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: TextStyle(fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildMenuTile(String title, String trailing, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
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
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Colors.grey.shade50,
      ),
    );
  }

  void _showProfileEditDialog() {
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

  void _showRecommendationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('맞춤 추천'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('입력하신 정보를 바탕으로 맞춤 정책을 추천해드립니다.'),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '추천 정책',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• 청년 취업 지원 프로그램'),
                    Text('• K-디지털 트레이닝'),
                    Text('• 청년 창업 지원 사업'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('닫기'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('맞춤 추천 알림이 설정되었습니다!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('알림 받기', style: TextStyle(color: Colors.white)),
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
}