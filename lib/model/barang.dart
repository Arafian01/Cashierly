import 'package:cloud_firestore/cloud_firestore.dart';

class Barang {
  final String id;
  final String namaBarang;
  final double harga;
  final int stok;
  final DocumentReference idKategori;

  Barang({required this.id, required this.namaBarang, required this.harga, required this.stok, required this.idKategori});

  factory Barang.fromSnapshot(DocumentSnapshot snapshot) {
    print("Parsing: ${snapshot.data()}"); // Debug log
    return Barang(
      id: snapshot.id,
      namaBarang: snapshot['nama_barang'],
      harga: (snapshot['harga'] ?? 0.0) as double, // Handle null
      stok: (snapshot['stok'] ?? 0) as int,       // Handle null
      idKategori: snapshot['id_kategori'] as DocumentReference,
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