import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MuhasabaAuthGate extends StatelessWidget {
  const MuhasabaAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF6F8F7),
            body: const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            ),
          );
        }
        
        // 🌟 লগইন থাকলে সরাসরি ইউজার প্রোফাইল পেজে নিয়ে যাবে (মুহাসাবা পেজে নয়)
        if (snapshot.hasData && snapshot.data != null) {
          return const UserProfilePage();
        }
        
        // লগইন না থাকলে লগইন/সাইন-আপ পেজ দেখাবে
        return const MuhasabaLoginPage();
      },
    );
  }
}

/// 👤 ইউজার প্রোফাইল ও অ্যাকাউন্ট ড্যাশবোর্ড পেজ (ডার্ক মোড সাপোর্টেড)
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String name = _userData?['name'] ?? currentUser?.displayName ?? 'সম্মানিত ব্যবহারকারী';
    final String email = _userData?['email'] ?? currentUser?.email ?? 'ইমেইল দেওয়া নেই';
    final String district = _userData?['districtName'] ?? 'ঢাকা';

    final bgCardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'আমার অ্যাকাউন্ট ও প্রোফাইল',
          style: TextStyle(
            fontFamily: 'SolaimanLipi',
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF004D40) : Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // প্রোফাইল এভাটার
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.teal, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: isDark ? const Color(0xFF004D40) : Colors.teal.shade50,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontFamily: 'SolaimanLipi',
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.tealAccent : Colors.teal.shade800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'SolaimanLipi',
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    style: TextStyle(
                      fontFamily: 'SolaimanLipi',
                      fontSize: 14,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // বিস্তারিত তথ্যের কার্ড
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgCardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.person_outline,
                          title: 'পুরো নাম',
                          value: name,
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
                        _buildInfoTile(
                          icon: Icons.email_outlined,
                          title: 'ইমেইল ঠিকানা',
                          value: email,
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
                        _buildInfoTile(
                          icon: Icons.location_on_outlined,
                          title: 'জেলা',
                          value: district,
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
                        _buildInfoTile(
                          icon: Icons.cloud_done_outlined,
                          title: 'ক্লাউড ব্যাকআপ ও সিঙ্ক',
                          value: 'সক্রিয় (মুহাসাবা ও নোটবই সিঙ্ক হচ্ছে)',
                          valueColor: isDark ? Colors.tealAccent : Colors.teal.shade800,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // লগআউট বাটন
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'অ্যাকাউন্ট থেকে লগআউট করুন',
                        style: TextStyle(
                          fontFamily: 'SolaimanLipi',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: bgCardColor,
                            title: Text(
                              'লগআউট নিশ্চিতকরণ',
                              style: TextStyle(
                                fontFamily: 'SolaimanLipi',
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            content: Text(
                              'আপনি কি আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?',
                              style: TextStyle(
                                fontFamily: 'SolaimanLipi',
                                color: subTextColor,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text(
                                  'না',
                                  style: TextStyle(fontFamily: 'SolaimanLipi', color: Colors.grey),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'হ্যাঁ, লগআউট',
                                  style: TextStyle(fontFamily: 'SolaimanLipi', color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirebaseAuth.instance.signOut();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.tealAccent : Colors.teal, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'SolaimanLipi',
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'SolaimanLipi',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? (isDark ? Colors.white : const Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔐 লগইন ও সাইনআপ পেজ (ডার্ক মোড সাপোর্টেড)
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
          content: Text(
            'অনুগ্রহ করে সবগুলো তথ্য পূরণ করুন',
            style: TextStyle(fontFamily: 'SolaimanLipi'),
          ),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে',
            style: TextStyle(fontFamily: 'SolaimanLipi'),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      if (_isSignUp) {
        final cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = cred.user;

        if (user != null) {
          await user.updateDisplayName(name);

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
        final cred = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = cred.user;

        if (user != null) {
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
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
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
            content: Text(
              msg,
              style: const TextStyle(fontFamily: 'SolaimanLipi'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ত্রুটি: $e',
              style: const TextStyle(fontFamily: 'SolaimanLipi'),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final inputFill = isDark ? const Color(0xFF0F172A) : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF004D40) : Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isSignUp ? 'নতুন অ্যাকাউন্ট তৈরি' : 'অ্যাকাউন্টে প্রবেশ (লগইন)',
          style: const TextStyle(
            fontFamily: 'SolaimanLipi',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
                  color: isDark ? const Color(0xFF004D40) : Colors.teal.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.tealAccent : Colors.teal.shade200,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: isDark ? Colors.tealAccent : Colors.teal,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ব্যবহারকারী অ্যাকাউন্ট',
                style: TextStyle(
                  fontFamily: 'SolaimanLipi',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.tealAccent : const Color(0xFF005A45),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'আপনার আমলের মুহাসাবা ও নোটবই সুরক্ষিত ও ক্লাউডে সিঙ্ক রাখতে সাইন-ইন করুন',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SolaimanLipi',
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.transparent),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black38 : const Color(0x0A000000),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_isSignUp) ...[
                      TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontFamily: 'SolaimanLipi',
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          labelText: 'আপনার নাম',
                          labelStyle: TextStyle(
                            fontFamily: 'SolaimanLipi',
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: isDark ? Colors.tealAccent : Colors.teal,
                          ),
                          filled: true,
                          fillColor: inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white24 : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.grey.shade200,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'ইমেইল ঠিকানা',
                        labelStyle: TextStyle(
                          fontFamily: 'SolaimanLipi',
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: isDark ? Colors.tealAccent : Colors.teal,
                        ),
                        filled: true,
                        fillColor: inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.grey.shade200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        labelStyle: TextStyle(
                          fontFamily: 'SolaimanLipi',
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: isDark ? Colors.tealAccent : Colors.teal,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.grey.shade200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 1,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isSignUp ? 'রেজিস্ট্রেশন সম্পন্ন করুন' : 'প্রবেশ করুন (লগইন)',
                                style: const TextStyle(
                                  fontFamily: 'SolaimanLipi',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
                  style: TextStyle(
                    fontFamily: 'SolaimanLipi',
                    color: isDark ? Colors.tealAccent : Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}