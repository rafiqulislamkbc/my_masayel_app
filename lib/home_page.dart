import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'helpers.dart';
import 'slide_in_item.dart';
import 'category_page.dart';
import 'masala_detail_page.dart';
import 'app_drawer.dart';
import 'app_update_helper.dart';
import 'theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> categories = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  bool isLoading = true;

  final Set<int> _animatedCategoryIndices = {};
  final Set<int> _animatedSearchIndices = {};
  int _searchQueryCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateHelper.checkAppUpdate(context, onUpdated: _loadCategories);
    });
  }

  void _loadCategories() async {
    final data = await DatabaseHelper.getCategories();
    if (mounted) {
      setState(() {
        categories = data;
        isLoading = false;
      });
    }
  }

  void _onSearch(String query) async {
    final currentQueryId = ++_searchQueryCounter;

    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    final results = await DatabaseHelper.searchMasayel(query);

    if (!mounted || currentQueryId != _searchQueryCounter) return;

    setState(() {
      isSearching = true;
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDarkMode = currentMode == ThemeMode.dark;

        return Scaffold(
          drawer: const AppDrawer(), // 🌟 সম্পূর্ণ আলাদা ক্লিন ড্রয়ার
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'আপনি যা জানতে চেয়েছেন',
              style: TextStyle(fontSize: 18),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                      size: 18,
                    ),
                    const SizedBox(width: 2),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: isDarkMode,
                        activeThumbColor: Colors.tealAccent,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) {
                          themeNotifier.value =
                              value ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'বিষয় বা মাসআলা খুঁজুন...',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    filled: true,
                    fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isSearching
                        ? _buildSearchResults()
                        : _buildCategoryList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    if (categories.isEmpty) {
      return const Center(child: Text('কোনো ক্যাটাগরি পাওয়া যায়নি।'));
    }
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final categoryName = categories[index];
        final card = Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.folder, color: Colors.white),
            ),
            title: Text(
              categoryName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryPage(categoryName: categoryName),
                ),
              );
            },
          ),
        );

        if (_animatedCategoryIndices.contains(index)) {
          return card;
        }
        _animatedCategoryIndices.add(index);
        return SlideInItem(index: index, child: card);
      },
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return const Center(child: Text('কোনো ফলাফল পাওয়া যায়নি।'));
    }
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        final card = Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            title: Text(
              item['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              item['category'],
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.tealAccent
                    : Colors.teal.shade700,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MasalaDetailPage(
                    masala: item,
                    serialNo: toBanglaNumber((index + 1).toString()),
                  ),
                ),
              );
            },
          ),
        );

        if (_animatedSearchIndices.contains(index)) {
          return card;
        }
        _animatedSearchIndices.add(index);
        return SlideInItem(index: index, child: card);
      },
    );
  }
}