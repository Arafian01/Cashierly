import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/barang.dart';

class BarangProvider with ChangeNotifier {
  final CollectionReference _barangRef = FirebaseFirestore.instance.collection('barang');
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
    return _barangRef.snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          return Barang.fromSnapshot(doc);
        }).toList();
      } catch (e) {
        _setError('Gagal memuat data barang');
        return <Barang>[];
      }
    });
  }

  Future<bool> addBarang(Barang barang) async {
    try {
      _setError(null);
      _setLoading(true);
      await _barangRef.add(barang.toMap());
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menambah barang: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  Future<bool> updateBarang(Barang barang) async {
    try {
      _setError(null);
      _setLoading(true);
      await _barangRef.doc(barang.id).update(barang.toMap());
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal memperbarui barang: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  Future<bool> deleteBarang(String id) async {
    try {
      _setError(null);
      _setLoading(true);
      await _barangRef.doc(id).delete();
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setLoading(false);
      _setError('Gagal menghapus barang: ${e.message}');
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