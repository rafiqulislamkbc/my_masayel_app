import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MuhasabaFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ডিফল্ট স্ট্যান্ডার্ড আমল তালিকা (অফলাইনের জন্য ফলব্যাক)
  static final List<Map<String, dynamic>> defaultAmols = [
    {
      'id': 'fajr',
      'title': 'ফজর নামাজ (জামাতে)',
      'category': 'ফরজ নামাজ',
      'points': 10,
      'order': 1,
      'isActive': true,
    },
    {
      'id': 'dhuhr',
      'title': 'জোহর নামাজ (জামাতে)',
      'category': 'ফরজ নামাজ',
      'points': 10,
      'order': 2,
      'isActive': true,
    },
    {
      'id': 'asr',
      'title': 'আসর নামাজ (জামাতে)',
      'category': 'ফরজ নামাজ',
      'points': 10,
      'order': 3,
      'isActive': true,
    },
    {
      'id': 'maghrib',
      'title': 'মাগরিব নামাজ (জামাতে)',
      'category': 'ফরজ নামাজ',
      'points': 10,
      'order': 4,
      'isActive': true,
    },
    {
      'id': 'isha',
      'title': 'এশা নামাজ (জামাতে)',
      'category': 'ফরজ নামাজ',
      'points': 10,
      'order': 5,
      'isActive': true,
    },
    {
      'id': 'quran',
      'title': 'দৈনিক কুরআন তিলাওয়াত',
      'category': 'নফল আমল',
      'points': 15,
      'order': 6,
      'isActive': true,
    },
    {
      'id': 'zikr_morning_evening',
      'title': 'সকাল ও সন্ধ্যার মাসনূন দোয়া/জিকির',
      'category': 'জিকির ও আজকার',
      'points': 10,
      'order': 7,
      'isActive': true,
    },
    {
      'id': 'istighfar',
      'title': 'দৈনিক ইস্তিগফার (কমপক্ষে ১০০ বার)',
      'category': 'জিকির ও আজকার',
      'points': 10,
      'order': 8,
      'isActive': true,
    },
    {
      'id': 'darood',
      'title': 'রাসূলুল্লাহ ﷺ-এর ওপর দরূদ পাঠ',
      'category': 'জিকির ও আজকার',
      'points': 10,
      'order': 9,
      'isActive': true,
    },
    {
      'id': 'tahajjud',
      'title': 'তাহাজ্জুদ নামাজ',
      'category': 'নফল নামাজ',
      'points': 20,
      'order': 10,
      'isActive': true,
    },
  ];

  /// ১. ফায়ারবেস থেকে সক্রিয় আমলগুলোর স্ট্রিম (অফলাইনে ক্যাশ/ফলব্যাকসহ)
  static Stream<List<Map<String, dynamic>>> getAmolListStream() {
    return _firestore
        .collection('muhasaba_amols')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      }
      // ফায়ারবেসে ডেটা না থাকলে বা অফলাইনে ক্যাশ না পেলে ডিফল্ট আমল দেখাবে
      return defaultAmols;
    }).handleError((error) {
      debugPrint('Error getting amols (falling back to default): $error');
      return defaultAmols;
    });
  }

  /// ২. দৈনিক ব্যানার ও অনুপ্রেরণামূলক হাদিস আনা
  static Stream<Map<String, dynamic>?> getDailyBannerStream() {
    return _firestore
        .collection('app_config')
        .doc('muhasaba_banner')
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return {
        'title': 'দৈনিক আত্মপর্যালোচনা',
        'subtitle': 'হিসাব নেওয়ার পূর্বেই নিজের হিসাব নাও। — হযরত উমর (রা.)',
      };
    }).handleError((_) => {
          'title': 'দৈনিক আত্মপর্যালোচনা',
          'subtitle': 'হিসাব নেওয়ার পূর্বেই নিজের হিসাব নাও। — হযরত উমর (রা.)',
        });
  }

  /// ৩. ইউজারের আজকের আমলের হিসাব ফায়ারবেসে সিঙ্ক করা (অফলাইন ও অনলাইন সমর্থিত)
  static Future<void> syncUserAmolRecord({
    required String userId,
    required String dateKey, // যেমন: '2026-08-15'
    required Map<String, bool> amolStatus,
    required int streakDays,
  }) async {
    try {
      // SetOptions(merge: true) অফলাইনে ডিভাইস স্টোরেজে রাইট করে এবং অনলাইনে অটো সিঙ্ক করে
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

  /// ৪. নির্দিষ্ট কোনো দিনের আমল রেকর্ড ফেচ করা (অফলাইন ক্যাশ ফার্স্ট)
  static Future<Map<String, dynamic>?> getUserAmolRecord({
    required String userId,
    required String dateKey,
  }) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('muhasaba_records')
          .doc(dateKey);

      // অফলাইন এবং অনলাইন উভয় উৎস থেকেই ডেটা আনার চেষ্টা
      final docSnap = await docRef.get(const GetOptions(source: Source.serverAndCache));
      if (docSnap.exists) {
        return docSnap.data();
      }
    } catch (e) {
      try {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('muhasaba_records')
            .doc(dateKey);
        final cacheSnap = await docRef.get(const GetOptions(source: Source.cache));
        return cacheSnap.data();
      } catch (_) {}
    }
    return null;
  }
}