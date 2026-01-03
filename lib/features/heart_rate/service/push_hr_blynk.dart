import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PushHrBlynk {
  static final String authToken = dotenv.env['AUTH_TOKEN_BLYNK'] ?? "";

  static Future<void> pushData(int bpm, double sys, double dia) async {
    String description = "Heart Rate: $bpm BPM, Blood Pressure: $sys/$dia mmHg";
    String code = "bpm";

    final urlPinV0 = Uri.parse(
      "https://blynk.cloud/external/api/update?token=$authToken&V0=$bpm",
    );
    final urlPinV1 = Uri.parse(
      "https://blynk.cloud/external/api/update?token=$authToken&V1=$sys",
    );
    final urlPinV2 = Uri.parse(
      "https://blynk.cloud/external/api/update?token=$authToken&V2=$dia",
    );

    //send event to blynk
    final urlSendEvent = Uri.parse(
      "https://blynk.cloud/external/api/logEvent?token=$authToken&code=$code&description=$description",
    );

    final response = await http.get(urlPinV0);
    final response1 = await http.get(urlPinV1);
    final response2 = await http.get(urlPinV2);
    final responseEvent = await http.get(urlSendEvent);

    if (response.statusCode == 200 && responseEvent.statusCode == 200 && response1.statusCode == 200 && response2.statusCode == 200) {
      print("✅ Sent $bpm to Blynk");
    } else {
      print("❌ Error: ${response.body}");
    }
  }
}
