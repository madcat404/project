import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/as_models.dart'; // 모델
import '../services/as_service.dart'; // 서비스
import 'as_detail_screen.dart'; // 상세 화면
import 'home_page.dart'; // [추가] 홈으로 이동하기 위해 import

class AsBoardScreen extends StatefulWidget {
  const AsBoardScreen({Key? key}) : super(key: key);

  @override
  State<AsBoardScreen> createState() => _AsBoardScreenState();
}

class _AsBoardScreenState extends State<AsBoardScreen> {
  List<AsRequest> _requests = [];
  List<AsRequest> _filteredRequests = [];
  bool _isLoading = true;
  String _selectedStatus = '전체';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<AsRequest> data = await AsService.getAsRequests();
      if (mounted) {
        setState(() {
          _requests = data;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedStatus == '전체') {
        _filteredRequests = _requests;
      } else {
        _filteredRequests = _requests.where((item) => item.status == _selectedStatus).toList();
      }
    });
  }

  void _onFilterChanged(String status) {
    setState(() {
      _selectedStatus = status;
      _applyFilter();
    });
  }

  // [추가] 하단 탭 클릭 시 HomePage로 이동하며 해당 탭 열기 (다른 화면들과 동일한 로직)
  void _onItemTapped(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
          (Route<dynamic> route) => false,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '접수': return Colors.redAccent;
      case '진행중': return Colors.orangeAccent;
      case '완료': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('수리 요청 현황', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() { _isLoading = true; });
              _loadData();
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // 1. 공통 필터바
              _buildFilterBar(),

              // 2. 내용 영역
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRequests.isEmpty
                    ? _buildEmptyView()
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 800) {
                      return _buildWebTableView();
                    } else {
                      return _buildMobileListView();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // [추가] 하단 네비게이션 바 추가
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: '캐쉬'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: '상품'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: '내집홍보'),
        ],
        currentIndex: 0, // 홈 탭 활성화 상태로 표시
        selectedItemColor: Colors.deepPurple.shade400, // 다른 화면과 색상 통일
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: ['전체', '접수', '진행중', '완료'].map((status) {
          final isSelected = _selectedStatus == status;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onFilterChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: isSelected
                    ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
                    : null,
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            '$_selectedStatus 내역이 없습니다.',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[100]),
              dataRowMinHeight: 50,
              dataRowMaxHeight: 50,
              columnSpacing: 30,
              showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text('작성일', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('호수', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('상태', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('제목', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('작성자', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _filteredRequests.map((item) {
                return DataRow(
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AsDetailScreen(item: item)));
                    }
                  },
                  cells: [
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(item.date))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                        child: Text(item.roomNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status).withOpacity(0.1),
                          border: Border.all(color: _getStatusColor(item.status)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(item.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(item.status))),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(item.title, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    DataCell(Text(item.author)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileListView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filteredRequests.length,
        itemBuilder: (context, index) {
          final item = _filteredRequests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AsDetailScreen(item: item)));
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                          child: Text(item.roomNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item.status).withOpacity(0.1),
                            border: Border.all(color: _getStatusColor(item.status)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(item.status, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _getStatusColor(item.status))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('작성자: ${item.author}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        Text(DateFormat('yyyy-MM-dd').format(item.date), style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}