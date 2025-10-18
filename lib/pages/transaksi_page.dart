import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/app_theme.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _cart = [];
  double _totalHarga = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textLight,
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textLight.withValues(alpha: 0.7),
          tabs: const [
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: 'Keranjang',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Riwayat',
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCartTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildCartTab() {
    return Column(
      children: [
        // Add Items Section
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: AppShadows.light,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Barang ke Keranjang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add),
                label: const Text('Pilih Barang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
        
        // Cart Items
        Expanded(
          child: _cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 100,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Keranjang kosong',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tambahkan barang untuk memulai transaksi',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _cart.length,
                  itemBuilder: (context, index) {
                    final item = _cart[index];
                    return _CartItemCard(
                      item: item,
                      onQuantityChanged: (newQuantity) {
                        setState(() {
                          if (newQuantity <= 0) {
                            _cart.removeAt(index);
                          } else {
                            _cart[index]['jumlah'] = newQuantity;
                            _cart[index]['subtotal'] = 
                                _cart[index]['harga'] * newQuantity;
                          }
                          _calculateTotal();
                        });
                      },
                      onRemove: () {
                        setState(() {
                          _cart.removeAt(index);
                          _calculateTotal();
                        });
                      },
                    );
                  },
                ),
        ),
        
        // Total and Checkout
        if (_cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: AppShadows.medium,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(_totalHarga),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: _processTransaction,
                  icon: const Icon(Icons.payment),
                  label: const Text('Proses Transaksi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textLight,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transaksi')
          .orderBy('tanggal_transaksi', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 100,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Belum ada transaksi',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _TransactionCard(
              transactionId: doc.id,
              data: data,
            );
          },
        );
      },
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onItemSelected: (item) {
          setState(() {
            // Check if item already exists in cart
            int existingIndex = _cart.indexWhere(
              (cartItem) => cartItem['id'] == item['id']
            );
            
            if (existingIndex != -1) {
              // Increase quantity
              _cart[existingIndex]['jumlah']++;
              _cart[existingIndex]['subtotal'] = 
                  _cart[existingIndex]['harga'] * _cart[existingIndex]['jumlah'];
            } else {
              // Add new item
              _cart.add({
                'id': item['id'],
                'nama': item['nama'],
                'harga': item['harga'],
                'stok': item['stok'],
                'jumlah': 1,
                'subtotal': item['harga'],
              });
            }
            _calculateTotal();
          });
        },
      ),
    );
  }

  void _calculateTotal() {
    _totalHarga = _cart.fold(0, (sum, item) => sum + item['subtotal']);
  }

  void _processTransaction() async {
    if (_cart.isEmpty) return;

    try {
      // Check stock availability
      for (var item in _cart) {
        DocumentSnapshot barangDoc = await FirebaseFirestore.instance
            .collection('barang')
            .doc(item['id'])
            .get();
        
        if (!barangDoc.exists) {
          throw Exception('Barang ${item['nama']} tidak ditemukan');
        }
        
        final data = barangDoc.data() as Map<String, dynamic>?;
        int currentStock = data?['stok'] ?? 0;
        if (currentStock < item['jumlah']) {
          throw Exception('Stok ${item['nama']} tidak mencukupi');
        }
      }

      // Create transaction
      await FirebaseFirestore.instance.collection('transaksi').add({
        'items': _cart,
        'total_harga': _totalHarga,
        'tanggal_transaksi': FieldValue.serverTimestamp(),
        'status': 'selesai',
      });

      // Update stock
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var item in _cart) {
        DocumentReference barangRef = FirebaseFirestore.instance
            .collection('barang')
            .doc(item['id']);
        
        batch.update(barangRef, {
          'stok': FieldValue.increment(-item['jumlah']),
        });
      }
      await batch.commit();

      // Clear cart
      setState(() {
        _cart.clear();
        _totalHarga = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaksi berhasil diproses'),
          backgroundColor: AppColors.success,
        ),
      );

      // Switch to history tab
      _tabController.animateTo(1);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses transaksi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(item['harga']),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Subtotal: ${NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(item['subtotal'])}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            Row(
              children: [
                IconButton(
                  onPressed: () => onQuantityChanged(item['jumlah'] - 1),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.error,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '${item['jumlah']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (item['jumlah'] < item['stok']) {
                      onQuantityChanged(item['jumlah'] + 1);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Stok tidak mencukupi'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.success,
                ),
              ],
            ),
            
            // Remove Button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String transactionId;
  final Map<String, dynamic> data;

  const _TransactionCard({
    required this.transactionId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final tanggal = (data['tanggal_transaksi'] as Timestamp?)?.toDate() ?? DateTime.now();
    final items = data['items'] as List<dynamic>? ?? [];
    final totalHarga = data['total_harga'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.receipt,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaksi #${transactionId.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(tanggal),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(totalHarga),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Barang:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item['nama']} x${item['jumlah']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(item['subtotal']),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onItemSelected;

  const _AddItemDialog({required this.onItemSelected});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              'Pilih Barang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Items List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('barang')
                    .where('stok', isGreaterThan: 0)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada barang tersedia'),
                    );
                  }

                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nama = (data['nama'] ?? '').toString().toLowerCase();
                    return _searchQuery.isEmpty || nama.contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      return ListTile(
                        title: Text(data['nama'] ?? ''),
                        subtitle: Text(
                          '${NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(data['harga'] ?? 0)} • Stok: ${data['stok']}',
                        ),
                        onTap: () {
                          widget.onItemSelected({
                            'id': doc.id,
                            'nama': data['nama'],
                            'harga': (data['harga'] ?? 0).toDouble(),
                            'stok': data['stok'] ?? 0,
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            
            // Close Button
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grey400,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }
}
