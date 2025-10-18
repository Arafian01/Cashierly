import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/app_theme.dart';
import '../widgets/low_stock_warning.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Toko'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
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
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.medium,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kelola toko Anda dengan mudah',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textLight.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: AppColors.textLight,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Low Stock Alert
              const _LowStockSection(),
              
              const SizedBox(height: AppSpacing.xl),

              // Statistics Section
              Text(
                'Statistik Toko',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              const _StatisticsGrid(),
              
              const SizedBox(height: AppSpacing.xl),

              // Recent Transactions
              Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              const _RecentTransactions(),
              
              const SizedBox(height: AppSpacing.xl),

              // Quick Actions
              Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              const _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.2,
      children: [
        _StatCard(
          title: 'Total Barang',
          icon: Icons.inventory,
          color: AppColors.success,
          future: _getTotalBarang(),
        ),
        _StatCard(
          title: 'Kategori',
          icon: Icons.category,
          color: AppColors.info,
          future: _getTotalKategori(),
        ),
        _StatCard(
          title: 'Transaksi Hari Ini',
          icon: Icons.receipt,
          color: AppColors.warning,
          future: _getTransaksiHariIni(),
        ),
        _StatCard(
          title: 'Pendapatan Hari Ini',
          icon: Icons.monetization_on,
          color: AppColors.primary,
          future: _getPendapatanHariIni(),
          isPrice: true,
        ),
      ],
    );
  }

  Future<int> _getTotalBarang() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;
    
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('barang')
        .where('uid', isEqualTo: user.uid)
        .get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalKategori() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;
    
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('kategori')
        .where('uid', isEqualTo: user.uid)
        .get();
    return snapshot.docs.length;
  }

  Future<int> _getTransaksiHariIni() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;
    
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('uid', isEqualTo: user.uid)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.length;
  }

  Future<double> _getPendapatanHariIni() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;
    
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('uid', isEqualTo: user.uid)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data() as Map<String, dynamic>)['total'] ?? 0;
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FutureBuilder<dynamic>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transaksi')
          .orderBy('tanggal_transaksi', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.light,
            ),
            child: Text(
              'Belum ada transaksi',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final tanggal = (data['tanggal_transaksi'] as Timestamp).toDate();
            final total = data['total_harga'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.light,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.receipt,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaksi ${doc.id.substring(0, 8)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(tanggal),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(total),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

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
          title: 'Tambah Barang',
          icon: Icons.add_box,
          color: AppColors.success,
          onTap: () {
            // Navigate to add barang page
            Navigator.pushNamed(context, '/add-barang');
          },
        ),
        _QuickActionCard(
          title: 'Transaksi Baru',
          icon: Icons.add_shopping_cart,
          color: AppColors.warning,
          onTap: () {
            // Navigate to transaksi page
            Navigator.pushNamed(context, '/transaksi');
          },
        ),
        _QuickActionCard(
          title: 'Lihat Laporan',
          icon: Icons.trending_up,
          color: AppColors.info,
          onTap: () {
            // Navigate to laporan page
            Navigator.pushNamed(context, '/laporan');
          },
        ),
        _QuickActionCard(
          title: 'Kelola Kategori',
          icon: Icons.category,
          color: AppColors.primary,
          onTap: () {
            // Navigate to kategori management
            Navigator.pushNamed(context, '/kategori');
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
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.light,
            border: Border.all(color: AppColors.grey200.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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

class _LowStockSection extends StatelessWidget {
  const _LowStockSection();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('barang')
          .where('uid', isEqualTo: user.uid)
          .where('stok', isLessThan: 5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        List<Map<String, dynamic>> lowStockItems = snapshot.data!.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'nama': data['nama_barang'] ?? '',
                'stok': data['stok'] ?? 0,
              };
            })
            .toList();

        return LowStockAlert(
          lowStockItems: lowStockItems,
          onViewAll: () {
            // Navigate to barang page with low stock filter
            Navigator.pushNamed(context, '/barang');
          },
        );
      },
    );
  }
}
