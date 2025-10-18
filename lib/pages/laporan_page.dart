import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_theme.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selector
            _buildDateRangeCard(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Summary Cards
            Text(
              'Ringkasan Periode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            _buildSummarySection(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Top Products
            Text(
              'Produk Terlaris',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            _buildTopProductsSection(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Daily Sales Chart
            Text(
              'Penjualan Harian',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            _buildDailySalesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.date_range,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Periode Laporan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  'Dari',
                  _startDate,
                  (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildDateSelector(
                  'Sampai',
                  _endDate,
                  (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, Function(DateTime) onDateChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              onDateChanged(selectedDate);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: AppColors.grey50,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd MMM yyyy').format(date),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transaksi')
          .where('uid', isEqualTo: user.uid)
          .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        double totalPendapatan = 0;
        int totalTransaksi = 0;
        int totalItemTerjual = 0;

        if (snapshot.hasData) {
          totalTransaksi = snapshot.data!.docs.length;
          
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalPendapatan += (data['total'] ?? 0);
            
            final items = data['daftar_barang'] as List<dynamic>? ?? [];
            for (var item in items) {
              totalItemTerjual += (item['jumlah'] ?? 0) as int;
            }
          }
        }

        double avgPerTransaksi = totalTransaksi > 0 ? totalPendapatan / totalTransaksi : 0;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
          children: [
            _buildSummaryCard(
              'Total Pendapatan',
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(totalPendapatan),
              Icons.monetization_on,
              AppColors.success,
            ),
            _buildSummaryCard(
              'Total Transaksi',
              totalTransaksi.toString(),
              Icons.receipt,
              AppColors.info,
            ),
            _buildSummaryCard(
              'Item Terjual',
              totalItemTerjual.toString(),
              Icons.shopping_cart,
              AppColors.warning,
            ),
            _buildSummaryCard(
              'Rata-rata/Transaksi',
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(avgPerTransaksi),
              Icons.trending_up,
              AppColors.primary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
                  size: 20,
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
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transaksi')
          .where('uid', isEqualTo: user.uid)
          .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, Map<String, dynamic>> productSales = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final items = data['daftar_barang'] as List<dynamic>? ?? [];
            
            for (var item in items) {
              final productName = item['nama_barang'] ?? '';
              final quantity = (item['jumlah'] ?? 0) as int;
              final subtotal = (item['subtotal'] ?? 0);
              
              if (productSales.containsKey(productName)) {
                productSales[productName]!['quantity'] += quantity;
                productSales[productName]!['revenue'] += subtotal;
              } else {
                productSales[productName] = {
                  'quantity': quantity,
                  'revenue': subtotal,
                  'price': item['harga'] ?? 0,
                };
              }
            }
          }
        }

        // Sort by quantity sold
        var sortedProducts = productSales.entries.toList()
          ..sort((a, b) => b.value['quantity'].compareTo(a.value['quantity']));

        if (sortedProducts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.light,
            ),
            child: Center(
              child: Text(
                'Tidak ada data produk untuk periode ini',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.light,
          ),
          child: Column(
            children: sortedProducts.take(5).map((entry) {
              final productName = entry.key;
              final data = entry.value;
              final index = sortedProducts.indexOf(entry);
              
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: index > 0 ? Border(
                    top: BorderSide(color: AppColors.grey200.withValues(alpha: 0.5))
                  ) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getRankColor(index).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getRankColor(index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${data['quantity']} unit terjual',
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
                      ).format(data['revenue']),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0: return AppColors.warning;
      case 1: return AppColors.grey600;
      case 2: return AppColors.warning.withValues(alpha: 0.7);
      default: return AppColors.primary;
    }
  }

  Widget _buildDailySalesSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transaksi')
          .where('uid', isEqualTo: user.uid)
          .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
          .orderBy('tanggal')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, double> dailySales = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['tanggal'] as Timestamp).toDate();
            final dateKey = DateFormat('yyyy-MM-dd').format(date);
            final totalHarga = (data['total'] ?? 0).toDouble();
            
            dailySales[dateKey] = (dailySales[dateKey] ?? 0) + totalHarga;
          }
        }

        if (dailySales.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.light,
            ),
            child: Center(
              child: Text(
                'Tidak ada data penjualan untuk periode ini',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        // Sort by date and prepare chart data
        var sortedSales = dailySales.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        List<FlSpot> chartData = [];
        List<String> dates = [];
        
        for (int i = 0; i < sortedSales.length; i++) {
          chartData.add(FlSpot(i.toDouble(), sortedSales[i].value));
          dates.add(DateFormat('dd/MM').format(DateTime.parse(sortedSales[i].key)));
        }

        double maxY = chartData.isNotEmpty 
            ? chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
            : 0;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.light,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      horizontalInterval: maxY > 0 ? maxY / 5 : 1000,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.grey300,
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: AppColors.grey300,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              NumberFormat.compact().format(value),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < dates.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  dates[index],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: AppColors.grey300,
                        width: 1,
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: AppColors.surface,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.3),
                              AppColors.primary.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    minX: 0,
                    maxX: chartData.isNotEmpty ? (chartData.length - 1).toDouble() : 0,
                    minY: 0,
                    maxY: maxY * 1.1,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Penjualan Harian (Rp)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
