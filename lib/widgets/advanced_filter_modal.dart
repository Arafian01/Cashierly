import 'package:flutter/material.dart';
import '../model/kategori.dart';
import 'app_theme.dart';
import 'app_button.dart';

enum SortOption {
  none,
  priceAsc,
  priceDesc,
  stockAsc,
  stockDesc,
  nameAsc,
  nameDesc,
}

enum StockFilter {
  all,
  inStock,
  lowStock,
  outOfStock,
}

class AdvancedFilterModal extends StatefulWidget {
  final List<Kategori> categories;
  final String? selectedCategoryId;
  final SortOption selectedSort;
  final StockFilter selectedStockFilter;
  final ValueChanged<Map<String, dynamic>> onFiltersApplied;

  const AdvancedFilterModal({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedSort,
    required this.selectedStockFilter,
    required this.onFiltersApplied,
  });

  @override
  State<AdvancedFilterModal> createState() => _AdvancedFilterModalState();
}

class _AdvancedFilterModalState extends State<AdvancedFilterModal> {
  String? _tempSelectedCategory;
  SortOption _tempSelectedSort = SortOption.none;
  StockFilter _tempSelectedStockFilter = StockFilter.all;

  @override
  void initState() {
    super.initState();
    _tempSelectedCategory = widget.selectedCategoryId;
    _tempSelectedSort = widget.selectedSort;
    _tempSelectedStockFilter = widget.selectedStockFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Urutkan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Filter Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter Section
                  _buildSectionTitle('Kategori'),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategoryFilter(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Sort Section
                  _buildSectionTitle('Urutkan'),
                  const SizedBox(height: AppSpacing.md),
                  _buildSortOptions(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Stock Filter Section
                  _buildSectionTitle('Status Stok'),
                  const SizedBox(height: AppSpacing.md),
                  _buildStockFilter(),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Reset Semua',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      setState(() {
                        _tempSelectedCategory = null;
                        _tempSelectedSort = SortOption.none;
                        _tempSelectedStockFilter = StockFilter.all;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    text: 'Terapkan',
                    onPressed: () {
                      widget.onFiltersApplied({
                        'categoryId': _tempSelectedCategory,
                        'sortOption': _tempSelectedSort,
                        'stockFilter': _tempSelectedStockFilter,
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      children: [
        // All Categories Option
        _buildFilterTile(
          title: 'Semua Kategori',
          isSelected: _tempSelectedCategory == null,
          icon: Icons.all_inclusive,
          onTap: () {
            setState(() {
              _tempSelectedCategory = null;
            });
          },
        ),
        
        // Individual Categories
        ...widget.categories.map((category) => _buildFilterTile(
          title: category.namaKategori,
          isSelected: _tempSelectedCategory == category.id,
          icon: Icons.label_outline,
          onTap: () {
            setState(() {
              _tempSelectedCategory = category.id;
            });
          },
        )),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: [
        _buildFilterTile(
          title: 'Default',
          isSelected: _tempSelectedSort == SortOption.none,
          icon: Icons.sort,
          onTap: () {
            setState(() {
              _tempSelectedSort = SortOption.none;
            });
          },
        ),
        _buildFilterTile(
          title: 'Harga: Termurah',
          isSelected: _tempSelectedSort == SortOption.priceAsc,
          icon: Icons.arrow_upward,
          onTap: () {
            setState(() {
              _tempSelectedSort = SortOption.priceAsc;
            });
          },
        ),
        _buildFilterTile(
          title: 'Harga: Termahal',
          isSelected: _tempSelectedSort == SortOption.priceDesc,
          icon: Icons.arrow_downward,
          onTap: () {
            setState(() {
              _tempSelectedSort = SortOption.priceDesc;
            });
          },
        ),
        _buildFilterTile(
          title: 'Nama: A-Z',
          isSelected: _tempSelectedSort == SortOption.nameAsc,
          icon: Icons.sort_by_alpha,
          onTap: () {
            setState(() {
              _tempSelectedSort = SortOption.nameAsc;
            });
          },
        ),
        _buildFilterTile(
          title: 'Stok: Terbanyak',
          isSelected: _tempSelectedSort == SortOption.stockDesc,
          icon: Icons.inventory,
          onTap: () {
            setState(() {
              _tempSelectedSort = SortOption.stockDesc;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStockFilter() {
    return Column(
      children: [
        _buildFilterTile(
          title: 'Semua Stok',
          isSelected: _tempSelectedStockFilter == StockFilter.all,
          icon: Icons.all_inclusive,
          onTap: () {
            setState(() {
              _tempSelectedStockFilter = StockFilter.all;
            });
          },
        ),
        _buildFilterTile(
          title: 'Tersedia (>0)',
          isSelected: _tempSelectedStockFilter == StockFilter.inStock,
          icon: Icons.check_circle,
          color: const Color(0xFF10B981),
          onTap: () {
            setState(() {
              _tempSelectedStockFilter = StockFilter.inStock;
            });
          },
        ),
        _buildFilterTile(
          title: 'Stok Menipis (≤10)',
          isSelected: _tempSelectedStockFilter == StockFilter.lowStock,
          icon: Icons.warning,
          color: const Color(0xFFF59E0B),
          onTap: () {
            setState(() {
              _tempSelectedStockFilter = StockFilter.lowStock;
            });
          },
        ),
        _buildFilterTile(
          title: 'Habis (0)',
          isSelected: _tempSelectedStockFilter == StockFilter.outOfStock,
          icon: Icons.cancel,
          color: AppColors.error,
          onTap: () {
            setState(() {
              _tempSelectedStockFilter = StockFilter.outOfStock;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterTile({
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final effectiveColor = color ?? (isSelected ? AppColors.primary : AppColors.onSurfaceVariant);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.grey200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: effectiveColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.onSurface,
          ),
        ),
        trailing: isSelected 
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
