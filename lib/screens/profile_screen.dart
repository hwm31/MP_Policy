import 'package:flutter/material.dart';
import 'job_recommendation_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  String _selectedAge = '20대 초반';
  String _selectedField = '개발/IT';
  String _selectedLocation = '서울';

  final List<String> ageGroups = [
    '10대 후반', '20대 초반', '20대 중반', '20대 후반', '30대 초반', '30대 중반', '30대 후반'
  ];

  final List<String> jobFields = [
    '개발/IT', '디자인', '마케팅', '기획', '영업', '서비스', '제조/생산', '교육', '의료', '기타'
  ];

  final List<String> locations = [
    '서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주'
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Hojun*****';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 프로필 섹션
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // 프로필 이미지
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.green.shade200,
                        child: Icon(
                          Icons.person,
                          color: Colors.green.shade700,
                          size: 40,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Hojun*****',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '10시 28분',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // 일자리 정보 수정 섹션
              Text(
                '일자리 정보 수정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 20),

              // 희망 직무 분야
              _buildSectionTitle('희망 직무 분야'),
              SizedBox(height: 8),
              _buildTextField('예: 개발, 디자인, 마케팅 등', _nameController),

              SizedBox(height: 20),

              // 취업 상황
              _buildSectionTitle('취업 상황'),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildChip('구직중', true)),
                  SizedBox(width: 8),
                  Expanded(child: _buildChip('재직중', false)),
                  SizedBox(width: 8),
                  Expanded(child: _buildChip('창업', false)),
                ],
              ),

              SizedBox(height: 20),

              // 거주 지역
              _buildSectionTitle('거주 지역'),
              SizedBox(height: 8),
              _buildDropdown('서울특별시', locations, _selectedLocation, (value) {
                setState(() {
                  _selectedLocation = value!;
                });
              }),

              SizedBox(height: 20),

              // 학력
              _buildSectionTitle('학력'),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildChip('고등학교 졸업', false)),
                  SizedBox(width: 8),
                  Expanded(child: _buildChip('대학 재학', false)),
                  SizedBox(width: 8),
                  Expanded(child: _buildChip('대학 졸업', true)),
                ],
              ),

              SizedBox(height: 32),

              // 추천 정책 알림 받기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobRecommendationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '추천 정책 알림 받기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // 선택 상태 변경 로직
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(String hint, List<T> items, T selectedValue, ValueChanged<T?> onChanged) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          hint: Text(hint),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<T>>((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(value.toString()),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}