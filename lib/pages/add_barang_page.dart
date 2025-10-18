import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_theme.dart';

class AddBarangPage extends StatefulWidget {
  final String? barangId;
  final Map<String, dynamic>? initialData;

  const AddBarangPage({
    super.key,
    this.barangId,
    this.initialData,
  });

  @override
  State<AddBarangPage> createState() => _AddBarangPageState();
}

class _AddBarangPageState extends State<AddBarangPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  
  String _selectedKategori = '';
  List<String> _kategoriList = [];
  bool _isLoading = false;
  bool get _isEdit => widget.barangId != null;

  @override
  void initState() {
    super.initState();
    _loadKategori();
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEdit && widget.initialData != null) {
      _namaController.text = widget.initialData!['nama'] ?? '';
      _deskripsiController.text = widget.initialData!['deskripsi'] ?? '';
      _hargaController.text = (widget.initialData!['harga'] ?? 0).toString();
      _stokController.text = (widget.initialData!['stok'] ?? 0).toString();
      _selectedKategori = widget.initialData!['kategori'] ?? '';
    }
  }

  void _loadKategori() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('kategori').get();
      List<String> kategori = [];
      for (var doc in snapshot.docs) {
        kategori.add(doc['nama']);
      }
      setState(() {
        _kategoriList = kategori;
        if (!_isEdit && kategori.isNotEmpty) {
          _selectedKategori = kategori.first;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat kategori: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Barang' : 'Tambah Barang'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.light,
                ),
                child: Column(
                  children: [
                    Icon(
                      _isEdit ? Icons.edit : Icons.add_box,
                      size: 60,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _isEdit ? 'Edit Data Barang' : 'Tambah Barang Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _isEdit 
                        ? 'Perbarui informasi barang Anda'
                        : 'Isi form di bawah untuk menambah barang baru',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Form Fields
              _buildFormCard(
                title: 'Informasi Dasar',
                icon: Icons.info_outline,
                children: [
                  _buildTextField(
                    controller: _namaController,
                    label: 'Nama Barang',
                    hint: 'Masukkan nama barang',
                    icon: Icons.inventory_2,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Nama barang tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildTextField(
                    controller: _deskripsiController,
                    label: 'Deskripsi',
                    hint: 'Masukkan deskripsi barang (opsional)',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildKategoriDropdown(),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              _buildFormCard(
                title: 'Harga & Stok',
                icon: Icons.monetization_on,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _hargaController,
                          label: 'Harga',
                          hint: '0',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Harga tidak boleh kosong';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Harga harus berupa angka';
                            }
                            if (double.parse(value) < 0) {
                              return 'Harga tidak boleh negatif';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(width: AppSpacing.md),
                      
                      Expanded(
                        child: _buildTextField(
                          controller: _stokController,
                          label: 'Stok',
                          hint: '0',
                          icon: Icons.inventory,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Stok tidak boleh kosong';
                            }
                            if (int.tryParse(value!) == null) {
                              return 'Stok harus berupa angka';
                            }
                            if (int.parse(value) < 0) {
                              return 'Stok tidak boleh negatif';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.grey400),
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  
                  const SizedBox(width: AppSpacing.md),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveBarang,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_isEdit ? 'Update' : 'Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
        border: Border.all(color: AppColors.grey200.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: AppColors.grey50,
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            color: AppColors.grey50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedKategori.isEmpty ? null : _selectedKategori,
              hint: Row(
                children: [
                  Icon(Icons.category, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Pilih kategori'),
                ],
              ),
              isExpanded: true,
              items: _kategoriList.map((String kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedKategori = newValue ?? '';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _saveBarang() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedKategori.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih kategori terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'nama': _namaController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'harga': double.parse(_hargaController.text),
        'stok': int.parse(_stokController.text),
        'kategori': _selectedKategori,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (_isEdit) {
        await FirebaseFirestore.instance
            .collection('barang')
            .doc(widget.barangId)
            .update(data);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Barang berhasil diperbarui'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        data['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('barang').add(data);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Barang berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan barang: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }
}
