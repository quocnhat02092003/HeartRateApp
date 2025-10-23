import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Image(
            image: AssetImage('assets/image/heart_rate.png'),
            width: 150,
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: "Vui lòng đọc kỹ trước khi sử dụng\n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextSpan(
                  text:
                      "- Mở ứng dụng và giữ ngón tay trỏ của bạn che ống kính của máy ảnh sau và đèn flash.\n",
                ),
                TextSpan(
                  text:
                      "Không giữ quá chặt nếu không bạn sẽ làm cho máu không lưu thông, dẫn đến kết quả không chính xác.\n",
                ),
                TextSpan(
                  text:
                      "- Sau 1 hoặc 2 giây, bạn sẽ nhìn thấy tín hiệu nhịp tim.\n",
                ),
                TextSpan(
                  text:
                      "Cần 5 giây kết quả tính toán hiển thị trên màn hình LCD.\n",
                ),
                TextSpan(
                  text:
                      "Sau khoảng hơn 10 giây nữa bạn sẽ có kết quả khá chính xác.\n",
                ),
                TextSpan(text: "- Xem thêm "),
                TextSpan(
                  text: "http://en.wikipedia.org/wiki/Heart_rate",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      //launch URL
                    },
                ),
                TextSpan(text: " nếu bạn muốn tìm hiểu thêm về nhịp tim."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
