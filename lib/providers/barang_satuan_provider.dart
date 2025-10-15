import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/barang_satuan.dart';
import '../services/firestore_service.dart';

class BarangSatuanProvider with ChangeNotifier {
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

  Stream<List<BarangSatuan>> getBarangSatuan() {
    try {
      return FirestoreService.getBarangSatuanStream();
    } catch (e) {
      _setError('Gagal memuat data barang satuan');
      return Stream.value(<BarangSatuan>[]);
    }
  }

  Stream<List<BarangSatuan>> getBarangSatuanByBarang(String idBarang) {
    try {
      return FirestoreService.getBarangSatuanByBarangStream(idBarang);
    } catch (e) {
      _setError('Gagal memuat data barang satuan berdasarkan barang');
      return Stream.value(<BarangSatuan>[]);
    }
  }

  Future<bool> addBarangSatuan({
    required String idBarang,
    required String namaSatuan,
    required double hargaJual,
    required int stokSatuan,
  }) async {
    try {
      _setError(null);
      _setLoading(true);
      
      BarangSatuan barangSatuan = BarangSatuan(
        id: '',
        idBarang: idBarang,
        namaSatuan: namaSatuan,
        hargaJual: hargaJual,
        stokSatuan: stokSatuan,
      );
      
      await FirestoreService.addBarangSatuan(barangSatuan);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menambah barang satuan: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  Future<bool> updateBarangSatuan(BarangSatuan barangSatuan) async {
    try {
      _setError(null);
      _setLoading(true);
      await FirestoreService.updateBarangSatuan(barangSatuan);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal memperbarui barang satuan: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  Future<bool> deleteBarangSatuan(String id) async {
    try {
      _setError(null);
      _setLoading(true);
      await FirestoreService.deleteBarangSatuan(id);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menghapus barang satuan: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga: $e');
      return false;
    }
  }

  Future<bool> updateStokSatuan(String idBarangSatuan, int newStok) async {
    try {
      _setError(null);
      _setLoading(true);
      await FirestoreService.updateStokSatuan(idBarangSatuan, newStok);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal memperbarui stok: ${e.message}');
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
