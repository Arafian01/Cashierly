import 'package:cloud_firestore/cloud_firestore.dart';

class BarangSatuan {
  final String id;
  final String idBarang; // Document ID dari koleksi barang
  final String namaSatuan;
  final double hargaJual;
  final int stokSatuan;

  BarangSatuan({
    required this.id,
    required this.idBarang,
    required this.namaSatuan,
    required this.hargaJual,
    required this.stokSatuan,
  });

  factory BarangSatuan.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BarangSatuan(
      id: snapshot.id,
      idBarang: data['id_barang'] ?? '',
      namaSatuan: data['nama_satuan'] ?? '',
      hargaJual: (data['harga_jual'] ?? 0).toDouble(),
      stokSatuan: (data['stok_satuan'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_barang': idBarang,
      'nama_satuan': namaSatuan,
      'harga_jual': hargaJual,
      'stok_satuan': stokSatuan,
    };
  }
}
