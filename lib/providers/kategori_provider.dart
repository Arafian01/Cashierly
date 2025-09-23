import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/kategori.dart';

class KategoriProvider with ChangeNotifier {
  final CollectionReference _kategoriRef = FirebaseFirestore.instance.collection('kategori');

  Stream<List<Kategori>> getKategori() {
    return _kategoriRef.snapshots().map((snapshot) => snapshot.docs.map((doc) => Kategori.fromSnapshot(doc)).toList());
  }

  Future<void> addKategori(Kategori kategori) async {
    await _kategoriRef.add(kategori.toMap());
    notifyListeners();
  }

  Future<void> updateKategori(Kategori kategori) async {
    await _kategoriRef.doc(kategori.id).update(kategori.toMap());
    notifyListeners();
  }

  Future<void> deleteKategori(String id) async {
    await _kategoriRef.doc(id).delete();
    notifyListeners();
  }
}