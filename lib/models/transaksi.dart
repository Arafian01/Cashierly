import 'package:cloud_firestore/cloud_firestore.dart';

enum MetodePembayaran { tunai, transfer, kartu }

class Transaksi {
  final String id;
  final List<ItemTransaksi> daftarBarang;
  final double total;
  final MetodePembayaran metodePembayaran;
  final DateTime tanggal;
  final String kasir;
  final String uid; // User ID untuk data per user

  Transaksi({
    required this.id,
    required this.daftarBarang,
    required this.total,
    required this.metodePembayaran,
    required this.tanggal,
    required this.kasir,
    required this.uid,
  });

  factory Transaksi.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    
    List<ItemTransaksi> items = [];
    if (data['daftar_barang'] != null) {
      items = (data['daftar_barang'] as List)
          .map((item) => ItemTransaksi.fromMap(item))
          .toList();
    }

    return Transaksi(
      id: snapshot.id,
      daftarBarang: items,
      total: (data['total'] ?? 0).toDouble(),
      metodePembayaran: _parseMetodePembayaran(data['metode_pembayaran']),
      tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      kasir: data['kasir'] ?? '',
      uid: data['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'daftar_barang': daftarBarang.map((item) => item.toMap()).toList(),
      'total': total,
      'metode_pembayaran': _metodePembayaranToString(metodePembayaran),
      'tanggal': Timestamp.fromDate(tanggal),
      'kasir': kasir,
      'uid': uid,
    };
  }

  static MetodePembayaran _parseMetodePembayaran(String? metode) {
    switch (metode) {
      case 'transfer':
        return MetodePembayaran.transfer;
      case 'kartu':
        return MetodePembayaran.kartu;
      default:
        return MetodePembayaran.tunai;
    }
  }

  static String _metodePembayaranToString(MetodePembayaran metode) {
    switch (metode) {
      case MetodePembayaran.transfer:
        return 'transfer';
      case MetodePembayaran.kartu:
        return 'kartu';
      case MetodePembayaran.tunai:
        return 'tunai';
    }
  }
}

class ItemTransaksi {
  final String namaBarang;
  final double harga;
  final int jumlah;
  final double subtotal;

  ItemTransaksi({
    required this.namaBarang,
    required this.harga,
    required this.jumlah,
    required this.subtotal,
  });

  factory ItemTransaksi.fromMap(Map<String, dynamic> map) {
    return ItemTransaksi(
      namaBarang: map['nama_barang'] ?? '',
      harga: (map['harga'] ?? 0).toDouble(),
      jumlah: map['jumlah'] ?? 0,
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_barang': namaBarang,
      'harga': harga,
      'jumlah': jumlah,
      'subtotal': subtotal,
    };
  }
}
