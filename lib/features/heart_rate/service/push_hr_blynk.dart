import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PushHrBlynk {
  static final String authToken = dotenv.env['AUTH_TOKEN_BLYNK'] ?? "";

  static Future<void> pushData(int value) async {
    print(value);
    String description = "Heart Rate: $value BPM";
    String code = "bpm";

    final url = Uri.parse(
      "https://blynk.cloud/external/api/update?token=$authToken&V0=$value",
    );

    //send event to blynk
    final urlSendEvent = Uri.parse(
      "https://blynk.cloud/external/api/logEvent?token=$authToken&code=$code&description=$description",
    );

    final response = await http.get(url);
    final responseEvent = await http.get(urlSendEvent);

    if (response.statusCode == 200 && responseEvent.statusCode == 200) {
      print("✅ Sent $value to Blynk");
    } else {
      print("❌ Error: ${response.body}");
    }
  }
}
