import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_button.dart';
import 'login_screen.dart';
import 'kategori_screen.dart';
import 'barang_screen.dart';
import 'transaksi_screen.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Kelontong'),
        actions: [
          AppButton(
            text: 'Keluar',
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
            icon: Icons.logout_rounded,
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang di',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            'Sistem Inventory',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Kelola barang dan transaksi toko dengan mudah.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Statistics Cards
              Text(
                'Ringkasan Data',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              const _StatisticsSection(),
              
              const SizedBox(height: AppSpacing.xl),

              // Quick Actions
              Text(
                'Menu Utama',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              const _QuickActionsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          title: 'Total Kategori',
          icon: Icons.category,
          color: Colors.blue,
          future: _getTotalKategori(),
        ),
        _StatCard(
          title: 'Total Barang',
          icon: Icons.inventory,
          color: Colors.green,
          future: _getTotalBarang(),
        ),
        _StatCard(
          title: 'Total Transaksi',
          icon: Icons.receipt,
          color: Colors.orange,
          future: _getTotalTransaksi(),
        ),
        _StatCard(
          title: 'Pendapatan Hari Ini',
          icon: Icons.attach_money,
          color: Colors.purple,
          future: _getPendapatanHariIni(),
          isPrice: true,
        ),
      ],
    );
  }

  Future<int> _getTotalKategori() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('kategori').get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalBarang() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('barang').get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalTransaksi() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('transaksi').get();
    return snapshot.docs.length;
  }

  Future<double> _getPendapatanHariIni() async {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('tanggal_transaksi', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal_transaksi', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data() as Map<String, dynamic>)['total_harga'] ?? 0;
    }
    return total;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Future<dynamic> future;
  final bool isPrice;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.future,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.light,
        border: Border.all(color: AppColors.grey200.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FutureBuilder<dynamic>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                );
              }

              String value;
              if (isPrice) {
                value = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(snapshot.data ?? 0);
              } else {
                value = (snapshot.data ?? 0).toString();
              }

              return Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.1,
      children: [
        _QuickActionCard(
          title: 'Kelola Kategori',
          icon: Icons.category,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KategoriScreen()),
            );
          },
        ),
        _QuickActionCard(
          title: 'Kelola Barang',
          icon: Icons.inventory,
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BarangScreen()),
            );
          },
        ),
        _QuickActionCard(
          title: 'Transaksi Baru',
          icon: Icons.add_shopping_cart,
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransaksiScreen()),
            );
          },
        ),
        _QuickActionCard(
          title: 'Riwayat Transaksi',
          icon: Icons.history,
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.light,
            border: Border.all(color: AppColors.grey200.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
