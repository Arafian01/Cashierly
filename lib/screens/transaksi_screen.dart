import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/barang.dart';
import '../model/transaksi.dart';
import '../providers/barang_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/transaksi_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/search_header.dart';
import 'cart_screen.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Barang> _filterBarang(List<Barang> barangList) {
    if (_searchQuery.isEmpty) return barangList;
    
    return barangList.where((barang) => 
      barang.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _addToCart(Barang barang, CartProvider cartProvider) {
    // TODO: This needs to be updated to work with BarangSatuan
    // For now, show a dialog to select which unit to add
    _showUnitSelectionDialog(barang, cartProvider);
  }
  
  void _showUnitSelectionDialog(Barang barang, CartProvider cartProvider) {
    // Show dialog to select barang_satuan unit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please implement unit selection for ${barang.namaBarang}'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BarangProvider, CartProvider>(
      builder: (context, barangProvider, cartProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                SizedBox(width: 8),
                Text('Shopping'),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Modern Search Header
                SearchHeader(
                  title: 'Available Products',
                  searchController: _searchController,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onCartPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  cartItemCount: cartProvider.uniqueItemCount,
                ),
                
                // Error message display
                if (barangProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            barangProvider.errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error),
                          onPressed: () => barangProvider.clearError(),
                        ),
                      ],
                    ),
                  ),
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
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => barangProvider.clearError(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      final barangList = snapshot.data ?? [];
                      final filteredList = _filterBarang(barangList);
                      
                      if (barangList.isEmpty) {
                        return _buildEmptyState();
                      }
                      
                      if (filteredList.isEmpty && _searchQuery.isNotEmpty) {
                        return _buildNoSearchResults();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final barang = filteredList[index];
                          final isInCart = cartProvider.isInCart(barang.id);
                          
                          return _BarangShopCard(
                            barang: barang,
                            isInCart: isInCart,
                            onAddToCart: () => _addToCart(barang, cartProvider),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 96, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Belum ada barang', 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Belum ada barang tersedia untuk dibeli.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 96, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tidak ada hasil untuk "$_searchQuery"',
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Coba kata kunci lain untuk mencari produk.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateTransaksiSheet(BuildContext context) async {
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    final namaController = TextEditingController();
    final bayarController = TextEditingController(text: '0');
    final totalController = TextEditingController(text: '0');
    final sisaController = TextEditingController(text: '0');
    final keteranganController = TextEditingController();

    DateTime tanggal = DateTime.now();
    DateTime? tanggalBayar;
    String status = 'Belum Lunas';

    final detailEntries = <_DetailEntry>[_DetailEntry()];

    void recalculateTotals(StateSetter setModalState) {
      final total = detailEntries.fold<double>(0, (sum, entry) {
        final harga = 0.0; // TODO: Get price from barang_satuan
        entry.subTotal = harga * entry.jumlah;
        return sum + entry.subTotal;
      });
      totalController.text = total.toStringAsFixed(0);
      final bayar = double.tryParse(bayarController.text.replaceAll(',', '.')) ?? 0;
      double sisa = total - bayar;
      if (sisa < 0) sisa = 0;
      sisaController.text = status.toLowerCase() == 'lunas' ? '0' : sisa.toStringAsFixed(0);
      setModalState(() {});
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.85,
                maxChildSize: 0.95,
                minChildSize: 0.6,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: StreamBuilder<List<Barang>>(
                      stream: barangProvider.getBarang(),
                      builder: (context, snapshot) {
                        final barangList = snapshot.data ?? [];
                        return Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text('Transaksi Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: namaController,
                                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                                validator: (val) => (val == null || val.isEmpty) ? 'Nama wajib diisi' : null,
                              ),
                              const SizedBox(height: 16),
                              _DatePickerField(
                                label: 'Tanggal Transaksi',
                                selectedDate: tanggal,
                                onDateSelected: (picked) {
                                  if (picked != null) {
                                    tanggal = picked;
                                    setModalState(() {});
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: status,
                                decoration: const InputDecoration(labelText: 'Status Pembayaran'),
                                items: const [
                                  DropdownMenuItem(value: 'Lunas', child: Text('Lunas')),
                                  DropdownMenuItem(value: 'Belum Lunas', child: Text('Belum Lunas')),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  status = value;
                                  if (status.toLowerCase() == 'lunas') {
                                    tanggalBayar = tanggalBayar ?? DateTime.now();
                                    sisaController.text = '0';
                                  }
                                  setModalState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              if (status.toLowerCase() == 'lunas')
                                _DatePickerField(
                                  label: 'Tanggal Bayar',
                                  selectedDate: tanggalBayar ?? DateTime.now(),
                                  onDateSelected: (picked) {
                                    tanggalBayar = picked;
                                    setModalState(() {});
                                  },
                                ),
                              const SizedBox(height: 24),
                              const Text('Detail Barang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              ...detailEntries.asMap().entries.map((entry) {
                                final index = entry.key;
                                final detail = entry.value;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: detail.barang?.id,
                                                decoration: const InputDecoration(labelText: 'Pilih Barang'),
                                                items: barangList
                                                    .map(
                                                      (barang) => DropdownMenuItem(
                                                        value: barang.id,
                                                        child: Text(barang.namaBarang),
                                                      ),
                                                    )
                                                    .toList(),
                                                validator: (val) => (val == null || val.isEmpty) ? 'Wajib pilih barang' : null,
                                                onChanged: (value) {
                                                  if (value == null || barangList.isEmpty) return;
                                                  final selected = barangList.firstWhere(
                                                    (barang) => barang.id == value,
                                                    orElse: () => barangList.first,
                                                  );
                                                  detail.barang = selected;
                                                  recalculateTotals(setModalState);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            if (detailEntries.length > 1)
                                              IconButton(
                                                onPressed: () {
                                                  detailEntries.removeAt(index);
                                                  if (detailEntries.isEmpty) {
                                                    detailEntries.add(_DetailEntry());
                                                  }
                                                  recalculateTotals(setModalState);
                                                },
                                                icon: const Icon(Icons.delete_outline),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: detail.jumlah.toString(),
                                                decoration: const InputDecoration(labelText: 'Jumlah'),
                                                keyboardType: TextInputType.number,
                                                validator: (val) => (val == null || val.isEmpty) ? 'Masukkan jumlah' : null,
                                                onChanged: (val) {
                                                  final parsed = int.tryParse(val) ?? 0;
                                                  detail.jumlah = parsed;
                                                  recalculateTotals(setModalState);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                _currency.format(detail.subTotal),
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              TextButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    detailEntries.add(_DetailEntry());
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Tambah Barang'),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: totalController,
                                decoration: const InputDecoration(labelText: 'Total'),
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: bayarController,
                                decoration: const InputDecoration(labelText: 'Bayar'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (val) => recalculateTotals(setModalState),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: sisaController,
                                decoration: const InputDecoration(labelText: 'Sisa'),
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: keteranganController,
                                decoration: const InputDecoration(labelText: 'Keterangan (opsional)'),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate()) return;
                                    final validDetails = detailEntries.where((detail) => detail.barang != null && detail.jumlah > 0).toList();
                                    if (validDetails.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Minimal tambahkan satu detail barang.')),
                                      );
                                      return;
                                    }

                                    final total = double.tryParse(totalController.text) ?? 0;
                                    final bayar = double.tryParse(bayarController.text) ?? 0;
                                    double sisa = double.tryParse(sisaController.text) ?? (total - bayar);
                                    if (sisa < 0) sisa = 0;

                                    // TODO: This transaction creation needs complete redesign for new structure
                                    // For now, disable transaction creation and show message
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Transaction system needs to be updated for new database structure'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                    return;
                                    
                                    // TODO: Implement with new structure:
                                    // final detailItems = validDetails.map((detail) => DetailTransaksiForm(
                                    //   idBarangSatuan: 'barang_satuan_id_here',
                                    //   jumlah: detail.jumlah,
                                    // )).toList();
                                    // 
                                    // String? transaksiId = await transaksiProvider.createCompleteTransaction(
                                    //   detailItems: detailItems,
                                    // );
                                  },
                                  child: const Text('Simpan Transaksi'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showAddDetailSheet(BuildContext context, Transaksi transaksi) async {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    Barang? selectedBarang;
    int jumlah = 1;
    double subTotal = 0;

    void recalcSubtotal() {
      final harga = 0.0; // TODO: Get price from barang_satuan
      subTotal = harga * jumlah;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.55,
                maxChildSize: 0.75,
                minChildSize: 0.4,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: StreamBuilder<List<Barang>>(
                      stream: barangProvider.getBarang(),
                      builder: (context, snapshot) {
                        final barangList = snapshot.data ?? [];
                        return Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text('Tambah Detail Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: selectedBarang?.id,
                                decoration: const InputDecoration(labelText: 'Pilih Barang'),
                                items: barangList
                                    .map(
                                      (barang) => DropdownMenuItem(
                                        value: barang.id,
                                        child: Text(barang.namaBarang),
                                      ),
                                    )
                                    .toList(),
                                validator: (val) => (val == null || val.isEmpty) ? 'Wajib pilih barang' : null,
                                onChanged: (value) {
                                  if (value == null || barangList.isEmpty) return;
                                  final found = barangList.firstWhere((barang) => barang.id == value, orElse: () => barangList.first);
                                  selectedBarang = found;
                                  recalcSubtotal();
                                  setModalState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: jumlah.toString(),
                                decoration: const InputDecoration(labelText: 'Jumlah'),
                                keyboardType: TextInputType.number,
                                validator: (val) => (val == null || val.isEmpty) ? 'Masukkan jumlah' : null,
                                onChanged: (val) {
                                  jumlah = int.tryParse(val) ?? 1;
                                  if (jumlah <= 0) jumlah = 1;
                                  recalcSubtotal();
                                  setModalState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              Text('Subtotal: ${_currency.format(subTotal)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate()) return;
                                    if (selectedBarang == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Pilih barang terlebih dahulu.')),
                                      );
                                      return;
                                    }

                                    recalcSubtotal();

                                    // TODO: Method needs to be implemented for new structure
                                    // DetailTransaksiForm(
                                    //   idBarangSatuan: 'placeholder_id', // TODO: Get actual barang_satuan ID
                                    //   jumlah: jumlah,
                                    // );
                                    
                                    // Show placeholder message for now
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Add detail functionality needs to be updated for new structure'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );

                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Detail transaksi ditambahkan.')),
                                    );
                                  },
                                  child: const Text('Simpan Detail'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showUpdateStatusSheet(Transaksi transaksi) async {
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    String status = 'Pending'; // TODO: New transaksi model doesn't have status
    DateTime? tanggalBayar = null; // TODO: New transaksi model doesn't have tanggalBayar
    final bayarController = TextEditingController(text: '0'); // TODO: New transaksi model doesn't have bayar

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Atur Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(labelText: 'Status Pembayaran'),
                        items: const [
                          DropdownMenuItem(value: 'Lunas', child: Text('Lunas')),
                          DropdownMenuItem(value: 'Belum Lunas', child: Text('Belum Lunas')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          status = value;
                          if (status.toLowerCase() == 'lunas') {
                            tanggalBayar = tanggalBayar ?? DateTime.now();
                            bayarController.text = transaksi.totalHarga.toStringAsFixed(0);
                          }
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: bayarController,
                        decoration: const InputDecoration(labelText: 'Nominal Bayar'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => (val == null || val.isEmpty) ? 'Nominal wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      if (status.toLowerCase() == 'lunas')
                        _DatePickerField(
                          label: 'Tanggal Bayar',
                          selectedDate: tanggalBayar ?? DateTime.now(),
                          onDateSelected: (picked) {
                            tanggalBayar = picked;
                            setModalState(() {});
                          },
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            final bayar = double.tryParse(bayarController.text) ?? 0;
                            double sisa = transaksi.totalHarga - bayar;
                            if (sisa < 0) sisa = 0;

                            // TODO: updateStatus method needs to be implemented
                            // Show placeholder message for now
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Update status functionality needs to be updated for new structure'),
                                backgroundColor: Colors.orange,
                              ),
                            );

                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Status pembayaran diperbarui.')),
                            );
                          },
                          child: const Text('Simpan Perubahan'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteTransaksi(Transaksi transaksi) async {
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Anda yakin ingin menghapus transaksi "${transaksi.kodeTransaksi}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await transaksiProvider.deleteTransaksi(transaksi.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi dihapus.')),
      );
    }
  }
}

class _BarangShopCard extends StatelessWidget {
  final Barang barang;
  final bool isInCart;
  final VoidCallback onAddToCart;

  const _BarangShopCard({
    required this.barang,
    required this.isInCart,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: Future.value(null), // TODO: Fix kategori lookup for new structure
      builder: (context, snapshot) {
        String kategoriName = 'Loading...';
        if (snapshot.hasData) {
          kategoriName = snapshot.data!['nama_kategori'] ?? 'Unknown';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.light,
            border: Border.all(color: AppColors.grey200.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Product Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang.namaBarang,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        kategoriName,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            'Multiple Units Available', // TODO: Show actual pricing from barang_satuan
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: barang.stokTotal > 10 
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : barang.stokTotal > 0
                                  ? const Color(0xFFF59E0B).withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              '${barang.stokTotal} left',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: barang.stokTotal > 10 
                                  ? const Color(0xFF10B981)
                                  : barang.stokTotal > 0
                                    ? const Color(0xFFF59E0B)
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Add to Cart Button
                Container(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: barang.stokTotal > 0 ? onAddToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: barang.stokTotal > 0 ? AppColors.primary : AppColors.grey300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      elevation: barang.stokTotal > 0 ? 2 : 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          barang.stokTotal <= 0 
                            ? Icons.block 
                            : isInCart 
                              ? Icons.check_circle 
                              : Icons.add_shopping_cart,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          barang.stokTotal <= 0
                              ? 'Out'
                              : isInCart
                                ? 'Added'
                                : 'Add',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        onDateSelected(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate)),
            const Icon(Icons.calendar_today_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DetailEntry {
  Barang? barang;
  int jumlah = 1;
  double subTotal = 0.0;
}
