import 'package:flutter/material.dart';

class PolicyScreen extends StatefulWidget {
  @override
  _PolicyScreenState createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  String _selectedCategory = '전체';

  final List<String> categories = ['전체', '일자리', '주거', '창업', '교육', '생활지원'];

  // 정책 더미 데이터
  final List<PolicyItem> policies = [
    PolicyItem(
      title: '2025 청년 창업 지원 사업',
      description: '만 39세 이하 청년의 창업을 위한 자금 지원 및 멘토링 프로그램',
      category: '창업',
      organization: '중소벤처기업부',
      deadline: '2025-06-30',
      amount: '최대 5,000만원',
      status: '진행중',
    ),
    PolicyItem(
      title: '청년 주거급여 지원',
      description: '청년층의 주거비 부담 완화를 위한 월세 지원 정책',
      category: '주거',
      organization: '국토교통부',
      deadline: '상시',
      amount: '월 최대 20만원',
      status: '진행중',
    ),
    PolicyItem(
      title: 'K-디지털 트레이닝',
      description: 'AI, 빅데이터 등 디지털 신기술 분야 직업훈련 과정',
      category: '교육',
      organization: '고용노동부',
      deadline: '2025-07-15',
      amount: '무료 + 훈련수당',
      status: '모집중',
    ),
    PolicyItem(
      title: '국민취업지원제도',
      description: '취업을 희망하는 청년에게 통합적인 취업지원 서비스 제공',
      category: '일자리',
      organization: '고용노동부',
      deadline: '상시',
      amount: '월 50만원',
      status: '진행중',
    ),
    PolicyItem(
      title: '청년 전세자금 대출',
      description: '무주택 청년의 전세자금 대출 지원',
      category: '주거',
      organization: '한국주택금융공사',
      deadline: '상시',
      amount: '최대 2억원',
      status: '진행중',
    ),
    PolicyItem(
      title: '청년 내일채움공제',
      description: '중소기업 취업 청년 장기근속 지원',
      category: '일자리',
      organization: '중소벤처기업부',
      deadline: '상시',
      amount: '최대 1,200만원',
      status: '진행중',
    ),
    PolicyItem(
      title: '청년문화예술패스',
      description: '만 24세 이하 청년 문화예술 관람료 지원',
      category: '생활지원',
      organization: '문화체육관광부',
      deadline: '2025-08-31',
      amount: '월 5만원',
      status: '모집중',
    ),
    PolicyItem(
      title: '스마트팜 청년 창업 지원',
      description: '스마트팜 분야 청년 창업자 육성 및 지원',
      category: '창업',
      organization: '농림축산식품부',
      deadline: '2025-09-30',
      amount: '최대 1억원',
      status: '예정',
    ),
  ];

  List<PolicyItem> get filteredPolicies {
    if (_selectedCategory == '전체') {
      return policies;
    }
    return policies.where((policy) => policy.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '정책 정보',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            Text('📋', style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 카테고리 탭
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade100 : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 필터 결과 표시
          if (_selectedCategory != '전체')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_selectedCategory} 정책',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '총 ${filteredPolicies.length}개',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

          // 정책 목록
          Expanded(
            child: ListView.builder(
              itemCount: filteredPolicies.length,
              itemBuilder: (context, index) {
                final policy = filteredPolicies[index];
                return _buildPolicyCard(policy);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(PolicyItem policy) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상태와 카테고리
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(policy.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  policy.status,
                  style: TextStyle(
                    color: _getStatusTextColor(policy.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(policy.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  policy.category,
                  style: TextStyle(
                    color: _getCategoryTextColor(policy.category),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // 제목
          Text(
            policy.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 4),

          // 주관 기관
          Text(
            policy.organization,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 8),

          // 설명
          Text(
            policy.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 12),

          // 지원 금액과 마감일
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 16,
                color: Colors.green,
              ),
              SizedBox(width: 4),
              Text(
                policy.amount,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.orange,
              ),
              SizedBox(width: 4),
              Text(
                '마감: ${policy.deadline}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '진행중':
        return Colors.green.shade100;
      case '모집중':
        return Colors.blue.shade100;
      case '예정':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case '진행중':
        return Colors.green.shade700;
      case '모집중':
        return Colors.blue.shade700;
      case '예정':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '일자리':
        return Colors.blue.shade100;
      case '주거':
        return Colors.green.shade100;
      case '창업':
        return Colors.purple.shade100;
      case '교육':
        return Colors.orange.shade100;
      case '생활지원':
        return Colors.pink.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category) {
      case '일자리':
        return Colors.blue.shade700;
      case '주거':
        return Colors.green.shade700;
      case '창업':
        return Colors.purple.shade700;
      case '교육':
        return Colors.orange.shade700;
      case '생활지원':
        return Colors.pink.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}

// 정책 아이템 모델
class PolicyItem {
  final String title;
  final String description;
  final String category;
  final String organization;
  final String deadline;
  final String amount;
  final String status;

  PolicyItem({
    required this.title,
    required this.description,
    required this.category,
    required this.organization,
    required this.deadline,
    required this.amount,
    required this.status,
  });
}