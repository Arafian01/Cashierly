import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/barang.dart';
import '../services/firestore_service.dart';

class BarangProvider with ChangeNotifier {
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

  Stream<List<Barang>> getBarang() {
    try {
      return FirestoreService.getBarangStream();
    } catch (e) {
      _setError('Gagal memuat data barang');
      return Stream.value(<Barang>[]);
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