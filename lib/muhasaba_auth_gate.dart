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
        // লোডিং স্টেট
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }

        // ইউজার লগইন থাকলে সরাসরি আমলের মুহাসাবা পেজে যাবে
        if (snapshot.hasData && snapshot.data != null) {
          return const AmolMuhasabaPage();
        }

        // লগইন না থাকলে লগইন স্ক্রিন দেখাবে
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

  // গুগল লগইন
  Future<void> _googleLogin() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('গুগল লগইন ব্যর্থ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ইমেইল লগইন / সাইনআপ
  Future<void> _emailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে ইমেইল ও পাসওয়ার্ড দিন')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await AuthService.registerWithEmailPassword(
          name: _nameController.text.trim().isEmpty ? 'মুসলিম সাথী' : _nameController.text.trim(),
          email: email,
          password: password,
        );
      } else {
        await AuthService.signInWithEmailPassword(email: email, password: password);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text('আমলের মুহাসাবা লগইন'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fact_check_rounded, size: 70, color: Colors.teal),
              const SizedBox(height: 12),
              const Text(
                'আমলের মুহাসাবা',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 6),
              const Text(
                'আপনার প্রতিদিনের আমল ও অগ্রগতি নিরাপদে সংরক্ষণ করতে সাইন-ইন করুন',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // ফর্ম কার্ড
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    if (_isSignUp) ...[
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'আপনার নাম',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'ইমেইল অ্যাড্রেস',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isLoading ? null : _emailAuth,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isSignUp ? 'রেজিস্ট্রেশন করুন' : 'লগইন করুন'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(_isSignUp
                          ? 'অলরেডি অ্যাকাউন্ট আছে? লগইন করুন'
                          : 'নতুন অ্যাকাউন্ট খুলতে চান? সাইন-আপ করুন'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('অথবা')),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // গুগল সাইন-ইন বাটন
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _googleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                  label: const Text(
                    'গুগল (Google) দিয়ে লগইন করুন',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}