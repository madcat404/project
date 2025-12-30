import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/as_models.dart'; // 모델
import '../services/as_service.dart'; // 서비스
import 'as_detail_screen.dart'; // [추가됨] 상세 화면 import

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
      body: Column(
        children: [
          // 1. 필터링 버튼 (Segmented Control 스타일)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(4),
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
          ),

          // 2. 리스트 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRequests.isEmpty
                ? Center(
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
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filteredRequests.length,
                itemBuilder: (context, index) {
                  return _buildAsCard(_filteredRequests[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsCard(AsRequest item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // [수정됨] 클릭 시 상세 화면으로 이동 복구
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
  }
}