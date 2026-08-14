import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

String toBanglaNumber(dynamic input) {
  const Map<String, String> bnDigits = {
    '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
    '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯'
  };
  return input.toString().split('').map((c) => bnDigits[c] ?? c).join();
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
  DistrictData(id: 'narayanganj', nameBn: 'নারায়ণগঞ্জ', division: 'ঢাকা', offsetMinutes: -1),
  DistrictData(id: 'tangail', nameBn: 'টাঙ্গাইল', division: 'ঢাকা', offsetMinutes: 1),
  DistrictData(id: 'gopalganj', nameBn: 'গোপালগঞ্জ', division: 'ঢাকা', offsetMinutes: 2),
  DistrictData(id: 'faridpur', nameBn: 'ফরিদপুর', division: 'ঢাকা', offsetMinutes: 2),
  DistrictData(id: 'madaripur', nameBn: 'মাদারীপুর', division: 'ঢাকা', offsetMinutes: 1),
  DistrictData(id: 'manikganj', nameBn: 'মানিকগঞ্জ', division: 'ঢাকা', offsetMinutes: 1),
  DistrictData(id: 'munshiganj', nameBn: 'মুন্সীগঞ্জ', division: 'ঢাকা', offsetMinutes: -1),
  DistrictData(id: 'narsingdi', nameBn: 'নরসিংদী', division: 'ঢাকা', offsetMinutes: -1),
  DistrictData(id: 'rajbari', nameBn: 'রাজবাড়ী', division: 'ঢাকা', offsetMinutes: 3),
  DistrictData(id: 'shariatpur', nameBn: 'শরীয়তপুর', division: 'ঢাকা', offsetMinutes: 0),
  DistrictData(id: 'kishoreganj', nameBn: 'কিশোরগঞ্জ', division: 'ঢাকা', offsetMinutes: -2),
  DistrictData(id: 'chattogram', nameBn: 'চট্টগ্রাম', division: 'চট্টগ্রাম', offsetMinutes: -5),
  DistrictData(id: 'coxsbazar', nameBn: 'কক্সবাজার', division: 'চট্টগ্রাম', offsetMinutes: -6),
  DistrictData(id: 'cumilla', nameBn: 'কুমিল্লা', division: 'চট্টগ্রাম', offsetMinutes: -3),
  DistrictData(id: 'feni', nameBn: 'ফেনী', division: 'চট্টগ্রাম', offsetMinutes: -4),
  DistrictData(id: 'brahmanbaria', nameBn: 'ব্রাহ্মণবাড়িয়া', division: 'চট্টগ্রাম', offsetMinutes: -2),
  DistrictData(id: 'chandpur', nameBn: 'চাঁদপুর', division: 'চট্টগ্রাম', offsetMinutes: -1),
  DistrictData(id: 'lakshmipur', nameBn: 'লক্ষ্মীপুর', division: 'চট্টগ্রাম', offsetMinutes: -2),
  DistrictData(id: 'noakhali', nameBn: 'নোয়াখালী', division: 'চট্টগ্রাম', offsetMinutes: -3),
  DistrictData(id: 'khagrachhari', nameBn: 'খাগড়াছড়ি', division: 'চট্টগ্রাম', offsetMinutes: -6),
  DistrictData(id: 'rangamati', nameBn: 'রাঙ্গামাটি', division: 'চট্টগ্রাম', offsetMinutes: -6),
  DistrictData(id: 'bandarban', nameBn: 'বান্দরবান', division: 'চট্টগ্রাম', offsetMinutes: -6),
  DistrictData(id: 'sylhet', nameBn: 'সিলেট', division: 'সিলেট', offsetMinutes: -6),
  DistrictData(id: 'moulvibazar', nameBn: 'মৌলভীবাজার', division: 'সিলেট', offsetMinutes: -5),
  DistrictData(id: 'habiganj', nameBn: 'হবিগঞ্জ', division: 'সিলেট', offsetMinutes: -4),
  DistrictData(id: 'sunamganj', nameBn: 'সুনামগঞ্জ', division: 'সিলেট', offsetMinutes: -5),
  DistrictData(id: 'rajshahi', nameBn: 'রাজশাহী', division: 'রাজশাহী', offsetMinutes: 6),
  DistrictData(id: 'bogra', nameBn: 'বগুড়া', division: 'রাজশাহী', offsetMinutes: 4),
  DistrictData(id: 'pabna', nameBn: 'পাবনা', division: 'রাজশাহী', offsetMinutes: 4),
  DistrictData(id: 'sirajganj', nameBn: 'সিরাজগঞ্জ', division: 'রাজশাহী', offsetMinutes: 2),
  DistrictData(id: 'naogaon', nameBn: 'নওগাঁ', division: 'রাজশাহী', offsetMinutes: 6),
  DistrictData(id: 'natore', nameBn: 'নাটোর', division: 'রাজশাহী', offsetMinutes: 5),
  DistrictData(id: 'chapainawabganj', nameBn: 'চাঁপাইনবাবগঞ্জ', division: 'রাজশাহী', offsetMinutes: 8),
  DistrictData(id: 'joypurhat', nameBn: 'জয়পুরহাট', division: 'রাজশাহী', offsetMinutes: 5),
  DistrictData(id: 'khulna', nameBn: 'খুলনা', division: 'খুলনা', offsetMinutes: 3),
  DistrictData(id: 'bagerhat', nameBn: 'বাগেরহাট', division: 'খুলনা', offsetMinutes: 2),
  DistrictData(id: 'chuadanga', nameBn: 'চুয়াডাঙ্গা', division: 'খুলনা', offsetMinutes: 6),
  DistrictData(id: 'jashore', nameBn: 'যশোর', division: 'খুলনা', offsetMinutes: 4),
  DistrictData(id: 'jhenaidah', nameBn: 'ঝিনাইদহ', division: 'খুলনা', offsetMinutes: 4),
  DistrictData(id: 'kushtia', nameBn: 'কুষ্টিয়া', division: 'খুলনা', offsetMinutes: 5),
  DistrictData(id: 'magura', nameBn: 'মাগুরা', division: 'খুলনা', offsetMinutes: 3),
  DistrictData(id: 'meherpur', nameBn: 'মেহেরপুর', division: 'খুলনা', offsetMinutes: 6),
  DistrictData(id: 'narail', nameBn: 'নড়াইল', division: 'খুলনা', offsetMinutes: 3),
  DistrictData(id: 'satkhira', nameBn: 'সাতক্ষীরা', division: 'খুলনা', offsetMinutes: 5),
  DistrictData(id: 'barishal', nameBn: 'বরিশাল', division: 'বরিশাল', offsetMinutes: 1),
  DistrictData(id: 'barguna', nameBn: 'বরগুনা', division: 'বরিশাল', offsetMinutes: 2),
  DistrictData(id: 'bhola', nameBn: 'ভোলা', division: 'বরিশাল', offsetMinutes: -1),
  DistrictData(id: 'jhalokati', nameBn: 'ঝালকাঠি', division: 'বরিশাল', offsetMinutes: 2),
  DistrictData(id: 'patuakhali', nameBn: 'পটুয়াখালী', division: 'বরিশাল', offsetMinutes: 1),
  DistrictData(id: 'pirojpur', nameBn: 'পিরোজপুর', division: 'বরিশাল', offsetMinutes: 3),
  DistrictData(id: 'rangpur', nameBn: 'রংপুর', division: 'রংপুর', offsetMinutes: 6),
  DistrictData(id: 'dinajpur', nameBn: 'দিনাজপুর', division: 'রংপুর', offsetMinutes: 8),
  DistrictData(id: 'gaibandha', nameBn: 'গাইবান্ধা', division: 'রংপুর', offsetMinutes: 4),
  DistrictData(id: 'kurigram', nameBn: 'কুড়িগ্রাম', division: 'রংপুর', offsetMinutes: 3),
  DistrictData(id: 'lalmonirhat', nameBn: 'লালমনিরহাট', division: 'রংপুর', offsetMinutes: 5),
  DistrictData(id: 'nilphamari', nameBn: 'নীলফামারী', division: 'রংপুর', offsetMinutes: 7),
  DistrictData(id: 'panchagarh', nameBn: 'পঞ্চগড়', division: 'রংপুর', offsetMinutes: 10),
  DistrictData(id: 'thakurgaon', nameBn: 'ঠাকুরগাঁও', division: 'রংপুর', offsetMinutes: 9),
  DistrictData(id: 'mymensingh', nameBn: 'ময়মনসিংহ', division: 'ময়মনসিংহ', offsetMinutes: 0),
  DistrictData(id: 'jamalpur', nameBn: 'জামালপুর', division: 'ময়মনসিংহ', offsetMinutes: 2),
  DistrictData(id: 'netrokona', nameBn: 'নেত্রকোণা', division: 'ময়মনসিংহ', offsetMinutes: -2),
  DistrictData(id: 'sherpur', nameBn: 'শেরপুর', division: 'ময়মনসিংহ', offsetMinutes: 1),
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
    AmolItem(id: 'quran', title: 'কুরআন তিলাওয়াত', subtitle: 'কমপক্ষে ১০ আয়াত বা অর্থসহ ১ রুকু', category: 'nafl_zikr'),
    AmolItem(id: 'chasht', title: 'চাশত সালাত (সালাতুদ দুহা)', subtitle: 'সূর্য ওঠার পর ২ থেকে ৪ রাকাত সালাত', category: 'nafl_zikr'),
    AmolItem(id: 'awwabin', title: 'আওয়াবিন সালাত', subtitle: 'মাগরিবের পর ৬ রাকাত নফল সালাত', category: 'nafl_zikr'),
    AmolItem(id: 'durood', title: 'দরুদ শরীফ (কমপক্ষে ১০০ বার)', subtitle: 'রাসূলুল্লাহ (ﷺ)-এর ওপর ১০০ বার দরুদ পাঠ', category: 'nafl_zikr'),
    AmolItem(id: 'istighfar', title: 'ইস্তিগফার ও জিকির (১০০ বার)', subtitle: 'সকাল ও সন্ধ্যার মাসনুন জিকির', category: 'nafl_zikr'),
    AmolItem(id: 'tahajjud', title: 'তাহাজ্জুদ সালাত', subtitle: 'রাতের শেষ তৃতীয়াংশে বিশেষ ইবাদত', category: 'nafl_zikr'),
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

  // ডিভাইসের লোকাল স্টোরেজ থেকে ডাটা লোড
  Future<void> _loadCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDistrictId = prefs.getString('user_district_id') ?? 'dhaka';
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);

    final localSubmitted = prefs.getBool('sub_local_$todayKey') ?? false;
    final localStreak = prefs.getInt('streak_local') ?? 0;

    for (var amol in amols) {
      amol.isCompleted = prefs.getBool('amol_local_${todayKey}_${amol.id}') ?? false;
    }

    if (mounted) {
      setState(() {
        _isSubmittedToday = localSubmitted;
        userStreakDays = localStreak;
        selectedDistrict = all64Districts.firstWhere(
          (d) => d.id == savedDistrictId,
          orElse: () => all64Districts[0],
        );
      });
    }
  }

  // বাটন ক্লিকে ডাটা সেভ
  Future<void> _submitTodayAmol() async {
    setState(() => _isSaving = true);

    final dateKey = DateTime.now().toIso8601String().substring(0, 10);
    final completedCount = amols.where((a) => a.isCompleted).length;
    final totalCount = amols.length;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sub_local_$dateKey', true);

      for (var item in amols) {
        await prefs.setBool('amol_local_${dateKey}_${item.id}', item.isCompleted);
      }

      final newStreak = userStreakDays + 1;
      await prefs.setInt('streak_local', newStreak);

      if (mounted) {
        setState(() {
          _isSubmittedToday = true;
          userStreakDays = newStreak;
          _isSaving = false;
        });

        // পপআপ ডায়ালগ
        if (completedCount == totalCount) {
          _showCelebrationDialog();
        } else {
          _showStandardThankYouDialog(completedCount, totalCount);
        }
      }
    } catch (e) {
      debugPrint('সেভ এরর: $e');
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showStandardThankYouDialog(int done, int total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.teal, size: 28),
            SizedBox(width: 8),
            Text('আমল জমা হয়েছে', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
          ],
        ),
        content: Text(
          'আলহামদুলিল্লাহ! আজকের দিনের ${toBanglaNumber(done)}টি আমল সফলভাবে সম্পন্ন হয়েছে। বাকি আমলগুলোও যথাসময়ে আদায় চেষ্টা করুন।',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'আপনার জেলা নির্বাচন করুন',
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (val) => setModalState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'জেলার নাম খুঁজুন...',
                          prefixIcon: const Icon(Icons.search, color: Colors.teal),
                          filled: true,
                          fillColor: Colors.grey.shade100,
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
                                ? 'ঢাকার সমসাময়িক'
                                : (dist.offsetMinutes > 0
                                    ? '+${toBanglaNumber(dist.offsetMinutes)} মিনিট'
                                    : '-${toBanglaNumber(dist.offsetMinutes.abs())} মিনিট');

                            return ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              tileColor: isSelected ? Colors.teal.shade50 : Colors.transparent,
                              leading: const Icon(Icons.location_on, color: Colors.teal),
                              title: Text(dist.nameBn, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${dist.division} বিভাগ • $offsetStr', style: const TextStyle(fontSize: 12)),
                              trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.teal) : null,
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString('user_district_id', dist.id);
                                setState(() => selectedDistrict = dist);
                                _updatePrayerTime();
                                if (context.mounted) Navigator.pop(context);
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
    final completedCount = amols.where((a) => a.isCompleted).length;
    final totalCount = amols.length;
    final percentage = ((completedCount / totalCount) * 100).round();

    final filteredAmols = selectedFilter == 'all'
        ? amols
        : amols.where((a) => a.category == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text('আমলের মুহাসাবা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
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
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.teal.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.teal, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${selectedDistrict.nameBn} জেলা',
                                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.teal, size: 18),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'আজ: ${toBanglaNumber(DateTime.now().day)} তারিখ',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('চলমান ওয়াক্ত: $currentWaqt', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          const Text('ওয়াক্ত শেষ হতে সময় বাকি:', style: TextStyle(color: Colors.black54, fontSize: 11)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Text(
                          remainingFormatted,
                          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF007A5E), Color(0xFF005A45)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      toBanglaNumber(userStreakDays),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${toBanglaNumber(userStreakDays)} দিনের মুহাসাবা জমা হয়েছে',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'আজকের টিক দেওয়া আমল: ${toBanglaNumber(completedCount)}/${toBanglaNumber(totalCount)} (${toBanglaNumber(percentage)}%)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('আজকের আমল তালিকা', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    _filterChip('all', 'সব'),
                    const SizedBox(width: 4),
                    _filterChip('farz', 'নামাজ'),
                    const SizedBox(width: 4),
                    _filterChip('nafl_zikr', 'নফল/জিকির'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAmols.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final amol = filteredAmols[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: amol.isCompleted ? Colors.teal : Colors.grey.shade200,
                      width: amol.isCompleted ? 1.5 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    activeColor: Colors.teal,
                    value: amol.isCompleted,
                    onChanged: _isSubmittedToday
                        ? null
                        : (val) {
                            setState(() {
                              amol.isCompleted = val ?? false;
                            });
                          },
                    title: Text(
                      amol.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: amol.isCompleted ? Colors.teal.shade900 : Colors.black87,
                      ),
                    ),
                    subtitle: Text(amol.subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    secondary: amol.category == 'nafl_zikr'
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)),
                            child: const Text('নফল', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                          )
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (_isSubmittedToday || _isSaving) ? null : _submitTodayAmol,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_isSubmittedToday ? Icons.lock : Icons.check_circle),
                label: Text(
                  _isSubmittedToday
                      ? 'আজকের আমল ইতোমধ্যে জমা দেওয়া হয়েছে'
                      : 'আজকের আমল জমা দিন',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmittedToday ? Colors.grey.shade400 : Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
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
      Colors.teal,
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
              color: Colors.white,
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
                const Text(
                  'মাশাআল্লাহ! ১০০% আমল সম্পন্ন',
                  style: TextStyle(color: Color(0xFF007A5E), fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'আপনি আজকের দিনের সকল আমল সফলভাবে সম্পন্ন করেছেন! শুকরিয়া',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'تَقَبَّلَ اللَّهُ مِنَّا وَمِنْكُم صَالِحَ الأَعْمَال',
                        style: TextStyle(color: Color(0xFF007A5E), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '"আল্লাহ তায়ালা আমাদের ও আপনার সকল নেক আমল কবুল করুন।"',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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