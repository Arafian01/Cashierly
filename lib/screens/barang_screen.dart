// lib/screens/barang_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/barang.dart';
import '../model/kategori.dart';
import '../providers/barang_provider.dart';
import '../providers/kategori_provider.dart';

class BarangScreen extends StatelessWidget {
  const BarangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final barangProvider = Provider.of<BarangProvider>(context);
    final kategoriProvider = Provider.of<KategoriProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Barang')),
      body: StreamBuilder<List<Barang>>(
        stream: barangProvider.getBarang(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print("No data or loading: ${snapshot.error}"); // Debug
            return const Center(child: CircularProgressIndicator());
          }
          final barangList = snapshot.data!;
          return ListView.builder(
            itemCount: barangList.length,
            itemBuilder: (context, index) {
              Barang barang = barangList[index];
              return FutureBuilder<DocumentSnapshot>(
                future: barang.idKategori.get(),
                builder: (context, katSnapshot) {
                  if (!katSnapshot.hasData) {
                    print("Loading kategori for ${barang.id}"); // Debug
                    return const ListTile(title: Text('Loading...'));
                  }
                  String namaKategori = katSnapshot.data!['nama_kategori'] ?? 'Unknown';
                  return ListTile(
                    title: Text(barang.namaBarang),
                    subtitle: Text('Harga: ${barang.harga}, Stok: ${barang.stok}, Kategori: $namaKategori'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showBarangDialog(context, barang: barang),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            barangProvider.deleteBarang(barang.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBarangDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBarangDialog(BuildContext context, {Barang? barang}) {
    final _formKey = GlobalKey<FormState>();
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
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: namaBarang,
                    decoration: const InputDecoration(labelText: 'Nama Barang'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                    onChanged: (val) => namaBarang = val,
                  ),
                  TextFormField(
                    initialValue: harga.toString(),
                    decoration: const InputDecoration(labelText: 'Harga'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                    onChanged: (val) => harga = double.tryParse(val) ?? 0.0,
                  ),
                  TextFormField(
                    initialValue: stok.toString(),
                    decoration: const InputDecoration(labelText: 'Stok'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                    onChanged: (val) => stok = int.tryParse(val) ?? 0,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedKategoriId,
                    hint: const Text('Pilih Kategori'),
                    validator: (val) => val == null ? 'Required' : null,
                    items: snapshot.data!.map((kat) => DropdownMenuItem(value: kat.id, child: Text(kat.namaKategori))).toList(),
                    onChanged: (val) => selectedKategoriId = val,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newBarang = Barang(
                  id: barang?.id ?? '',
                  namaBarang: namaBarang,
                  harga: harga,
                  stok: stok,
                  idKategori: FirebaseFirestore.instance.collection('kategori').doc(selectedKategoriId),
                );
                if (barang == null) {
                  barangProvider.addBarang(newBarang);
                } else {
                  barangProvider.updateBarang(newBarang);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}