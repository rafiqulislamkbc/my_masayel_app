import 'package:flutter/material.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Spacer(),
              Image(
                image: ResizeImage(
                  const AssetImage('assets/logo.png'),
                  height: (85 * MediaQuery.of(context).devicePixelRatio).round(),
                ),
                height: 85,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'আপনি যা জানতে চেয়েছেন',
                style: TextStyle(
                  fontSize: 20,
                  color: isDarkMode ? Colors.tealAccent : const Color(0xFF006B49),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(
                color: Colors.teal,
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 35.0),
                child: Column(
                  children: [
                    Text(
                      'ডেভেলপার: রফিকুল ইসলাম',
                      style: TextStyle(
                        color: Color.fromARGB(255, 19, 145, 19),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 0),
                    Text(
                      'হ্যালো: ০১৮৩৩-০৭০৩২০',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}