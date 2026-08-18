import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'home_page.dart';
import 'masala_detail_page.dart';
import 'amol_muhasaba_page.dart';
import 'muhasaba_auth_gate.dart';
import 'pages/notebook_page.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  // 🌟 মেমোরিতে জীবন্ত থাকা ৪টি মূল পেজ
  final List<Widget> _pages = const [
    HomePage(),          // 0: হোম
    AmolMuhasabaPage(),  // 1: মুহাসাবা
    NotebookPage(),      // 2: নোটবই
    MuhasabaAuthGate(),  // 3 (ট্যাবে ৪): অ্যাকাউন্ট
  ];

  @override
  void initState() {
    super.initState();
    // ৩ নম্বর ছিল অ্যাকশন বাটন, তাই ৩ আসলে হোমে থাকবে, ৪ আসলে অ্যাকাউন্টে থাকবে
    _currentIndex = (widget.initialIndex == 3 || widget.initialIndex < 0 || widget.initialIndex > 4)
        ? 0
        : widget.initialIndex;
  }

  // 🌟 সর্বশেষ পঠিত মাসআলা মসৃণভাবে খোলার ফাংশন
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

  // বটম নেভিগেশন বারের ইনডেক্স থেকে IndexedStack-এর ইনডেক্সে রূপান্তর
  int _getStackIndex() {
    if (_currentIndex == 4) return 3; // অ্যাকাউন্ট পেজ
    if (_currentIndex >= 0 && _currentIndex <= 2) return _currentIndex;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 🌟 IndexedStack ব্যবহার করায় কোনো পেজের ডাটা নষ্ট হবে না এবং কোনো ঝাঁকি খাবে না
      body: IndexedStack(
        index: _getStackIndex(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 3) {
            // ৩ নম্বর ইনডেক্সটি একটি সরাসরি অ্যাকশন (সর্বশেষ পঠিত পেজে নিয়ে যাবে)
            await _openLastRead(context);
          } else {
            // অন্য যেকোনো ট্যাবে মসৃণভাবে সুইচ করবে
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: isDark ? Colors.tealAccent : Colors.teal,
        unselectedItemColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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