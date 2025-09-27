import 'package:cloud_firestore/cloud_firestore.dart';

class Barang {
  final String id;
  final String namaBarang;
  final double harga;
  final int stok;
  final DocumentReference idKategori;

  Barang({required this.id, required this.namaBarang, required this.harga, required this.stok, required this.idKategori});

  factory Barang.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final harga = (data['harga'] ?? 0) as num;
    final stok = (data['stok'] ?? 0) as num;

    return Barang(
      id: snapshot.id,
      namaBarang: data['nama_barang'] ?? '',
      harga: harga.toDouble(),
      stok: stok.toInt(),
      idKategori: data['id_kategori'] as DocumentReference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_barang': namaBarang,
      'harga': harga,
      'stok': stok,
      'id_kategori': idKategori,
    };
  }
}