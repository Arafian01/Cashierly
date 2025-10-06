import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/kategori.dart';
import '../providers/kategori_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/search_header.dart';

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({Key? key}) : super(key: key);

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Kategori> _filterKategori(List<Kategori> kategoriList) {
    if (_searchQuery.isEmpty) return kategoriList;
    
    return kategoriList.where((kategori) => 
      kategori.namaKategori.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KategoriProvider>(
      builder: (context, kategoriProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kelola Kategori')),
          body: SafeArea(
            child: Column(
              children: [
                // Modern Search Header
                SearchHeader(
                  title: 'Daftar Kategori',
                  searchController: _searchController,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                // Error message display
                if (kategoriProvider.errorMessage != null)
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
                            kategoriProvider.errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error),
                          onPressed: () => kategoriProvider.clearError(),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: StreamBuilder<List<Kategori>>(
                    stream: kategoriProvider.getKategori(),
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
                                onPressed: () => kategoriProvider.clearError(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }

                      final kategoriList = snapshot.data ?? [];
                      final filteredList = _filterKategori(kategoriList);
                      
                      if (kategoriList.isEmpty) {
                        return _EmptyState(onAdd: () => _showKategoriSheet(context));
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
                                'Daftar Kategori (${filteredList.length})',
                                style: const TextStyle(
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  child: const Text('Hapus Filter'),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                            ),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final kategori = filteredList[index];
                              return _KategoriCard(
                                kategori: kategori,
                                onEdit: () => _showKategoriSheet(context, kategori: kategori),
                                onDelete: () => _confirmDelete(context, kategori),
                              );
                            },
                          ),
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
            onPressed: kategoriProvider.isLoading ? null : () => _showKategoriSheet(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: kategoriProvider.isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.add),
            label: Text(kategoriProvider.isLoading ? 'Memproses...' : 'Tambah Kategori'),
          ),
        );
      },
    );
  }

  Future<void> _showKategoriSheet(BuildContext context, {Kategori? kategori}) async {
    final kategoriProvider = Provider.of<KategoriProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: kategori?.namaKategori ?? '');

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
                    kategori == null ? 'Tambah Kategori' : 'Edit Kategori',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Nama Kategori'),
                    validator: (val) => (val == null || val.isEmpty) ? 'Nama kategori wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final newKategori = Kategori(id: kategori?.id ?? '', namaKategori: controller.text.trim());
                        bool success;
                        
                        if (kategori == null) {
                          success = await kategoriProvider.addKategori(newKategori);
                        } else {
                          success = await kategoriProvider.updateKategori(newKategori);
                        }

                        if (!context.mounted) return;
                        
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kategori ${kategori == null ? 'ditambahkan' : 'diperbarui'} berhasil.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(kategoriProvider.errorMessage ?? 'Terjadi kesalahan'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(kategori == null ? 'Simpan Kategori' : 'Perbarui Kategori'),
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

  Future<void> _confirmDelete(BuildContext context, Kategori kategori) async {
    final kategoriProvider = Provider.of<KategoriProvider>(context, listen: false);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Anda yakin ingin menghapus kategori "${kategori.namaKategori}"?'),
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
      bool success = await kategoriProvider.deleteKategori(kategori.id);
      if (!context.mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kategoriProvider.errorMessage ?? 'Gagal menghapus kategori'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _KategoriCard extends StatelessWidget {
  final Kategori kategori;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KategoriCard({
    required this.kategori,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.label_rounded, 
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    kategori.namaKategori,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 96, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Belum ada kategori', 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Tambahkan kategori untuk mulai mengelola barang.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Kategori'),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Coba kata kunci lain atau hapus filter untuk melihat semua kategori.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}