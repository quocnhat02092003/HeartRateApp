import 'package:flutter/material.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/screens/ai_assistant_screen.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/screens/blood_pressure_screen.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/tabs/history_mesure_tab.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/widgets/card_setting.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/widgets/card_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../firebase/auth/GoogleAuthService.dart';

class MoreTab extends StatefulWidget {
  final VoidCallback goToHistoryMeasureTab;
  const MoreTab({super.key, required this.goToHistoryMeasureTab});
  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  GoogleSignInAccount? _user;

  Future<void> _loginWithGoogle() async {
    final user = await GoogleAuthService.signIn();
    if (user != null) {
      setState(() => _user = user);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập thành công: ${user.displayName}")),
      );
    }
  }

  Future<void> _checkExistingUser() async {
    // Get current user (if logged in)
    if (GoogleAuthService.currentUser != null) {
      setState(() => _user = GoogleAuthService.currentUser);
      return;
    }

    // Auto login
    final user = await GoogleAuthService.signInSilently();
    if (mounted && user != null) {
      setState(() => _user = user);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
    _user = GoogleAuthService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _user != null
                ? CardUser(
                    name: _user!.displayName ?? '',
                    email: _user!.email,
                    avatarUrl: _user!.photoUrl ?? '',
                  )
                : CardUser(name: '', email: '', avatarUrl: ''),
            const SizedBox(height: 20),
            const Divider(color: Colors.white70),
            //Account
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _user == null
                ? CardSetting(
                    icon: Icons.account_circle_outlined,
                    title: 'Đăng nhập với Google',
                    onTap: _loginWithGoogle,
                    time:
                        'Lưu dữ liệu, đồng bộ dữ liệu giữa các thiết bị và hơn thế nữa',
                  )
                : SizedBox.shrink(),
            CardSetting(
              icon: Icons.auto_awesome,
              title: 'Trợ lý AI',
              time: 'Chuyên gia AI giúp phân tích vấn đề qua nhịp tim',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                );
              },
            ),
            CardSetting(
              icon: Icons.info,
              title: 'Thay đổi thông tin sức khỏe',
              time: 'Thay đổi thông tin sức khỏe cá nhân trước đó',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BloodPressureScreen(mode: BloodPressureMode.edit),
                  ),
                );
              },
            ),
            CardSetting(
              icon: Icons.history_outlined,
              onTap: widget.goToHistoryMeasureTab,
              title: 'Lịch sử đo',
              time: 'Lịch sử đã từng đo đạc thông số nhịp tim',
            ),
            _user != null
                ? CardSetting(
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    time: 'Đăng xuất khỏi tài khoản',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Đăng xuất?"),
                            content: const Text(
                              "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?",
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Hủy"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Đăng xuất"),
                                onPressed: () async {
                                  await GoogleAuthService.signOut();
                                  setState(() => _user = null);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Đã đăng xuất"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
            const Divider(color: Colors.white70),
            //More
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'More',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            CardSetting(
              icon: Icons.abc_outlined,
              title: 'Tìm hiểu thêm',
              time: 'Tìm hiểu thêm cách thức hoạt động của nhịp tim',
            ),
            CardSetting(
              icon: Icons.feedback,
              title: 'Gửi phản hồi',
              time: 'Giúp cải thiện, sửa lỗi,...',
            ),
            CardSetting(
              icon: Icons.policy,
              title: 'Điều khoản',
              time: 'Điều khoản của phần mềm',
            ),
          ],
        ),
      ),
    );
  }
}
