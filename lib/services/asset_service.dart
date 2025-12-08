import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/models/asset_models.dart';

class AssetService {
  Future<List<Building>> getBuildings() async {
    // 1. 기존 더미 데이터 (로컬 데이터)
    List<Building> buildings = [
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

    // 2. 서버 데이터 가져오기 (비동기)
    String ownerName = '김계화';
    String ownerBirth = '600720';

    try {
      final url = Uri.parse('https://fms.iwin.kr/brother/asset_add.php?owner_name=$ownerName&owner_birth=$ownerBirth');
      print('Fetching data from: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 1. JSON 디코딩 (전체를 Map으로 받음)
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 2. 'data' 키 안에 있는 리스트를 가져옴
        if (responseData['data'] != null) {
          List<dynamic> jsonList = responseData['data'];

          for (var item in jsonList) {
            if (item['building_name'] != null) {
              buildings.add(Building(
                name: item['building_name'].toString(),
                address: item['road_address']?.toString() ?? '주소 미입력', // PHP 컬럼명에 맞춤
                totalUnits: 0,
                vacantUnits: 0,
                units: [],
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

    return buildings;
  }

  // PDF 업로드 로직
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
      throw Exception('업로드 실패: $e');
    }
  }
}