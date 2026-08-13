import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart'; 
import 'home_page.dart';
import 'masala_detail_page.dart';
import 'muhasaba_auth_gate.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  final String bkashNumber = '01833-070320';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অনুদান ও সহযোগিতা'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 60, color: Colors.teal),
            const SizedBox(height: 16),
            const Text(
              'দ্বীনি খিদমায় সহযোগিতা করুন',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'দশের লাঠি, একের বোঝা! তাই গুরুত্বপূর্ণ এ অ্যাপটির উন্নয়ন কার্যক্রম সচল রাখতে আপনিও আমাদের সহযোগী হতে পারেন। সাদাকায়ে জারিয়ার অংশীদার হবেন ইনশাআল্লাহ। টাকা পাঠানোর জন্য স্ক্রীনে প্রদত্ত নম্বরে বিকাশ, নগদ, রকেট বা উপায়-এর মাধ্যমে সেন্ড মানি করতে হবে।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 74, 74, 74)),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    'বিকাশ, নগদ, রকেট, উপায় (Personal)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bkashNumber,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

final List<Widget> _pages = [
  const HomePage(),            // 0: হোম
  const MuhasabaAuthGate(),    // 1: লগইন থাকলে আমল পেজ, না থাকলে লগইন পেজ দেখাবে
  const DonationPage(),        // 3: অনুদান
];

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
        const SnackBar(content: Text('কোনো সর্বশেষ পঠিত মাসআলা পাওয়া যায়নি!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex == 2 ? 1 : _currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 0) {
            setState(() {
              _currentIndex = 0;
            });
          } else if (index == 1) {
            await _openLastRead(context);
          } else if (index == 2) {
            setState(() {
              _currentIndex = 2;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'হোম',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'সর্বশেষ পঠিত',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'অনুদান',
          ),
        ],
      ),
    );
  }
}