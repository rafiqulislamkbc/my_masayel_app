import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'home_page.dart';
import 'masala_detail_page.dart';
import 'amol_muhasaba_page.dart'; // সরাসরি মুহাসাবা পেজ
import 'muhasaba_auth_gate.dart';  // অ্যাকাউন্ট / লগইন গেট
import 'pages/notebook_page.dart'; // নোটবই পেজ

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  // ৫টি পেইজের তালিকা
  final List<Widget> _pages = [
    const HomePage(),          // 0: হোম
    const AmolMuhasabaPage(),  // 1: সরাসরি মুহাসাবা পেজ (লগইন ব্যারিয়ার ছাড়া)
    const NotebookPage(),      // 2: নোটবই ও সংরক্ষিত তথ্য
    const SizedBox(),          // 3: সর্বশেষ পঠিত (অন-ক্লিক পুশ হবে)
    const MuhasabaAuthGate(),  // 4: অ্যাকাউন্ট / লগইন ও প্রোফাইল ব্যবস্থাপনা
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _openLastRead(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastId = prefs.getInt('last_masala_id');

    if (lastId != null) {
      Map<String, dynamic>? masala = await DatabaseHelper.getMasalaById(lastId);

      if (masala != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MasalaDetailPage(
              masala: masala,
              serialNo: masala['id'].toString(),
            ),
          ),
        );
        return;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'কোনো সর্বশেষ পঠিত মাসআলা পাওয়া যায়নি!',
            style: TextStyle(fontFamily: 'SolaimanLipi'),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 3 ? _pages[0] : _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 3) {
            // সর্বশেষ পঠিত মাসআলা ওপেন হবে
            await _openLastRead(context);
          } else {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'SolaimanLipi',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'SolaimanLipi',
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: 'মুহাসাবা',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: 'নোটবই',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'সর্বশেষ পঠিত',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'অ্যাকাউন্ট',
          ),
        ],
      ),
    );
  }
}