import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'helpers.dart';
import 'slide_in_item.dart';
import 'masala_detail_page.dart';

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
    );
  }
}