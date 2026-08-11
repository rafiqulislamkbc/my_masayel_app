import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'helpers.dart';

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
    bool isArabicOrUrdu = RegExp(r'[؀-ۿݐ-ݿ]').hasMatch(text);

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
        
        bool isArabic = RegExp(r'[؀-ۿݐ-ݿ]').hasMatch(line);

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
        title: Text('মাসআলা নং: $masalaIdBangla'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'কপি করুন',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fullContent));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('লেখাটি কপি করা হয়েছে!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'শেয়ার করুন',
            onPressed: () {
              Share.share(fullContent);
            },
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

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('ফন্ট সাইজ: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () {
                        if (fontSize > 14) setState(() => fontSize -= 2);
                      },
                    ),
                    Text(
                      toBanglaNumber(fontSize.toInt().toString()),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
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
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            
            buildReferenceSection(referenceText, fontSize - 2),
          ],
        ),
      ),
    );
  }
}