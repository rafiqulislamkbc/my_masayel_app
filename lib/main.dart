import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'database_helper.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background notification received: ${message.messageId}');
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
          0,
          title,
          question,
          platformChannelSpecifics,
          payload: id.toString(),
        );
      }
    } catch (e) {
      debugPrint("Error in daily background task: $e");
    }

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        int? masalaId = int.tryParse(response.payload!);
        if (masalaId != null) {
          final masalaData = await DatabaseHelper.getMasalaById(masalaId);
          if (masalaData != null && navigatorKey.currentContext != null) {
            showDialog(
              context: navigatorKey.currentContext!,
              builder: (context) => AlertDialog(
                title: Text(masalaData['title'] ?? 'মাসআলা'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "প্রশ্ন: ${masalaData['question'] ?? ''}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text("উত্তর: ${masalaData['answer'] ?? ''}"),
                    ],
                  ),
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
        }
      }
    },
  );

  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "daily_masala_unique_task",
    "sendDailyMasala",
    frequency: const Duration(hours: 24),
  );

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  final token = await messaging.getToken();
  debugPrint('==============================');
  debugPrint('FCM TOKEN: $token');
  debugPrint('==============================');

  runApp(const MasayelApp());
}

class MasayelApp extends StatelessWidget {
  const MasayelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'আপনি যা জানতে চেয়েছেন',
          themeMode: currentMode,
          
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
            fontFamily: 'SolaimanLipi',
            fontFamilyFallback: const ['TraditionalArabic', 'JameelNoori'],
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 2,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
            fontFamily: 'SolaimanLipi',
            fontFamilyFallback: const ['TraditionalArabic', 'JameelNoori'],
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF004D40),
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 2,
            ),
          ),
          
          home: const SplashScreen(),
        );
      },
    );
  }
}