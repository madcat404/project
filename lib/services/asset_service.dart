import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/models/asset_models.dart';

class AssetService {
  // [설정] API 기본 도메인 주소 (유지보수를 위해 상수로 분리)
  static const String _baseUrl = 'https://fms.iwin.kr/brother';

  // [설정] 네트워크 타임아웃 시간 (초)
  static const Duration _timeOut = Duration(seconds: 10);

  /// 건물 및 호실 정보 목록을 가져오는 함수
  Future<List<Building>> getBuildings() async {
    List<Building> buildings = [];

    try {
      // URL 생성
      final url = Uri.parse('$_baseUrl/contract_add.php?owner_name=all&t=${DateTime.now().millisecondsSinceEpoch}');
      print('[AssetService] 데이터 가져오는 중: $url');

      // GET 요청 (타임아웃 설정 추가)
      final response = await http.get(url).timeout(_timeOut);

      // 한글 깨짐 방지를 위한 UTF-8 디코딩
      String responseBody = utf8.decode(response.bodyBytes).trim();

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          print('[AssetService] JSON 파싱 에러: $e');
          print('수신된 데이터: $responseBody'); // 디버깅용 로그
          return [];
        }

        // 데이터 구조 확인 ('data' 키가 있고 리스트인지)
        if (responseData['data'] != null && responseData['data'] is List) {
          List<dynamic> jsonList = responseData['data'];

          for (var item in jsonList) {
            // 건물 정보 파싱 (Null일 경우 기본값 처리)
            String buildingName = item['building_name']?.toString() ?? '이름 없음';
            String roadAddress = item['road_address']?.toString() ?? '';

            List<Unit> parsedUnits = [];

            // 호실 정보 파싱
            if (item['units'] != null && item['units'] is List) {
              for (var u in item['units']) {
                // 옵션 처리: JSON 문자열로 들어오는 경우를 대비
                List<String> options = [];
                if (u['options'] != null) {
                  try {
                    // PHP에서 json_encode 된 문자열이 넘어오는 경우 디코딩
                    var rawOptions = u['options'];
                    if (rawOptions is String) {
                      options = List<String>.from(jsonDecode(rawOptions));
                    } else if (rawOptions is List) {
                      options = List<String>.from(rawOptions);
                    }
                  } catch (e) {
                    print('[AssetService] 옵션 파싱 경고: $e');
                  }
                }

                // Unit 모델 생성
                parsedUnits.add(Unit(
                  id: u['no']?.toString() ?? '',
                  roomNumber: u['room_number']?.toString() ?? '호수 미정',
                  tenantName: u['tenant_name']?.toString() ?? '-',
                  // PHP의 1/0 혹은 true/false 모두 대응
                  isVacant: (u['is_vacant'] == true || u['is_vacant'] == 1 || u['is_vacant'] == '1'),
                  expiryDate: u['expiry_date']?.toString() ?? '-',
                  deposit: u['deposit']?.toString() ?? '-',
                  rent: u['rent']?.toString() ?? '-',
                  gender: u['lessee_sex']?.toString() ?? '-',
                  contact: u['lessee_phone']?.toString() ?? '-',

                  // 부동산 정보
                  realty: u['realtor_office_name']?.toString() ?? '-',
                  realtyPhone: u['realtor_phone']?.toString() ?? '-',

                  // 메모 처리: 메모가 없으면 임대인 이름 표시
                  notes: u['memo']?.toString() ?? (u['lessor_name'] != null ? '임대인: ${u['lessor_name']}' : ''),
                  contractDate: u['contract_date']?.toString() ?? '-',
                  unpaidAmount: '0원', // 초기값
                  area: u['area']?.toString() ?? '-',
                  moveInDate: u['contract_date']?.toString() ?? '-', // 입주일을 계약일로 대체 (필요시 수정)
                  entrancePassword: u['entrance_pw']?.toString() ?? '-',
                  roomPassword: u['room_pw']?.toString() ?? '-',

                  // 옵션 여부 체크
                  hasAc: options.contains('에어컨'),
                  hasFridge: options.contains('냉장고'),
                  hasGasStove: options.contains('가스레인지'),
                  hasWasher: options.contains('세탁기'),
                  hasTv: options.contains('TV'),
                  hasInternet: options.contains('인터넷'),
                  hasParking: options.contains('주차장'),
                  hasElevator: options.contains('엘리베이터'),

                  depositStatus: DepositStatus.none,
                ));
              }
            }

            // 건물 리스트에 추가
            buildings.add(Building(
              id: 'bld_${buildings.length}', // 앱 내부용 고유 ID 생성
              name: buildingName,
              address: roadAddress,
              totalUnits: parsedUnits.length,
              vacantUnits: parsedUnits.where((u) => u.isVacant).length,
              units: parsedUnits,
            ));
          }
        }
      } else {
        print('[AssetService] 서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('[AssetService] 네트워크 또는 처리 에러: $e');
    }

    return buildings;
  }

  /// 호실 정보를 수정하는 함수
  Future<bool> updateUnit(Unit unit) async {
    try {
      final url = Uri.parse('$_baseUrl/asset_unit_update.php');

      // 옵션 리스트 생성
      List<String> options = [];
      if (unit.hasAc) options.add('에어컨');
      if (unit.hasFridge) options.add('냉장고');
      if (unit.hasGasStove) options.add('가스레인지');
      if (unit.hasWasher) options.add('세탁기');
      if (unit.hasTv) options.add('TV');
      if (unit.hasInternet) options.add('인터넷');
      if (unit.hasParking) options.add('주차장');
      if (unit.hasElevator) options.add('엘리베이터');

      // 전송할 데이터 바디 구성
      final body = {
        'no': unit.id,
        'tenant_name': unit.tenantName,
        'contact': unit.contact,
        'expiry_date': unit.expiryDate,
        // 숫자만 남기고 나머지 문자 제거 (PHP 서버 호환성 위함)
        'deposit': unit.deposit.replaceAll(RegExp(r'[^0-9]'), ''),
        'rent': unit.rent.replaceAll(RegExp(r'[^0-9]'), ''),
        'area': unit.area,
        'move_in_date': unit.moveInDate,
        'entrance_pw': unit.entrancePassword,
        'room_pw': unit.roomPassword,
        'gender': unit.gender,
        'realty': unit.realty,
        'realtor_phone': unit.realtyPhone,
        'notes': unit.notes,
        'options': jsonEncode(options), // 배열을 JSON 문자열로 변환하여 전송
      };

      print('[AssetService] 업데이트 요청 전송: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // JSON 형식임을 명시
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(_timeOut);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('[AssetService] 업데이트 결과: $result');
        return result['status'] == 'success';
      } else {
        print('[AssetService] 업데이트 서버 오류: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('[AssetService] 업데이트 실패: $e');
      return false;
    }
  }

  /// 계약서 PDF 업로드 함수
  Future<String> uploadContractPdf(List<int> fileBytes, String fileName) async {
    try {
      var uri = Uri.parse('$_baseUrl/contract_pdf_upload.php');

      // Multipart 요청 생성
      var request = http.MultipartRequest('POST', uri);

      // 파일 추가
      request.files.add(http.MultipartFile.fromBytes(
          'uploaded_file',
          fileBytes,
          filename: fileName
      ));

      print('[AssetService] PDF 업로드 시작: $fileName');

      // 요청 전송 및 응답 대기
      var response = await request.send().timeout(const Duration(seconds: 30)); // 업로드는 시간 더 줌

      // 응답 스트림을 문자열로 변환
      String responseStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return responseStr;
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('[AssetService] 계약서 업로드 예외 발생: $e');
      throw Exception('계약서 업로드 실패: $e');
    }
  }
}