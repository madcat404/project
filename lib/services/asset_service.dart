import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/models/asset_models.dart';

class AssetService {
  Future<List<Building>> getBuildings() async {
    List<Building> buildings = [];

    try {
      final url = Uri.parse('https://fms.iwin.kr/brother/contract_add.php?owner_name=all');
      print('Fetching data from: $url');

      final response = await http.get(url);
      String responseBody = utf8.decode(response.bodyBytes).trim();

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          print('JSON 파싱 에러: $e');
          return [];
        }

        if (responseData['data'] != null && responseData['data'] is List) {
          List<dynamic> jsonList = responseData['data'];

          for (var item in jsonList) {
            String buildingName = item['building_name']?.toString() ?? '이름 없음';
            String roadAddress = item['road_address']?.toString() ?? '';

            List<Unit> parsedUnits = [];
            if (item['units'] != null && item['units'] is List) {
              for (var u in item['units']) {
                List<String> options = [];
                if (u['options'] != null) {
                  try {
                    options = List<String>.from(jsonDecode(u['options']));
                  } catch (_) {}
                }

                parsedUnits.add(Unit(
                  id: u['no']?.toString() ?? '',
                  roomNumber: u['room_number']?.toString() ?? '호수 미정',
                  tenantName: u['tenant_name']?.toString() ?? '-',
                  isVacant: u['is_vacant'] == true || u['is_vacant'] == 1,
                  expiryDate: u['expiry_date']?.toString() ?? '-',
                  deposit: u['deposit']?.toString() ?? '-',
                  rent: u['rent']?.toString() ?? '-',
                  gender: u['lessee_sex']?.toString() ?? '-',
                  contact: u['lessee_phone']?.toString() ?? '-',

                  // [수정] 부동산 이름과 연락처를 각각 분리하여 저장
                  realty: u['realtor_office_name']?.toString() ?? '-',
                  realtyPhone: u['realtor_phone']?.toString() ?? '-',

                  notes: u['memo']?.toString() ?? (u['lessor_name'] != null ? '임대인: ${u['lessor_name']}' : ''),
                  contractDate: u['contract_date']?.toString() ?? '-',
                  unpaidAmount: '0원',
                  area: u['area']?.toString() ?? '-',
                  moveInDate: u['contract_date']?.toString() ?? '-',
                  entrancePassword: u['entrance_pw']?.toString() ?? '-',
                  roomPassword: u['room_pw']?.toString() ?? '-',
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

            buildings.add(Building(
              id: 'bld_${buildings.length}',
              name: buildingName,
              address: roadAddress,
              totalUnits: parsedUnits.length,
              vacantUnits: parsedUnits.where((u) => u.isVacant).length,
              units: parsedUnits,
            ));
          }
        }
      }
    } catch (e) {
      print('에러 발생: $e');
    }

    return buildings;
  }

  Future<bool> updateUnit(Unit unit) async {
    try {
      final url = Uri.parse('https://fms.iwin.kr/brother/asset_unit_update.php');

      List<String> options = [];
      if (unit.hasAc) options.add('에어컨');
      if (unit.hasFridge) options.add('냉장고');
      if (unit.hasGasStove) options.add('가스레인지');
      if (unit.hasWasher) options.add('세탁기');
      if (unit.hasTv) options.add('TV');
      if (unit.hasInternet) options.add('인터넷');
      if (unit.hasParking) options.add('주차장');
      if (unit.hasElevator) options.add('엘리베이터');

      final body = {
        'no': unit.id,
        'tenant_name': unit.tenantName,
        'contact': unit.contact,
        'expiry_date': unit.expiryDate,
        'deposit': unit.deposit.replaceAll(RegExp(r'[^0-9]'), ''),
        'rent': unit.rent.replaceAll(RegExp(r'[^0-9]'), ''),
        'area': unit.area,
        'move_in_date': unit.moveInDate,
        'entrance_pw': unit.entrancePassword,
        'room_pw': unit.roomPassword,
        'gender': unit.gender,
        'realty': unit.realty,           // 부동산 이름
        'realtor_phone': unit.realtyPhone, // [추가] 부동산 연락처
        'notes': unit.notes,
        'options': jsonEncode(options),
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('업데이트 실패: $e');
      return false;
    }
  }

  Future<String> uploadContractPdf(List<int> fileBytes, String fileName) async {
    try {
      var uri = Uri.parse('https://fms.iwin.kr/brother/ocr_contract_pdf_upload.php');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes('uploaded_file', fileBytes, filename: fileName));
      var response = await request.send();
      return await response.stream.bytesToString();
    } catch (e) {
      throw Exception('계약서 업로드 실패: $e');
    }
  }
}