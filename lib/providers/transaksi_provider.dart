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
