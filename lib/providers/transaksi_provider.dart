import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../model/transaksi.dart';
import '../model/detail_transaksi.dart';
import '../services/firestore_service.dart';

class DetailTransaksiForm {
  final String idBarangSatuan;
  final int jumlah;

  DetailTransaksiForm({
    required this.idBarangSatuan,
    required this.jumlah,
  });
}

class TransaksiProvider with ChangeNotifier {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  final List<Transaksi> _transaksi = [];
  List<Transaksi> get transaksi => List.unmodifiable(_transaksi);

  DocumentSnapshot? _lastTransaksiDocument;
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

  Stream<List<Transaksi>> getTransaksi() {
    try {
      return FirestoreService.getTransaksiStream();
    } catch (e) {
      _setError('Gagal memuat data transaksi');
      return Stream.value(<Transaksi>[]);
    }
  }

  Future<void> loadInitialTransaksi({int limit = 20}) async {
    if (_isLoading) return;
    try {
      _setError(null);
      _setLoading(true);
      _transaksi.clear();
      _lastTransaksiDocument = null;
      _hasMore = true;

      final result = await FirestoreService.fetchTransaksiPage(limit: limit);
      _transaksi.addAll(result.items);
      _lastTransaksiDocument = result.lastDocument;
      _hasMore = result.hasMore;
    } on FirebaseException catch (e) {
      _setError('Gagal memuat transaksi: ${e.message}');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreTransaksi({int limit = 20}) async {
    if (_isFetchingMore || !_hasMore || _isLoading) return;
    _isFetchingMore = true;
    notifyListeners();

    try {
      final result = await FirestoreService.fetchTransaksiPage(
        startAfter: _lastTransaksiDocument,
        limit: limit,
      );
      _transaksi.addAll(result.items);
      _lastTransaksiDocument = result.lastDocument;
      _hasMore = result.hasMore;
    } on FirebaseException catch (e) {
      _setError('Gagal memuat transaksi berikutnya: ${e.message}');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga: $e');
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Stream<List<DetailTransaksi>> getDetailTransaksi(String transaksiId) {
    try {
      return FirestoreService.getDetailTransaksiByTransaksiStream(transaksiId);
    } catch (e) {
      _setError('Gagal memuat detail transaksi');
      return Stream.value(<DetailTransaksi>[]);
    }
  }

  Future<String?> createCompleteTransaction({
    required List<DetailTransaksiForm> detailItems,
  }) async {
    try {
      _setError(null);
      _setLoading(true);
      
      String kodeTransaksi = await FirestoreService.generateKodeTransaksi();
      
      List<Map<String, dynamic>> items = detailItems.map((detail) => {
        'idBarangSatuan': detail.idBarangSatuan,
        'jumlah': detail.jumlah,
      }).toList();
      
      String transaksiId = await FirestoreService.createCompleteTransaction(
        kodeTransaksi: kodeTransaksi,
        items: items,
      );
      
      _setLoading(false);
      return transaksiId;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal membuat transaksi: ${e.message}');
      return null;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return null;
    }
  }

  Future<bool> deleteTransaksi(String transaksiId) async {
    try {
      _setError(null);
      _setLoading(true);
      await FirestoreService.deleteTransaksi(transaksiId);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menghapus transaksi: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCompleteTransactionData(String idTransaksi) async {
    try {
      return await FirestoreService.getCompleteTransactionData(idTransaksi);
    } catch (e) {
      _setError('Gagal memuat data lengkap transaksi: $e');
      return null;
    }
  }

  void clearError() {
    _setError(null);
  }
}
