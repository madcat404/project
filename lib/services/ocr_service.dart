import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;

class OcrService {
  static Future<String> performOcr(String filePath) async {
    if (filePath.isEmpty) {
      return '';
    }
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      final text = recognizedText.text;
      
      // OCR로 추출된 텍스트를 데이터베이스에 저장합니다.
      await saveTextToDatabase(text);

      return text;
    } catch (e) {
      print("OCR 처리 중 오류가 발생했습니다: $e");
      return 'OCR 처리 중 오류가 발생했습니다: $e';
    }
  }

  static Future<void> saveTextToDatabase(String text) async {
    var url = Uri.parse('https://fms.iwin.kr/brother/ocr.php');

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
