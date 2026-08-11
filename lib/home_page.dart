import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'database_helper.dart';
import 'helpers.dart';
import 'slide_in_item.dart';
import 'category_page.dart';
import 'masala_detail_page.dart';
import 'main.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppUpdate(context);
    });
  }

  Future<void> _checkAppUpdate(BuildContext context) async {
    const String url =
        'https://raw.githubusercontent.com/rafiqulislamkbc/masayel-updates/main/version.json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        String latestVersion = data['app_info']['latest_version'] ?? '1.0';
        bool forceUpdate = data['app_info']['force_update'] ?? false;
        String updateMessage =
            data['app_info']['update_message'] ?? 'নতুন আপডেট এসেছে!';
        String jsonUrl = data['app_info']['masayel_json_url'] ??
            'https://raw.githubusercontent.com/rafiqulislamkbc/masayel-updates/main/new_data.json';

        const String currentVersion = '1.0';

if (latestVersion != currentVersion && context.mounted) {
  _showUpdateDialog(context, updateMessage, jsonUrl, forceUpdate);
 }
}
    } catch (e) {
      debugPrint('আপডেট চেক এরর: $e');
    }
  }

  void _showUpdateDialog(
      BuildContext context, String message, String url, bool forceUpdate) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (dialogContext) => AlertDialog(
        title: const Text('নতুন আপডেট পাওয়া গেছে'),
        content: Text(message),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('পরে করুন'),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('নতুন মাসআলা ডাউনলোড হচ্ছে...')),
              );

              try {
                final response = await http.get(Uri.parse(url));

                if (response.statusCode == 200) {
                  final List<dynamic> newMasayelList =
                      jsonDecode(utf8.decode(response.bodyBytes));

                  int addedCount =
                      await DatabaseHelper.insertNewMasayel(newMasayelList);

                  if (context.mounted) {
                    _loadCategories();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(addedCount > 0
                            ? '$addedCount টি নতুন মাসআলা সফলভাবে যুক্ত হয়েছে!'
                            : 'নতুন কোনো মাসআলা যুক্ত করার নেই।'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  }
                }
              } catch (e) {
                debugPrint('ডাটা আপডেট এরর: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('আপডেট করতে সমস্যা হয়েছে! ইন্টারনেট সংযোগ চেক করুন।'),
                    ),
                  );
                }
              }
            },
            child: const Text('আপডেট করুন'),
          ),
        ],
      ),
    );
  }

  void _loadCategories() async {
    final data = await DatabaseHelper.getCategories();
    setState(() {
      categories = data;
      isLoading = false;
    });
  }

  int _searchQueryCounter = 0;

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

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('অ্যাপ সম্পর্কে'),
        content: const Text(
          'এটি একটি ইসলামিক মাসআলা ভিত্তিক মোবাইল অ্যাপ্লিকেশন। এখানে দৈনন্দিন জীবনের বিভিন্ন গুরুত্বপূর্ণ মাসআলা ও সমাধান খুব সহজে খুঁজে পাওয়া যাবে। অ্যাপ সংস্করণ: ১.০.০',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  void _showNaseehaItDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নাসিহাহ আইটি'),
        content: const Text(
          'নাসিহাহ আইটি হলো একটি প্রযুক্তিভিত্তিক প্রতিষ্ঠান, যা ইসলামিক ও জনকল্যাণমূলক সফটওয়্যার এবং মোবাইল অ্যাপ তৈরি করে থাকে। আমাদের লক্ষ্য প্রযুক্তির ছোঁয়া পৌঁছে দেওয়া।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ধন্যবাদ'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('গোপনীয়তা নীতিমালা'),
        content: const Text(
          'আপনার গোপনীয়তা আমাদের কাছে অত্যন্ত গুরুত্বপূর্ণ। এই অ্যাপটি ব্যবহারকারীর কোনো ব্যক্তিগত তথ্য সংগ্রহ বা অপব্যবহার করে না।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বন্ধ করুন'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Center(
          child: Text(
            'ডেভেলপার পরিচিতি',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.teal,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/developer.jpg'),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'রফিকুল ইসলাম',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0),
            Text(
              'আমি রফিকুল ইসলাম। ২০২৬ইং সনে কওমী মাদরাসা থেকে দাওরায়ে হাদিস সম্পন্ন করেছি। পড়াশোনার পাশাপাশি লেখালেখি, ডিজাইন এবং আধুনিক টেকনোলজির প্রতি আগ্রহ রয়েছে। পড়াশোনাকে মূল রেখে অবসর সময়গুলোতে শখের বশে বিভিন্ন ওয়েবসাইট, মোবাইল অ্যাপ তৈরি করেছি। এই অ্যাপটির প্রয়োজনীয়তা অনুভব করে কষ্ট হওয়া সত্ত্বেও এ কাজ হাতে নিয়েছিলাম। আশা করি কিছুটা হলেও সফল হয়েছি। আল্লাহ তায়ালা এ মেহনতকে কবুল করুন এবং সাদাকায়ে জারিয়ার অন্তর্ভূক্ত করুন। আমীন। সবার নিকট আবেদন থাকবে, অ্যাপটি শেয়ার করে অন্যদেরকে গুরুত্বপূর্ণ এ মাসাআলাগুলো জানার ব্যবস্থা করে দিবেন ইনশাআল্লাহ। অ্যাপটির আপডেট চলমান থাকবে; নতুন আপডেট আসলেই অ্যাপে নোটিশ চলে আসবে। আল্লাহ তায়ালা সকলের কল্যাণ করুন।',
              style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 3, 0, 0)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'যোগাযোগ: ০১৮৩৩-০৭০৩২০',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 165, 164, 164)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('বন্ধ করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDarkMode = currentMode == ThemeMode.dark;

        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  color: isDarkMode ? const Color(0xFF004D40) : Colors.teal,
                  padding: const EdgeInsets.only(
                      top: 48, bottom: 16, left: 16, right: 16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 34,
                          backgroundImage: ResizeImage(
                            AssetImage('assets/developer.jpg'),
                            width: 140,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'রফিকুল ইসলাম',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'আলেম, লেখক এবং\nমোবাইল অ্যাপ ডেভেলপার',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.teal),
                  title: const Text('অ্যাপ সম্পর্কে'),
                  subtitle: const Text('অ্যাপের পরিচিতি ও বিবরণ'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutAppDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business, color: Colors.teal),
                  title: const Text('নাসিহাহ আইটি'),
                  subtitle: const Text('ডেভলপকারী প্রতিষ্ঠানের পরিচিতি'),
                  onTap: () {
                    Navigator.pop(context);
                    _showNaseehaItDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.teal),
                  title: const Text('ডেভেলপার পরিচিতি'),
                  subtitle: const Text('বিস্তারিত জানতে ক্লিক করুন'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeveloperDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.teal),
                  title: const Text('যোগাযোগ'),
                  subtitle: const Text('০১৮৩৩-০৭০৩২০'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Colors.teal),
                  title: const Text('প্রাইভেসি পলিসি'),
                  subtitle: const Text('আমাদের নীতিমালা'),
                  onTap: () {
                    Navigator.pop(context);
                    _showPrivacyPolicyDialog(context);
                  },
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.teal),
                  title: Text('অ্যাপ ভার্সন'),
                  subtitle: Text('১.০'),
                ),
              ],
            ),
          ),
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