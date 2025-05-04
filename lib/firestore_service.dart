import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CarbonFootprint.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveDailyFootprint(double kgCO2e) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');


    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);

    final docId = '${user.email}_${midnight.toIso8601String().substring(0, 10)}';

    final footprint = CarbonFootprint(
      uid: user.email!,
      date: Timestamp.fromDate(midnight),
      kgCO2e: kgCO2e,
    );

    await _db
        .collection('EcoLife')
        .doc(docId)
        .set(footprint.toJson(), SetOptions(merge: true)); // merge 可防丢字段
  }
}
