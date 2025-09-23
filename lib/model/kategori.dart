import 'package:cloud_firestore/cloud_firestore.dart';

class Kategori {
  final String id;
  final String namaKategori;

  Kategori({required this.id, required this.namaKategori});

  factory Kategori.fromSnapshot(DocumentSnapshot snapshot) {
    return Kategori(
      id: snapshot.id,
      namaKategori: snapshot['nama_kategori'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'nama_kategori': namaKategori};
  }
}