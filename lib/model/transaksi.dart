import 'package:cloud_firestore/cloud_firestore.dart';

class Transaksi {
  final String id;
  final String nama;
  final DateTime tanggal;
  final double total;
  final double bayar;
  final double sisa;
  final String status;
  final DateTime? tanggalBayar;
  final String? keterangan;

  Transaksi({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.total,
    required this.bayar,
    required this.sisa,
    required this.status,
    this.tanggalBayar,
    this.keterangan,
  });

  factory Transaksi.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Transaksi(
      id: snapshot.id,
      nama: data['nama'] ?? '',
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      total: (data['total'] ?? 0).toDouble(),
      bayar: (data['bayar'] ?? 0).toDouble(),
      sisa: (data['sisa'] ?? 0).toDouble(),
      status: data['status'] ?? 'Belum Lunas',
      tanggalBayar: data['tanggal_bayar'] != null ? (data['tanggal_bayar'] as Timestamp).toDate() : null,
      keterangan: data['keterangan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'tanggal': Timestamp.fromDate(tanggal),
      'total': total,
      'bayar': bayar,
      'sisa': sisa,
      'status': status,
      'tanggal_bayar': tanggalBayar != null ? Timestamp.fromDate(tanggalBayar!) : null,
      'keterangan': keterangan,
    };
  }

  Transaksi copyWith({
    String? id,
    String? nama,
    DateTime? tanggal,
    double? total,
    double? bayar,
    double? sisa,
    String? status,
    DateTime? tanggalBayar,
    String? keterangan,
  }) {
    return Transaksi(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tanggal: tanggal ?? this.tanggal,
      total: total ?? this.total,
      bayar: bayar ?? this.bayar,
      sisa: sisa ?? this.sisa,
      status: status ?? this.status,
      tanggalBayar: tanggalBayar ?? this.tanggalBayar,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
