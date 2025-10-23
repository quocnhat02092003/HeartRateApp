import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class AiAssistantScreen extends StatefulWidget {
  final int bpm;
  const AiAssistantScreen({super.key, required this.bpm});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.aiAssitant)),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80, top: 20),
        child: Column(
          children: [
            //AI
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                CircleAvatar(child: Icon(Icons.person)),
                SizedBox(width: 10),
                SizedBox(
                  width: 200,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Trợ lý AI trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các",
                      style: const TextStyle(color: Colors.white),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            //User
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 200,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Trợ lý AI trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các trả lời câu hỏi các",
                      style: const TextStyle(color: Colors.white),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: const Color.fromARGB(255, 27, 24, 24),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: false,
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
                      child: const Icon(
                        Icons.arrow_upward,
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
