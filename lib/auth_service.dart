import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ১. ইমেইল ও পাসওয়ার্ড দিয়ে লগইন
  static Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// ২. নতুন অ্যাকাউন্ট রেজিস্ট্রেশন
  static Future<UserCredential> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      await credential.user!.updateDisplayName(name.trim());
      await _saveUserToFirestore(credential.user!, name: name.trim());
    }

    return credential;
  }

  /// ৩. পাসওয়ার্ড ভুলে গেলে রিসেট ইমেইল পাঠানো
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// ৪. লগআউট
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// ফায়ারস্টোর 'users' কালেকশনে ইউজারের প্রোফাইল তথ্য সংরক্ষণ
  static Future<void> _saveUserToFirestore(User user, {String? name}) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name ?? user.displayName ?? 'মুসলিম সাথী',
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save user error: $e');
    }
  }
}