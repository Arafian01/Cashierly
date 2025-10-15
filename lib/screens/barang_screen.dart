import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/barang.dart';
import '../model/kategori.dart';
import '../providers/barang_provider.dart';
import '../providers/kategori_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/search_header.dart';
import '../widgets/advanced_filter_modal.dart';
import 'edit_barang_screen.dart';
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

  Future<Kategori?> _getKategoriById(String kategoriId) async {
    // Use provider to get kategori stream and find by ID
    try {
      final kategoriProvider = Provider.of<KategoriProvider>(context, listen: false);
      final kategoriStream = kategoriProvider.getKategori();
      final kategoriList = await kategoriStream.first;
      return kategoriList.firstWhere((k) => k.id == kategoriId);
    } catch (e) {
      return null;
    }
  }

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
        barang.idKategori == _selectedKategoriFilter
      ).toList();
    }
    
    // Filter by stock status
    switch (_selectedStockFilter) {
      case StockFilter.inStock:
        // TODO: Implement stock filter using barang_satuan
        // filtered = filtered.where((barang) => barang.stokTotal > 0).toList();
        break;
      case StockFilter.lowStock:
        // TODO: Implement low stock filter using barang_satuan
        // filtered = filtered.where((barang) => barang.stokTotal <= 10 && barang.stokTotal > 0).toList();
        break;
      case StockFilter.outOfStock:
        // TODO: Implement out of stock filter using barang_satuan
        // filtered = filtered.where((barang) => barang.stokTotal == 0).toList();
        break;
      case StockFilter.all:
        break;
    }
    
    // Apply sorting
    switch (_selectedSort) {
      case SortOption.priceAsc:
        // TODO: Implement price sorting using barang_satuan
        // filtered.sort((a, b) => a.harga.compareTo(b.harga));
        break;
      case SortOption.priceDesc:
        // TODO: Implement price sorting using barang_satuan
        // filtered.sort((a, b) => b.harga.compareTo(a.harga));
        break;
      case SortOption.nameAsc:
        filtered.sort((a, b) => a.namaBarang.compareTo(b.namaBarang));
        break;
      case SortOption.nameDesc:
        filtered.sort((a, b) => b.namaBarang.compareTo(a.namaBarang));
        break;
      case SortOption.stockAsc:
        filtered.sort((a, b) => a.stokTotal.compareTo(b.stokTotal));
        break;
      case SortOption.stockDesc:
        filtered.sort((a, b) => b.stokTotal.compareTo(a.stokTotal));
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
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.payments, color: Colors.white),
                SizedBox(width: 8),
                Text('My Expenses'),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Modern Search Header
                SearchHeader(
                  title: 'Expense History',
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
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBarangScreen(barang: barang),
                                ),
                              );
                            },
                            onDelete: () => _confirmDelete(context, barang),
                            currencyFormatter: _currencyFormatter,
                            getKategoriById: _getKategoriById,
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
            onPressed: barangProvider.isLoading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditBarangScreen(),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: barangProvider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.add),
            label: Text(barangProvider.isLoading ? 'Processing...' : 'Add Expense'),
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
          Icon(Icons.payments_outlined, size: 96, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No expenses yet', 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Start tracking your expenses by adding your first expense.', 
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
            Text('Delete Item'),
          ],
        ),
        content: Text('Are you sure you want to delete "${barang.namaBarang}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
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
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Text('${barang.namaBarang} deleted successfully'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(barangProvider.errorMessage ?? 'Failed to delete item'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
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
  final Future<Kategori?> Function(String) getKategoriById;

  const _BarangCard({
    required this.barang,
    required this.onEdit,
    required this.onDelete,
    required this.currencyFormatter,
    required this.getKategoriById,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: onEdit,
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
                        Icons.monetization_on, 
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
                              color: barang.stokTotal > 10 
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : barang.stokTotal > 0
                                  ? const Color(0xFFF59E0B).withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '${barang.stokTotal} unit',
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
                    ),
                    // Delete button
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                FutureBuilder<Kategori?>(
                  future: getKategoriById(barang.idKategori),
                  builder: (context, snapshot) {
                    String kategoriName = 'Loading...';
                    if (snapshot.hasData && snapshot.data != null) {
                      kategoriName = snapshot.data!.namaKategori;
                    } else if (snapshot.hasError) {
                      kategoriName = 'Unknown';
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
                              'Multiple Units', // TODO: Show actual pricing from barang_satuan
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
