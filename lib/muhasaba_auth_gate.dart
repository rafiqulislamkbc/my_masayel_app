import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'amol_muhasaba_page.dart';

class MuhasabaAuthGate extends StatelessWidget {
  const MuhasabaAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F8F7),
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }

        // লগইন থাকলে সরাসরি মুহাসাবা পেজে যাবে
        if (snapshot.hasData && snapshot.data != null) {
          return const AmolMuhasabaPage();
        }

        // লগইন না থাকলে লগইন পেজ
        return const MuhasabaLoginPage();
      },
    );
  }
}

class MuhasabaLoginPage extends StatefulWidget {
  const MuhasabaLoginPage({super.key});

  @override
  State<MuhasabaLoginPage> createState() => _MuhasabaLoginPageState();
}

class _MuhasabaLoginPageState extends State<MuhasabaLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ফায়ারবেস এরর কোড বাংলায় রূপান্তর
  String _getBanglaErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'এই ইমেইলে কোনো অ্যাকাউন্ট খোলা নেই! অনুগ্রহ করে আগে "সাইন-আপ" করুন।';
      case 'wrong-password':
      case 'invalid-credential':
        return 'পাসওয়ার্ডটি ভুল হয়েছে! সঠিক পাসওয়ার্ড দিন অথবা পাসওয়ার্ড রিসেট করুন।';
      case 'email-already-in-use':
        return 'এই ইমেইল দিয়ে অলরেডি একটি অ্যাকাউন্ট রয়েছে! সরাসরি লগইন করুন।';
      case 'invalid-email':
        return 'ইমেইল ঠিকানার ফরম্যাটটি সঠিক নয়।';
      case 'weak-password':
        return 'পাসওয়ার্ডটি অত্যন্ত দুর্বল! কমপক্ষে ৬ অক্ষরের শক্তিশালী পাসওয়ার্ড দিন।';
      case 'too-many-requests':
        return 'অনেকবার ভুল চেষ্টা করা হয়েছে। কিছুক্ষণ পর আবার চেষ্টা করুন।';
      default:
        return 'ত্রুটি: ${e.message ?? "লগইন করা সম্ভব হয়নি"}';
    }
  }

  // ইমেইল লগইন / সাইন-আপ হ্যান্ডলার
  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showSnackbar('অনুগ্রহ করে আপনার ইমেইল অ্যাড্রেস লিখুন');
      return;
    }
    if (password.isEmpty) {
      _showSnackbar('অনুগ্রহ করে আপনার পাসওয়ার্ড লিখুন');
      return;
    }
    if (password.length < 6) {
      _showSnackbar('পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        final name = _nameController.text.trim();
        await AuthService.registerWithEmailPassword(
          name: name.isEmpty ? 'মুসলিম সাথী' : name,
          email: email,
          password: password,
        );
        _showSnackbar('অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে!');
      } else {
        await AuthService.signInWithEmailPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar(_getBanglaErrorMessage(e));
    } catch (e) {
      _showSnackbar('একটি অজানা সমস্যা দেখা দিয়েছে: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // পাসওয়ার্ড রিসেট ডায়ালগ
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('পাসওয়ার্ড রিসেট করুন', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'আপনার অ্যাকাউন্টের ইমেইল দিন। পাসওয়ার্ড পরিবর্তনের একটি লিংক আপনার ইমেইলে পাঠিয়ে দেওয়া হবে:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'ইমেইল অ্যাড্রেস',
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.teal),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('অনুগ্রহ করে ইমেইল অ্যাড্রেস লিখুন')),
                );
                return;
              }
              try {
                await AuthService.sendPasswordResetEmail(email);
                if (context.mounted) {
                  Navigator.pop(context);
                  _showSnackbar('পাসওয়ার্ড রিসেটের লিংক আপনার ইমেইলে পাঠানো হয়েছে। ইনবক্স চেক করুন।');
                }
              } on FirebaseAuthException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_getBanglaErrorMessage(e))),
                  );
                }
              }
            },
            child: const Text('লিংক পাঠান'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.teal.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: Text(_isSignUp ? 'নতুন অ্যাকাউন্ট খুলুন' : 'মুহাসাবা সাইন-ইন'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fact_check_rounded, size: 54, color: Colors.teal),
              ),
              const SizedBox(height: 14),
              const Text(
                'আমলের মুহাসাবা',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 6),
              const Text(
                'প্রতিদিনের আমল ও স্ট্রিক নিরাপদে ক্লাউডে সংরক্ষণ করতে লগইন করুন',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    if (_isSignUp) ...[
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'আপনার নাম',
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.teal),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'ইমেইল অ্যাড্রেস',
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.teal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    if (!_isSignUp) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text('পাসওয়ার্ড ভুলে গেছেন?', style: TextStyle(color: Colors.teal, fontSize: 13)),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 18),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _handleAuth,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isSignUp ? 'রেজিস্ট্রেশন সম্পূর্ণ করুন' : 'লগইন করুন',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp
                            ? 'অলরেডি অ্যাকাউন্ট আছে? লগইন করুন'
                            : 'নতুন অ্যাকাউন্ট খুলতে চান? সাইন-আপ করুন',
                        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
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