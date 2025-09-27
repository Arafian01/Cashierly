import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> register(String email, String password) async {
    try {
      _setError(null);
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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
}