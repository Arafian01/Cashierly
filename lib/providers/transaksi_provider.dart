import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../model/transaksi.dart';
import '../model/detail_transaksi.dart';

class DetailTransaksiForm {
  final DocumentReference idBarang;
  final int jumlah;
  final double subTotal;

  DetailTransaksiForm({
    required this.idBarang,
    required this.jumlah,
    required this.subTotal,
  });

  Map<String, dynamic> toMap({required DocumentReference transaksiRef}) {
    return {
      'id_transaksi': transaksiRef,
      'id_barang': idBarang,
      'jumlah': jumlah,
      'sub_total': subTotal,
    };
  }
}

class TransaksiProvider with ChangeNotifier {
  final CollectionReference _transaksiRef = FirebaseFirestore.instance.collection('transaksi');
  final CollectionReference _detailRef = FirebaseFirestore.instance.collection('detail_transaksi');
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Stream<List<Transaksi>> getTransaksi({Source source = Source.serverAndCache}) {
    return _transaksiRef
        .orderBy('tanggal', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Transaksi.fromSnapshot(doc)).toList();
      } catch (e) {
        debugPrint('Error loading transaksi: $e');
        _setError('Gagal memuat data transaksi: ${e.toString()}');
        return <Transaksi>[];
      }
    }).handleError((error) {
      debugPrint('Stream error in getTransaksi: $error');
      _setError('Koneksi database bermasalah');
      return <Transaksi>[];
    });
  }

  Stream<List<DetailTransaksi>> getDetailTransaksi(String transaksiId) {
    final transaksiRef = _transaksiRef.doc(transaksiId);
    return _detailRef
        .where('id_transaksi', isEqualTo: transaksiRef)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => DetailTransaksi.fromSnapshot(doc)).toList();
      } catch (e) {
        debugPrint('Error loading detail transaksi: $e');
        _setError('Gagal memuat detail transaksi: ${e.toString()}');
        return <DetailTransaksi>[];
      }
    }).handleError((error) {
      debugPrint('Stream error in getDetailTransaksi: $error');
      _setError('Koneksi database bermasalah');
      return <DetailTransaksi>[];
    });
  }

  Future<DocumentReference> createTransaksiWithDetails({
    required Transaksi transaksi,
    required List<DetailTransaksiForm> detailItems,
  }) async {
    final docRef = await _transaksiRef.add(transaksi.toMap());
    for (final detail in detailItems) {
      await _detailRef.add(detail.toMap(transaksiRef: docRef));
    }
    notifyListeners();
    return docRef;
  }

  Future<void> addDetailToTransaksi(String transaksiId, DetailTransaksiForm detail) async {
    final transaksiRef = _transaksiRef.doc(transaksiId);
    final transaksiSnapshot = await transaksiRef.get();
    if (!transaksiSnapshot.exists) return;
    final currentData = transaksiSnapshot.data() as Map<String, dynamic>;
    final currentTotal = (currentData['total'] ?? 0).toDouble();
    final currentBayar = (currentData['bayar'] ?? 0).toDouble();
    final currentStatus = (currentData['status'] ?? 'Belum Lunas') as String;

    await _detailRef.add(detail.toMap(transaksiRef: transaksiRef));

    final newTotal = currentTotal + detail.subTotal;
    final newSisa = (newTotal - currentBayar).clamp(0, double.infinity);

    await transaksiRef.update({
      'total': newTotal,
      'sisa': currentStatus.toLowerCase() == 'lunas' ? 0 : newSisa,
    });
    notifyListeners();
  }

  Future<void> deleteDetail(String detailId) async {
    final detailDoc = _detailRef.doc(detailId);
    final snapshot = await detailDoc.get();
    if (!snapshot.exists) return;
    final data = snapshot.data() as Map<String, dynamic>;
    final transaksiRef = data['id_transaksi'] as DocumentReference<Object?>;
    final subTotal = (data['sub_total'] ?? 0).toDouble();

    await detailDoc.delete();

    final transaksiSnapshot = await transaksiRef.get();
    if (transaksiSnapshot.exists) {
      final transaksiData = transaksiSnapshot.data() as Map<String, dynamic>;
      final currentTotal = (transaksiData['total'] ?? 0).toDouble();
      final currentBayar = (transaksiData['bayar'] ?? 0).toDouble();
      final currentStatus = (transaksiData['status'] ?? 'Belum Lunas') as String;

      final updatedTotal = (currentTotal - subTotal).clamp(0, double.infinity);
      final updatedSisa = (updatedTotal - currentBayar).clamp(0, double.infinity);

      await transaksiRef.update({
        'total': updatedTotal,
        'sisa': currentStatus.toLowerCase() == 'lunas' ? 0 : updatedSisa,
      });
    }
    notifyListeners();
  }

  Future<void> updateStatus({
    required String transaksiId,
    required String status,
    double? bayar,
    double? sisa,
    DateTime? tanggalBayar,
  }) async {
    final data = <String, dynamic>{
      'status': status,
    };
    if (bayar != null) data['bayar'] = bayar;
    if (sisa != null) data['sisa'] = sisa;
    if (tanggalBayar != null) {
      data['tanggal_bayar'] = Timestamp.fromDate(tanggalBayar);
    }
    await _transaksiRef.doc(transaksiId).update(data);
    notifyListeners();
  }

  Future<void> deleteTransaksi(String transaksiId) async {
    final transaksiRef = _transaksiRef.doc(transaksiId);
    final detailSnapshot = await _detailRef.where('id_transaksi', isEqualTo: transaksiRef).get();
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in detailSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(transaksiRef);

    await batch.commit();
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
