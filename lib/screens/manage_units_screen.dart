import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../model/barang.dart';
import '../model/barang_satuan.dart';
import '../services/firestore_service.dart';
import '../widgets/app_theme.dart';

class ManageUnitsScreen extends StatefulWidget {
  final Barang barang;

  const ManageUnitsScreen({super.key, required this.barang});

  @override
  State<ManageUnitsScreen> createState() => _ManageUnitsScreenState();
}

class _ManageUnitsScreenState extends State<ManageUnitsScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kelola Satuan', style: TextStyle(fontSize: 18)),
            Text(
              widget.barang.namaBarang,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Item Info Card
            Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.barang.namaBarang,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kode: ${widget.barang.kodeBarang}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Total Stok: ${widget.barang.stokTotal}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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

            // Units List
            Expanded(
              child: StreamBuilder<List<BarangSatuan>>(
                stream: FirestoreService.getBarangSatuanByBarangStream(widget.barang.id),
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
                            onPressed: () => setState(() {}),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  final units = snapshot.data ?? [];

                  if (units.isEmpty) {
                    return _EmptyUnitsState(onAdd: () => _showAddUnitSheet(context));
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daftar Satuan (${units.length})',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...units.map((unit) => _UnitCard(
                        unit: unit,
                        onEdit: () => _showEditUnitSheet(context, unit),
                        onDelete: () => _confirmDeleteUnit(context, unit),
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
        onPressed: _isLoading ? null : () => _showAddUnitSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add),
        label: Text(_isLoading ? 'Memproses...' : 'Tambah Satuan'),
      ),
    );
  }

  Future<void> _showAddUnitSheet(BuildContext context) async {
    await _showUnitSheet(context, null);
  }

  Future<void> _showEditUnitSheet(BuildContext context, BarangSatuan unit) async {
    await _showUnitSheet(context, unit);
  }

  Future<void> _showUnitSheet(BuildContext context, BarangSatuan? unit) async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: unit?.namaSatuan ?? '');
    final hargaController = TextEditingController(
      text: unit?.hargaJual.toString() ?? '',
    );
    final stokController = TextEditingController(
      text: unit?.stokSatuan.toString() ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Padding(
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
                  Text(
                    unit == null ? 'Tambah Satuan' : 'Edit Satuan',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Satuan',
                      hintText: 'Contoh: Pcs, Box, Karton, dll',
                    ),
                    validator: (val) => (val == null || val.isEmpty) 
                        ? 'Nama satuan wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: hargaController,
                    decoration: const InputDecoration(
                      labelText: 'Harga Jual',
                      prefixText: 'Rp ',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Harga jual wajib diisi';
                      }
                      if (double.tryParse(val) == null || double.parse(val) <= 0) {
                        return 'Harga harus lebih besar dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: stokController,
                    decoration: const InputDecoration(
                      labelText: 'Stok Satuan',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Stok satuan wajib diisi';
                      }
                      if (int.tryParse(val) == null || int.parse(val) < 0) {
                        return 'Stok tidak boleh negatif';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        setState(() => _isLoading = true);

                        try {
                          if (unit == null) {
                            // Add new unit
                            await FirestoreService.addBarangSatuan(
                              BarangSatuan(
                                id: '',
                                idBarang: widget.barang.id,
                                namaSatuan: namaController.text.trim(),
                                hargaJual: double.parse(hargaController.text),
                                stokSatuan: int.parse(stokController.text),
                              ),
                            );
                          } else {
                            // Update existing unit
                            final updatedUnit = BarangSatuan(
                              id: unit.id,
                              idBarang: unit.idBarang,
                              namaSatuan: namaController.text.trim(),
                              hargaJual: double.parse(hargaController.text),
                              stokSatuan: int.parse(stokController.text),
                            );
                            await FirestoreService.updateBarangSatuan(updatedUnit);
                          }

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Satuan ${unit == null ? 'ditambahkan' : 'diperbarui'} berhasil.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          setState(() => _errorMessage = e.toString());
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                      child: Text(unit == null ? 'Simpan Satuan' : 'Perbarui Satuan'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteUnit(BuildContext context, BarangSatuan unit) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            Text('Hapus Satuan'),
          ],
        ),
        content: Text('Yakin ingin menghapus satuan "${unit.namaSatuan}"?'),
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
      setState(() => _isLoading = true);
      try {
        await FirestoreService.deleteBarangSatuan(unit.id);
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Satuan berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _UnitCard extends StatelessWidget {
  final BarangSatuan unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final NumberFormat currencyFormatter;

  const _UnitCard({
    required this.unit,
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
        border: Border.all(color: AppColors.grey200.withOpacity(0.5)),
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.straighten,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.namaSatuan,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(unit.hargaJual),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
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
                    color: unit.stokSatuan > 0 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Stok: ${unit.stokSatuan}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: unit.stokSatuan > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
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

class _EmptyUnitsState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyUnitsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.straighten, size: 96, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Belum ada satuan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Tambahkan satuan barang untuk menentukan\nharga jual dan stok per satuan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Satuan'),
          ),
        ],
      ),
    );
  }
}
