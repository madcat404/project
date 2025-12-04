// lib/services/ocr_service_web.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OcrService {
  // TODO: 발급받은 Google Vision API 키로 교체해주세요.
  static const String _apiKey = 'AIzaSyBCWxkmkhGrHugDPmBSwGPeGuwB5nEQVkY';

  static Future<String> performOcr(String filePath) async {
    // 웹에서 filePath는 이미지 피커(image_picker)를 통해 얻은 blob URL이어야 합니다.
    if (filePath.isEmpty) {
        return '';
    }

    try {
      // blob URL로부터 이미지 데이터를 가져옵니다.
      final response = await http.get(Uri.parse(filePath));
      if (response.statusCode != 200) {
        print('blob URL에서 이미지를 불러오는데 실패했습니다: ${response.statusCode}');
        return 'blob URL에서 이미지를 불러오는데 실패했습니다: ${response.statusCode}';
      }

      final imageBytes = response.bodyBytes;
      final base64Image = base64Encode(imageBytes);

      final visionApiResponse = await http.post(
        Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'TEXT_DETECTION'}
              ],
              'imageContext': {
                'languageHints': ['ko']
              },
            }
          ]
        }),
      );

      if (visionApiResponse.statusCode == 200) {
        final responseBody = utf8.decode(visionApiResponse.bodyBytes);
        final data = jsonDecode(responseBody);

        if (data['responses'] != null && data['responses'].isNotEmpty) {
          final annotations = data['responses'][0];
          if (annotations.containsKey('fullTextAnnotation')) {
            final text = annotations['fullTextAnnotation']['text'] as String;
            
            // OCR로 추출된 텍스트를 데이터베이스에 저장합니다.
            await saveTextToDatabase(text);
            
            return text;
          }
        }
      } else {
        final errorBody = utf8.decode(visionApiResponse.bodyBytes);
        print('Google Vision API 오류: ${visionApiResponse.statusCode}');
        print(errorBody);
        return 'Google Vision API 오류: ${visionApiResponse.statusCode}\n$errorBody';
      }
    } catch (e) {
      print("OCR 처리 중 오류가 발생했습니다: $e");
      return "OCR 처리 중 오류가 발생했습니다: $e";
    }

    return '';
  }

  // 서버로 OCR 텍스트를 전송하는 함수를 static으로 변경
  static Future<void> saveTextToDatabase(String text) async {
    var url = Uri.parse('https://fms.iwin.kr/brother/ocr.php'); // 새로 만든 PHP 파일 주소

    try {
      var response = await http.post(
        url,
        body: {
          'kind': text,
        },
      );

      if (response.statusCode == 200) {
        print('DB 저장 성공: ${response.body}');
      } else {
        print('DB 저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('네트워크 에러: $e');
    }
  }
}
