import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PushHrZaloBot {
  static final String botToken = dotenv.env['BOT_TOKEN_ZALO'] ?? '';

  static Future<void> pushDataZalo(int value) async {
    String description = "Heart Rate: $value BPM";

    //send event to blynk
    final urlSendEvent = Uri.parse(
      "https://bot-api.zapps.me/bot$botToken/sendMessage",
    );

    final responseEvent = await http.post(urlSendEvent , body: {
        "chat_id": "1f6016dce18908d75198",
        "text": "$description, được đo vào lúc ${DateTime.now()}"
    });

    if ( responseEvent.statusCode == 200) {
      print("✅ Sent $value to Zalo Bot");
    } else {
      print("❌ Error: ${responseEvent.body}");
    }
  }
}
