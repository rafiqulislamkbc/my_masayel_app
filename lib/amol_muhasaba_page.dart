import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// মডেল ও বাংলা সংখ্যা কনভার্টার
/// ---------------------------------------------------------------------------
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

// বাংলাদেশের ৬৪ জেলার তালিকা
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
  int userStreakDays = 5;
  DistrictData selectedDistrict = all64Districts[0];
  String selectedFilter = 'all';

  Timer? _timer;
  String currentWaqt = 'যোহর';
  String remainingFormatted = '৪ ঘণ্টা ৩৪ মিনিট বাকি';
  String remainingDigital = '০৪:৩৪:০০';

  final List<AmolItem> amols = [
    AmolItem(id: 'fajr', title: 'ফজর', subtitle: '২ রাকাত সুন্নাত ও ২ রাকাত ফরজ', category: 'farz', isCompleted: true),
    AmolItem(id: 'dhuhr', title: 'যোহর', subtitle: '৪ রাকাত ফরজ ও সুন্নাত সালাত', category: 'farz', isCompleted: true),
    AmolItem(id: 'asr', title: 'আসর', subtitle: '৪ রাকাত ফরজ সালাত', category: 'farz', isCompleted: true),
    AmolItem(id: 'maghrib', title: 'মাগরিব', subtitle: '৩ রাকাত ফরজ ও ২ রাকাত সুন্নাত', category: 'farz', isCompleted: true),
    AmolItem(id: 'isha', title: 'এশা', subtitle: '৪ রাকাত ফরজ ও বিতর সালাত', category: 'farz', isCompleted: true),
    AmolItem(id: 'quran', title: 'কুরআন তিলাওয়াত', subtitle: 'কমপক্ষে ১০ আয়াত বা অর্থসহ ১ রুকু', category: 'nafl_zikr', isCompleted: true),
    AmolItem(id: 'chasht', title: 'চাশত সালাত (সালাতুদ দুহা)', subtitle: 'সূর্য ওঠার পর ২ থেকে ৪ রাকাত সালাত', category: 'nafl_zikr', isCompleted: true),
    AmolItem(id: 'awwabin', title: 'আওয়াবিন সালাত', subtitle: 'মাগরিবের পর ৬ রাকাত নফল সালাত', category: 'nafl_zikr', isCompleted: false),
    AmolItem(id: 'durood', title: 'দরুদ শরীফ (কমপক্ষে ১০০ বার)', subtitle: 'রাসূলুল্লাহ (ﷺ)-এর ওপর ১০০ বার দরুদ পাঠ', category: 'nafl_zikr', isCompleted: true),
    AmolItem(id: 'istighfar', title: 'ইস্তিগফার ও জিকির (১০০ বার)', subtitle: 'সকাল ও সন্ধ্যার মাসনুন জিকির', category: 'nafl_zikr', isCompleted: false),
    AmolItem(id: 'tahajjud', title: 'তাহাজ্জুদ সালাত', subtitle: 'রাতের শেষ তৃতীয়াংশে বিশেষ ইবাদত', category: 'nafl_zikr', isCompleted: false),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _updatePrayerTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updatePrayerTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDistrictId = prefs.getString('user_district_id') ?? 'dhaka';
    final savedStreak = prefs.getInt('user_streak_days') ?? 5;

    for (var amol in amols) {
      if (prefs.containsKey('amol_${amol.id}')) {
        amol.isCompleted = prefs.getBool('amol_${amol.id}') ?? false;
      }
    }

    if (mounted) {
      setState(() {
        userStreakDays = savedStreak;
        selectedDistrict = all64Districts.firstWhere(
          (d) => d.id == savedDistrictId,
          orElse: () => all64Districts[0],
        );
      });
    }
  }

  Future<void> _saveAmolState(String id, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('amol_$id', val);
  }

  Future<void> _saveDistrict(DistrictData district) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_district_id', district.id);
    if (mounted) {
      setState(() {
        selectedDistrict = district;
      });
    }
    _updatePrayerTime();
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
      waqtName = 'চাশত / ইশরাক';
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

  void _triggerCelebration() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF064E3B), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFBBF24), width: 2),
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
                  ),
                  child: const Icon(Icons.emoji_events, color: Color(0xFF064E3B), size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'মাশাআল্লাহ! ১০০% আমল সম্পন্ন',
                  style: TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'আজকের দিনের সকল আমল সফলভাবে সম্পন্ন হয়েছে!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x6610B981)),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'تَقَبَّلَ اللَّهُ مِنَّا وَمِنْكُم صَالِحَ الأَعْمَال',
                        style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '"আল্লাহ তায়ালা আমাদের ও আপনার সকল নেক আমল কবুল করুন।"',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  ),
                  child: const Text(
                    'আলহামদুলিল্লাহ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDistrictPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E131F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'আপনার জেলা নির্বাচন করুন (৬৪ জেলা)',
                        style: TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (val) => setModalState(() => searchQuery = val),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'জেলার নাম খুঁজুন...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                          filled: true,
                          fillColor: const Color(0xFF1A2234),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              tileColor: isSelected ? const Color(0xFF007A5E) : Colors.transparent,
                              leading: const Icon(Icons.location_on, color: Color(0xFF10B981)),
                              title: Text(
                                dist.nameBn,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${dist.division} বিভাগ • $offsetStr',
                                style: TextStyle(
                                  color: isSelected ? Colors.white70 : Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Color(0xFFFBBF24))
                                  : null,
                              onTap: () {
                                _saveDistrict(dist);
                                Navigator.pop(context);
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
      backgroundColor: const Color(0xFF0E131F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E131F),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'আমলের মুহাসাবা',
          style: TextStyle(
            color: Color(0xFF6EE7B7),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ১. শীর্ষ কার্ড: জেলা ও লাইভ ওয়াক্ত
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF062D24), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x5910B981)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _openDistrictPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0x2610B981),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x6610B981)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFF10B981), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${selectedDistrict.nameBn} জেলা',
                                style: const TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFF10B981), size: 18),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'আজ: ${toBanglaNumber(DateTime.now().day)} আগস্ট',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFBBF24),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'চলমান ওয়াক্ত',
                                  style: TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$currentWaqt নামাজের সময় শেষ হতে:',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x2610B981),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              remainingFormatted,
                              style: const TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              remainingDigital,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ২. মুহাসাবা সম্পন্ন ব্যাজ
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF007A5E),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66007A5E),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      toBanglaNumber(userStreakDays),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${toBanglaNumber(userStreakDays)} দিনের মুহাসাবা সম্পন্ন',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'আজকের অর্জন: ${toBanglaNumber(completedCount)}/${toBanglaNumber(totalCount)} আমল (${toBanglaNumber(percentage)}%)',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ৩. ফিল্টার বাটন
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'আজকের টাস্ক',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _filterChip('all', 'সব'),
                    const SizedBox(width: 6),
                    _filterChip('farz', 'নামাজ'),
                    const SizedBox(width: 6),
                    _filterChip('nafl_zikr', 'অন্যান্য আমল'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ৪. আমল তালিকা
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAmols.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final amol = filteredAmols[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      amol.isCompleted = !amol.isCompleted;
                    });

                    _saveAmolState(amol.id, amol.isCompleted);

                    final allDone = amols.every((a) => a.isCompleted);
                    if (allDone) {
                      _triggerCelebration();
                    }
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: amol.isCompleted ? const Color(0xFF007A5E) : const Color(0xFF141C2E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: amol.isCompleted
                            ? const Color(0x8010B981)
                            : Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    amol.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (amol.category == 'nafl_zikr') ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: amol.isCompleted
                                            ? Colors.black26
                                            : const Color(0x33FBBF24),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'নফল/জিকির',
                                        style: TextStyle(
                                          color: Color(0xFFFBBF24),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                amol.subtitle,
                                style: TextStyle(
                                  color: amol.isCompleted ? Colors.white70 : Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: amol.isCompleted ? Colors.white : Colors.transparent,
                            border: Border.all(
                              color: amol.isCompleted ? Colors.transparent : Colors.white38,
                              width: 2,
                            ),
                          ),
                          child: amol.isCompleted
                              ? const Icon(Icons.check, size: 20, color: Color(0xFF007A5E))
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1A2234),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}