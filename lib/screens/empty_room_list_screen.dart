import 'package:flutter/material.dart';
import 'package:project/screens/home_page.dart';
import 'empty_room_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- 데이터 모델 ---
class EmptyRoomSummary {
  final String buildingName, roomNumber, propertyType, vacancyDuration, leaseCondition;
  final String deposit, monthlyRent;
  final String contractEndDate;
  final EmptyRoomDetail detail;

  const EmptyRoomSummary({
    required this.buildingName,
    required this.roomNumber,
    required this.propertyType,
    required this.vacancyDuration,
    required this.leaseCondition,
    required this.deposit,
    required this.monthlyRent,
    required this.contractEndDate,
    required this.detail,
  });

  factory EmptyRoomSummary.fromJson(Map<String, dynamic> json) {
    String depositVal = json['deposit']?.toString() ?? '0';
    String rentVal = json['monthly_rent']?.toString() ?? '0';
    String buildingNameVal = json['building_name']?.toString() ?? '이름 없음';
    String roomNumberVal = json['room_number']?.toString() ?? '정보 없음';
    String durationVal = json['vacancy_duration']?.toString() ?? '0일';
    String leaseVal = json['lease_condition']?.toString() ?? '$depositVal / $rentVal';
    String endDateVal = json['contract_end_date']?.toString() ?? '-';

    return EmptyRoomSummary(
      buildingName: buildingNameVal,
      roomNumber: roomNumberVal,
      propertyType: json['property_type']?.toString() ?? '주거',
      vacancyDuration: durationVal,
      leaseCondition: leaseVal,
      deposit: depositVal,
      monthlyRent: rentVal,
      contractEndDate: endDateVal,
      detail: EmptyRoomDetail(
        propertyAddress: roomNumberVal,
        propertyType: json['property_type']?.toString() ?? '주거',
        vacancyDuration: durationVal,
        desiredLeaseCondition: leaseVal,
        vacancyStartDate: endDateVal,
        previousLeaseCondition: '-',
        cleaningStatus: '-',
        wallpaperStatus: '-', mainOptions: '-', repairHistory: '-',
        lastInspectionDate: '-', inspectionItems: '-', actionTaken: '-',
        periodicChecks: '-', managementFee: '-', utilityBills: '-',
        otherCosts: '-', totalCosts: '-', registeredAgencies: '-',
        onlinePlatforms: '-', adContent: '-', showingHistory: '-',
        inquiryStatus: '-', leaseConditionChanges: '-', doorLockInfo: '-',
        securityChecks: '-',
      ),
    );
  }
}

// 필터 타입 정의
enum VacancyFilterType { all, recent, longterm }

class EmptyRoomListScreen extends StatefulWidget {
  final String? buildingName;
  const EmptyRoomListScreen({super.key, this.buildingName});

  @override
  State<EmptyRoomListScreen> createState() => _EmptyRoomListScreenState();
}

class _EmptyRoomListScreenState extends State<EmptyRoomListScreen> {
  // 천 단위 콤마 함수
  String formatCurrency(String value) {
    if (value == '0' || value.isEmpty) return '0';
    String numericOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) return '0';
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return numericOnly.replaceAllMapped(regExp, (Match m) => '${m[1]},');
  }

  Future<List<EmptyRoomSummary>>? _roomsFuture;
  VacancyFilterType _activeFilter = VacancyFilterType.all;

  @override
  void initState() {
    super.initState();
    _roomsFuture = fetchRooms();
  }

  Future<List<EmptyRoomSummary>> fetchRooms() async {
    try {
      final response = await http.get(Uri.parse('https://fms.iwin.kr/brother/empty_rooms.php'));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((item) => EmptyRoomSummary.fromJson(item)).toList();
      } else {
        throw Exception('서버가 응답하지 않습니다.');
      }
    } catch (e) {
      throw Exception('데이터 로드 중 오류가 발생했습니다: $e');
    }
  }

  // [수정] 장부관리와 동일한 네비게이션 로직
  void _onItemTapped(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(initialIndex: index)),
          (Route<dynamic> route) => false,
    );
  }

  void _setFilter(VacancyFilterType filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  Widget _buildSummaryCard(String title, String value, String unit, {Color? highlightColor, VoidCallback? onTap, bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? Colors.deepPurple.shade400 : Colors.grey.withOpacity(0.2), width: isSelected ? 2 : 1), // [수정] 선택 색상 통일
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: isSelected ? Colors.deepPurple.shade400 : Colors.grey[700], fontWeight: FontWeight.w600)), // [수정] 텍스트 색상 통일
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: highlightColor ?? Colors.black)),
                      const SizedBox(width: 4),
                      Text(unit, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공실 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<EmptyRoomSummary>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('조회 가능한 공실 데이터가 없습니다.'));
          }

          final allRooms = snapshot.data!;
          final List<int> durationDays = allRooms
              .map((e) => int.tryParse(e.vacancyDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
              .toList();

          final int totalCount = allRooms.length;
          final int avgDays = durationDays.isEmpty ? 0 : (durationDays.reduce((a, b) => a + b) / durationDays.length).round();
          final int recentCount = durationDays.where((d) => d <= 90).length;
          final int longTermCount = durationDays.where((d) => d > 90).length;

          List<EmptyRoomSummary> displayList;
          String listTitle;
          switch (_activeFilter) {
            case VacancyFilterType.recent:
              displayList = allRooms.where((room) {
                int days = int.tryParse(room.vacancyDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                return days <= 90;
              }).toList();
              listTitle = '신규 공실 내역 (90일 내)';
              break;
            case VacancyFilterType.longterm:
              displayList = allRooms.where((room) {
                int days = int.tryParse(room.vacancyDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                return days > 90;
              }).toList();
              listTitle = '장기 공실 내역 (90일 초과)';
              break;
            default:
              displayList = allRooms;
              listTitle = '전체 공실 상세 내역';
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 800;
              double contentWidth = isWide ? 1200 : constraints.maxWidth;

              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('요약 현황 (카드를 클릭해 필터링하세요)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        const SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isWide ? 4 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isWide ? 1.5 : 1.3,
                          children: [
                            _buildSummaryCard('총 공실', '$totalCount', '건',
                                onTap: () => _setFilter(VacancyFilterType.all),
                                isSelected: _activeFilter == VacancyFilterType.all),
                            _buildSummaryCard('평균 공실일', '$avgDays', '일'),
                            _buildSummaryCard('신규 (90일 내)', '$recentCount', '건',
                                highlightColor: Colors.blueAccent,
                                onTap: () => _setFilter(VacancyFilterType.recent),
                                isSelected: _activeFilter == VacancyFilterType.recent),
                            _buildSummaryCard('장기 (90일 초과)', '$longTermCount', '건',
                                highlightColor: Colors.redAccent,
                                onTap: () => _setFilter(VacancyFilterType.longterm),
                                isSelected: _activeFilter == VacancyFilterType.longterm),
                          ],
                        ),
                        const SizedBox(height: 48),
                        Text(listTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        isWide ? _buildVacancyTable(displayList) : _buildMobileList(displayList),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      // [수정] 장부관리와 동일한 하단 바 디자인 적용
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: '캐쉬'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: '상품'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: '내집홍보'),
        ],
        currentIndex: 0, // 홈 탭 활성화
        selectedItemColor: Colors.deepPurple.shade400, // [수정] 장부관리와 동일한 색상 (Deep Purple)
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildMobileList(List<EmptyRoomSummary> rooms) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(room.buildingName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(room.roomNumber),
            trailing: Text(room.vacancyDuration, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EmptyRoomDetailScreen(
                detail: EmptyRoomDetail(
                  propertyAddress: room.roomNumber,
                  propertyType: room.propertyType,
                  vacancyDuration: room.vacancyDuration,
                  desiredLeaseCondition: room.leaseCondition,
                  vacancyStartDate: room.contractEndDate,
                  previousLeaseCondition: '${formatCurrency(room.deposit)} / ${formatCurrency(room.monthlyRent)}',
                  cleaningStatus: '-',
                  wallpaperStatus: '-', mainOptions: '-', repairHistory: '-',
                  lastInspectionDate: '-', inspectionItems: '-', actionTaken: '-',
                  periodicChecks: '-', managementFee: '-', utilityBills: '-',
                  otherCosts: '-', totalCosts: '-', registeredAgencies: '-',
                  onlinePlatforms: '-', adContent: '-', showingHistory: '-',
                  inquiryStatus: '-', leaseConditionChanges: '-', doorLockInfo: '-',
                  securityChecks: '-',
                )
            ))),
          ),
        );
      },
    );
  }

  Widget _buildVacancyTable(List<EmptyRoomSummary> rooms) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.3))),
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('건물명')),
          DataColumn(label: Text('상세주소')),
          DataColumn(label: Text('공실 기간')),
          DataColumn(label: Text('임대 조건')),
        ],
        rows: rooms.map((room) => DataRow(
          onSelectChanged: (_) => Navigator.push(context, MaterialPageRoute(builder: (context) => EmptyRoomDetailScreen(
              detail: EmptyRoomDetail(
                propertyAddress: room.roomNumber,
                propertyType: room.propertyType,
                vacancyDuration: room.vacancyDuration,
                desiredLeaseCondition: room.leaseCondition,
                vacancyStartDate: room.contractEndDate,
                previousLeaseCondition: '${formatCurrency(room.deposit)} / ${formatCurrency(room.monthlyRent)}',
                cleaningStatus: '-',
                wallpaperStatus: '-', mainOptions: '-', repairHistory: '-',
                lastInspectionDate: '-', inspectionItems: '-', actionTaken: '-',
                periodicChecks: '-', managementFee: '-', utilityBills: '-',
                otherCosts: '-', totalCosts: '-', registeredAgencies: '-',
                onlinePlatforms: '-', adContent: '-', showingHistory: '-',
                inquiryStatus: '-', leaseConditionChanges: '-', doorLockInfo: '-',
                securityChecks: '-',
              )
          ))),
          cells: [
            DataCell(Text(room.buildingName, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(room.roomNumber)),
            DataCell(Text(room.vacancyDuration)),
            DataCell(Text('${formatCurrency(room.deposit)} / ${formatCurrency(room.monthlyRent)}')),
          ],
        )).toList(),
      ),
    );
  }
}