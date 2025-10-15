import 'package:cloud_firestore/cloud_firestore.dart';

class DetailTransaksi {
  final String id;
  final String idTransaksi; // Document ID dari koleksi transaksi
  final String idBarangSatuan; // Document ID dari koleksi barang_satuan
  final int jumlah;

  DetailTransaksi({
    required this.id,
    required this.idTransaksi,
    required this.idBarangSatuan,
    required this.jumlah,
  });

  factory DetailTransaksi.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return DetailTransaksi(
      id: snapshot.id,
      idTransaksi: data['id_transaksi'] ?? '',
      idBarangSatuan: data['id_barang_satuan'] ?? '',
      jumlah: (data['jumlah'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaksi': idTransaksi,
      'id_barang_satuan': idBarangSatuan,
      'jumlah': jumlah,
    };
  }
}
