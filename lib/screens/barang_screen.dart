import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../model/barang.dart';
import '../model/kategori.dart';
import '../providers/barang_provider.dart';
import '../providers/kategori_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/search_header.dart';
import 'edit_barang_screen.dart';
import 'manage_units_screen.dart';

class BarangScreen extends StatefulWidget {
  const BarangScreen({super.key});

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedKategoriFilter;
  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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
        barang.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        barang.kodeBarang.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filter by category
    if (_selectedKategoriFilter != null && _selectedKategoriFilter != 'all') {
      filtered = filtered.where((barang) => 
        barang.idKategori == _selectedKategoriFilter
      ).toList();
    }
    
    return filtered;
  }

  void _showFilterModal() {
    final kategoriProvider = Provider.of<KategoriProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StreamBuilder<List<Kategori>>(
        stream: kategoriProvider.getKategori(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];
          return _FilterModal(
            categories: categories,
            selectedCategoryId: _selectedKategoriFilter,
            onFiltersApplied: (categoryId) {
              setState(() {
                _selectedKategoriFilter = categoryId;
              });
              Navigator.pop(context);
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
          appBar: AppBar(
            title: const Text('Kelola Barang'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search Header
                SearchHeader(
                  title: 'Daftar Barang',
                  searchController: _searchController,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onFilterPressed: _showFilterModal,
                  hasActiveFilter: _selectedKategoriFilter != null,
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
                        return _EmptyState(onAdd: () => _navigateToAdd());
                      }
                      
                      if (filteredList.isEmpty && _searchQuery.isNotEmpty) {
                        return _NoSearchResults(searchQuery: _searchQuery);
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar Barang (${filteredList.length})',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              if (_selectedKategoriFilter != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedKategoriFilter = null;
                                    });
                                  },
                                  child: const Text('Hapus Filter'),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...filteredList.map((barang) => _BarangCard(
                            barang: barang,
                            onTap: () => _navigateToDetail(barang),
                            onEdit: () => _navigateToEdit(barang),
                            onDelete: () => _confirmDelete(context, barang),
                            onManageUnits: () => _navigateToManageUnits(barang),
                            currencyFormatter: _currencyFormatter,
                          )),
                          const SizedBox(height: 80), // Space for FAB
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: barangProvider.isLoading ? null : _navigateToAdd,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: barangProvider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add),
            label: Text(barangProvider.isLoading ? 'Memproses...' : 'Tambah Barang'),
          ),
        );
      },
    );
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditBarangScreen(),
      ),
    );
  }

  void _navigateToEdit(Barang barang) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBarangScreen(barang: barang),
      ),
    );
  }

  void _navigateToDetail(Barang barang) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _BarangDetailScreen(barang: barang),
      ),
    );
  }

  void _navigateToManageUnits(Barang barang) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageUnitsScreen(barang: barang),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Barang barang) async {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            Text('Hapus Barang'),
          ],
        ),
        content: Text('Yakin ingin menghapus "${barang.namaBarang}"? Tindakan ini tidak dapat dibatalkan dan akan menghapus semua satuan barang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
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
          SnackBar(
            content: Text('${barang.namaBarang} berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(barangProvider.errorMessage ?? 'Gagal menghapus barang'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _BarangCard extends StatelessWidget {
  final Barang barang;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageUnits;
  final NumberFormat currencyFormatter;

  const _BarangCard({
    required this.barang,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onManageUnits,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: onTap,
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
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
                            barang.namaBarang,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kode: ${barang.kodeBarang}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: barang.stokTotal > 0 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Stok: ${barang.stokTotal}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: barang.stokTotal > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Category info
                FutureBuilder<Kategori?>(
                  future: FirestoreService.getKategoriById(barang.idKategori),
                  builder: (context, snapshot) {
                    final kategori = snapshot.data;
                    return Row(
                      children: [
                        const Icon(Icons.category, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          kategori?.namaKategori ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onManageUnits,
                        icon: const Icon(Icons.view_list, size: 16),
                        label: const Text('Satuan'),
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
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      child: const Icon(Icons.delete_outline, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterModal extends StatelessWidget {
  final List<Kategori> categories;
  final String? selectedCategoryId;
  final Function(String?) onFiltersApplied;

  const _FilterModal({
    required this.categories,
    required this.selectedCategoryId,
    required this.onFiltersApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
          const Text(
            'Filter Barang',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Kategori',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          
          ListTile(
            title: const Text('Semua Kategori'),
            leading: Radio<String?>(
              value: null,
              groupValue: selectedCategoryId,
              onChanged: (value) => onFiltersApplied(value),
            ),
          ),
          
          ...categories.map((kategori) => ListTile(
            title: Text(kategori.namaKategori),
            leading: Radio<String?>(
              value: kategori.id,
              groupValue: selectedCategoryId,
              onChanged: (value) => onFiltersApplied(value),
            ),
          )),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 96, color: AppColors.primary.withOpacity(0.5)),
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
            'Tambahkan barang untuk mulai mengelola inventory.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Barang'),
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
            'Coba kata kunci lain atau hapus filter untuk melihat semua barang.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens - these will be implemented later
class _BarangDetailScreen extends StatelessWidget {
  final Barang barang;

  const _BarangDetailScreen({required this.barang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(barang.namaBarang)),
      body: const Center(child: Text('Detail barang akan diimplementasikan')),
    );
  }
}

