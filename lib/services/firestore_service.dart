import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/kategori.dart';
import '../model/barang.dart';
import '../model/barang_satuan.dart';
import '../model/transaksi.dart';
import '../model/detail_transaksi.dart';

class PaginatedResult<T> {
  PaginatedResult({
    required this.items,
    required this.lastDocument,
  });

  final List<T> items;
  final DocumentSnapshot? lastDocument;

  bool get hasMore => lastDocument != null;
}

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Collection references
  static final CollectionReference _kategoriRef = _db.collection('kategori');
  static final CollectionReference _barangRef = _db.collection('barang');
  static final CollectionReference _barangSatuanRef = _db.collection('barang_satuan');
  static final CollectionReference _transaksiRef = _db.collection('transaksi');
  static final CollectionReference _detailTransaksiRef = _db.collection('detail_transaksi');
  
  // KATEGORI CRUD Operations
  static Future<String> addKategori(Kategori kategori) async {
    DocumentReference docRef = await _kategoriRef.add(kategori.toMap());
    return docRef.id;
  }
  
  static Stream<List<Kategori>> getKategoriStream() {
    return _kategoriRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Kategori.fromSnapshot(doc)).toList();
    });
  }
  
  static Future<Kategori?> getKategoriById(String id) async {
    DocumentSnapshot doc = await _kategoriRef.doc(id).get();
    return doc.exists ? Kategori.fromSnapshot(doc) : null;
  }
  
  static Future<void> updateKategori(Kategori kategori) async {
    await _kategoriRef.doc(kategori.id).update(kategori.toMap());
  }
  
  static Future<void> deleteKategori(String id) async {
    await _kategoriRef.doc(id).delete();
  }
  
  // BARANG CRUD Operations
  static Future<String> addBarang(Barang barang) async {
    DocumentReference docRef = await _barangRef.add(barang.toMap());
    return docRef.id;
  }
  
  static Stream<List<Barang>> getBarangStream() {
    return _barangRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Barang.fromSnapshot(doc)).toList();
    });
  }
  
  static Stream<List<Barang>> getBarangByKategoriStream(String idKategori) {
    return _barangRef.where('id_kategori', isEqualTo: idKategori)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Barang.fromSnapshot(doc)).toList();
    });
  }
  
  static Future<Barang?> getBarangById(String id) async {
    DocumentSnapshot doc = await _barangRef.doc(id).get();
    return doc.exists ? Barang.fromSnapshot(doc) : null;
  }
  
  static Future<void> updateBarang(Barang barang) async {
    await _barangRef.doc(barang.id).update(barang.toMap());
  }
  
  static Future<void> deleteBarang(String id) async {
    // Also delete all related barang_satuan
    QuerySnapshot satuanSnapshot = await _barangSatuanRef
        .where('id_barang', isEqualTo: id).get();
    
    WriteBatch batch = _db.batch();
    for (QueryDocumentSnapshot doc in satuanSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_barangRef.doc(id));
    await batch.commit();
  }
  
  // BARANG SATUAN CRUD Operations
  static Future<String> addBarangSatuan(BarangSatuan barangSatuan) async {
    DocumentReference docRef = await _barangSatuanRef.add(barangSatuan.toMap());
    return docRef.id;
  }
  
  static Stream<List<BarangSatuan>> getBarangSatuanStream() {
    return _barangSatuanRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BarangSatuan.fromSnapshot(doc)).toList();
    });
  }
  
  static Stream<List<BarangSatuan>> getBarangSatuanByBarangStream(String idBarang) {
    return _barangSatuanRef.where('id_barang', isEqualTo: idBarang)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BarangSatuan.fromSnapshot(doc)).toList();
    });
  }
  
  static Future<BarangSatuan?> getBarangSatuanById(String id) async {
    DocumentSnapshot doc = await _barangSatuanRef.doc(id).get();
    return doc.exists ? BarangSatuan.fromSnapshot(doc) : null;
  }
  
  static Future<void> updateBarangSatuan(BarangSatuan barangSatuan) async {
    await _barangSatuanRef.doc(barangSatuan.id).update(barangSatuan.toMap());
  }
  
  static Future<void> deleteBarangSatuan(String id) async {
    await _barangSatuanRef.doc(id).delete();
  }

  // Update stok satuan when transaction occurs
  static Future<void> updateStokSatuan(String idBarangSatuan, int newStok) async {
    await _barangSatuanRef.doc(idBarangSatuan).update({'stok_satuan': newStok});
  }

  static Future<PaginatedResult<Barang>> fetchBarangPage({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _barangRef.orderBy('nama_barang').limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    QuerySnapshot snapshot = await query.get();
    final items = snapshot.docs.map((doc) => Barang.fromSnapshot(doc)).toList();
    final DocumentSnapshot? lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return PaginatedResult<Barang>(
      items: items,
      lastDocument: lastDocument,
    );
  }
  
  // TRANSAKSI CRUD Operations
  static Future<String> addTransaksi(Transaksi transaksi) async {
    DocumentReference docRef = await _transaksiRef.add(transaksi.toMap());
    return docRef.id;
  }
  
  static Stream<List<Transaksi>> getTransaksiStream() {
    return _transaksiRef.orderBy('tanggal_transaksi', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Transaksi.fromSnapshot(doc)).toList();
    });
  }
  
  static Future<Transaksi?> getTransaksiById(String id) async {
    DocumentSnapshot doc = await _transaksiRef.doc(id).get();
    return doc.exists ? Transaksi.fromSnapshot(doc) : null;
  }
  
  static Future<void> updateTransaksi(Transaksi transaksi) async {
    await _transaksiRef.doc(transaksi.id).update(transaksi.toMap());
  }
  
  static Future<void> deleteTransaksi(String id) async {
    // Also delete all related detail_transaksi
    QuerySnapshot detailSnapshot = await _detailTransaksiRef
        .where('id_transaksi', isEqualTo: id).get();
    
    WriteBatch batch = _db.batch();
    for (QueryDocumentSnapshot doc in detailSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_transaksiRef.doc(id));
    await batch.commit();
  }
  
  // DETAIL TRANSAKSI CRUD Operations
  static Future<String> addDetailTransaksi(DetailTransaksi detailTransaksi) async {
    DocumentReference docRef = await _detailTransaksiRef.add(detailTransaksi.toMap());
    return docRef.id;
  }
  
  static Stream<List<DetailTransaksi>> getDetailTransaksiByTransaksiStream(String idTransaksi) {
    return _detailTransaksiRef.where('id_transaksi', isEqualTo: idTransaksi)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DetailTransaksi.fromSnapshot(doc)).toList();
    });
  }
  
  static Future<List<DetailTransaksi>> getDetailTransaksiByTransaksi(String idTransaksi) async {
    QuerySnapshot snapshot = await _detailTransaksiRef
        .where('id_transaksi', isEqualTo: idTransaksi).get();
    return snapshot.docs.map((doc) => DetailTransaksi.fromSnapshot(doc)).toList();
  }
  
  static Future<void> updateDetailTransaksi(DetailTransaksi detailTransaksi) async {
    await _detailTransaksiRef.doc(detailTransaksi.id).update(detailTransaksi.toMap());
  }
  
  static Future<void> deleteDetailTransaksi(String id) async {
    await _detailTransaksiRef.doc(id).delete();
  }

  static Future<PaginatedResult<Transaksi>> fetchTransaksiPage({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _transaksiRef.orderBy('tanggal_transaksi', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    QuerySnapshot snapshot = await query.get();
    final items = snapshot.docs.map((doc) => Transaksi.fromSnapshot(doc)).toList();
    final DocumentSnapshot? lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return PaginatedResult<Transaksi>(
      items: items,
      lastDocument: lastDocument,
    );
  }
  
  // COMPLEX OPERATIONS
  
  // Create complete transaction with multiple items
  static Future<String> createCompleteTransaction({
    required String kodeTransaksi,
    required List<Map<String, dynamic>> items, // [{idBarangSatuan, jumlah}, ...]
  }) async {
    WriteBatch batch = _db.batch();
    double totalHarga = 0;
    
    // Create transaction document
    DocumentReference transaksiRef = _transaksiRef.doc();
    Transaksi transaksi = Transaksi(
      id: transaksiRef.id,
      kodeTransaksi: kodeTransaksi,
      tanggalTransaksi: DateTime.now(),
      totalHarga: 0, // Will be calculated
    );
    
    // Calculate total and prepare detail transactions
    for (Map<String, dynamic> item in items) {
      String idBarangSatuan = item['idBarangSatuan'];
      int jumlah = item['jumlah'];
      
      // Get barang satuan to calculate price and update stock
      BarangSatuan? barangSatuan = await getBarangSatuanById(idBarangSatuan);
      if (barangSatuan != null) {
        double subtotal = barangSatuan.hargaJual * jumlah;
        totalHarga += subtotal;
        
        // Create detail transaksi
        DocumentReference detailRef = _detailTransaksiRef.doc();
        DetailTransaksi detail = DetailTransaksi(
          id: detailRef.id,
          idTransaksi: transaksiRef.id,
          idBarangSatuan: idBarangSatuan,
          jumlah: jumlah,
        );
        batch.set(detailRef, detail.toMap());
        
        // Update stock
        int newStok = barangSatuan.stokSatuan - jumlah;
        batch.update(_barangSatuanRef.doc(idBarangSatuan), {'stok_satuan': newStok});
      }
    }
    
    // Update transaction with calculated total
    transaksi = Transaksi(
      id: transaksi.id,
      kodeTransaksi: transaksi.kodeTransaksi,
      tanggalTransaksi: transaksi.tanggalTransaksi,
      totalHarga: totalHarga,
    );
    batch.set(transaksiRef, transaksi.toMap());
    
    await batch.commit();
    return transaksiRef.id;
  }
  
  // Get complete transaction data with joined information
  static Future<Map<String, dynamic>> getCompleteTransactionData(String idTransaksi) async {
    Transaksi? transaksi = await getTransaksiById(idTransaksi);
    if (transaksi == null) return {};
    
    List<DetailTransaksi> details = await getDetailTransaksiByTransaksi(idTransaksi);
    List<Map<String, dynamic>> detailsWithItems = [];
    
    for (DetailTransaksi detail in details) {
      BarangSatuan? barangSatuan = await getBarangSatuanById(detail.idBarangSatuan);
      if (barangSatuan != null) {
        Barang? barang = await getBarangById(barangSatuan.idBarang);
        if (barang != null) {
          Kategori? kategori = await getKategoriById(barang.idKategori);
          
          detailsWithItems.add({
            'detail': detail,
            'barangSatuan': barangSatuan,
            'barang': barang,
            'kategori': kategori,
            'subtotal': barangSatuan.hargaJual * detail.jumlah,
          });
        }
      }
    }
    
    return {
      'transaksi': transaksi,
      'details': detailsWithItems,
    };
  }
  
  // Get product with all variants (satuan)
  static Future<Map<String, dynamic>> getCompleteBarangData(String idBarang) async {
    Barang? barang = await getBarangById(idBarang);
    if (barang == null) return {};
    
    Kategori? kategori = await getKategoriById(barang.idKategori);
    
    QuerySnapshot satuanSnapshot = await _barangSatuanRef
        .where('id_barang', isEqualTo: idBarang).get();
    List<BarangSatuan> satuanList = satuanSnapshot.docs
        .map((doc) => BarangSatuan.fromSnapshot(doc)).toList();
    
    return {
      'barang': barang,
      'kategori': kategori,
      'satuan_list': satuanList,
    };
  }
  
  // Generate automatic codes
  static Future<String> generateKodeTransaksi() async {
    String today = DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '');
    QuerySnapshot snapshot = await _transaksiRef
        .where('kode_transaksi', isGreaterThanOrEqualTo: 'TRX$today')
        .where('kode_transaksi', isLessThan: 'TRX${today}Z')
        .get();
    
    int count = snapshot.docs.length + 1;
    return 'TRX$today${count.toString().padLeft(3, '0')}';
  }
  
  static Future<String> generateKodeBarang(String idKategori) async {
    Kategori? kategori = await getKategoriById(idKategori);
    if (kategori == null) return 'BRG001';
    
    String prefix = kategori.namaKategori.substring(0, 3).toUpperCase();
    QuerySnapshot snapshot = await _barangRef
        .where('id_kategori', isEqualTo: idKategori).get();
    
    int count = snapshot.docs.length + 1;
    return '$prefix${count.toString().padLeft(3, '0')}';
  }
}
