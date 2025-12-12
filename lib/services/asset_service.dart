import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/models/asset_models.dart';

class AssetService {
  // 건물 데이터 가져오기 (서버 + 더미)
  Future<List<Building>> getBuildings() async {
    // 1. 기존 더미 데이터 (복원됨)
    List<Building> dummyBuildings = [
      Building(
          name: '강남 럭키빌딩',
          address: '서울시 강남구 테헤란로 123',
          totalUnits: 15,
          vacantUnits: 1,
          units: [
            const Unit(roomNumber: '101호', tenantName: '김철수', isVacant: false, expiryDate: '2025-10-31', deposit: '1억', rent: '150만원', gender: '남성', contact: '010-1111-2222', realty: '강남부동산', notes: '애완동물(강아지) 키움.', contractDate: '2023-11-01', unpaidAmount: '0원', area: '25평', moveInDate: '2023-11-01', entrancePassword: '*1234#', roomPassword: '#5678', hasAc: true, hasFridge: true, hasGasStove: true, hasWasher: true, hasTv: true, hasInternet: true, hasParking: false, hasElevator: true, depositStatus: DepositStatus.imminent),
            const Unit(roomNumber: '102호', tenantName: '-', isVacant: true, expiryDate: '-', deposit: '-', rent: '-', gender: '-', contact: '-', realty: '-', notes: '도배, 장판 새로 완료.', contractDate: '-', unpaidAmount: '0원', area: '25평', moveInDate: '-', entrancePassword: '*0000#', roomPassword: '#9999', hasAc: true, hasFridge: true, hasGasStove: true, hasWasher: true, hasTv: false, hasInternet: true, hasParking: false, hasElevator: true, depositStatus: DepositStatus.returned),
            const Unit(roomNumber: '201호', tenantName: '이영희', isVacant: false, expiryDate: '2025-03-15', deposit: '1.2억', rent: '160만원', gender: '여성', contact: '010-3333-4444', realty: '강남부동산', notes: '-', contractDate: '2023-03-16', unpaidAmount: '160만원', area: '28평', moveInDate: '2023-03-16', entrancePassword: '#5678*', roomPassword: '#1212', hasAc: true, hasFridge: true, hasGasStove: true, hasWasher: true, hasTv: true, hasInternet: true, hasParking: false, hasElevator: true, depositStatus: DepositStatus.partiallyReturned),
            const Unit(roomNumber: '202호', tenantName: '박지민', isVacant: false, expiryDate: '2026-01-20', deposit: '1억', rent: '155만원', gender: '남성', contact: '010-5555-6666', realty: '삼성부동산', notes: '-', contractDate: '2024-01-21', unpaidAmount: '0원', area: '25평', moveInDate: '2024-01-21', entrancePassword: '#1122*', roomPassword: '#3434', hasAc: true, hasFridge: true, hasGasStove: false, hasWasher: true, hasTv: true, hasInternet: true, hasParking: false, hasElevator: true, depositStatus: DepositStatus.imminent),
            const Unit(roomNumber: '301호', tenantName: '최유나', isVacant: false, expiryDate: '2024-12-10', deposit: '5천만원', rent: '120만원', gender: '여성', contact: '010-7777-8888', realty: '강남부동산', notes: '-', contractDate: '2022-12-11', unpaidAmount: '0원', area: '22평', moveInDate: '2022-12-11', entrancePassword: '#3344*', roomPassword: '#7878', hasAc: true, hasFridge: true, hasGasStove: true, hasWasher: true, hasTv: false, hasInternet: true, hasParking: false, hasElevator: true, depositStatus: DepositStatus.imminent),
          ]
      ),
      const Building(name: '골든파크빌', address: '부산광역시 서구 아미동2가 19-8', totalUnits: 8, vacantUnits: 1, units: [
        Unit(roomNumber: '708호', tenantName: '홍길동', isVacant: false, expiryDate: '2025-05-10', deposit: '1억', rent: '100만원', gender: '남성', contact: '010-9999-8888', realty: '부산부동산', notes: '-', contractDate: '2023-05-11', unpaidAmount: '500,000원', area: '30평', moveInDate: '2023-05-11', entrancePassword: '*9988#', roomPassword: '#1234', hasAc: true, hasFridge: true, hasGasStove: true, hasWasher: true, hasTv: true, hasInternet: true, hasParking: true, hasElevator: true, depositStatus: DepositStatus.imminent),
        Unit(roomNumber: '303호', tenantName: '김영희', isVacant: false, expiryDate: '2024-11-20', deposit: '5천만원', rent: '80만원', gender: '여성', contact: '010-1111-3333', realty: '부산부동산', notes: '-', contractDate: '2022-11-21', unpaidAmount: '470,000원', area: '18평', moveInDate: '2022-11-21', entrancePassword: '*1133#', roomPassword: '#5678', hasAc: true, hasFridge: true, hasGasStove: false, hasWasher: true, hasTv: false, hasInternet: true, hasParking: true, hasElevator: true, depositStatus: DepositStatus.imminent),
        Unit(roomNumber: '201호', tenantName: '박철수', isVacant: false, expiryDate: '2025-09-01', deposit: '8천만원', rent: '90만원', gender: '남성', contact: '010-4444-5555', realty: '부산부동산', notes: '-', contractDate: '2023-09-02', unpaidAmount: '450,000원', area: '20평', moveInDate: '2023-09-02', entrancePassword: '*4455#', roomPassword: '#9012', hasAc: true, hasFridge: true, hasGasStove: true, hasWasher: true, hasTv: true, hasInternet: false, hasParking: true, hasElevator: true, depositStatus: DepositStatus.imminent),
      ]),
    ];

    // 2. 서버 데이터 가져오기
    List<Building> serverBuildings = [];

    // 로그인한 사용자 정보 (하드코딩)
    String ownerName = '김계화';
    String ownerBirth = '600720';

    try {
      final url = Uri.parse('https://fms.iwin.kr/brother/asset_add.php?owner_name=$ownerName&owner_birth=$ownerBirth');
      print('Fetching data from: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 데이터가 있는지 확인 ('data' 키)
        if (responseData['data'] != null) {
          List<dynamic> jsonList = responseData['data'];

          for (var item in jsonList) {
            String buildingName = item['building_name']?.toString() ?? '건물명 미상';
            String address = item['road_address']?.toString() ?? '주소 미입력';

            // 호실(Unit) 정보 파싱
            List<Unit> units = [];
            if (item['units'] != null && item['units'] is List) {
              for (var u in item['units']) {
                String roomNum = u['room_number']?.toString() ?? '호수미상';
                String area = u['area']?.toString() ?? '-';
                String floorInfoJson = u['floor_info']?.toString() ?? '';

                // floor_info JSON 파싱하여 비고란에 용도/층 표시
                String note = '';
                if (floorInfoJson.isNotEmpty) {
                  try {
                    List<dynamic> floors = jsonDecode(floorInfoJson);
                    if (floors.isNotEmpty) {
                      // 첫 번째 항목의 층과 용도 사용
                      String f = floors[0]['floor'] ?? '';
                      String use = floors[0]['usage'] ?? '';
                      note = "$f $use";
                    }
                  } catch (_) {
                    // JSON 파싱 실패 시 무시
                  }
                }
                if (note.isEmpty) note = '전용면적: ${area}㎡';

                units.add(Unit(
                  roomNumber: roomNum,
                  tenantName: '-', // 입주민 정보 없음
                  isVacant: true,  // 기본 공실
                  expiryDate: '-',
                  deposit: '-',
                  rent: '-',
                  gender: '-',
                  contact: '-',
                  realty: '-',
                  notes: note, // 비고에 층/용도 표시
                  contractDate: '-',
                  unpaidAmount: '0원',
                  area: '$area㎡',
                  moveInDate: '-',
                  entrancePassword: '-',
                  roomPassword: '-',
                  hasAc: false, hasFridge: false, hasGasStove: false, hasWasher: false,
                  hasTv: false, hasInternet: false, hasParking: false, hasElevator: false,
                  depositStatus: DepositStatus.returned,
                ));
              }
            }

            // 호실이 없어도 건물 목록에 추가
            if (buildingName != '건물명 미상') {
              serverBuildings.add(Building(
                name: buildingName,
                address: address,
                totalUnits: units.length,
                vacantUnits: units.length,
                units: units,
              ));
            }
          }
        }
      } else {
        print('서버 통신 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('데이터 가져오기 실패: $e');
    }

    // [중요] 서버 데이터 + 더미 데이터 합쳐서 반환
    return [...serverBuildings, ...dummyBuildings];
  }

  // 건물 PDF 업로드
  Future<String> uploadPdf(List<int> fileBytes, String fileName) async {
    try {
      var uri = Uri.parse('https://fms.iwin.kr/brother/ocr_pdf_upload.php');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'uploaded_file',
        fileBytes,
        filename: fileName,
      ));

      var response = await request.send();
      return await response.stream.bytesToString();
    } catch (e) {
      throw Exception('건물 PDF 업로드 실패: $e');
    }
  }

  // 호실 PDF 업로드
  Future<String> uploadUnitPdf(List<int> fileBytes, String fileName) async {
    try {
      var uri = Uri.parse('https://fms.iwin.kr/brother/ocr_unit_pdf_upload.php');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'uploaded_file',
        fileBytes,
        filename: fileName,
      ));

      var response = await request.send();
      return await response.stream.bytesToString();
    } catch (e) {
      throw Exception('호실 PDF 업로드 실패: $e');
    }
  }
}