import 'package:http/http.dart' as http;

class PushHrZaloBot {
  static const String botToken = "3179939951305615471:OUEdhyGNcRiUhTIKlsxnRNBkpEhMigruCqEUeoQCAbZZAviEwcfHqmAKiJuwhUrU";

  static Future<void> pushDataZalo(int value) async {
    print(value);
    String description = "Heart Rate: $value BPM";
    String code = "bpm";

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
