import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart'; 
import 'home_page.dart';
import 'masala_detail_page.dart';
import 'muhasaba_auth_gate.dart';
import 'pages/notebook_page.dart'; // নোটবই পেজ ইমপোর্ট

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  // ৪টি পেইজের তালিকা (অনুদানের স্থানে নোটবই)
  final List<Widget> _pages = [
    const HomePage(),          // 0: হোম
    const MuhasabaAuthGate(),  // 1: মুহাসাবা
    const SizedBox(),          // 2: সর্বশেষ পঠিত (ডায়ালগ/পুশ পেজ)
    const NotebookPage(),      // 3: নোটবই ও সংরক্ষিত তথ্য
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? _pages[0]
          : _currentIndex == 1
              ? _pages[1]
              : _pages[3], // ৩ নম্বর ইন্ডেক্সে নোটবই লোড হবে
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 0) {
            setState(() => _currentIndex = 0);
          } else if (index == 1) {
            setState(() => _currentIndex = 1);
          } else if (index == 2) {
            await _openLastRead(context);
          } else if (index == 3) {
            setState(() => _currentIndex = 3);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
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
            icon: Icon(Icons.history),
            label: 'সর্বশেষ পঠিত',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: 'নোটবই',
          ),
        ],
      ),
    );
  }
}