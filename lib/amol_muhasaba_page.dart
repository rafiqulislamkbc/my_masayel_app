import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmolItem {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String icon;
  final int points;
  final String? hadithNote;
  bool isCompleted;

  AmolItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.points,
    this.hadithNote,
    this.isCompleted = false,
  });
}

class AmolMuhasabaPage extends StatefulWidget {
  const AmolMuhasabaPage({super.key});

  @override
  State<AmolMuhasabaPage> createState() => _AmolMuhasabaPageState();
}

class _AmolMuhasabaPageState extends State<AmolMuhasabaPage> {
  DateTime selectedDate = DateTime.now();
  String selectedCategory = 'all';

  List<AmolItem> amolList = [
    AmolItem(id: 'fajr', category: 'namaz', title: 'ফজর সালাত (জামাতে/সময়ে)', subtitle: 'ফজরের ২ রাকাত সুন্নাত দুনিয়া ও তার মধ্যকার সকল কিছুর চেয়ে উত্তম।', icon: '🕌', points: 10, hadithNote: 'সহীহ মুসলিম: ৭২৫'),
    AmolItem(id: 'dhuhr', category: 'namaz', title: 'যোহর সালাত', subtitle: 'প্রথম ওয়াক্তে সালাত আদায় করা সর্বোত্তম আমল।', icon: '🕌', points: 10, hadithNote: 'তিরমিযী: ১৭০'),
    AmolItem(id: 'asr', category: 'namaz', title: 'আসর সালাত', subtitle: 'যে ব্যক্তি দুই শীতের সময় সালাত আদায় করবে সে জান্নাতে প্রবেশ করবে।', icon: '🕌', points: 10, hadithNote: 'সহীহ বুখারী: ৫৭৪'),
    AmolItem(id: 'maghrib', category: 'namaz', title: 'মাগরিব সালাত', subtitle: 'সূর্যাস্তের পরপরই মাগরিব সালাত আদায় করা বাঞ্ছনীয়।', icon: '🕌', points: 10, hadithNote: 'আবু দাউদ: ৪১৮'),
    AmolItem(id: 'isha', category: 'namaz', title: 'এশা ও বিতর সালাত', subtitle: 'এশার সালাত জামাতে আদায় করলে অর্ধেক রাত ইবাদতের সওয়াব মেলে।', icon: '🕌', points: 10, hadithNote: 'সহীহ মুসলিম: ৬৫৬'),
    AmolItem(id: 'quran', category: 'quran', title: 'কুরআন তিলাওয়াত (অর্থসহ)', subtitle: 'তোমাদের মধ্যে সর্বোত্তম সে ব্যক্তি, যে নিজে কুরআন শেখে ও শেখে।', icon: '📖', points: 15, hadithNote: 'সহীহ বুখারী: ৫০২৭'),
    AmolItem(id: 'tahajjud', category: 'sunnah', title: 'তাহাজ্জুদ সালাত ও বিশেষ দোয়া', subtitle: 'ফরজ সালাতের পর সবচেয়ে উত্তম সালাত হলো রাতের সালাত।', icon: '🤲', points: 15, hadithNote: 'সহীহ মুসলিম: ১১৬৩'),
    AmolItem(id: 'zikr', category: 'zikr', title: 'সকাল-সন্ধ্যার মাসনুন জিকির', subtitle: 'সকাল ও সন্ধ্যার জিকির বান্দাকে শয়তান ও অনিষ্ট থেকে রক্ষা করে।', icon: '📿', points: 10, hadithNote: 'হিসনুল মুসলিম'),
    AmolItem(id: 'istighfar', category: 'zikr', title: '১০০ বার ইস্তিগফার ও দুরুদ শরিফ', subtitle: 'যে ব্যক্তি নিয়মিত ইস্তিগফার করে, আল্লাহ তার দুশ্চিন্তা দূর করেন।', icon: '✨', points: 10, hadithNote: 'আবু দাউদ: ১৫১৮'),
    AmolItem(id: 'sadqah', category: 'sunnah', title: 'দৈনিক দান অথবা উত্তম আচরণ', subtitle: 'তোমার ভাইয়ের মুখের দিকে তাকিয়ে একটু মুচকি হাসাও একটি সদকা।', icon: '💛', points: 5, hadithNote: 'তিরমিযী: ১৯৫৬'),
  ];

  @override
  void initState() {
    super.initState();
    _loadAmolData();
  }

  // Pure Dart date keys - no external intl package required
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatBanglaDate(DateTime date) {
    const months = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    String toBanglaNum(int num) {
      return num.toString().split('').map((d) {
        int val = int.tryParse(d) ?? -1;
        return val >= 0 ? banglaDigits[val] : d;
      }).join('');
    }

    String day = toBanglaNum(date.day);
    String month = months[date.month - 1];
    String year = toBanglaNum(date.year);

    return '$day $month, $year';
  }

  Future<void> _loadAmolData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(selectedDate);
    setState(() {
      for (var item in amolList) {
        item.isCompleted = prefs.getBool('amol_${key}_${item.id}') ?? false;
      }
    });
  }

  Future<void> _toggleAmol(AmolItem item) async {
    setState(() {
      item.isCompleted = !item.isCompleted;
    });
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(selectedDate);
    await prefs.setBool('amol_${key}_${item.id}', item.isCompleted);
  }

  int get totalPoints => amolList.where((a) => a.isCompleted).fold(0, (sum, a) => sum + a.points);
  int get maxPoints => amolList.fold(0, (sum, a) => sum + a.points);
  double get progressRatio => maxPoints == 0 ? 0 : totalPoints / maxPoints;

  String get levelBadge {
    if (totalPoints >= 80) return '🌟 লেভেল ৩: নেক আমলের পথিক';
    if (totalPoints >= 50) return '⚔️ লেভেল ২: মুজাহিদ';
    return '🌿 লেভেল ১: আমলকারী';
  }

  @override
  Widget build(BuildContext context) {
    int percentage = (progressRatio * 100).round();
    final filteredList = selectedCategory == 'all'
        ? amolList
        : amolList.where((a) => a.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF050C1A),
      appBar: AppBar(
        title: const Text(
          'আজকের আমলের মুহাসাবা',
          style: TextStyle(
            fontFamily: 'SolaimanLipi',
            fontWeight: FontWeight.bold,
            color: Color(0xFFA7F3D0),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📅 তারিখ নেভিগেটর
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.tealAccent, size: 18),
                    onPressed: () {
                      setState(() => selectedDate = selectedDate.subtract(const Duration(days: 1)));
                      _loadAmolData();
                    },
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.tealAccent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _formatBanglaDate(selectedDate),
                        style: const TextStyle(
                          fontFamily: 'SolaimanLipi',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.tealAccent, size: 18),
                    onPressed: () {
                      setState(() => selectedDate = selectedDate.add(const Duration(days: 1)));
                      _loadAmolData();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 📊 স্কোর ও প্রোগ্রেস গেজ
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF022C22), Color(0xFF050C1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(color: Colors.teal.withValues(alpha: 0.2), blurRadius: 18, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'আজকের অর্জিত নম্বর',
                            style: TextStyle(fontFamily: 'SolaimanLipi', color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$totalPoints ',
                                  style: const TextStyle(fontFamily: 'SolaimanLipi', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                                ),
                                TextSpan(
                                  text: '/ $maxPoints পয়েন্ট',
                                  style: const TextStyle(fontFamily: 'SolaimanLipi', fontSize: 14, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black38,
                          border: Border.all(color: Colors.amberAccent, width: 2),
                        ),
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(fontFamily: 'SolaimanLipi', fontWeight: FontWeight.bold, color: Colors.amberAccent, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      levelBadge,
                      style: const TextStyle(fontFamily: 'SolaimanLipi', color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 12,
                      backgroundColor: Colors.black54,
                      color: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📋 আমল লিস্ট
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: item.isCompleted ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: item.isCompleted ? Colors.tealAccent.withValues(alpha: 0.5) : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.isCompleted ? Colors.tealAccent : const Color(0xFF334155),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isCompleted ? Icons.check : Icons.circle_outlined,
                        color: item.isCompleted ? Colors.black : Colors.white38,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'SolaimanLipi',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4, left: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.subtitle,
                            style: const TextStyle(fontFamily: 'SolaimanLipi', color: Colors.white60, fontSize: 11),
                          ),
                          if (item.hadithNote != null)
                            Text(
                              '• ${item.hadithNote}',
                              style: const TextStyle(fontFamily: 'SolaimanLipi', color: Colors.amberAccent, fontSize: 10),
                            ),
                        ],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.isCompleted ? Colors.teal.withValues(alpha: 0.3) : Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: item.isCompleted ? Colors.tealAccent : Colors.white24),
                      ),
                      child: Text(
                        '+${item.points}',
                        style: const TextStyle(fontFamily: 'SolaimanLipi', color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    onTap: () => _toggleAmol(item),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}