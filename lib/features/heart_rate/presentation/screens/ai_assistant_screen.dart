import 'package:flutter/material.dart';
import 'package:flutter_heartrate/features/heart_rate/service/ai_service.dart';
import '../../../../core/constants/app_strings.dart';


class AiAssistantScreen extends StatefulWidget {

  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();

}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final myController = TextEditingController();
  List<Map<String, String>> messages = [];
  Map<String, String> response = {};
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    messages = [
      {
        "role" : "user",
        "content" : "Xin chào, bạn có thể giúp tôi như thế nào?"
      },
      {
        "role" : "model",
        "content" : "Chào bạn! Tôi là trợ lý AI của bạn. Tôi có thể giúp bạn với các câu hỏi về sức khỏe, y tế và sinh học. Bạn cần hỗ trợ gì hôm nay?"
      },
    ];
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (myController.text.isNotEmpty) {
      final userMsg = myController.text;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });


      setState(() {
        messages.add({"role": "user", "content": userMsg});
        myController.clear();
      });

      // Gọi API ngoài setState
      final botResponse = await getContentFromGemini(userMsg);

      setState(() {
        messages.add(botResponse);
      });

      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.aiAssitant)),
      backgroundColor: Colors.grey[900],
      body: Expanded(child: ListView.builder(
        controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 80),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          if (message['role'] == "user") {
            return _buildUserMessage(message['content']!);
          } else {
            return _buildAIMessage(message['content']!);
          }
        },
      ),),
      bottomSheet: Container(
        color: const Color.fromARGB(255, 27, 24, 24),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: false,
                controller: myController,
                decoration: InputDecoration(
                  hintText: "Hỏi đáp với trợ lý AI...",
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(onPressed: () {
                        _sendMessage();
                      }, icon: const Icon(Icons.arrow_upward),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildUserMessage(String message) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              softWrap: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const CircleAvatar(child: Icon(Icons.person)),
      ],
    ),
  );
}

Widget _buildAIMessage(String message) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(child: Icon(Icons.android)), // Đổi icon cho AI
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              softWrap: true,
            ),
          ),
        ),
      ],
    ),
  );
}

