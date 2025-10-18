import 'package:cloud_firestore/cloud_firestore.dart';

class Barang {
  final String id;
  final String namaBarang;
  final double harga;
  final int stok;
  final String kategori;
  final DateTime tanggalInput;
  final String uid; // User ID untuk data per user

  Barang({
    required this.id,
    required this.namaBarang,
    required this.harga,
    required this.stok,
    required this.kategori,
    required this.tanggalInput,
    required this.uid,
  });

  factory Barang.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Barang(
      id: snapshot.id,
      namaBarang: data['nama_barang'] ?? '',
      harga: (data['harga'] ?? 0).toDouble(),
      stok: (data['stok'] ?? 0) as int,
      kategori: data['kategori'] ?? '',
      tanggalInput: (data['tanggal_input'] as Timestamp?)?.toDate() ?? DateTime.now(),
      uid: data['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_barang': namaBarang,
      'harga': harga,
      'stok': stok,
      'kategori': kategori,
      'tanggal_input': Timestamp.fromDate(tanggalInput),
      'uid': uid,
    };
  }

  // Method to check if stock is low
  bool get isLowStock => stok < 5;
  
  // Method to get stock warning message
  String get stockWarningMessage => 'Stok hampir habis! Tersisa $stok unit';
}