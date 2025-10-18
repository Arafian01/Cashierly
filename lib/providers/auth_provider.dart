import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum UserRole { admin, kasir }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get user => _auth.currentUser;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _auth.currentUser != null;
  
  UserRole? _userRole;
  UserRole? get userRole => _userRole;
  String? _userName;
  String? get userName => _userName;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _userRole = null;
        _userName = null;
      }
      notifyListeners();
    });
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _userName = data['name'] ?? '';
        String roleString = data['role'] ?? 'kasir';
        _userRole = roleString == 'admin' ? UserRole.admin : UserRole.kasir;
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<bool> register(String email, String password, String name, UserRole role) async {
    try {
      _setError(null);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Create user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role == UserRole.admin ? 'admin' : 'kasir',
        'created_at': FieldValue.serverTimestamp(),
      });
      
      // Load the profile immediately
      await _loadUserProfile(userCredential.user!.uid);
      
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          _setError('Password terlalu lemah');
          break;
        case 'email-already-in-use':
          _setError('Email sudah terdaftar');
          break;
        case 'invalid-email':
          _setError('Format email tidak valid');
          break;
        default:
          _setError('Terjadi kesalahan: ${e.message}');
      }
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setError(null);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Load user profile after successful login
      await _loadUserProfile(userCredential.user!.uid);
      
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _setError('Email tidak terdaftar');
          break;
        case 'wrong-password':
          _setError('Password salah');
          break;
        case 'invalid-email':
          _setError('Format email tidak valid');
          break;
        case 'user-disabled':
          _setError('Akun telah dinonaktifkan');
          break;
        case 'too-many-requests':
          _setError('Terlalu banyak percobaan login. Coba lagi nanti');
          break;
        default:
          _setError('Terjadi kesalahan: ${e.message}');
      }
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _setError(null);
      await _auth.signOut();
    } catch (e) {
      _setError('Gagal logout');
    }
  }

  void clearError() {
    _setError(null);
  }

  Future<void> checkAuthStatus() async {
    // This method can be used to refresh auth state if needed
    // For now, it just ensures the current user state is up to date
    await Future.delayed(const Duration(milliseconds: 100));
    notifyListeners();
  }
}