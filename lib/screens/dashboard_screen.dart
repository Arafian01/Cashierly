import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/barang.dart';
import '../model/kategori.dart';
import '../model/transaksi.dart';
import '../providers/auth_provider.dart';
import '../providers/barang_provider.dart';
import '../providers/kategori_provider.dart';
import '../providers/transaksi_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
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
          AppButton(
            text: 'Keluar',
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
            icon: Icons.logout_rounded,
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Pantau inventaris, kategori, dan transaksi dalam satu tempat.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Statistics Section
              Text(
                'Statistik',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Statistics Cards - Mobile Responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                  final childAspectRatio = constraints.maxWidth > 600 ? 1.3 : 1.1;
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                children: [
                  StreamBuilder<List<Kategori>>(
                    stream: kategoriProvider.getKategori(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return StatCard(
                        title: 'Kategori',
                        value: count.toString(),
                        icon: Icons.category_rounded,
                        color: AppColors.primary,
                        isLoading: snapshot.connectionState == ConnectionState.waiting,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KategoriScreen())),
                      );
                    },
                  ),
                  StreamBuilder<List<Barang>>(
                    stream: barangProvider.getBarang(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return StatCard(
                        title: 'Barang',
                        value: count.toString(),
                        icon: Icons.inventory_2_rounded,
                        color: const Color(0xFF10B981), // Green
                        isLoading: snapshot.connectionState == ConnectionState.waiting,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangScreen())),
                      );
                    },
                  ),
                  StreamBuilder<List<Transaksi>>(
                    stream: transaksiProvider.getTransaksi(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return StatCard(
                        title: 'Transaksi',
                        value: count.toString(),
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFFF59E0B), // Orange
                        isLoading: snapshot.connectionState == ConnectionState.waiting,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransaksiScreen())),
                      );
                    },
                  ),
                  // Add a new card for Cart or Quick Actions
                  StatCard(
                    title: 'Aksi Cepat',
                    value: '★',
                    icon: Icons.flash_on_rounded,
                    color: AppColors.error,
                    onTap: () {
                      // Show quick actions dialog or navigate to cart
                    },
                  ),
                ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Quick Actions Section
              Text(
                'Kelola Modul',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              InfoCard(
                title: 'Kelola Kategori',
                subtitle: 'Tambah, edit, dan hapus kategori barang.',
                icon: Icons.category_outlined,
                iconColor: AppColors.primary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KategoriScreen())),
              ),
              InfoCard(
                title: 'Kelola Barang',
                subtitle: 'Atur stok, harga, dan informasi barang.',
                icon: Icons.inventory_outlined,
                iconColor: const Color(0xFF10B981),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarangScreen())),
              ),
              InfoCard(
                title: 'Kelola Transaksi',
                subtitle: 'Catat penjualan, pembayaran, serta detail barang.',
                icon: Icons.point_of_sale_rounded,
                iconColor: const Color(0xFFF59E0B),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransaksiScreen())),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}