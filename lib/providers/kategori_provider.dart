import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/kategori.dart';
import '../services/firestore_service.dart';

class KategoriProvider with ChangeNotifier {
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
    try {
      return FirestoreService.getKategoriStream();
    } catch (e) {
      _setError('Gagal memuat data kategori');
      return Stream.value(<Kategori>[]);
    }
  }

  Future<bool> addKategori({
    required String namaKategori,
    String? deskripsi,
  }) async {
    try {
      _setError(null);
      _setLoading(true);
      
      Kategori kategori = Kategori(
        id: '',
        namaKategori: namaKategori,
        deskripsi: deskripsi,
      );
      
      await FirestoreService.addKategori(kategori);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menambah kategori: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  Future<bool> updateKategori(Kategori kategori) async {
    try {
      _setError(null);
      _setLoading(true);
      await FirestoreService.updateKategori(kategori);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal memperbarui kategori: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  Future<bool> deleteKategori(String id) async {
    try {
      _setError(null);
      _setLoading(true);
      await FirestoreService.deleteKategori(id);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menghapus kategori: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }
}