import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedJob = '구직중';
  String _selectedEducation = '대학 졸업';
  String _selectedLocation = '서울특별시';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
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
                    Column(
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

              Spacer(),

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
}