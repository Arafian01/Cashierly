import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/kategori.dart';
import '../providers/kategori_provider.dart';

class KategoriScreen extends StatelessWidget {
  const KategoriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kategoriProvider = Provider.of<KategoriProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: StreamBuilder<List<Kategori>>(
        stream: kategoriProvider.getKategori(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Kategori kategori = snapshot.data![index];
              return ListTile(
                title: Text(kategori.namaKategori),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showKategoriDialog(context, kategori: kategori),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        kategoriProvider.deleteKategori(kategori.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showKategoriDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showKategoriDialog(BuildContext context, {Kategori? kategori}) {
    final _formKey = GlobalKey<FormState>();
    String namaKategori = kategori?.namaKategori ?? '';
    final kategoriProvider = Provider.of<KategoriProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(kategori == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: namaKategori,
            decoration: const InputDecoration(labelText: 'Nama Kategori'),
            validator: (val) => val!.isEmpty ? 'Required' : null,
            onChanged: (val) => namaKategori = val,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newKategori = Kategori(id: kategori?.id ?? '', namaKategori: namaKategori);
                if (kategori == null) {
                  kategoriProvider.addKategori(newKategori);
                } else {
                  kategoriProvider.updateKategori(newKategori);
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