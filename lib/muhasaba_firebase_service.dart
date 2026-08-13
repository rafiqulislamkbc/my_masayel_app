import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MuhasabaFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ১. ফায়ারবেস থেকে সক্রিয় আমলগুলোর লাইভ স্ট্রিম আনা
  static Stream<List<Map<String, dynamic>>> getAmolListStream() {
    return _firestore
        .collection('muhasaba_amols')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// ২. দৈনিক ব্যানার ও অনুপ্রেরণামূলক হাদিস আনা
  static Stream<Map<String, dynamic>?> getDailyBannerStream() {
    return _firestore
        .collection('app_config')
        .doc('muhasaba_banner')
        .snapshots()
        .map((doc) => doc.data());
  }

  /// ৩. ইউজারের আজকের আমলের হিসাব ফায়ারবেসে সিঙ্ক করা
  static Future<void> syncUserAmolRecord({
    required String userId,
    required String dateKey, // যেমন: '2026-08-13'
    required Map<String, bool> amolStatus,
    required int streakDays,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('muhasaba_records')
          .doc(dateKey)
          .set({
        'date': dateKey,
        'completedAmols': amolStatus,
        'streakDays': streakDays,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore Sync Error: $e');
    }
  }
}