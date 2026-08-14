import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'amol_muhasaba_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MuhasabaAuthGate extends StatelessWidget {
  const MuhasabaAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F8F7),
            body: Center(
              child: CircularProgressIndicator(color: Colors.teal),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const AmolMuhasabaPage();
        }
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

Future<void> _submit() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final name = _nameController.text.trim();

  if (email.isEmpty || password.isEmpty || (_isSignUp && name.isEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('অনুগ্রহ করে সবগুলো তথ্য পূরণ করুন'),
      ),
    );
    return;
  }

  if (password.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে'),
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    if (_isSignUp) {
      // ============================
      // নতুন অ্যাকাউন্ট তৈরি
      // ============================
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;

      if (user != null) {
        // Firebase Auth profile-এ নাম
        await user.updateDisplayName(name);

        // Firestore-এ User Profile তৈরি
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'districtId': 'dhaka',
          'districtName': 'ঢাকা',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'lastActive': null,
          'lastSubmitTime': null,
        });
      }
    } else {
      // ============================
      // Login
      // ============================
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;

      if (user != null) {
        // Login-এর সময় lastLogin আপডেট
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? email,
          'name': user.displayName ?? 'মুসলিম সাথী',
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  } on FirebaseAuthException catch (e) {
    String msg = 'লগইনে সমস্যা হয়েছে';

    if (e.code == 'user-not-found') {
      msg = 'এই ইমেইলে কোনো অ্যাকাউন্ট পাওয়া যায়নি';
    } else if (e.code == 'wrong-password' ||
        e.code == 'invalid-credential') {
      msg = 'ভুল ইমেইল অথবা পাসওয়ার্ড দিয়েছেন';
    } else if (e.code == 'email-already-in-use') {
      msg = 'এই ইমেইল দিয়ে ইতোমধ্যে অ্যাকাউন্ট তৈরি করা হয়েছে';
    } else if (e.code == 'invalid-email') {
      msg = 'ইমেইল ফরম্যাট সঠিক নয়';
    } else if (e.code == 'weak-password') {
      msg = 'পাসওয়ার্ড আরও শক্তিশালী দিন';
    } else {
      msg = e.message ?? msg;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade800,
          content: Text(msg),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ত্রুটি: $e'),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isSignUp ? 'নতুন অ্যাকাউন্ট তৈরি' : 'মুহাসাবা লগইন',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.teal.shade200, width: 2),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.teal, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'আমলের মুহাসাবা',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005A45),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'আপনার প্রতিদিনের আমল ও স্ট্রিক সুরক্ষিত রাখতে লগইন করুন',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 15, offset: Offset(0, 5)),
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
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'ইমেইল ঠিকানা',
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.teal),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 1,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                _isSignUp ? 'রেজিস্ট্রেশন সম্পন্ন করুন' : 'প্রবেশ করুন (লগইন)',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp
                      ? 'ইতোমধ্যে অ্যাকাউন্ট আছে? লগইন করুন'
                      : 'অ্যাকাউন্ট নেই? নতুন অ্যাকাউন্ট তৈরি করুন',
                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}