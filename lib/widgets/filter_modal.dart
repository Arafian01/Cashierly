import 'package:flutter/material.dart';
import '../model/kategori.dart';
import 'app_theme.dart';
import 'app_button.dart';

class FilterModal extends StatefulWidget {
  final List<Kategori> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const FilterModal({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String? _tempSelectedCategory;

  @override
  void initState() {
    super.initState();
    _tempSelectedCategory = widget.selectedCategoryId;
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
                  'Filter Kategori',
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
          
          // Category List
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // All Categories Option
                _buildCategoryTile(
                  title: 'Semua Kategori',
                  value: null,
                  icon: Icons.all_inclusive,
                ),
                
                // Individual Categories
                ...widget.categories.map((category) => _buildCategoryTile(
                  title: category.namaKategori,
                  value: category.id,
                  icon: Icons.label_outline,
                )),
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Reset',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      setState(() {
                        _tempSelectedCategory = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    text: 'Terapkan',
                    onPressed: () {
                      widget.onCategorySelected(_tempSelectedCategory);
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

  Widget _buildCategoryTile({
    required String title,
    required String? value,
    required IconData icon,
  }) {
    final isSelected = _tempSelectedCategory == value;
    
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
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
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
        onTap: () {
          setState(() {
            _tempSelectedCategory = value;
          });
        },
      ),
    );
  }
}
