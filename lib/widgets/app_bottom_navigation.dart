import 'package:flutter/material.dart';
import 'app_theme.dart';

enum BottomNavItem {
  dashboard,
  barang,
  transaksi,
}

class AppBottomNavigation extends StatelessWidget {
  final BottomNavItem currentItem;
  final Function(BottomNavItem) onItemTapped;

  const AppBottomNavigation({
    super.key,
    required this.currentItem,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isActive: currentItem == BottomNavItem.dashboard,
                onTap: () => onItemTapped(BottomNavItem.dashboard),
              ),
              _NavItem(
                icon: Icons.inventory_2_rounded,
                label: 'Barang',
                isActive: currentItem == BottomNavItem.barang,
                onTap: () => onItemTapped(BottomNavItem.barang),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'Transaksi',
                isActive: currentItem == BottomNavItem.transaksi,
                onTap: () => onItemTapped(BottomNavItem.transaksi),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, isActive ? -2 : 0, 0),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isActive ? AppColors.primary : AppColors.grey400,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? AppColors.primary : AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
