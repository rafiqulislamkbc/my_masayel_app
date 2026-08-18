import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class AppUpdateHelper {
  static Future<void> checkAppUpdate(BuildContext context, {VoidCallback? onUpdated}) async {
    const String url =
        'https://raw.githubusercontent.com/rafiqulislamkbc/masayel-updates/main/version.json';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        String latestVersion = data['app_info']['latest_version'] ?? '1.0';
        bool forceUpdate = data['app_info']['force_update'] ?? false;
        String updateMessage = data['app_info']['update_message'] ?? 'নতুন আপডেট এসেছে!';
        String jsonUrl = data['app_info']['masayel_json_url'] ??
            'https://raw.githubusercontent.com/rafiqulislamkbc/masayel-updates/main/new_data.json';

        final prefs = await SharedPreferences.getInstance();
        String currentVersion = prefs.getString('masala_db_version') ?? '1.0';

        if (latestVersion != currentVersion && context.mounted) {
          _showUpdateDialog(context, updateMessage, jsonUrl, forceUpdate, latestVersion, onUpdated);
        }
      }
    } catch (e) {
      debugPrint('আপডেট চেক এরর: $e');
    }
  }

  static void _showUpdateDialog(
    BuildContext context,
    String message,
    String url,
    bool forceUpdate,
    String newVersion,
    VoidCallback? onUpdated,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.system_update_alt, color: Colors.teal),
            SizedBox(width: 8),
            Text('নতুন আপডেট পাওয়া গেছে', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Text(message),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('পরে করুন', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('নতুন মাসআলা ডাউনলোড হচ্ছে...')),
              );

              try {
                final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

                if (response.statusCode == 200) {
                  final List<dynamic> newMasayelList = jsonDecode(utf8.decode(response.bodyBytes));
                  int addedCount = await DatabaseHelper.insertNewMasayel(newMasayelList);

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('masala_db_version', newVersion);

                  if (context.mounted) {
                    if (onUpdated != null) onUpdated();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(addedCount > 0
                            ? '$addedCount টি নতুন মাসআলা সফলভাবে যুক্ত/আপডেট হয়েছে!'
                            : 'সকল মাসআলা ইতোমধ্যে আপ-টু-ডেট আছে।'),
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
}