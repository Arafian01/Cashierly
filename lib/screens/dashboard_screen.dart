import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/barang.dart';
import '../providers/auth_provider.dart';
import '../providers/barang_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_button.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final barangProvider = Provider.of<BarangProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Savings Bank'),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            'Flutter Savings Bank',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Manage your accounts and transactions securely.',
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
                        Icons.inventory,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // My Accounts Section
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 30),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'My Accounts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Inventory by Category Section
              Row(
                children: [
                  const Icon(Icons.category, color: AppColors.primary, size: 30),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Inventory by Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Category Cards
              StreamBuilder<List<Barang>>(
                stream: barangProvider.getBarang(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final barangList = snapshot.data ?? [];
                  return _buildCategoryCards(barangList);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCards(List<Barang> barangList) {
    // Group items by category
    Map<String, List<Barang>> groupedByCategory = {};
    
    for (var barang in barangList) {
      // We'll need to get the category name from the reference
      // For now, we'll use a placeholder approach
      String categoryKey = barang.idKategori;
      if (!groupedByCategory.containsKey(categoryKey)) {
        groupedByCategory[categoryKey] = [];
      }
      groupedByCategory[categoryKey]!.add(barang);
    }

    if (groupedByCategory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.grey400),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No items in inventory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Add some items to see category breakdown',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      children: groupedByCategory.entries.map((entry) {
        return CategoryCard(
          categoryId: entry.key,
          itemCount: entry.value.length,
          items: entry.value,
        );
      }).toList(),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String categoryId;
  final int itemCount;
  final List<Barang> items;

  const CategoryCard({
    super.key,
    required this.categoryId,
    required this.itemCount,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: () {
            // Navigate to category details or barang screen filtered by category
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              color: AppColors.surface,
              boxShadow: AppShadows.light,
              border: Border.all(color: AppColors.grey200.withOpacity(0.5)),
            ),
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('kategori').doc(categoryId).get(),
              builder: (context, snapshot) {
                String categoryName = 'Loading...';
                if (snapshot.hasData && snapshot.data!.exists) {
                  categoryName = snapshot.data!.get('nama_kategori') ?? 'Unknown Category';
                }
                
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '$itemCount items',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        itemCount.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
