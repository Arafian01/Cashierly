import 'package:cloud_firestore/cloud_firestore.dart';

class Kategori {
  final String id;
  final String namaKategori;
  final String? deskripsi;

  Kategori({
    required this.id, 
    required this.namaKategori,
    this.deskripsi,
  });

  factory Kategori.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Kategori(
      id: snapshot.id,
      namaKategori: data['nama_kategori'] ?? '',
      deskripsi: data['deskripsi'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_kategori': namaKategori,
      'deskripsi': deskripsi,
    };
  }
}