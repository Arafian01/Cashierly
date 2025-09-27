import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/kategori.dart';

class KategoriProvider with ChangeNotifier {
  final CollectionReference _kategoriRef = FirebaseFirestore.instance.collection('kategori');
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Stream<List<Kategori>> getKategori() {
    return _kategoriRef.snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Kategori.fromSnapshot(doc)).toList();
      } catch (e) {
        _setError('Gagal memuat data kategori');
        return <Kategori>[];
      }
    });
  }

  Future<bool> addKategori(Kategori kategori) async {
    try {
      _setError(null);
      _setLoading(true);
      await _kategoriRef.add(kategori.toMap());
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menambah kategori: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  Future<bool> updateKategori(Kategori kategori) async {
    try {
      _setError(null);
      _setLoading(true);
      await _kategoriRef.doc(kategori.id).update(kategori.toMap());
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal memperbarui kategori: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  Future<bool> deleteKategori(String id) async {
    try {
      _setError(null);
      _setLoading(true);
      await _kategoriRef.doc(id).delete();
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menghapus kategori: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }
}