import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// সংখ্যা বাংলায় রূপান্তর
String toBanglaNumber(dynamic input) {
  const Map<String, String> bnDigits = {
    '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
    '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯'
  };
  return input.toString().split('').map((c) => bnDigits[c] ?? c).join();
}

// সম্পূর্ণ বাংলা তারিখ
String getBanglaFullDate(DateTime date) {
  const List<String> bnMonths = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];
  final day = toBanglaNumber(date.day);
  final month = bnMonths[date.month - 1];
  final year = toBanglaNumber(date.year);
  return 'আজ $day $month $year';
}

class DistrictData {
  final String id;
  final String nameBn;
  final String division;
  final int offsetMinutes;

  const DistrictData({
    required this.id,
    required this.nameBn,
    required this.division,
    required this.offsetMinutes,
  });
}

const List<DistrictData> all64Districts = [
  DistrictData(id: 'dhaka', nameBn: 'ঢাকা', division: 'ঢাকা', offsetMinutes: 0),
  DistrictData(id: 'gazipur', nameBn: 'গাজীপুর', division: 'ঢাকা', offsetMinutes: 0),
  DistrictData(id: 'narayanganj', nameBn: 'নারায়ণগঞ্জ', division: 'ঢাকা', offsetMinutes: -1),
  DistrictData(id: 'tangail', nameBn: 'টাঙ্গাইল', division: 'ঢাকা', offsetMinutes: 1),
  DistrictData(id: 'gopalganj', nameBn: 'গোপালগঞ্জ', division: 'ঢাকা', offsetMinutes: 2),
  DistrictData(id: 'faridpur', nameBn: 'ফরিদপুর', division: 'ঢাকা', offsetMinutes: 2),
  DistrictData(id: 'madaripur', nameBn: 'মাদারীপুর', division: 'ঢাকা', offsetMinutes: 1),
  DistrictData(id: 'manikganj', nameBn: 'মানিকগঞ্জ', division: 'ঢাকা', offsetMinutes: 1),
  DistrictData(id: 'munshiganj', nameBn: 'মুন্সীগঞ্জ', division: 'ঢাকা', offsetMinutes: -1),
  DistrictData(id: 'narsingdi', nameBn: 'নরসিংদী', division: 'ঢাকা', offsetMinutes: -1),
  DistrictData(id: 'rajbari', nameBn: 'রাজবাড়ী', division: 'ঢাকা', offsetMinutes: 3),
  DistrictData(id: 'shariatpur', nameBn: 'শরীয়তপুর', division: 'ঢাকা', offsetMinutes: 0),
  DistrictData(id: 'kishoreganj', nameBn: 'কিশোরগঞ্জ', division: 'ঢাকা', offsetMinutes: -2),
  DistrictData(id: 'chattogram', nameBn: 'চট্টগ্রাম', division: 'চট্টগ্রাম', offsetMinutes: -5),
  DistrictData(id: 'coxsbazar', nameBn: 'কক্সবাজার', division: 'চট্টগ্রাম', offsetMinutes: -6),
  DistrictData(id: 'cumilla', nameBn: 'কুমিল্লা', division: 'চট্টগ্রাম', offsetMinutes: -3),
  DistrictData(id: 'feni', nameBn: 'ফেনী', division: 'চট্টগ্রাম', offsetMinutes: -4),
  DistrictData(id: 'brahmanbaria', nameBn: 'ব্রাহ্মণবাড়িয়া', division: 'চট্টগ্রাম', offsetMinutes: -2),
  DistrictData(id: 'chandpur', nameBn: 'চাঁদপুর', division: 'চট্টগ্রাম', offsetMinutes: -1),
  DistrictData(id: 'lakshmipur', nameBn: 'লক্ষ্মীপুর', division: 'চট্টগ্রাম', offsetMinutes: -2),
  DistrictData(id: 'noakhali', nameBn: 'নোয়াখালী', division: 'চট্টগ্রাম', offsetMinutes: -3),
  DistrictData(id: 'khagrachhari', nameBn: 'খাগড়াছড়ি', division: 'চট্টগ্রাম', offsetMinutes: -6),
  DistrictData(id: 'rangamati', nameBn: 'রাঙ্গামাটি', division: 'চট্টগ্রাম', offsetMinutes: -6),
  DistrictData(id: 'bandarban', nameBn: 'বান্দরবান', division: 'চট্টগ্রাম', offsetMinutes: -6),
  DistrictData(id: 'sylhet', nameBn: 'সিলেট', division: 'সিলেট', offsetMinutes: -6),
  DistrictData(id: 'moulvibazar', nameBn: 'মৌলভীবাজার', division: 'সিলেট', offsetMinutes: -5),
  DistrictData(id: 'habiganj', nameBn: 'হবিগঞ্জ', division: 'সিলেট', offsetMinutes: -4),
  DistrictData(id: 'sunamganj', nameBn: 'সুনামগঞ্জ', division: 'সিলেট', offsetMinutes: -5),
  DistrictData(id: 'rajshahi', nameBn: 'রাজশাহী', division: 'রাজশাহী', offsetMinutes: 6),
  DistrictData(id: 'bogra', nameBn: 'বগুড়া', division: 'রাজশাহী', offsetMinutes: 4),
  DistrictData(id: 'pabna', nameBn: 'পাবনা', division: 'রাজশাহী', offsetMinutes: 4),
  DistrictData(id: 'sirajganj', nameBn: 'সিরাজগঞ্জ', division: 'রাজশাহী', offsetMinutes: 2),
  DistrictData(id: 'naogaon', nameBn: 'নওগাঁ', division: 'রাজশাহী', offsetMinutes: 6),
  DistrictData(id: 'natore', nameBn: 'নাটোর', division: 'রাজশাহী', offsetMinutes: 5),
  DistrictData(id: 'chapainawabganj', nameBn: 'চাঁপাইনবাবগঞ্জ', division: 'রাজশাহী', offsetMinutes: 8),
  DistrictData(id: 'joypurhat', nameBn: 'জয়পুরহাট', division: 'রাজশাহী', offsetMinutes: 5),
  DistrictData(id: 'khulna', nameBn: 'খুলনা', division: 'খুলনা', offsetMinutes: 3),
  DistrictData(id: 'bagerhat', nameBn: 'বাগেরহাট', division: 'খুলনা', offsetMinutes: 2),
  DistrictData(id: 'chuadanga', nameBn: 'চুয়াডাঙ্গা', division: 'খুলনা', offsetMinutes: 6),
  DistrictData(id: 'jashore', nameBn: 'যশোর', division: 'খুলনা', offsetMinutes: 4),
  DistrictData(id: 'jhenaidah', nameBn: 'ঝিনাইদহ', division: 'খুলনা', offsetMinutes: 4),
  DistrictData(id: 'kushtia', nameBn: 'কুষ্টিয়া', division: 'খুলনা', offsetMinutes: 5),
  DistrictData(id: 'magura', nameBn: 'মাগুরা', division: 'খুলনা', offsetMinutes: 3),
  DistrictData(id: 'meherpur', nameBn: 'মেহেরপুর', division: 'খুলনা', offsetMinutes: 6),
  DistrictData(id: 'narail', nameBn: 'নড়াইল', division: 'খুলনা', offsetMinutes: 3),
  DistrictData(id: 'satkhira', nameBn: 'সাতক্ষীরা', division: 'খুলনা', offsetMinutes: 5),
  DistrictData(id: 'barishal', nameBn: 'বরিশাল', division: 'বরিশাল', offsetMinutes: 1),
  DistrictData(id: 'barguna', nameBn: 'বরগুনা', division: 'বরিশাল', offsetMinutes: 2),
  DistrictData(id: 'bhola', nameBn: 'ভোলা', division: 'বরিশাল', offsetMinutes: -1),
  DistrictData(id: 'jhalokati', nameBn: 'ঝালকাঠি', division: 'বরিশাল', offsetMinutes: 2),
  DistrictData(id: 'patuakhali', nameBn: 'পটুয়াখালী', division: 'বরিশাল', offsetMinutes: 1),
  DistrictData(id: 'pirojpur', nameBn: 'পিরোজপুর', division: 'বরিশাল', offsetMinutes: 3),
  DistrictData(id: 'rangpur', nameBn: 'রংপুর', division: 'রংপুর', offsetMinutes: 6),
  DistrictData(id: 'dinajpur', nameBn: 'দিনাজপুর', division: 'রংপুর', offsetMinutes: 8),
  DistrictData(id: 'gaibandha', nameBn: 'গাইবান্ধা', division: 'রংপুর', offsetMinutes: 4),
  DistrictData(id: 'kurigram', nameBn: 'কুড়িগ্রাম', division: 'রংপুর', offsetMinutes: 3),
  DistrictData(id: 'lalmonirhat', nameBn: 'লালমনিরহাট', division: 'রংপুর', offsetMinutes: 5),
  DistrictData(id: 'nilphamari', nameBn: 'নীলফামারী', division: 'রংপুর', offsetMinutes: 7),
  DistrictData(id: 'panchagarh', nameBn: 'পঞ্চগড়', division: 'রংপুর', offsetMinutes: 10),
  DistrictData(id: 'thakurgaon', nameBn: 'ঠাকুরগাঁও', division: 'রংপুর', offsetMinutes: 9),
  DistrictData(id: 'mymensingh', nameBn: 'ময়মনসিংহ', division: 'ময়মনসিংহ', offsetMinutes: 0),
  DistrictData(id: 'jamalpur', nameBn: 'জামালপুর', division: 'ময়মনসিংহ', offsetMinutes: 2),
  DistrictData(id: 'netrokona', nameBn: 'নেত্রকোণা', division: 'ময়মনসিংহ', offsetMinutes: -2),
  DistrictData(id: 'sherpur', nameBn: 'শেরপুর', division: 'ময়মনসিংহ', offsetMinutes: 1),
];

class AmolItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  bool isCompleted;

  AmolItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.isCompleted = false,
  });
}

class AmolMuhasabaPage extends StatefulWidget {
  const AmolMuhasabaPage({super.key});

  @override
  State<AmolMuhasabaPage> createState() => _AmolMuhasabaPageState();
}

class _AmolMuhasabaPageState extends State<AmolMuhasabaPage> {
  int userStreakDays = 0;
  bool _isSubmittedToday = false;
  bool _isSaving = false;

  DistrictData selectedDistrict = all64Districts[0];
  String selectedFilter = 'all';

  Timer? _timer;
  String currentWaqt = 'যোহর';
  String remainingFormatted = '৪ ঘণ্টা ৩৪ মিনিট বাকি';
  String remainingDigital = '০৪:৩৪:০০';

  final List<AmolItem> amols = [
    AmolItem(id: 'fajr', title: 'ফজর', subtitle: '২ রাকাত সুন্নাত ও ২ রাকাত ফরজ', category: 'farz'),
    AmolItem(id: 'dhuhr', title: 'যোহর', subtitle: '৪ রাকাত ফরজ ও সুন্নাত সালাত', category: 'farz'),
    AmolItem(id: 'asr', title: 'আসর', subtitle: '৪ রাকাত ফরজ সালাত', category: 'farz'),
    AmolItem(id: 'maghrib', title: 'মাগরিব', subtitle: '৩ রাকাত ফরজ ও ২ রাকাত সুন্নাত', category: 'farz'),
    AmolItem(id: 'isha', title: 'এশা', subtitle: '৪ রাকাত ফরজ ও বিতর সালাত', category: 'farz'),
    AmolItem(id: 'quran', title: 'কুরআন তিলাওয়াত', subtitle: 'কমপক্ষে ১০ আয়াত বা অর্থসহ ১ রুকু', category: 'nafl_zikr'),
    AmolItem(id: 'q&a', title: 'প্রশ্নোত্তর পাঠ', subtitle: 'এই অ্যাপ থেকে কমপক্ষে ৫টি', category: 'nafl_zikr'),
    AmolItem(id: 'chasht', title: 'চাশত সালাত (সালাতুদ দুহা)', subtitle: 'সূর্য ওঠার পর ২ থেকে ৪ রাকাত সালাত', category: 'nafl_zikr'),
    AmolItem(id: 'awwabin', title: 'আওয়াবিন সালাত', subtitle: 'মাগরিবের পর ৬ রাকাত নফল সালাত', category: 'nafl_zikr'),
    AmolItem(id: 'durood', title: 'দরুদ শরীফ (কমপক্ষে ১০০ বার)', subtitle: 'রাসূলুল্লাহ (ﷺ)-এর ওপর ১০০ বার দরুদ পাঠ', category: 'nafl_zikr'),
    AmolItem(id: 'istighfar', title: 'ইস্তিগফার ও জিকির (১০০ বার)', subtitle: 'সকাল ও সন্ধ্যার মাসনুন জিকির', category: 'nafl_zikr'),
    AmolItem(id: 'tahajjud', title: 'তাহাজ্জুদ সালাত', subtitle: 'রাতের শেষ তৃতীয়াংশে বিশেষ ইবাদত', category: 'nafl_zikr'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
    _updatePrayerTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updatePrayerTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);

    for (var amol in amols) {
      amol.isCompleted = false;
    }

    if (user == null) {
      if (mounted) {
        setState(() {
          _isSubmittedToday = false;
          userStreakDays = 0;
        });
      }
      return;
    }

    final uid = user.uid;
    String savedDistrictId = 'dhaka';

    try {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(uid);
      final userSnap = await userRef.get();

      String districtId = 'dhaka';
      if (userSnap.exists && userSnap.data() != null) {
        final userData = userSnap.data()!;
        districtId = userData['districtId']?.toString() ?? 'dhaka';
      } else {
        await userRef.set({
          'uid': uid,
          'email': user.email ?? '',
          'name': user.displayName ?? 'নাম প্রকাশে অনিচ্ছুক',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      savedDistrictId = prefs.getString('user_district_id') ?? districtId;
      final selected = all64Districts.firstWhere(
        (d) => d.id == savedDistrictId,
        orElse: () => all64Districts.first,
      );

      final recordsRef = userRef.collection('muhasaba_records');
      final todaySnap = await recordsRef.doc(todayKey).get();

      bool submittedToday = false;
      if (todaySnap.exists && todaySnap.data() != null) {
        final data = todaySnap.data()!;
        submittedToday = data['isSubmitted'] == true;

        final tasks = data['tasks'] as Map<String, dynamic>?;
        if (tasks != null) {
          for (var amol in amols) {
            if (tasks.containsKey(amol.id)) {
              amol.isCompleted = tasks[amol.id] == true;
            }
          }
        }
      }

      final streak = await _calculateStreak(recordsRef);

      await prefs.setString('user_district_id', selected.id);
      await prefs.setBool('sub_${uid}_$todayKey', submittedToday);

      for (var amol in amols) {
        await prefs.setBool('amol_${uid}_${todayKey}_${amol.id}', amol.isCompleted);
      }
      await prefs.setInt('streak_$uid', streak);

      if (mounted) {
        setState(() {
          _isSubmittedToday = submittedToday;
          userStreakDays = streak;
          selectedDistrict = selected;
        });
      }
    } catch (e) {
      debugPrint('Firestore Load Error: $e');
      final localSubmitted = prefs.getBool('sub_${uid}_$todayKey') ?? false;
      final localStreak = prefs.getInt('streak_$uid') ?? 0;

      for (var amol in amols) {
        amol.isCompleted = prefs.getBool('amol_${uid}_${todayKey}_${amol.id}') ?? false;
      }

      if (mounted) {
        setState(() {
          _isSubmittedToday = localSubmitted;
          userStreakDays = localStreak;
          selectedDistrict = all64Districts.firstWhere(
            (d) => d.id == savedDistrictId,
            orElse: () => all64Districts.first,
          );
        });
      }
    }
  }

  Future<int> _calculateStreak(CollectionReference recordsRef) async {
    try {
      final snapshot = await recordsRef.get();
      if (snapshot.docs.isEmpty) return 0;

      final dates = snapshot.docs
          .map((doc) => doc.id)
          .where((date) => RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date))
          .toList();

      dates.sort((a, b) => b.compareTo(a));
      if (dates.isEmpty) return 0;

      DateTime today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      DateTime latestDate = DateTime.parse(dates.first);
      final difference = today.difference(latestDate).inDays;

      if (difference > 1) return 0;

      int streak = 1;
      DateTime previousDate = latestDate;

      for (int i = 1; i < dates.length; i++) {
        final currentDate = DateTime.parse(dates[i]);
        final gap = previousDate.difference(currentDate).inDays;

        if (gap == 1) {
          streak++;
          previousDate = currentDate;
        } else if (gap == 0) {
          continue;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      debugPrint('Streak Calculation Error: $e');
      return 0;
    }
  }

  Future<void> _submitTodayAmol() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে প্রথমে লগইন করুন')),
      );
      return;
    }

    if (_isSubmittedToday) return;

    setState(() => _isSaving = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final uid = user.uid;
      final dateKey = DateTime.now().toIso8601String().substring(0, 10);

      final Map<String, bool> taskMap = {
        for (var item in amols) item.id: item.isCompleted,
      };

      final completedCount = amols.where((a) => a.isCompleted).length;
      final totalCount = amols.length;

      final userRef = firestore.collection('users').doc(uid);

      await userRef.set({
        'uid': uid,
        'email': user.email ?? '',
        'name': user.displayName ?? 'নাম প্রকাশে অনিচ্ছুক',
        'districtId': selectedDistrict.id,
        'districtName': selectedDistrict.nameBn,
        'lastActive': dateKey,
        'lastSubmitTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await userRef.collection('muhasaba_records').doc(dateKey).set({
        'date': dateKey,
        'tasks': taskMap,
        'completedCount': completedCount,
        'totalCount': totalCount,
        'isSubmitted': true,
        'districtId': selectedDistrict.id,
        'districtName': selectedDistrict.nameBn,
        'submittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final streak = await _calculateStreak(userRef.collection('muhasaba_records'));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sub_${uid}_$dateKey', true);

      for (var entry in taskMap.entries) {
        await prefs.setBool('amol_${uid}_${dateKey}_${entry.key}', entry.value);
      }

      await prefs.setInt('streak_$uid', streak);
      await prefs.setString('user_district_id', selectedDistrict.id);

      if (mounted) {
        setState(() {
          _isSubmittedToday = true;
          userStreakDays = streak;
          _isSaving = false;
        });

        if (completedCount == totalCount) {
          _showCelebrationDialog();
        } else {
          _showStandardThankYouDialog(completedCount, totalCount);
        }
      }
    } catch (e) {
      debugPrint('Firestore Save Error: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('সেভ করতে সমস্যা হয়েছে: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  void _showStandardThankYouDialog(int completedCount, int totalCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2923) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('জাযাকাল্লাহু খাইরান', style: TextStyle(color: Color(0xFF007A5E), fontWeight: FontWeight.bold)),
        content: Text(
          'আপনি আজ $completedCount/$totalCount আমল সম্পন্ন করেছেন। প্রতিদিনের ধারাবাহিকতা বজায় রাখার চেষ্টা করুন।',
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007A5E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  void _showCelebrationDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CelebrationConfettiDialog(),
    );
  }

  void _updatePrayerTime() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute + (now.second / 60.0);
    final offset = selectedDistrict.offsetMinutes;

    final fajrStart = (4 * 60 + 15) + offset;
    final sunrise = (5 * 60 + 35) + offset;
    final dhuhrStart = (12 * 60 + 5) + offset;
    final asrStart = (16 * 60 + 38) + offset;
    final maghribStart = (18 * 60 + 35) + offset;
    final ishaStart = (19 * 60 + 52) + offset;

    String waqtName = 'যোহর';
    double targetEnd = asrStart.toDouble();

    if (currentMinutes >= fajrStart && currentMinutes < sunrise) {
      waqtName = 'ফজর';
      targetEnd = sunrise.toDouble();
    } else if (currentMinutes >= sunrise && currentMinutes < dhuhrStart) {
      waqtName = 'চাশত/ইশরাক';
      targetEnd = dhuhrStart.toDouble();
    } else if (currentMinutes >= dhuhrStart && currentMinutes < asrStart) {
      waqtName = 'যোহর';
      targetEnd = asrStart.toDouble();
    } else if (currentMinutes >= asrStart && currentMinutes < maghribStart) {
      waqtName = 'আসর';
      targetEnd = maghribStart.toDouble();
    } else if (currentMinutes >= maghribStart && currentMinutes < ishaStart) {
      waqtName = 'মাগরিব';
      targetEnd = ishaStart.toDouble();
    } else {
      waqtName = 'এশা';
      targetEnd = (currentMinutes >= ishaStart) ? (24 * 60 + fajrStart).toDouble() : fajrStart.toDouble();
    }

    double diff = targetEnd - currentMinutes;
    if (diff < 0) diff += 24 * 60;

    final totalSecs = (diff * 60).toInt();
    final hours = totalSecs ~/ 3600;
    final mins = (totalSecs % 3600) ~/ 60;
    final secs = totalSecs % 60;

    String formattedText;
    if (hours > 0) {
      formattedText = '${toBanglaNumber(hours)} ঘণ্টা ${toBanglaNumber(mins)} মিনিট বাকি';
    } else if (mins > 0) {
      formattedText = '${toBanglaNumber(mins)} মিনিট ${toBanglaNumber(secs)} সেকেন্ড বাকি';
    } else {
      formattedText = '${toBanglaNumber(secs)} সেকেন্ড বাকি';
    }

    final hh = hours > 0 ? '${toBanglaNumber(hours.toString().padLeft(2, '0'))}:' : '';
    final mm = toBanglaNumber(mins.toString().padLeft(2, '0'));
    final ss = toBanglaNumber(secs.toString().padLeft(2, '0'));

    if (mounted) {
      setState(() {
        currentWaqt = waqtName;
        remainingFormatted = formattedText;
        remainingDigital = '$hh$mm:$ss';
      });
    }
  }

  void _openDistrictPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E2923) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = all64Districts.where((d) {
              return d.nameBn.contains(searchQuery) || d.division.contains(searchQuery);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.92,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'আপনার জেলা নির্বাচন করুন',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF007A5E),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (val) => setModalState(() => searchQuery = val),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'জেলার নাম খুঁজুন...',
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                          prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF34D399) : const Color(0xFF007A5E)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF141C18) : const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final dist = filtered[idx];
                            final isSelected = dist.id == selectedDistrict.id;
                            final offsetStr = dist.offsetMinutes == 0
                                ? 'ঢাকার সময়'
                                : (dist.offsetMinutes > 0
                                    ? '+${toBanglaNumber(dist.offsetMinutes)} মিনিট'
                                    : '-${toBanglaNumber(dist.offsetMinutes.abs())} মিনিট');

                            return ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              tileColor: isSelected
                                  ? (isDark ? const Color(0xFF273830) : const Color(0xFFE6F4F0))
                                  : Colors.transparent,
                              leading: Icon(Icons.location_on, color: isDark ? const Color(0xFF34D399) : const Color(0xFF007A5E)),
                              title: Text(
                                dist.nameBn,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                '${dist.division} বিভাগ • $offsetStr',
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle, color: isDark ? const Color(0xFF34D399) : const Color(0xFF007A5E))
                                  : null,
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                final user = FirebaseAuth.instance.currentUser;

                                await prefs.setString('user_district_id', dist.id);
                                setState(() {
                                  selectedDistrict = dist;
                                });

                                if (user != null) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .set({
                                      'districtId': dist.id,
                                      'districtName': dist.nameBn,
                                      'updatedAt': FieldValue.serverTimestamp(),
                                    }, SetOptions(merge: true));
                                  } catch (e) {
                                    debugPrint('District Save Error: $e');
                                  }
                                }

                                _updatePrayerTime();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 অ্যাপের বর্তমান মোড নির্ণয় (Dark or Light)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // থিম অনুযায়ী ডায়নামিক কালার প্যালেট
    final scaffoldBg = isDark ? const Color(0xFF101614) : const Color(0xFFF3F5F4);
    final cardBg = isDark ? const Color(0xFF1A2420) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF283832) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    final timerCardBg = isDark ? const Color(0xFF16211D) : const Color(0xFFEBF7F2);
    final timerCardBorder = isDark ? const Color(0xFF23352E) : const Color(0xFFC7EADB);
    final topBarBg = isDark ? const Color(0xFF131D19) : Colors.teal;

    final filteredAmols = selectedFilter == 'all'
        ? amols
        : amols.where((a) => a.category == selectedFilter).toList();

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: topBarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              'আমলের মুহাসাবা',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 2),
            Text(
              'আপনার দৈনন্দিন আমলের হিসাব করুন',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'লগআউট',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: cardBg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(
                    'লগআউট নিশ্চিতকরণ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  content: Text(
                    'আপনি কি আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?',
                    style: TextStyle(color: textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('না', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007A5E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('লগআউট'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle, color: Color(0xFF007A5E), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ব্যবহারকারী: ${user.displayName ?? user.email ?? "নাম প্রকাশে অনিচ্ছুক"}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.cloud_done, color: Color(0xFF007A5E), size: 18),
                  ],
                ),
              ),

            // 🟢 ১. টাইমার ও জেলা কার্ড (থিম এডাপ্টিভ)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: timerCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: timerCardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:isDark ? 0.2 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _openDistrictPicker,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? const Color(0xFF344E44) : const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFF007A5E), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${selectedDistrict.nameBn} জেলা',
                                style: const TextStyle(color: Color(0xFF007A5E), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFF007A5E), size: 18),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        getBanglaFullDate(DateTime.now()),
                        style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Divider(height: 22, color: timerCardBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('চলমান ওয়াক্ত: $currentWaqt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary)),
                          const SizedBox(height: 3),
                          Text('ওয়াক্ত শেষ হতে সময় বাকি:', style: TextStyle(color: textSecondary, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007A5E),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF007A5E).withValues(alpha:0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          remainingFormatted,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 🟢 ২. স্ট্রিক কার্ড
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color.fromARGB(5, 7, 7, 7) : const Color(0xFF00897B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF005A4E), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:isDark ? 0.35 : 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBBF24),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x66FBBF24),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 34),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            toBanglaNumber(userStreakDays),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF18382E) : const Color(0xFFD8F3E5),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(23)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 16, color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF004D40)),
                          const SizedBox(width: 6),
                          Text(
                            '${toBanglaNumber(userStreakDays)} দিন আমলের ধারাবাহিকতা',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF004D40),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('আজকের আমল তালিকা', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textPrimary)),
                Row(
                  children: [
                    _filterChip('all', 'সব', isDark),
                    const SizedBox(width: 6),
                    _filterChip('farz', 'নামাজ', isDark),
                    const SizedBox(width: 6),
                    _filterChip('nafl_zikr', 'নফল/জিকির', isDark),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🟢 ৩. আমল কার্ড তালিকা (ডার্ক ও লাইট ফ্রেন্ডলি)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAmols.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final amol = filteredAmols[index];
                final isDone = amol.isCompleted;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isSubmittedToday
                        ? null
                        : () {
                            setState(() {
                              amol.isCompleted = !amol.isCompleted;
                            });
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _isSubmittedToday
                            ? (isDone ? const Color(0xFF007A5E) : (isDark ? const Color(0xFF141C18) : const Color(0xFFF9FAFB)))
                            : (isDone ? const Color(0xFF007A5E) : cardBg),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDone ? const Color(0xFF00664E) : cardBorder,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDone
                                ? const Color(0xFF007A5E).withValues(alpha:0.2)
                                : Colors.black.withValues(alpha:isDark ? 0.15 : 0.02),
                            blurRadius: isDone ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        amol.title,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: _isSubmittedToday && !isDone
                                              ? (isDark ? Colors.white30 : Colors.grey.shade400)
                                              : (isDone ? Colors.white : textPrimary),
                                        ),
                                      ),
                                    ),
                                    if (amol.category == 'nafl_zikr') ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDone
                                              ? Colors.white.withValues(alpha:0.2)
                                              : (isDark ? const Color(0xFF1E3A2F) : const Color(0xFFECFDF5)),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isDone
                                                ? Colors.white.withValues(alpha:0.3)
                                                : (isDark ? const Color(0xFF285443) : const Color(0xFFA7F3D0)),
                                          ),
                                        ),
                                        child: Text(
                                          'নফল',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isDone ? Colors.white : (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (amol.subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    amol.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isSubmittedToday && !isDone
                                          ? (isDark ? Colors.white30 : Colors.grey.shade400)
                                          : (isDone ? const Color(0xFFCCFBF1) : textSecondary),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // ডানপাশের কাস্টম গোল চেকমার্ক
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone ? Colors.white : (isDark ? const Color(0xFF141C18) : const Color(0xFFF9FAFB)),
                              border: Border.all(
                                color: isDone ? Colors.white : (isDark ? const Color(0xFF374E45) : const Color(0xFFD1D5DB)),
                                width: 2,
                              ),
                              boxShadow: isDone
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha:0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isDone
                                ? const Center(
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFF007A5E),
                                      size: 18,
                                      weight: 800,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),

            // 🟢 ৪. সাবমিট বাটন
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: (_isSubmittedToday || _isSaving) ? null : _submitTodayAmol,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(
                        _isSubmittedToday ? Icons.lock_outline_rounded : Icons.cloud_upload_outlined,
                        size: 20,
                      ),
                label: Text(
                  _isSubmittedToday
                      ? 'আজকের আমল ইতোমধ্যে জমা দেওয়া হয়েছে'
                      : 'আজকের আমল জমা দিন',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmittedToday
                      ? (isDark ? const Color(0xFF374151) : const Color(0xFF9CA3AF))
                      : const Color(0xFF007A5E),
                  foregroundColor: Colors.white,
                  elevation: _isSubmittedToday ? 0 : 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String key, String label, bool isDark) {
    final isSelected = selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF007A5E)
              : (isDark ? const Color(0xFF1E2923) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF007A5E)
                : (isDark ? const Color(0xFF2E3F37) : const Color(0xFFE5E7EB)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF007A5E).withValues(alpha:0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class CelebrationConfettiDialog extends StatefulWidget {
  const CelebrationConfettiDialog({super.key});

  @override
  State<CelebrationConfettiDialog> createState() => _CelebrationConfettiDialogState();
}

class _CelebrationConfettiDialogState extends State<CelebrationConfettiDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.update();
          }
        });
      });

    final colors = [
      Colors.amber,
      const Color(0xFF007A5E),
      Colors.green,
      Colors.orange,
      Colors.yellowAccent,
      Colors.cyan,
    ];

    for (int i = 0; i < 60; i++) {
      _particles.add(ConfettiParticle(colors[i % colors.length]));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: ConfettiPainter(_particles),
          ),
        ),
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2923) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.shade300, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBBF24),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66FBBF24),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 14),
                Text(
                  'মাশাআল্লাহ! ১০০% আমল সম্পন্ন',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF007A5E),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'আপনি আজকের দিনের সকল আমল সফলভাবে সম্পন্ন করেছেন! শুকরিয়া',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141C18) : const Color(0xFFE6F4F0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF2E4D3E) : const Color(0xFFA7F3D0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'تَقَبَّلَ اللَّهُ مِنَّا وَمِنْكُم صَالِحَ الأَعْمَال',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF007A5E),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"আল্লাহ তায়ালা আমাদের ও আপনার সকল নেক আমল কবুল করুন।"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007A5E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('আলহামদুলিল্লাহ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ConfettiParticle {
  double x = 0.5;
  double y = 0.3;
  double vx = 0;
  double vy = 0;
  double size = 8;
  double rotation = 0;
  final Color color;

  ConfettiParticle(this.color) {
    final rand = DateTime.now().microsecondsSinceEpoch;
    x = (rand % 100) / 100.0;
    y = -0.1 - ((rand % 50) / 100.0);
    vx = ((rand % 10) - 5) / 1000.0;
    vy = 0.005 + ((rand % 10) / 100.0);
    size = 6.0 + (rand % 6);
  }

  void update() {
    x += vx;
    y += vy;
    rotation += 0.08;
    if (y > 1.2) {
      y = -0.1;
    }
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = p.color;
      final px = p.x * size.width;
      final py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}