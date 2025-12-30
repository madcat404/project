import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http 패키지 필수
import 'package:project/models/asset_models.dart';

class AssetBuildingDetailsScreen extends StatefulWidget {
  final Building building;

  const AssetBuildingDetailsScreen({super.key, required this.building});

  @override
  State<AssetBuildingDetailsScreen> createState() => _AssetBuildingDetailsScreenState();
}

class _AssetBuildingDetailsScreenState extends State<AssetBuildingDetailsScreen> {
  // 화면에 표시할 데이터 (키: 항목명, 값: 내용)
  Map<String, String> _buildingLedgerData = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBuildingInfo();
  }

  // ------------------------------------------------------------------------
  // [핵심] PHP API 호출 및 데이터 파싱
  // ------------------------------------------------------------------------
  Future<void> _fetchBuildingInfo() async {
    // 모델에 있는 주소를 가져옵니다.
    final String address = widget.building.address;

    // ★ 서버 주소 (본인의 도메인으로 변경 확인)
    final String url = "https://fms.iwin.kr/brother/asset_building_detail.php?address=${Uri.encodeComponent(address)}";

    try {
      debugPrint("API 호출: $url"); // 디버깅용 로그
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data'] != null) {
          final dbData = data['data'];

          if (mounted) {
            setState(() {
              // DB 컬럼(영어) -> UI 항목(한글) 매핑
              _buildingLedgerData = {
                "건물명": _val(dbData['bld_nm']),
                "대지위치": _val(dbData['plat_plc']),
                "도로명주소": _val(dbData['new_plat_plc']),
                "주용도": "${_val(dbData['main_purps_cd_nm'])} (${_val(dbData['etc_purps'])})",

                // 면적 정보
                "대지면적": "${_fmtNum(dbData['plat_area'])} ㎡",
                "연면적": "${_fmtNum(dbData['tot_area'])} ㎡",
                "건폐율": "${_fmtNum(dbData['bc_rat'])} %",
                "용적률": "${_fmtNum(dbData['vl_rat'])} %",

                // 구조 정보
                "주구조": "${_val(dbData['strct_cd_nm'])}",
                "지붕구조": "${_val(dbData['roof_cd_nm'])}",
                "높이": "${_fmtNum(dbData['heit'])} m",

                // 층수 및 세대수
                "층수": "지상 ${dbData['grnd_flr_cnt']}층 / 지하 ${dbData['ugrnd_flr_cnt']}층",
                "세대/가구": "세대: ${dbData['hhld_cnt']} / 가구: ${dbData['fmly_cnt']} / 호수: ${dbData['ho_cnt']}",

                // 주차 및 승강기
                "주차장": "총 ${dbData['tot_pkng_cnt']}대 (옥내 ${dbData['indr_auto_utcnt']} / 옥외 ${dbData['oudr_auto_utcnt']})",
                "승강기": "승용 ${dbData['ride_use_elvt_cnt']}대 / 비상 ${dbData['emgen_use_elvt_cnt']}대",

                // 기타 정보
                "사용승인일": _fmtDate(dbData['use_apr_day']),
                "내진설계": (dbData['rserthqk_dsgn_apply_yn'] == '1')
                    ? "적용됨 (${_val(dbData['rserthqk_ablty'])})"
                    : "미적용",
              };
              _isLoading = false;
            });
          }
        } else {
          // 데이터가 없는 경우
          _handleError("건축물대장 정보가 없습니다.\n(API 메시지: ${data['message']})");
        }
      } else {
        _handleError("서버 통신 오류: ${response.statusCode}");
      }
    } catch (e) {
      _handleError("데이터를 불러오지 못했습니다.\n(인터넷 연결을 확인해주세요)");
      debugPrint("에러 상세: $e");
    }
  }

  void _handleError(String msg) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = msg;
      });
    }
  }

  // ------------------------------------------------------------------------
  // [헬퍼 함수] 데이터 포맷팅
  // ------------------------------------------------------------------------

  // null이거나 빈 값이면 '-' 표시
  String _val(dynamic val) {
    if (val == null || val.toString() == 'null' || val.toString().trim().isEmpty) {
      return '-';
    }
    return val.toString();
  }

  // 숫자 포맷 (소수점 정리)
  String _fmtNum(dynamic val) {
    if (val == null) return "0";
    double d = double.tryParse(val.toString()) ?? 0;
    // 소수점이 .00이면 정수처럼, 아니면 소수점 2자리까지
    return d.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  // 날짜 포맷 (YYYYMMDD -> YYYY-MM-DD)
  String _fmtDate(dynamic val) {
    String s = val.toString();
    if (s.length == 8) {
      return "${s.substring(0, 4)}-${s.substring(4, 6)}-${s.substring(6, 8)}";
    }
    return s;
  }

  // ------------------------------------------------------------------------
  // [UI 구성]
  // ------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("건물 상세 정보"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. 로딩 중
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("건축물대장 정보를 조회하고 있습니다...", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text("(최초 조회 시 공공데이터 수집에 시간이 걸릴 수 있습니다)",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    // 2. 에러 발생
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _fetchBuildingInfo(); // 재시도
                },
                icon: const Icon(Icons.refresh),
                label: const Text("다시 시도"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
              )
            ],
          ),
        ),
      );
    }

    // 3. 데이터 표시
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 20),
          Row(
            children: const [
              Icon(Icons.verified_user_outlined, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "건축물대장 표제부 정보",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailTable(),
          const SizedBox(height: 30), // 하단 여백
        ],
      ),
    );
  }

  // 상단 요약 카드 (모델 데이터 사용)
  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.apartment, size: 30, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.building.name, // 모델의 건물명 (DB에서 가져온 이름 우선)
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.building.address, // 모델의 주소
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상세 정보 테이블 (API 데이터 사용)
  Widget _buildDetailTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: _buildingLedgerData.entries.map((entry) {
          final isLast = entry.key == _buildingLedgerData.keys.last;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, thickness: 0.5, color: Colors.grey),
            ],
          );
        }).toList(),
      ),
    );
  }
}