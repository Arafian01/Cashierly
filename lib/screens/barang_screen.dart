import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/barang.dart';
import '../model/kategori.dart';
import '../providers/barang_provider.dart';
import '../providers/kategori_provider.dart';
import '../widgets/responsive_container.dart';

class BarangScreen extends StatelessWidget {
  const BarangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BarangProvider>(
      builder: (context, barangProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kelola Barang')),
          body: ResponsiveContainer(
            child: Column(
              children: [
                // Error message display
                if (barangProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            barangProvider.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => barangProvider.clearError(),
                          color: Colors.red.shade700,
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
                      if (barangList.isEmpty) {
                        return _EmptyState(onAdd: () => _showBarangDialog(context));
                      }

                      return ListView(
                        children: [
                          const Text(
                            'Daftar Barang',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          ...barangList.map((barang) => _BarangCard(
                                barang: barang,
                                onEdit: () => _showBarangDialog(context, barang: barang),
                                onDelete: () => _confirmDelete(context, barang),
                              )),
                          const SizedBox(height: 80),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: barangProvider.isLoading ? null : () => _showBarangDialog(context),
            icon: barangProvider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(barangProvider.isLoading ? 'Memproses...' : 'Tambah Barang'),
          ),
        );
      },
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

  const _BarangCard({
    required this.barang,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    barang.namaBarang,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(Icons.inventory_2_rounded, color: Colors.red),
              ],
            ),
            const SizedBox(height: 8),
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
                    Text('Kategori: $kategoriName'),
                    Text('Harga: Rp ${barang.harga.toStringAsFixed(0)}'),
                    Text('Stok: ${barang.stok} unit'),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    label: const Text('Hapus'),
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 96, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Belum ada barang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text('Tambahkan barang untuk mulai mengelola inventaris.', textAlign: TextAlign.center),
          const SizedBox(height: 24),
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