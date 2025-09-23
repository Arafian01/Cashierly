import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/barang.dart';

class BarangProvider with ChangeNotifier {
  final CollectionReference _barangRef = FirebaseFirestore.instance.collection('barang');

  Stream<List<Barang>> getBarang() {
    return _barangRef.snapshots().map((snapshot) {
      print("Snapshot data: ${snapshot.docs.length} documents");
      return snapshot.docs.map((doc) {
        print("Document ID: ${doc.id}, Data: ${doc.data()}");
        return Barang.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<void> addBarang(Barang barang) async {
    await _barangRef.add(barang.toMap());
    notifyListeners();
  }

  Future<void> updateBarang(Barang barang) async {
    await _barangRef.doc(barang.id).update(barang.toMap());
    notifyListeners();
  }

  Future<void> deleteBarang(String id) async {
    await _barangRef.doc(id).delete();
    notifyListeners();
  }
}