import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/kategori_provider.dart';
import '../providers/barang_provider.dart';
import '../model/kategori.dart';
import '../model/barang.dart';
import 'kategori_screen.dart';
import 'barang_screen.dart';
import 'login_screen.dart'; // Add this import

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kategoriProvider = Provider.of<KategoriProvider>(context);
    final barangProvider = Provider.of<BarangProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<List<Kategori>>(
            stream: kategoriProvider.getKategori(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return ListTile(title: Text('Kategori: ${snapshot.data!.length}'));
            },
          ),
          StreamBuilder<List<Barang>>(
            stream: barangProvider.getBarang(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return ListTile(title: Text('Barang: ${snapshot.data!.length}'));
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KategoriScreen())),
            child: const Text('Kelola Kategori'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangScreen())),
            child: const Text('Kelola Barang'),
          ),
        ],
      ),
    );
  }
}