import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_theme.dart';
import '../screens/login_screen.dart';
import '../services/backup_service.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  bool _isBackupLoading = false;
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.medium,
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: AppColors.textLight,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Admin User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'admin@inventoryapp.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textLight.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text(
                      'Administrator',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Menu Sections
            _buildMenuSection(
              title: 'Profil',
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  subtitle: 'Ubah informasi pribadi Anda',
                  onTap: () => _showComingSoonDialog('Edit Profil'),
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  title: 'Ubah Password',
                  subtitle: 'Ganti kata sandi akun',
                  onTap: () => _showComingSoonDialog('Ubah Password'),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            _buildMenuSection(
              title: 'Pengaturan',
              items: [
                _MenuItem(
                  icon: Icons.notifications,
                  title: 'Notifikasi',
                  subtitle: 'Atur preferensi notifikasi',
                  onTap: () => _showComingSoonDialog('Pengaturan Notifikasi'),
                ),
                _MenuItem(
                  icon: Icons.language,
                  title: 'Bahasa',
                  subtitle: 'Bahasa Indonesia',
                  onTap: () => _showComingSoonDialog('Pengaturan Bahasa'),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Theme Toggle Section
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
              child: Text(
                'Tampilan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const _ThemeToggleItem(),
            
            const SizedBox(height: AppSpacing.lg),
            
            _buildMenuSection(
              title: 'Aplikasi',
              items: [
                _MenuItem(
                  icon: Icons.backup_outlined,
                  title: 'Backup Data',
                  subtitle: 'Cadangkan data toko Anda',
                  onTap: _showBackupDialog,
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Bantuan',
                  subtitle: 'FAQ dan panduan penggunaan',
                  onTap: () => _showComingSoonDialog('Bantuan'),
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Versi 1.0.0',
                  onTap: () => _showAboutDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Logout Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.light,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: _showLogoutDialog,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.logout,
                            color: AppColors.error,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                              Text(
                                'Keluar dari aplikasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.light,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              
              return Container(
                decoration: BoxDecoration(
                  border: !isLast ? Border(
                    bottom: BorderSide(
                      color: AppColors.grey200.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ) : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              item.icon,
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
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (item.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Segera Hadir'),
          ],
        ),
        content: Text('Fitur $feature sedang dalam pengembangan dan akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.store,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Tentang Aplikasi'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Versi: 1.0.0'),
            Text('Build: 2024.10.18'),
            SizedBox(height: 16),
            Text(
              'Aplikasi manajemen inventory untuk toko kelontong dengan fitur lengkap untuk mengelola barang, transaksi, dan laporan penjualan.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 Inventory App. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showBackupDialog() {
    BackupService.showBackupDialog(
      context,
      isLoading: _isBackupLoading,
      onBackup: _performBackup,
    );
  }

  Future<void> _performBackup() async {
    setState(() {
      _isBackupLoading = true;
    });

    try {
      final filePath = await BackupService.createBackup();
      
      Navigator.pop(context); // Close backup dialog
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup berhasil disimpan!\nLokasi: $filePath'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: AppColors.textLight,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close backup dialog
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup gagal: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackupLoading = false;
        });
      }
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

class _ThemeToggleItem extends StatelessWidget {
  const _ThemeToggleItem();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.light,
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
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
                          'Mode Gelap',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          themeProvider.isDarkMode ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
