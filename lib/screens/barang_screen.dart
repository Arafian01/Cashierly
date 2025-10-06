import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/barang.dart';
import '../model/kategori.dart';
import '../providers/barang_provider.dart';
import '../providers/kategori_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/search_header.dart';
import '../widgets/advanced_filter_modal.dart';
import 'package:intl/intl.dart';

class BarangScreen extends StatefulWidget {
  const BarangScreen({super.key});

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedKategoriFilter;
  SortOption _selectedSort = SortOption.none;
  StockFilter _selectedStockFilter = StockFilter.all;
  final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Barang> _filterBarang(List<Barang> barangList) {
    List<Barang> filtered = barangList;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((barang) => 
        barang.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filter by category
    if (_selectedKategoriFilter != null && _selectedKategoriFilter != 'all') {
      filtered = filtered.where((barang) => 
        barang.idKategori.id == _selectedKategoriFilter
      ).toList();
    }
    
    // Filter by stock status
    switch (_selectedStockFilter) {
      case StockFilter.inStock:
        filtered = filtered.where((barang) => barang.stok > 0).toList();
        break;
      case StockFilter.lowStock:
        filtered = filtered.where((barang) => barang.stok <= 10 && barang.stok > 0).toList();
        break;
      case StockFilter.outOfStock:
        filtered = filtered.where((barang) => barang.stok == 0).toList();
        break;
      case StockFilter.all:
        break;
    }
    
    // Apply sorting
    switch (_selectedSort) {
      case SortOption.priceAsc:
        filtered.sort((a, b) => a.harga.compareTo(b.harga));
        break;
      case SortOption.priceDesc:
        filtered.sort((a, b) => b.harga.compareTo(a.harga));
        break;
      case SortOption.nameAsc:
        filtered.sort((a, b) => a.namaBarang.compareTo(b.namaBarang));
        break;
      case SortOption.nameDesc:
        filtered.sort((a, b) => b.namaBarang.compareTo(a.namaBarang));
        break;
      case SortOption.stockAsc:
        filtered.sort((a, b) => a.stok.compareTo(b.stok));
        break;
      case SortOption.stockDesc:
        filtered.sort((a, b) => b.stok.compareTo(a.stok));
        break;
      case SortOption.none:
        break;
    }
    
    return filtered;
  }

  void _showFilterModal() {
    final kategoriProvider = Provider.of<KategoriProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreamBuilder<List<Kategori>>(
        stream: kategoriProvider.getKategori(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];
          return AdvancedFilterModal(
            categories: categories,
            selectedCategoryId: _selectedKategoriFilter,
            selectedSort: _selectedSort,
            selectedStockFilter: _selectedStockFilter,
            onFiltersApplied: (filters) {
              setState(() {
                _selectedKategoriFilter = filters['categoryId'];
                _selectedSort = filters['sortOption'];
                _selectedStockFilter = filters['stockFilter'];
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BarangProvider>(
      builder: (context, barangProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kelola Barang')),
          body: SafeArea(
            child: Column(
              children: [
                // Modern Search Header
                SearchHeader(
                  title: 'Daftar Barang',
                  searchController: _searchController,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onFilterPressed: _showFilterModal,
                  hasActiveFilter: _selectedKategoriFilter != null || 
                                 _selectedSort != SortOption.none || 
                                 _selectedStockFilter != StockFilter.all,
                ),
                // Error message display
                if (barangProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
                        itemCount: filteredList.length + 1, // +1 for bottom spacing
                        itemBuilder: (context, index) {
                          if (index == filteredList.length) {
                            return const SizedBox(height: 80); // Bottom spacing for FAB
                          }
                          final barang = filteredList[index];
                          return _BarangCard(
                            barang: barang,
                            onEdit: () => _showBarangDialog(context, barang: barang),
                            onDelete: () => _confirmDelete(context, barang),
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: barangProvider.isLoading ? null : () => _showBarangDialog(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: barangProvider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.add),
            label: Text(barangProvider.isLoading ? 'Memproses...' : 'Tambah Barang'),
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
            'Tambahkan barang pertama Anda.', 
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
            'Coba kata kunci lain untuk mencari barang.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showBarangDialog(BuildContext context, {Barang? barang}) {
    final formKey = GlobalKey<FormState>();
    String namaBarang = barang?.namaBarang ?? '';
    double harga = barang?.harga ?? 0.0;
    int stok = barang?.stok ?? 0;
    String? selectedKategoriId = barang?.idKategori.id;
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(barang == null ? 'Tambah Barang' : 'Edit Barang'),
        content: StreamBuilder<List<Kategori>>(
          stream: Provider.of<KategoriProvider>(context).getKategori(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: namaBarang,
                    decoration: const InputDecoration(labelText: 'Nama Barang'),
                    validator: (val) => val!.isEmpty ? 'Nama barang wajib diisi' : null,
                    onChanged: (val) => namaBarang = val,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: harga.toString() == '0.0' ? '' : harga.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) return 'Harga wajib diisi';
                      final price = double.tryParse(val);
                      if (price == null || price <= 0) return 'Harga harus lebih dari 0';
                      return null;
                    },
                    onChanged: (val) => harga = double.tryParse(val) ?? 0.0,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: stok.toString() == '0' ? '' : stok.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      suffixText: 'unit',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) return 'Stok wajib diisi';
                      final stock = int.tryParse(val);
                      if (stock == null || stock < 0) return 'Stok tidak boleh negatif';
                      return null;
                    },
                    onChanged: (val) => stok = int.tryParse(val) ?? 0,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedKategoriId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    hint: const Text('Pilih Kategori'),
                    validator: (val) => val == null ? 'Kategori wajib dipilih' : null,
                    items: snapshot.data!.map((kat) => DropdownMenuItem(value: kat.id, child: Text(kat.namaKategori))).toList(),
                    onChanged: (val) => selectedKategoriId = val,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newBarang = Barang(
                  id: barang?.id ?? '',
                  namaBarang: namaBarang,
                  harga: harga,
                  stok: stok,
                  idKategori: FirebaseFirestore.instance.collection('kategori').doc(selectedKategoriId),
                );
                
                bool success;
                if (barang == null) {
                  success = await barangProvider.addBarang(newBarang);
                } else {
                  success = await barangProvider.updateBarang(newBarang);
                }

                if (!context.mounted) return;
                
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Barang ${barang == null ? 'ditambahkan' : 'diperbarui'} berhasil.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(barangProvider.errorMessage ?? 'Terjadi kesalahan'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(barang == null ? 'Simpan' : 'Perbarui'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Barang barang) async {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Anda yakin ingin menghapus barang "${barang.namaBarang}"?'),
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
      bool success = await barangProvider.deleteBarang(barang.id);
      if (!context.mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(barangProvider.errorMessage ?? 'Gagal menghapus barang'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _BarangCard extends StatelessWidget {
  final Barang barang;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final NumberFormat currencyFormatter;

  const _BarangCard({
    required this.barang,
    required this.onEdit,
    required this.onDelete,
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1), // Green for items
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded, 
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang.namaBarang,
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: barang.stok > 10 
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : barang.stok > 0
                              ? const Color(0xFFF59E0B).withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '${barang.stok} unit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: barang.stok > 10 
                              ? const Color(0xFF10B981)
                              : barang.stok > 0
                                ? const Color(0xFFF59E0B)
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<DocumentSnapshot>(
              future: barang.idKategori.get(),
              builder: (context, snapshot) {
                String kategoriName = 'Loading...';
                if (snapshot.hasData) {
                  kategoriName = snapshot.data!['nama_kategori'] ?? 'Unknown';
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.label_outline, size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          kategoriName,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          currencyFormatter.format(barang.harga),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
