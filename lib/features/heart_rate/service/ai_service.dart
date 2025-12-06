// dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const String GEMINI_API_KEY = "AIzaSyC2iO_w1tlkltS1edVjgdlqynb6TPUnvtg";

Future<Map<String, String>> getContentFromGemini(String value) async {
  final String url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // Build the request payload
  final Map<String, dynamic> payload = {
    "contents": [
      {
        "role": "model",
        "parts": [
          {
            "text": "Bạn là một trợ lý AI chuyên về y tế. "
                "Vai trò DUY NHẤT của bạn là cung cấp thông tin về sức khỏe, y khoa, và sinh học. "
                "TUYỆT ĐỐI KHÔNG trả lời bất kỳ câu hỏi nào không liên quan đến y tế. "
                "Nếu người dùng hỏi về chủ đề khác (ví dụ: lịch sử, toán học, tin tức), "
                "bạn PHẢI từ chối và nhắc lại rằng bạn chỉ hỗ trợ các câu hỏi y tế. Nếu người dùng cần tư "
                "vấn chuyên sâu thì đưa ra lời khuyên đến bác sĩ để được tư vấn"
                "Trả lời ngắn gọn không dài dòng và chi tiết"
          }
        ]
      },
      {
        "role": "user",
        "parts": [
          {
            "text": value
          }
        ]
      }
    ]
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key' : GEMINI_API_KEY,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String text =
          data['candidates']?[0]?['content']?['parts']?[0]?['text']?.toString() ??
              "No content returned.";

      return {"role": 'model', "content": text};
    } else {
      return {
        "role": 'model',
        "content": "Xin lỗi, đã có lỗi kết nối máy chủ."
      };
    }
  } catch (e) {
    print("Exception occurred: $e");
    return {
      "role": 'model',
      "content": "Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại."
    };
  }
}