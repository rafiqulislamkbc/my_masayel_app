import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'helpers.dart';
import 'main_screen.dart'; // 🌟 বটমবার নেভিগেশনের জন্য ইমপোর্ট
import 'pages/notebook_page.dart';

class MasalaDetailPage extends StatefulWidget {
  final Map<String, dynamic> masala;
  final String serialNo;

  const MasalaDetailPage({
    super.key,
    required this.masala,
    required this.serialNo,
  });

  @override
  State<MasalaDetailPage> createState() => _MasalaDetailPageState();
}

class _MasalaDetailPageState extends State<MasalaDetailPage> {
  double fontSize = 18.0;

  TextStyle appTextStyle({
    required double size,
    FontWeight weight = FontWeight.normal,
    Color? color,
    double height = 1.4,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      fontFamily: 'SolaimanLipi',
      fontFamilyFallback: const [
        'TraditionalArabic',
        'JameelNoori',
      ],
    );
  }

  Widget buildParagraph(String text, double size, {bool isReference = false}) {
    bool hasBengali = RegExp(r'[ঀ-৿]').hasMatch(text);
    bool isArabicOrUrdu = RegExp(r'[\u0600-\u06FF\u0750-\u077F]').hasMatch(text);

    if (isArabicOrUrdu && !hasBengali) {
      return Container(
        width: double.infinity,
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: appTextStyle(
              size: size,
              height: 1.5,
              color: isReference ? Colors.teal.shade900 : null,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: appTextStyle(size: size),
        ),
      );
    }
  }

  Widget buildFormattedContent(String content, double size) {
    List<String> paragraphs = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((p) {
        if (p.trim().isEmpty) return const SizedBox(height: 8);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: buildParagraph(p, size),
        );
      }).toList(),
    );
  }

  Widget buildReferenceSection(String refText, double size) {
    List<String> lines = refText.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox.shrink();
        
        bool isArabic = RegExp(r'[\u0600-\u06FF\u0750-\u077F]').hasMatch(line);

        if (isArabic) {
          return Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 6.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                line.trim(),
                textAlign: TextAlign.right,
                style: appTextStyle(
                  size: size,
                  height: 1.6,
                  color: Colors.teal.shade900,
                ),
              ),
            ),
          );
        } else {
          return Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              line.trim(),
              textAlign: TextAlign.left,
              style: appTextStyle(
                size: size,
                height: 1.5,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masala = widget.masala;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final rawId = masala['id'] != null ? masala['id'].toString() : widget.serialNo;
    final masalaIdBangla = toBanglaNumber(rawId);

    final publicationInfo = masala['publication_info'] ?? '';
    final referenceText = masala['reference'] ?? 'উল্লেখ নেই';

    final fullContent = '''
মাসআলা নং: ${widget.serialNo}
বিষয়: ${masala['title']}
প্রশ্নকারী: ${masala['questioner'] ?? 'অজ্ঞাত'}

প্রশ্ন: ${masala['question']}

উত্তর: ${masala['answer']}

রেফারেন্স: $referenceText
''';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0, // 🌟 বামপাশের ফাঁকা কমিয়ে টাইটেলকে পর্যাপ্ত স্পেস প্রদান
        title: Text(
          'মাসআলা নং: $masalaIdBangla',
          style: const TextStyle(
            fontFamily: 'SolaimanLipi',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // বুকমার্ক বাটন
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'নোটবইতে সংরক্ষণ করুন',
            onPressed: () async {
              final noteBody = '''
প্রশ্ন: ${masala['question'] ?? ''}

উত্তর: ${masala['answer'] ?? ''}

রেফারেন্স: ${masala['reference'] ?? 'উল্লেখ নেই'}
'''.trim();

              await NotebookPage.saveQuickNote(
                context: context,
                title: 'মাসআলা: ${masala['title'] ?? 'শিরোনামহীন'}',
                content: noteBody,
                category: 'মাসআলা নোট',
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'মাসআলাটি সফলভাবে নোটবইতে সংরক্ষিত হয়েছে!',
                            style: TextStyle(
                              fontFamily: 'SolaimanLipi',
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.teal.shade800,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          
          // 🌟 কপি ও শেয়ার অপশন মেনুর ভেতরে
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            onSelected: (val) {
              if (val == 'copy') {
                Clipboard.setData(ClipboardData(text: fullContent));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'লেখাটি কপি করা হয়েছে!',
                      style: TextStyle(fontFamily: 'SolaimanLipi'),
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else if (val == 'share') {
                Share.share(fullContent);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(
                      Icons.copy,
                      size: 18,
                      color: isDarkMode ? Colors.tealAccent : Colors.teal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'কপি করুন',
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(
                      Icons.share,
                      size: 18,
                      color: isDarkMode ? Colors.tealAccent : Colors.teal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'শেয়ার করুন',
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (publicationInfo.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF004D40) : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDarkMode ? Colors.teal.shade700 : Colors.teal.shade200,
                        ),
                      ),
                      child: Text(
                        publicationInfo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.tealAccent : Colors.teal.shade800,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                if (publicationInfo.isNotEmpty) const SizedBox(width: 8),

                // 🌟 ফন্ট সাইজ কন্ট্রোলারের কমপ্যাক্ট স্পেসিং
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ফন্ট সাইজ:',
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      color: isDarkMode ? Colors.tealAccent : Colors.teal,
                      onPressed: () {
                        if (fontSize > 14) setState(() => fontSize -= 2);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        toBanglaNumber(fontSize.toInt().toString()),
                        style: TextStyle(
                          fontFamily: 'SolaimanLipi',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      color: isDarkMode ? Colors.tealAccent : Colors.teal,
                      onPressed: () {
                        if (fontSize < 30) setState(() => fontSize += 2);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            Text(
              masala['title'],
              style: appTextStyle(
                size: fontSize + 4,
                weight: FontWeight.bold,
                color: isDarkMode ? Colors.tealAccent : Colors.teal.shade800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'প্রশ্নকারী: ${masala['questioner'] ?? 'অজ্ঞাত'}',
              style: appTextStyle(
                size: fontSize - 2,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E2D2B) : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.teal.shade700 : Colors.teal.shade200,
                ),
              ),
              child: Text(
                'প্রশ্ন: ${masala['question']}',
                style: appTextStyle(
                  size: fontSize,
                  weight: FontWeight.w500,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'উত্তর:',
              style: appTextStyle(
                size: 20,
                weight: FontWeight.bold,
                color: isDarkMode ? Colors.tealAccent : Colors.teal,
              ),
            ),
            const SizedBox(height: 8),

            buildFormattedContent(masala['answer'], fontSize),
            const SizedBox(height: 10),

            Divider(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              thickness: 1,
              height: 20,
            ),
            const SizedBox(height: 4),

            const Text(
              'রেফারেন্স:',
              style: TextStyle(
                fontFamily: 'SolaimanLipi',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            
            buildReferenceSection(referenceText, fontSize - 2),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // ডিফল্ট সিলেকশন (সর্বশেষ পঠিত)
        onTap: (index) {
          if (index == 3) {
            // ইতোমধ্যে মাসআলা ডিটেইল পেজে আছেন
          } else {
            // সরাসরি কাঙ্ক্ষিত ট্যাবে নিয়ে যাবে
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(initialIndex: index),
              ),
              (route) => false,
            );
          }
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