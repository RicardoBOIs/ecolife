import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CarbonFootprint.dart';
import 'pages/tips_education.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  //Save Daily FootPrint
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
        .doc('footprints')
        .collection('daily')
        .doc(docId)
        .set(footprint.toJson(), SetOptions(merge: true));


  }
  //Save tips for admin
  Future<void> saveTip(Tip tip) async {
    await _db
        .collection('EcoLife')
        .doc('tips')
        .collection('items')
        .add({
      'title': tip.title,
      'subtitle': tip.subtitle,
      'reference': tip.reference,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update and Save user profile
  Future<void> saveUserProfile({
    required String username,
    required String phone,
    required String location,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await _db
        .collection('EcoLife')
        .doc('users')
        .collection('profiles')
        .doc(user.email)
        .set({
      'email': user.email,
      'username': username,
      'phone': phone,
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }


}
