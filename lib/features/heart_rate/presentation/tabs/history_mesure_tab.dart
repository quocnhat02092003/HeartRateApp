import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/widgets/history_measure_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../database/db/heart_rate_record.dart';
import '../../../../firebase/auth/GoogleAuthService.dart';
import '../widgets/history_measure_chart.dart';
import 'dart:async';

class HistoryMeasureTab extends StatefulWidget {
  const HistoryMeasureTab({super.key});

  @override
  State<HistoryMeasureTab> createState() => _HistoryMeasureTabState();
}

class _HistoryMeasureTabState extends State<HistoryMeasureTab> {
  GoogleSignInAccount? _user;

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    // Nếu đã có user được giữ trong service, dùng luôn
    if (GoogleAuthService.currentUser != null) {
      setState(() => _user = GoogleAuthService.currentUser);
      return;
    }

    // Còn nếu chưa có, thử đăng nhập ngầm (tự động)
    final user = await GoogleAuthService.signInSilently();
    if (mounted && user != null) {
      setState(() => _user = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Vui lòng đăng nhập để xem lịch sử đo.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                GoogleAuthService.signIn().then((user) {
                  if (user != null) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Đăng nhập thành công: ${user.displayName}",
                        ),
                      ),
                    );
                  }
                });
              },
              child: Text("Đăng nhập"),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          height: 150,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getHeartRateRecordsStream(_user!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có dữ liệu đo',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final records = snapshot.data!;

                final bpmList = records
                    .map((rec) => (rec['bpm'] as num).toDouble())
                    .toList()
                    .reversed
                    .toList();

                return HistoryMeasureChart(values: bpmList);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          alignment: Alignment.center,
          width: double.infinity, // full chiều ngang
          color: const Color.fromARGB(66, 103, 233, 240),
          padding: const EdgeInsets.all(8), // padding cho đẹp
          child: const Text(
            'KẾT QUẢ GẦN ĐÂY',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: getHeartRateRecordsStream(_user!.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Chưa có dữ liệu đo',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final records = snapshot.data!;

              return ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final rec = records[index];
                  final bpm = rec['bpm'];
                  final timestamp = rec['timestamp'];
                  final List<double> ppgSignal =
                  (rec['ppgSignal'] as List<dynamic>)
                      .map((e) => (e as num).toDouble())
                      .toList();
                  final time = timestamp is Timestamp
                      ? timestamp.toDate()
                      : DateTime.tryParse(timestamp.toString()) ??
                            DateTime.now();

                  return HistoryMeasureButton(bpm: bpm, timestamp: time, ppgSignal: ppgSignal,);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
