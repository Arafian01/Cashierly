import 'package:cloud_firestore/cloud_firestore.dart';

class DetailTransaksi {
  final String id;
  final DocumentReference idTransaksi;
  final DocumentReference idBarang;
  final int jumlah;
  final double subTotal;

  DetailTransaksi({
    required this.id,
    required this.idTransaksi,
    required this.idBarang,
    required this.jumlah,
    required this.subTotal,
  });

  factory DetailTransaksi.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return DetailTransaksi(
      id: snapshot.id,
      idTransaksi: data['id_transaksi'] as DocumentReference,
      idBarang: data['id_barang'] as DocumentReference,
      jumlah: (data['jumlah'] ?? 0) as int,
      subTotal: (data['sub_total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaksi': idTransaksi,
      'id_barang': idBarang,
      'jumlah': jumlah,
      'sub_total': subTotal,
    };
  }
}
