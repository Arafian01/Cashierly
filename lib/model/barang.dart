import 'package:cloud_firestore/cloud_firestore.dart';

class Barang {
  final String id;
  final String idKategori; // Document ID dari koleksi kategori
  final String kodeBarang;
  final String namaBarang;
  final int stokTotal;

  Barang({
    required this.id,
    required this.idKategori,
    required this.kodeBarang,
    required this.namaBarang,
    required this.stokTotal,
  });

  factory Barang.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Barang(
      id: snapshot.id,
      idKategori: data['id_kategori'] ?? '',
      kodeBarang: data['kode_barang'] ?? '',
      namaBarang: data['nama_barang'] ?? '',
      stokTotal: (data['stok_total'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_kategori': idKategori,
      'kode_barang': kodeBarang,
      'nama_barang': namaBarang,
      'stok_total': stokTotal,
    };
  }
}