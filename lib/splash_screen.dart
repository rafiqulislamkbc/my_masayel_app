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
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  // 🌟 অ্যাপ ওপেন হওয়ার প্রথম মুহূর্তেই ছবিগুলো মেমরিতে ইনস্ট্যান্ট লোড করার ব্যবস্থা
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/logo.png'), context);
    precacheImage(const AssetImage('assets/app_icon.png'), context);
    precacheImage(const AssetImage('assets/developer.jpg'), context);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Spacer(flex: 3),
              
              // 🌟 মোবাইল ও উইন্ডোজ উভয়ের জন্য পারফেক্ট সাইজ লিমিট
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 180, // উইন্ডোজ ও ট্যাবলেটে ১৮০ পিক্সেলের বেশি বড় হবে না
                  maxHeight: 160,
                ),
                child: Image.asset(
                  'assets/logo.png',
                  width: screenWidth * 0.40, // মোবাইলের জন্য মার্জিত সাইজ
                  fit: BoxFit.contain,
                  gaplessPlayback: true, // 🌟 কোনো ফ্লিকার বা লোডিং ডিলে হতে দেবে না
                  filterQuality: FilterQuality.medium,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // লোডিং ইন্ডিকেটর
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: isDarkMode ? Colors.tealAccent : const Color(0xFF00796B),
                  strokeWidth: 2.5,
                ),
              ),
              
              const Spacer(flex: 4),
              
              // 🌟 নিচের ব্র্যান্ডিং টেক্সট
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    Text(
                      'NASEEHAH IT PRESENTS',
                      style: TextStyle(
                        color: isDarkMode ? Colors.tealAccent : const Color(0xFF00796B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 0),
                    Text(
                      'রফিকুল ইসলাম • ০১৮৩৩-০৭০৩২০',
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
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