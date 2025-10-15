import 'package:cloud_firestore/cloud_firestore.dart';

class Transaksi {
  final String id;
  final String kodeTransaksi;
  final DateTime tanggalTransaksi;
  final double totalHarga;

  Transaksi({
    required this.id,
    required this.kodeTransaksi,
    required this.tanggalTransaksi,
    required this.totalHarga,
  });

  factory Transaksi.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Transaksi(
      id: snapshot.id,
      kodeTransaksi: data['kode_transaksi'] ?? '',
      tanggalTransaksi: (data['tanggal_transaksi'] as Timestamp).toDate(),
      totalHarga: (data['total_harga'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kode_transaksi': kodeTransaksi,
      'tanggal_transaksi': Timestamp.fromDate(tanggalTransaksi),
      'total_harga': totalHarga,
    };
  }
}
