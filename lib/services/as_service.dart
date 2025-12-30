// 파일 경로: lib/services/as_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/as_models.dart'; // [수정됨] as_request.dart -> as_models.dart

class AsService {
  static const String _baseUrl = 'https://fms.iwin.kr/brother';

  static Future<List<AsRequest>> getAsRequests() async {
    final url = Uri.parse('$_baseUrl/as_get_list.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => AsRequest.fromJson(item)).toList();
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('데이터 로드 실패: $e');
    }
  }
}