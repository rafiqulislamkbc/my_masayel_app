import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    final String name = _userData?['name'] ?? currentUser?.displayName ?? 'নাম প্রকাশে অনিচ্ছুক';
    final String email = _userData?['email'] ?? currentUser?.email ?? 'ইমেইল দেওয়া নেই';
    final String district = _userData?['districtName'] ?? 'উল্লেখ নেই';

    final bgCardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ইউজার প্রোফাইল',
          style: TextStyle(
            fontFamily: 'SolaimanLipi',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF004D40) : Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
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
                        radius: 45,
                        backgroundColor: isDark ? const Color(0xFF004D40) : Colors.teal.shade50,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontFamily: 'SolaimanLipi',
                            fontSize: 36,
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                          title: 'নাম',
                          value: name,
                          isDark: isDark,
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          icon: Icons.email_outlined,
                          title: 'ইমেইল অ্যাড্রেস',
                          value: email,
                          isDark: isDark,
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          icon: Icons.location_on_outlined,
                          title: 'জেলা',
                          value: district,
                          isDark: isDark,
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          icon: Icons.cloud_done_outlined,
                          title: 'ক্লাউড সিঙ্ক স্ট্যাটাস',
                          value: 'সক্রিয় (মুহাসাবা ও নোটবই সংযুক্ত)',
                          valueColor: Colors.teal,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // লগআউট বাটন
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                              'অ্যাকাউন্ট থেকে লগআউট করলে আপনার বর্তমান অ্যাকাউন্টের মুহাসাবা ও নোটবইয়ের তথ্য অদৃশ্য হতে পারে। আপনি কি নিশ্চিতভাবে আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?',
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
          Icon(icon, color: Colors.teal, size: 22),
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