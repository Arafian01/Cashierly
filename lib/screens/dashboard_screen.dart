import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/barang.dart';
import '../model/kategori.dart';
import '../model/transaksi.dart';
import '../providers/auth_provider.dart';
import '../providers/barang_provider.dart';
import '../providers/kategori_provider.dart';
import '../providers/transaksi_provider.dart';
import '../widgets/responsive_container.dart';
import 'barang_screen.dart';
import 'kategori_screen.dart';
import 'login_screen.dart';
import 'transaksi_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kategoriProvider = Provider.of<KategoriProvider>(context);
    final barangProvider = Provider.of<BarangProvider>(context);
    final transaksiProvider = Provider.of<TransaksiProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Inventaris'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Pantau inventaris, kategori, dan transaksi dalam satu tempat dengan tampilan modern.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  StreamBuilder<List<Kategori>>(
                    stream: kategoriProvider.getKategori(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return _SummaryCard(
                        title: 'Kategori',
                        icon: Icons.category_rounded,
                        count: count,
                        accentColor: Colors.redAccent,
                        isLoading: snapshot.connectionState == ConnectionState.waiting,
                      );
                    },
                  ),
                  StreamBuilder<List<Barang>>(
                    stream: barangProvider.getBarang(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return _SummaryCard(
                        title: 'Barang',
                        icon: Icons.inventory_2_rounded,
                        count: count,
                        accentColor: Colors.red,
                        isLoading: snapshot.connectionState == ConnectionState.waiting,
                      );
                    },
                  ),
                  StreamBuilder<List<Transaksi>>(
                    stream: transaksiProvider.getTransaksi(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return _SummaryCard(
                        title: 'Transaksi',
                        icon: Icons.receipt_long_rounded,
                        count: count,
                        accentColor: Colors.deepOrange,
                        isLoading: snapshot.connectionState == ConnectionState.waiting,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Kelola Modul',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _NavigationCard(
                    title: 'Kelola Kategori',
                    description: 'Tambah, edit, dan hapus kategori barang.',
                    icon: Icons.category_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KategoriScreen())),
                  ),
                  _NavigationCard(
                    title: 'Kelola Barang',
                    description: 'Atur stok, harga, dan informasi barang.',
                    icon: Icons.inventory_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangScreen())),
                  ),
                  _NavigationCard(
                    title: 'Kelola Transaksi',
                    description: 'Catat penjualan, pembayaran, serta detail barang.',
                    icon: Icons.point_of_sale_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransaksiScreen())),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color accentColor;
  final bool isLoading;

  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.accentColor,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.4))
                  : Text(
                      '$count',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.redAccent, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Lihat selengkapnya', style: TextStyle(fontWeight: FontWeight.w600)),
                    Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}