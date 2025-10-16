import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/barang.dart';
import '../services/firestore_service.dart';

class BarangProvider with ChangeNotifier {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  final List<Barang> _barangList = [];
  List<Barang> get barangList => List.unmodifiable(_barangList);

  DocumentSnapshot? _lastBarangDocument;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Stream<List<Barang>> getBarang() {
    try {
      return FirestoreService.getBarangStream();
    } catch (e) {
      _setError('Gagal memuat data barang');
      return Stream.value(<Barang>[]);
    }
  }

  Future<void> loadInitialBarang({int limit = 20}) async {
    if (_isLoading) return;
    try {
      _setError(null);
      _setLoading(true);
      _barangList.clear();
      _lastBarangDocument = null;
      _hasMore = true;

      final result = await FirestoreService.fetchBarangPage(limit: limit);
      _barangList.addAll(result.items);
      _lastBarangDocument = result.lastDocument;
      _hasMore = result.hasMore;
    } on FirebaseException catch (e) {
      _setError('Gagal memuat barang: ${e.message}');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreBarang({int limit = 20}) async {
    if (_isFetchingMore || !_hasMore || _isLoading) return;
    _isFetchingMore = true;
    notifyListeners();

    try {
      final result = await FirestoreService.fetchBarangPage(
        startAfter: _lastBarangDocument,
        limit: limit,
      );
      _barangList.addAll(result.items);
      _lastBarangDocument = result.lastDocument;
      _hasMore = result.hasMore;
    } on FirebaseException catch (e) {
      _setError('Gagal memuat barang berikutnya: ${e.message}');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga: $e');
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Stream<List<Barang>> getBarangByKategori(String idKategori) {
    try {
      return FirestoreService.getBarangByKategoriStream(idKategori);
    } catch (e) {
      _setError('Gagal memuat data barang berdasarkan kategori');
      return Stream.value(<Barang>[]);
    }
  }

  Future<bool> addBarang({
    required String idKategori,
    required String namaBarang,
    required int stokTotal,
  }) async {
    try {
      _setError(null);
      _setLoading(true);
      
      String kodeBarang = await FirestoreService.generateKodeBarang(idKategori);
      
      Barang barang = Barang(
        id: '',
        idKategori: idKategori,
        kodeBarang: kodeBarang,
        namaBarang: namaBarang,
        stokTotal: stokTotal,
      );
      
      await FirestoreService.addBarang(barang);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menambah barang: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  Future<bool> updateBarang(Barang barang) async {
    try {
      _setError(null);
      _setLoading(true);
      await FirestoreService.updateBarang(barang);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal memperbarui barang: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  Future<bool> deleteBarang(String id) async {
    try {
      _setError(null);
      _setLoading(true);
      await FirestoreService.deleteBarang(id);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menghapus barang: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCompleteBarangData(String idBarang) async {
    try {
      return await FirestoreService.getCompleteBarangData(idBarang);
    } catch (e) {
      _setError('Gagal memuat data lengkap barang: $e');
      return null;
    }
  }

  void clearError() {
    _setError(null);
  }
}