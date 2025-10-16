import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../model/barang.dart';
import '../model/barang_satuan.dart';
import '../model/kategori.dart';
import '../providers/barang_provider.dart';
import '../providers/kategori_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/search_header.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<CartItem> _cartItems = [];
  bool _isProcessing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Barang> _filterBarang(List<Barang> barangList) {
    if (_searchQuery.isEmpty) return barangList;
    
    return barangList.where((barang) => 
      barang.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      barang.kodeBarang.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  double get _totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + (item.harga * item.jumlah));
  }

  void _addToCart(BarangSatuan unit, int quantity) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item.idBarangSatuan == unit.id);
      
      if (existingIndex >= 0) {
        _cartItems[existingIndex].jumlah += quantity;
      } else {
        _cartItems.add(CartItem(
          idBarangSatuan: unit.id,
          namaSatuan: unit.namaSatuan,
          harga: unit.hargaJual,
          jumlah: quantity,
          stokTersedia: unit.stokSatuan,
        ));
      }
    });
  }

  void _updateCartItemQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].jumlah = newQuantity;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BarangProvider>(
      builder: (context, barangProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Transaksi Baru'),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: _cartItems.isEmpty ? null : () => _showCartBottomSheet(),
                  ),
                  if (_cartItems.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search Header
                SearchHeader(
                  title: 'Pilih Barang',
                  searchController: _searchController,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                // Cart Summary (if items exist)
                if (_cartItems.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_cartItems.length} item dalam keranjang',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _currencyFormatter.format(_totalAmount),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showCartBottomSheet(),
                          child: const Text('Lihat'),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // Items List
                Expanded(
                  child: StreamBuilder<List<Barang>>(
                    stream: barangProvider.getBarang(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('Terjadi kesalahan: ${snapshot.error}'),
                            ],
                          ),
                        );
                      }

                      final barangList = snapshot.data ?? [];
                      final filteredList = _filterBarang(barangList);

                      if (barangList.isEmpty) {
                        return const _EmptyState();
                      }

                      if (filteredList.isEmpty && _searchQuery.isNotEmpty) {
                        return _NoSearchResults(searchQuery: _searchQuery);
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final barang = filteredList[index];
                          return _BarangCard(
                            barang: barang,
                            onSelectUnit: (unit, quantity) => _addToCart(unit, quantity),
                            currencyFormatter: _currencyFormatter,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Keranjang Belanja',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _cartItems.clear());
                        Navigator.pop(context);
                      },
                      child: const Text('Kosongkan'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Cart Items
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _CartItemCard(
                        item: item,
                        currencyFormatter: _currencyFormatter,
                        onQuantityChanged: (newQuantity) {
                          _updateCartItemQuantity(index, newQuantity);
                        },
                        onRemove: () => _updateCartItemQuantity(index, 0),
                      );
                    },
                  ),
                ),
                
                // Total and Checkout
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _currencyFormatter.format(_totalAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processTransaction,
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Proses Transaksi'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _processTransaction() async {
    if (_cartItems.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Prepare transaction items
      final items = _cartItems.map((item) => {
        'idBarangSatuan': item.idBarangSatuan,
        'jumlah': item.jumlah,
      }).toList();

      // Generate transaction code
      final kodeTransaksi = await FirestoreService.generateKodeTransaksi();

      // Create transaction
      await FirestoreService.createCompleteTransaction(
        kodeTransaksi: kodeTransaksi,
        items: items,
      );

      if (!mounted) return;

      // Clear cart and show success
      setState(() {
        _cartItems.clear();
        _isProcessing = false;
      });

      Navigator.pop(context); // Close cart modal
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi $kodeTransaksi berhasil diproses!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      setState(() => _isProcessing = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses transaksi: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class CartItem {
  final String idBarangSatuan;
  final String namaSatuan;
  final double harga;
  int jumlah;
  final int stokTersedia;

  CartItem({
    required this.idBarangSatuan,
    required this.namaSatuan,
    required this.harga,
    required this.jumlah,
    required this.stokTersedia,
  });
}

class _BarangCard extends StatelessWidget {
  final Barang barang;
  final Function(BarangSatuan unit, int quantity) onSelectUnit;
  final NumberFormat currencyFormatter;

  const _BarangCard({
    required this.barang,
    required this.onSelectUnit,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.light,
        border: Border.all(color: AppColors.grey200.withOpacity(0.5)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.inventory_2,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          barang.namaBarang,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode: ${barang.kodeBarang}'),
            FutureBuilder<Kategori?>(
              future: FirestoreService.getKategoriById(barang.idKategori),
              builder: (context, snapshot) {
                final kategori = snapshot.data;
                return Text(
                  'Kategori: ${kategori?.namaKategori ?? 'Loading...'}',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ],
        ),
        children: [
          StreamBuilder<List<BarangSatuan>>(
            stream: FirestoreService.getBarangSatuanByBarangStream(barang.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final units = snapshot.data ?? [];

              if (units.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text('Tidak ada satuan tersedia'),
                );
              }

              return Column(
                children: units.map((unit) => _UnitTile(
                  unit: unit,
                  onAdd: (quantity) => onSelectUnit(unit, quantity),
                  currencyFormatter: currencyFormatter,
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  final BarangSatuan unit;
  final Function(int quantity) onAdd;
  final NumberFormat currencyFormatter;

  const _UnitTile({
    required this.unit,
    required this.onAdd,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = unit.stokSatuan <= 0;

    return ListTile(
      title: Text(unit.namaSatuan),
      subtitle: Text(currencyFormatter.format(unit.hargaJual)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Stok: ${unit.stokSatuan}',
            style: TextStyle(
              color: isOutOfStock ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isOutOfStock ? null : () => _showQuantityDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOutOfStock ? Colors.grey : AppColors.primary,
              minimumSize: const Size(60, 36),
            ),
            child: const Text('Tambah', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(BuildContext context) {
    final controller = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah ${unit.namaSatuan}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stok tersedia: ${unit.stokSatuan}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(controller.text) ?? 0;
              if (quantity > 0 && quantity <= unit.stokSatuan) {
                onAdd(quantity);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$quantity ${unit.namaSatuan} ditambahkan ke keranjang'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jumlah tidak valid'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final NumberFormat currencyFormatter;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.currencyFormatter,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaSatuan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currencyFormatter.format(item.harga),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Subtotal: ${currencyFormatter.format(item.harga * item.jumlah)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => onQuantityChanged(item.jumlah - 1),
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.grey200,
                  minimumSize: const Size(32, 32),
                ),
              ),
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${item.jumlah}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: item.jumlah < item.stokTersedia
                    ? () => onQuantityChanged(item.jumlah + 1)
                    : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: item.jumlah < item.stokTersedia 
                      ? AppColors.primary 
                      : AppColors.grey200,
                  foregroundColor: item.jumlah < item.stokTersedia 
                      ? Colors.white 
                      : AppColors.grey500,
                  minimumSize: const Size(32, 32),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 96, color: AppColors.grey400),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Tidak ada barang tersedia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Tambahkan barang terlebih dahulu untuk melakukan transaksi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  final String searchQuery;

  const _NoSearchResults({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 96, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tidak ada hasil untuk "$searchQuery"',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Coba kata kunci lain untuk mencari barang.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
