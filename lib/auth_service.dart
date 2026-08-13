import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // বর্তমান লগইন করা ইউজার
  static User? get currentUser => _auth.currentUser;

  // লগইন স্টেট পরিবর্তনের লাইভ স্ট্রিম
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ১. গুগল সাইন-ইন (Firebase Native Provider দিয়ে - কোনো অতিরিক্ত প্যাকেজের মেথড কনফ্লিক্ট ছাড়া)
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // ফায়ারবেস অথেনটিকেশনের মাধ্যমে গুগল পপআপ / প্রোভাইডার লগইন
      final UserCredential userCredential = await _auth.signInWithProvider(googleProvider);

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// ২. ইমেইল ও পাসওয়ার্ড দিয়ে লগইন
  static Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// ৩. ইমেইল ও পাসওয়ার্ড দিয়ে নতুন অ্যাকাউন্ট রেজিস্ট্রেশন
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
        'photoUrl': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save user error: $e');
    }
  }
}