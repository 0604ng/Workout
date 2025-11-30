import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  User? get currentUser => _auth.currentUser;
  String get currentUserId => _auth.currentUser?.uid ?? '';

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 🔥 Load user data từ Firestore (bao gồm isAdmin)
  Future<void> loadUserData() async {
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .get();

    if (doc.exists) {
      _isAdmin = doc.data()?['isAdmin'] == true;
      notifyListeners();
    }
  }

  // 🔥 Middleware kiểm tra admin
  Future<bool> ensureAdmin() async {
    if (currentUser == null) return false;
    await loadUserData();
    return _isAdmin;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadUserData(); // 🔥 Load quyền admin sau đăng nhập
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await loadUserData(); // 🔥 Load quyền admin nếu có
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
      _isAdmin = false; // 🔥 Reset quyền admin
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
