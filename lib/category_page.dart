import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'helpers.dart';
import 'slide_in_item.dart';
import 'masala_detail_page.dart';
import 'main_screen.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;

  const CategoryPage({super.key, required this.categoryName});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> masayelList = [];
  bool isLoading = true;
  final Set<int> _animatedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadMasayel();
  }

  void _loadMasayel() async {
    final data = await DatabaseHelper.getMasayelByCategory(widget.categoryName);
    setState(() {
      masayelList = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: masayelList.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final item = masayelList[index];
                final serialNo = toBanglaNumber((index + 1).toString());

                final card = Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        serialNo,
                        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      item['title'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('last_masala_id', item['id']);

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MasalaDetailPage(
                              masala: item,
                              serialNo: serialNo,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );

                if (_animatedIndices.contains(index)) {
                  return card;
                }
                _animatedIndices.add(index);
                return SlideInItem(index: index, child: card);
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // হোম সেকশনের অধীনে সক্রিয়
        onTap: (index) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(initialIndex: index),
            ),
            (route) => false,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: isDarkMode ? Colors.tealAccent : Colors.teal,
        unselectedItemColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
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