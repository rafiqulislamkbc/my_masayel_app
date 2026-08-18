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
              
              // 🌟 লোগোটিকে বড় ও মানানসই করা হয়েছে (স্ক্রিনের ৫০% প্রস্থ)
              Image.asset(
                'assets/logo.png',
                width: screenWidth * 0.52, // 👈 পারফেক্ট সাইজ (বড় ও স্পষ্ট)
                fit: BoxFit.contain,
              ),
              
              const SizedBox(height: 36),
              
              // লোডিং ইন্ডিকেটর
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: isDarkMode ? Colors.tealAccent : const Color(0xFF00796B),
                  strokeWidth: 2.8,
                ),
              ),
              
              const Spacer(flex: 4),
              
              // 🌟 নিচের পরিপাটি ব্র্যান্ডিং
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    Text(
                      'NASEEHAH IT PRESENTS',
                      style: TextStyle(
                        color: isDarkMode ? Colors.tealAccent : const Color(0xFF00796B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'রফিকুল ইসলাম • ০১৮৩৩-০৭০৩২০',
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 13,
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