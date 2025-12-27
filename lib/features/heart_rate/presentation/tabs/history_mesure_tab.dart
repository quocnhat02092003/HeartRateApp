import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../database/db/heart_rate_record.dart';
import '../../../../firebase/auth/GoogleAuthService.dart';
import '../widgets/history_measure_button.dart';
import '../widgets/history_measure_chart.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

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
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = GoogleAuthService.currentUser ?? await GoogleAuthService.signInSilently();
    if (mounted) setState(() {});
  }

  Future<void> _exportPdf(List<Map<String, dynamic>> records) async {
    try {
      // Load font unicode
      final fontData = await rootBundle.load("assets/fonts/times.ttf");
      final boldFontData = await rootBundle.load("assets/fonts/timesbd.ttf");

      final PdfFont normalFont =
      PdfTrueTypeFont(fontData.buffer.asUint8List(), 10);
      final PdfFont boldFont =
      PdfTrueTypeFont(boldFontData.buffer.asUint8List(), 14);

      // Create PDF
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();

      final PdfGraphics graphics = page.graphics;

      // Title
      graphics.drawString(
        "Lịch sử đo nhịp tim",
        boldFont,
        brush: PdfBrushes.black,
        bounds: const Rect.fromLTWH(0, 0, 500, 30),
      );

      // Create table
      final PdfGrid grid = PdfGrid();
      grid.columns.add(count: 3);

      grid.headers.add(1);
      final PdfGridRow header = grid.headers[0];

      header.style = PdfGridRowStyle(
        backgroundBrush: PdfBrushes.lightGray,
        font: boldFont,
        textBrush: PdfBrushes.black,
      );

      header.cells[0].value = "Ngày đo";
      header.cells[1].value = "Nhịp tim (BPM)";
      header.cells[2].value = "Ghi chú";

      grid.style = PdfGridStyle(
        font: normalFont,
        cellPadding: PdfPaddings(left: 4, right: 4, top: 6, bottom: 6),
      );

      // Add rows
      for (var rec in records) {
        final row = grid.rows.add();

        final timestamp = rec['timestamp'];
        final date = timestamp is Timestamp
            ? timestamp.toDate()
            : DateTime.now();

        row.cells[0].value = DateFormat("dd/MM/yyyy HH:mm").format(date);
        row.cells[1].value = rec['bpm'].toString();
        row.cells[2].value = "Đo nhịp tim cá nhân";
      }

      // Draw grid safely
      grid.draw(
        page: page,
        bounds: const Rect.fromLTWH(0, 40, 0, 0),
      );

      // Ensure the document is fully saved without null exception
      final List<int> bytes = await document.save();
      document.dispose();

      // Save file
      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/heart_rate_${DateTime.now().millisecondsSinceEpoch}.pdf";

      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      // Open the file
      await OpenFilex.open(path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã lưu file PDF tại: $path")),
        );
      }

    } catch (e, st) {
      debugPrint("PDF EXPORT ERROR: $e\n$st");
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return _loginRequest();
    }

    return Column(
      children: [
        _exportButton(),
        _recentChart(),
        _recentHeader(),
        _historyList(),
      ],
    );
  }

  Widget _loginRequest() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Vui lòng đăng nhập để xem lịch sử đo.", style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () async {
            final user = await GoogleAuthService.signIn();
            if (user != null) setState(() => _user = user);
          },
          child: const Text("Đăng nhập"),
        )
      ],
    ),
  );

  Widget _exportButton() => SizedBox(
    width: double.infinity,
    child: TextButton(
      style: TextButton.styleFrom(backgroundColor: Colors.cyan, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
      onPressed: () async {
        print("Exporting PDF...");
        final snapshot = await getHeartRateRecordsStream(_user!.id).first;

        if (snapshot.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Không có dữ liệu để xuất PDF")));
          return;
        }
        await _exportPdf(snapshot);
      },
      child: const Text("Xuất file PDF lịch sử nhịp tim", style: TextStyle(color: Colors.white)),
    ),
  );

  Widget _recentChart() => SizedBox(
    height: 150,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getHeartRateRecordsStream(_user!.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có dữ liệu đo", style: TextStyle(color: Colors.white70)));
          }
          final bpmValues = snapshot.data!.map((e) => (e['bpm'] as num).toDouble()).toList().reversed.toList();
          return HistoryMeasureChart(values: bpmValues);
        },
      ),
    ),
  );

  Widget _recentHeader() => Container(
    width: double.infinity,
    color: Colors.teal,
    padding: const EdgeInsets.all(8),
    alignment: Alignment.center,
    child: const Text("KẾT QUẢ GẦN ĐÂY", style: TextStyle(color: Colors.white)),
  );

  Widget _historyList() => Expanded(
    child: StreamBuilder<List<Map<String, dynamic>>>(
      stream: getHeartRateRecordsStream(_user!.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Chưa có dữ liệu đo", style: TextStyle(color: Colors.white70)));
        }
        final records = snapshot.data!;
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final rec = records[index];
            final bpm = rec['bpm'];
            final timestamp = rec['timestamp'];
            final time = timestamp is Timestamp ? timestamp.toDate() : DateTime.now();
            final ppgRaw = rec['ppgSignal'] as List<dynamic>? ?? [];
            final ppg = ppgRaw.whereType<num>().map((e) => e.toDouble()).toList();

            return HistoryMeasureButton(
              bpm: bpm,
              timestamp: time,
              ppgSignal: ppg,
            );
          },
        );
      },
    ),
  );
}