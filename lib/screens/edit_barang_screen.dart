import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/barang.dart';
import '../model/barang_satuan.dart';
import '../model/kategori.dart';
import '../providers/barang_provider.dart';
import '../providers/barang_satuan_provider.dart';
import '../providers/kategori_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_button.dart';

class EditBarangScreen extends StatefulWidget {
  final Barang? barang; // null for add, non-null for edit

  const EditBarangScreen({
    super.key,
    this.barang,
  });

  @override
  State<EditBarangScreen> createState() => _EditBarangScreenState();
}

class _EditBarangScreenState extends State<EditBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kodeController = TextEditingController();
  final _stokTotalController = TextEditingController();
  
  // Barang Satuan fields
  final _namaSatuanController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _stokSatuanController = TextEditingController();
  
  String? _selectedKategoriId;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.barang != null;
    if (_isEditMode) {
      // Edit mode - populate fields
      _namaController.text = widget.barang!.namaBarang;
      _kodeController.text = widget.barang!.kodeBarang;
      _stokTotalController.text = widget.barang!.stokTotal.toString();
      _selectedKategoriId = widget.barang!.idKategori;
      
      // Note: In edit mode, barang_satuan will be managed separately
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    _stokTotalController.dispose();
    _namaSatuanController.dispose();
    _hargaJualController.dispose();
    _stokSatuanController.dispose();
    super.dispose();
  }

  Future<void> _saveBarang() async {
    if (!_formKey.currentState!.validate() || _selectedKategoriId == null) {
      setState(() {
        _errorMessage = 'Please fill all fields and select a category';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final barangProvider = Provider.of<BarangProvider>(context, listen: false);
      final barangSatuanProvider = Provider.of<BarangSatuanProvider>(context, listen: false);

      if (_isEditMode) {
        // Update existing barang
        final updatedBarang = Barang(
          id: widget.barang!.id,
          idKategori: _selectedKategoriId!,
          kodeBarang: _kodeController.text.trim(),
          namaBarang: _namaController.text.trim(),
          stokTotal: int.parse(_stokTotalController.text),
        );
        final success = await barangProvider.updateBarang(updatedBarang);
        if (!success) {
          throw Exception(barangProvider.errorMessage ?? 'Failed to update item');
        }
      } else {
        // Add new barang
        final success = await barangProvider.addBarang(
          idKategori: _selectedKategoriId!,
          namaBarang: _namaController.text.trim(),
          stokTotal: int.parse(_stokTotalController.text),
        );
        if (!success) {
          throw Exception(barangProvider.errorMessage ?? 'Failed to add item');
        }
        
        // If we have barang_satuan data, add it too
        if (_namaSatuanController.text.isNotEmpty && _hargaJualController.text.isNotEmpty) {
          // Note: We would need the barang ID here, which requires refactoring the provider
          // For now, barang_satuan will be added separately
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.barang == null ? 'Item added successfully' : 'Item updated successfully'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barang == null ? 'Add Item' : 'Edit Item'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          widget.barang == null ? Icons.add_box : Icons.edit,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.barang == null ? 'Add New Item' : 'Edit Item',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.barang == null 
                                ? 'Fill in the details below to add a new item'
                                : 'Update the item information',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error),
                          onPressed: () => setState(() => _errorMessage = null),
                        ),
                      ],
                    ),
                  ),

                // Form Fields
                _buildFormField(
                  label: 'Item Name',
                  controller: _namaController,
                  icon: Icons.inventory_2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                _buildFormField(
                  label: 'Product Code',
                  controller: _kodeController,
                  icon: Icons.qr_code,
                  enabled: _isEditMode, // Code is auto-generated for new items
                  validator: (value) {
                    if (_isEditMode && (value == null || value.trim().isEmpty)) {
                      return 'Please enter product code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                _buildFormField(
                  label: 'Total Stock',
                  controller: _stokTotalController,
                  icon: Icons.inventory,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter total stock';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Please enter a valid stock quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Barang Satuan Section (for new items)
                if (!_isEditMode) ..._buildBarangSatuanSection(),
                const SizedBox(height: AppSpacing.lg),

                // Category Dropdown
                _buildCategoryDropdown(),
                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Cancel',
                        variant: AppButtonVariant.secondary,
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        text: widget.barang == null ? 'Add Item' : 'Update Item',
                        variant: AppButtonVariant.primary,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _saveBarang,
                      ),
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Consumer<KategoriProvider>(
          builder: (context, kategoriProvider, child) {
            return StreamBuilder<List<Kategori>>(
              stream: kategoriProvider.getKategori(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Text('Loading categories...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
                            'Error loading categories: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final categories = snapshot.data ?? [];
                
                if (categories.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.onSurfaceVariant),
                        SizedBox(width: AppSpacing.sm),
                        Text('No categories available'),
                      ],
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedKategoriId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.grey200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.grey200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  hint: const Text('Select a category'),
                  items: categories.map((kategori) {
                    return DropdownMenuItem<String>(
                      value: kategori.id,
                      child: Text(kategori.namaKategori),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKategoriId = value;
                      _errorMessage = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildBarangSatuanSection() {
    return [
      const SizedBox(height: AppSpacing.lg),
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Initial Unit & Pricing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Add the first unit type and pricing for this product',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFormField(
              label: 'Unit Name (e.g., Kg, Pcs, Box)',
              controller: _namaSatuanController,
              icon: Icons.straighten,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter unit name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFormField(
              label: 'Selling Price',
              controller: _hargaJualController,
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter selling price';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFormField(
              label: 'Unit Stock',
              controller: _stokSatuanController,
              icon: Icons.inventory,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter unit stock';
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return 'Please enter a valid stock quantity';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    ];
  }
}
