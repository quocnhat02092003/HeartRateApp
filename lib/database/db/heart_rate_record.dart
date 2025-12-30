import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//Upload heart rate record to Firestore
Future<void> addHeartRateRecordToCloud(String userId, int bpm, List<double> ppgSignal, double bp_sys, double bp_dia) async {
  await db.collection('heart-rate-record').add({
    'userId': userId,
    'bpm': bpm,
    'ppgSignal': ppgSignal,
    'timestamp': FieldValue.serverTimestamp(),
    'bp_sys': bp_sys,
    'bp_dia': bp_dia,
  }).then((s) => print("Document added with ID ${s.id}"));
}

//Get heart rate records stream from Firestore
Stream<List<Map<String, dynamic>>> getHeartRateRecordsStream(String userId) {
  return db
      .collection('heart-rate-record')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => doc.data())
      .toList());
}

//get last bpm once
Future<int?> getLastBpmOnce(String userId) async {
  final query = await db
      .collection('heart-rate-record')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get();

  if (query.docs.isEmpty) return null;
  return query.docs.first['bpm'] as int?;
}