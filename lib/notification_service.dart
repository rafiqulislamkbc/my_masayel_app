import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'database_helper.dart';
import 'firebase_options.dart';
import 'masala_detail_page.dart';
import 'amol_muhasaba_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Background notification received: ${message.messageId}');
  } catch (e) {
    debugPrint('Background notification error: $e');
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final masala = await DatabaseHelper.getRandomMasalaForNotification();

      if (masala != null) {
        final int id = masala['id'] is int ? masala['id'] : int.parse(masala['id'].toString());
        final String title = masala['title'] ?? "আজকের নির্বাচিত মাসআলা";
        final String question = masala['question'] ?? "";

        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const InitializationSettings initializationSettings =
            InitializationSettings(android: initializationSettingsAndroid);

        await flutterLocalNotificationsPlugin.initialize(initializationSettings);

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'daily_masala_channel',
          'দৈনিক মাসআলা',
          channelDescription: 'প্রতিদিনের নির্বাচিত মাসআলার নোটিফিকেশন',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.show(
          id,
          title,
          question,
          platformChannelSpecifics,
          payload: "MASALA:$id",
        );
      }
    } catch (e) {
      debugPrint("Error in daily background task: $e");
    }

    return Future.value(true);
  });
}

class NotificationService {
  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          final payload = response.payload;
          if (payload == "AMOL_MUHASABA" || payload == "MUHASABA") {
            await _navigateToAmolMuhasabaPage(navigatorKey);
          } else if (payload != null && payload.startsWith("MASALA:")) {
            final idStr = payload.replaceFirst("MASALA:", "");
            await _navigateToMasalaDetailPage(navigatorKey, idStr);
          }
        },
      );

      final NotificationAppLaunchDetails? launchDetails =
          await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload == "AMOL_MUHASABA" || payload == "MUHASABA") {
          _navigateToAmolMuhasabaPage(navigatorKey);
        } else if (payload != null && payload.startsWith("MASALA:")) {
          final idStr = payload.replaceFirst("MASALA:", "");
          _navigateToMasalaDetailPage(navigatorKey, idStr);
        }
      }

      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          _handleMessageRoute(navigatorKey, message);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessageRoute(navigatorKey, message);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'campaign_notice_channel',
                'জরুরি বিজ্ঞপ্তি',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );
        }
      });

      Workmanager().initialize(callbackDispatcher);
      Workmanager().registerPeriodicTask(
        "daily_masala_unique_task",
        "sendDailyMasala",
        frequency: const Duration(hours: 24),
      );

      await scheduleDailyMasalaNotification(hour: 19, minute: 0);

      Future.microtask(() async {
        try {
          final messaging = FirebaseMessaging.instance;
          await messaging.requestPermission(alert: true, badge: true, sound: true);
          final token = await messaging.getToken().timeout(const Duration(seconds: 4));
          debugPrint('FCM TOKEN: $token');
        } catch (e) {
          debugPrint('FCM token offline or bypassed: $e');
        }
      });
    } catch (e) {
      debugPrint("Notification Setup error: $e");
    }
  }

  static Future<void> scheduleDailyMasalaNotification({required int hour, required int minute}) async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final masala = await DatabaseHelper.getRandomMasalaForNotification();
      if (masala != null) {
        final int id = masala['id'] is int ? masala['id'] : int.parse(masala['id'].toString());
        final String title = masala['title'] ?? "আজকের নির্বাচিত মাসআলা";
        final String question = masala['question'] ?? "";

        await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          title,
          question,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_masala_channel',
              'দৈনিক মাসআলা',
              channelDescription: 'প্রতিদিনের নির্দিষ্ট সময়ের মাসআলা নোটিফিকেশন',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: "MASALA:$id",
        );
      }
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  static void _handleMessageRoute(GlobalKey<NavigatorState> navigatorKey, RemoteMessage message) {
    final type = message.data['type'] ?? message.data['target'];
    if (type == 'muhasaba' || message.data['click_action'] == 'FLUTTER_NOTIFICATION_CLICK') {
      _navigateToAmolMuhasabaPage(navigatorKey);
    } else {
      final title = message.notification?.title ?? message.data['title'] ?? 'জরুরি বিজ্ঞপ্তি';
      final body = message.notification?.body ?? message.data['body'] ?? '';
      final url = message.data['url'] ?? message.data['link'];
      if (body.isNotEmpty || title.isNotEmpty) {
        _showCustomNoticeDialog(navigatorKey, title, body, url: url?.toString());
      }
    }
  }

  static Future<void> _navigateToMasalaDetailPage(GlobalKey<NavigatorState> navigatorKey, String rawId) async {
    int? masalaId = int.tryParse(rawId);
    if (masalaId == null) return;

    await Future.delayed(const Duration(milliseconds: 2500));
    for (int i = 0; i < 10; i++) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final masalaData = await DatabaseHelper.getMasalaById(masalaId);
        if (masalaData != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MasalaDetailPage(
                masala: masalaData,
                serialNo: masalaId.toString(),
              ),
            ),
          );
          break;
        }
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  static Future<void> _navigateToAmolMuhasabaPage(GlobalKey<NavigatorState> navigatorKey) async {
    await Future.delayed(const Duration(milliseconds: 2500));
    for (int i = 0; i < 10; i++) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AmolMuhasabaPage(),
          ),
        );
        break;
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  static Future<void> _showCustomNoticeDialog(
    GlobalKey<NavigatorState> navigatorKey,
    String title,
    String body, {
    String? url,
  }) async {
    await Future.delayed(const Duration(milliseconds: 2500));
    for (int i = 0; i < 10; i++) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.campaign, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.isEmpty ? 'জরুরি বিজ্ঞপ্তি' : title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(body, style: const TextStyle(fontSize: 15, height: 1.4)),
                  if (url != null && url.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link, color: Colors.teal, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                url,
                                style: const TextStyle(
                                  color: Colors.teal,
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (url != null && url.isNotEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('বিস্তারিত দেখুন'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('বন্ধ করুন', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ],
          ),
        );
        break;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}