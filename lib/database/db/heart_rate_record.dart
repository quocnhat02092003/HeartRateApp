import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//Upload heart rate record to Firestore
Future<void> addHeartRateRecordToCloud(String userId, int bpm) async {
  await db.collection('heart-rate-record').add({
    'userId': userId,
    'bpm': bpm,
    'timestamp': FieldValue.serverTimestamp(),
  }).then((s) => print("Document added with ID ${s.id}"));
}

//Get heart rate records stream from Firestore
Stream<List<Map<String, dynamic>>> getHeartRateRecordsStream(String userId) {
  return db
      .collection('heart-rate-record')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => doc.data())
      .toList());
}