import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MuhasabaFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ডিফল্ট স্ট্যান্ডার্ড আমল তালিকা (ইন্টারনেট না থাকলে বা ফায়ারবেস লোড হওয়ার আগে দেখাবে)
  static final List<Map<String, dynamic>> defaultAmols = [
    {'id': 'fajr', 'title': 'ফজর', 'subtitle': '২ রাকাত সুন্নাত ও ২ রাকাত ফরজ', 'category': 'farz', 'order': 1, 'isActive': true},
    {'id': 'dhuhr', 'title': 'যোহর', 'subtitle': '৪ রাকাত ফরজ ও সুন্নাত সালাত', 'category': 'farz', 'order': 2, 'isActive': true},
    {'id': 'asr', 'title': 'আসর', 'subtitle': '৪ রাকাত ফরজ সালাত', 'category': 'farz', 'order': 3, 'isActive': true},
    {'id': 'maghrib', 'title': 'মাগরিব', 'subtitle': '৩ রাকাত ফরজ ও ২ রাকাত সুন্নাত', 'category': 'farz', 'order': 4, 'isActive': true},
    {'id': 'isha', 'title': 'এশা', 'subtitle': '৪ রাকাত ফরজ ও বিতর সালাত', 'category': 'farz', 'order': 5, 'isActive': true},
    {'id': 'quran', 'title': 'কুরআন তিলাওয়াত', 'subtitle': 'কমপক্ষে ১০ আয়াত বা অর্থসহ ১ রুকু', 'category': 'nafl_zikr', 'order': 6, 'isActive': true},
    {'id': 'q&a', 'title': 'প্রশ্নোত্তর পাঠ', 'subtitle': 'এই অ্যাপ থেকে কমপক্ষে ৫টি', 'category': 'nafl_zikr', 'order': 7, 'isActive': true},
    {'id': 'chasht', 'title': 'চাশত সালাত (সালাতুদ দুহা)', 'subtitle': 'সূর্য ওঠার পর ২ থেকে ৪ রাকাত সালাত', 'category': 'nafl_zikr', 'order': 8, 'isActive': true},
    {'id': 'awwabin', 'title': 'আওয়াবিন সালাত', 'subtitle': 'মাগরিবের পর ৬ রাকাত নফল সালাত', 'category': 'nafl_zikr', 'order': 9, 'isActive': true},
    {'id': 'durood', 'title': 'দরুদ শরীফ (কমপক্ষে ১০০ বার)', 'subtitle': 'রাসূলুল্লাহ (ﷺ)-এর ওপর ১০০ বার দরুদ পাঠ', 'category': 'nafl_zikr', 'order': 10, 'isActive': true},
    {'id': 'istighfar', 'title': 'ইস্তিগফার ও জিকির (১০০ বার)', 'subtitle': 'সকাল ও সন্ধ্যার মাসনুন জিকির', 'category': 'nafl_zikr', 'order': 11, 'isActive': true},
    {'id': 'tahajjud', 'title': 'তাহাজ্জুদ সালাত', 'subtitle': 'রাতের শেষ তৃতীয়াংশে বিশেষ ইবাদত', 'category': 'nafl_zikr', 'order': 12, 'isActive': true},
  ];

  /// ১. ফায়ারবেস থেকে সক্রিয় আমলগুলোর স্ট্রিম (রিয়েলটাইম আপডেট)
  static Stream<List<Map<String, dynamic>>> getDynamicAmolsStream() {
    return _firestore
        .collection('muhasaba_amols')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = data['id'] ?? doc.id;
          return data;
        }).toList();
      }
      return defaultAmols;
    }).handleError((error) {
      debugPrint('Error getting amols (fallback to default): $error');
      return defaultAmols;
    });
  }

  /// ২. দৈনিক ব্যানার ও অনুপ্রেরণামূলক হাদিস স্ট্রিম
  static Stream<Map<String, dynamic>> getDailyBannerStream() {
    return _firestore
        .collection('app_config')
        .doc('muhasaba_banner')
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
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
}