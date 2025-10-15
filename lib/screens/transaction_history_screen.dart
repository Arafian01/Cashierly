import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/transaksi.dart';
import '../providers/transaksi_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/search_header.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaksi> _filterTransaksi(List<Transaksi> transaksiList) {
    if (_searchQuery.isEmpty) return transaksiList;
    
    return transaksiList.where((transaksi) => 
      transaksi.kodeTransaksi.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
      case 'completed':
      case 'success':
        return const Color(0xFF10B981); // Green - Completed
      case 'belum lunas':
      case 'pending':
        return const Color(0xFFF59E0B); // Orange - Pending
      case 'dibatalkan':
      case 'failed':
      case 'cancelled':
        return AppColors.error; // Red - Failed/Cancelled
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
      case 'completed':
      case 'success':
        return Icons.check_circle;
      case 'belum lunas':
      case 'pending':
        return Icons.schedule;
      case 'dibatalkan':
      case 'failed':
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
        return 'Completed';
      case 'belum lunas':
        return 'Pending';
      case 'dibatalkan':
        return 'Failed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(
      builder: (context, transaksiProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white),
                SizedBox(width: 8),
                Text('Transaction History'),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Modern Search Header
                SearchHeader(
                  title: 'Recent Transactions',
                  searchController: _searchController,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                // Error message display
                if (transaksiProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            transaksiProvider.errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error),
                          onPressed: () => transaksiProvider.clearError(),
                        ),
                      ],
                    ),
                  ),
                
                Expanded(
                  child: StreamBuilder<List<Transaksi>>(
                    stream: transaksiProvider.getTransaksi(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                              const SizedBox(height: AppSpacing.lg),
                              Text('Terjadi kesalahan: ${snapshot.error}'),
                              const SizedBox(height: AppSpacing.lg),
                              ElevatedButton(
                                onPressed: () => transaksiProvider.clearError(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }

                      final transaksiList = snapshot.data ?? [];
                      final filteredList = _filterTransaksi(transaksiList);
                      
                      if (transaksiList.isEmpty) {
                        return _buildEmptyState();
                      }
                      
                      if (filteredList.isEmpty && _searchQuery.isNotEmpty) {
                        return _buildNoSearchResults();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final transaksi = filteredList[index];
                          return _TransactionCard(
                            transaksi: transaksi,
                            currencyFormatter: _currencyFormatter,
                            getStatusColor: _getStatusColor,
                            getStatusIcon: _getStatusIcon,
                            getStatusDisplayText: _getStatusDisplayText,
                            onTap: () => _showTransactionDetail(transaksi),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 96, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Belum ada transaksi', 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Transaksi akan muncul di sini setelah Anda melakukan pembelian.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 96, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tidak ada hasil untuk "$_searchQuery"',
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Coba kata kunci lain untuk mencari transaksi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(Transaksi transaksi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailModal(
        transaksi: transaksi,
        currencyFormatter: _currencyFormatter,
        getStatusColor: _getStatusColor,
        getStatusIcon: _getStatusIcon,
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaksi transaksi;
  final NumberFormat currencyFormatter;
  final Color Function(String) getStatusColor;
  final IconData Function(String) getStatusIcon;
  final String Function(String) getStatusDisplayText;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaksi,
    required this.currencyFormatter,
    required this.getStatusColor,
    required this.getStatusIcon,
    required this.getStatusDisplayText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaksi.kodeTransaksi,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm', 'en_US').format(transaksi.tanggalTransaksi),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor('Completed').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getStatusIcon('Completed'),
                          size: 14,
                          color: getStatusColor('Completed'),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          getStatusDisplayText('Completed'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: getStatusColor('Completed'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Amount Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(transaksi.totalHarga),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (transaksi.sisa > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Remaining',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Rp 0',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              // View Detail Button
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionDetailModal extends StatelessWidget {
  final Transaksi transaksi;
  final NumberFormat currencyFormatter;
  final Color Function(String) getStatusColor;
  final IconData Function(String) getStatusIcon;

  const _TransactionDetailModal({
    required this.transaksi,
    required this.currencyFormatter,
    required this.getStatusColor,
    required this.getStatusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detail Transaksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Transaction Details
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Info
                  _buildDetailRow('Kode Transaksi', transaksi.kodeTransaksi),
                  _buildDetailRow('Tanggal Transaksi', DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(transaksi.tanggalTransaksi)),
                  
                  // Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor('Completed').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getStatusIcon('Completed'),
                              size: 16,
                              color: getStatusColor('Completed'),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: getStatusColor('Completed'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Payment Info
                  const Text(
                    'Informasi Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildDetailRow('Total', currencyFormatter.format(transaksi.total)),
                  _buildDetailRow('Dibayar', currencyFormatter.format(transaksi.bayar)),
                  _buildDetailRow('Sisa', currencyFormatter.format(transaksi.sisa)),
                  
                  if (transaksi.tanggalBayar != null)
                    _buildDetailRow('Tanggal Bayar', DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(transaksi.tanggalBayar!)),
                  
                  if (transaksi.keterangan != null && transaksi.keterangan!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Keterangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Text(
                        transaksi.keterangan!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
