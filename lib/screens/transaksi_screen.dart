import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/barang.dart';
import '../model/transaksi.dart';
import '../model/detail_transaksi.dart';
import '../providers/barang_provider.dart';
import '../providers/transaksi_provider.dart';
import '../widgets/responsive_container.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _DetailEntry {
  Barang? barang;
  int jumlah;
  double subTotal;

  _DetailEntry()
      : barang = null,
        jumlah = 1,
        subTotal = 0;
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final NumberFormat _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(
      builder: (context, transaksiProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Transaksi')),
          body: ResponsiveContainer(
            child: Column(
              children: [
                // Error message display
                if (transaksiProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaksiProvider.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => transaksiProvider.clearError(),
                          color: Colors.red.shade700,
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
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('Terjadi kesalahan: ${snapshot.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => transaksiProvider.clearError(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      final transaksiList = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: transaksiList.length,
                        itemBuilder: (context, index) {
                          final transaksi = transaksiList[index];
                          return _buildTransaksiCard(context, transaksi);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateTransaksiSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Transaksi'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.receipt_long, size: 96, color: Colors.redAccent),
        SizedBox(height: 16),
        Text('Belum ada transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        SizedBox(height: 12),
        Text('Tekan tombol tambah untuk membuat transaksi pertama Anda.', textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildTransaksiCard(BuildContext context, Transaksi transaksi) {
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final statusColor = transaksi.status.toLowerCase() == 'lunas' ? Colors.green : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    transaksi.nama,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Chip(
                  backgroundColor: statusColor.withOpacity(0.12),
                  labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                  label: Text(transaksi.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoTile('Tanggal', DateFormat('dd MMMM yyyy', 'id_ID').format(transaksi.tanggal)),
                _buildInfoTile('Total', _currency.format(transaksi.total)),
                _buildInfoTile('Bayar', _currency.format(transaksi.bayar)),
                _buildInfoTile('Sisa', _currency.format(transaksi.sisa)),
                if (transaksi.tanggalBayar != null)
                  _buildInfoTile('Tanggal Bayar', DateFormat('dd MMMM yyyy', 'id_ID').format(transaksi.tanggalBayar!)),
              ],
            ),
            if (transaksi.keterangan != null && transaksi.keterangan!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(transaksi.keterangan!, style: TextStyle(color: Colors.grey[700])),
            ],
            const SizedBox(height: 16),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: const Text('Detail Transaksi', style: TextStyle(fontWeight: FontWeight.w600)),
              children: [
                StreamBuilder<List<DetailTransaksi>>(
                  stream: transaksiProvider.getDetailTransaksi(transaksi.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final details = snapshot.data ?? [];
                    if (details.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Belum ada detail transaksi.'),
                      );
                    }
                    return Column(
                      children: details
                          .map(
                            (detail) => FutureBuilder<DocumentSnapshot>(
                              future: detail.idBarang.get(),
                              builder: (context, barangSnapshot) {
                                final namaBarang = barangSnapshot.data != null
                                    ? (barangSnapshot.data!.data() as Map<String, dynamic>)['nama_barang'] ?? 'Barang'
                                    : 'Memuat...';
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(namaBarang),
                                  subtitle: Text('Jumlah: ${detail.jumlah}\nSubtotal: ${_currency.format(detail.subTotal)}'),
                                );
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showAddDetailSheet(context, transaksi),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Tambah Detail'),
                ),
                FilledButton.icon(
                  onPressed: () => _showUpdateStatusSheet(transaksi),
                  icon: const Icon(Icons.payments_rounded),
                  label: const Text('Atur Pembayaran'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDeleteTransaksi(transaksi),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _showCreateTransaksiSheet(BuildContext context) async {
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    final namaController = TextEditingController();
    final bayarController = TextEditingController(text: '0');
    final totalController = TextEditingController(text: '0');
    final sisaController = TextEditingController(text: '0');
    final keteranganController = TextEditingController();

    DateTime tanggal = DateTime.now();
    DateTime? tanggalBayar;
    String status = 'Belum Lunas';

    final detailEntries = <_DetailEntry>[_DetailEntry()];

    void recalculateTotals(StateSetter setModalState) {
      final total = detailEntries.fold<double>(0, (sum, entry) {
        final harga = entry.barang?.harga ?? 0;
        entry.subTotal = harga * entry.jumlah;
        return sum + entry.subTotal;
      });
      totalController.text = total.toStringAsFixed(0);
      final bayar = double.tryParse(bayarController.text.replaceAll(',', '.')) ?? 0;
      double sisa = total - bayar;
      if (sisa < 0) sisa = 0;
      sisaController.text = status.toLowerCase() == 'lunas' ? '0' : sisa.toStringAsFixed(0);
      setModalState(() {});
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.85,
                maxChildSize: 0.95,
                minChildSize: 0.6,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: StreamBuilder<List<Barang>>(
                      stream: barangProvider.getBarang(),
                      builder: (context, snapshot) {
                        final barangList = snapshot.data ?? [];
                        return Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text('Transaksi Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: namaController,
                                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                                validator: (val) => (val == null || val.isEmpty) ? 'Nama wajib diisi' : null,
                              ),
                              const SizedBox(height: 16),
                              _DatePickerField(
                                label: 'Tanggal Transaksi',
                                selectedDate: tanggal,
                                onDateSelected: (picked) {
                                  if (picked != null) {
                                    tanggal = picked;
                                    setModalState(() {});
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: status,
                                decoration: const InputDecoration(labelText: 'Status Pembayaran'),
                                items: const [
                                  DropdownMenuItem(value: 'Lunas', child: Text('Lunas')),
                                  DropdownMenuItem(value: 'Belum Lunas', child: Text('Belum Lunas')),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  status = value;
                                  if (status.toLowerCase() == 'lunas') {
                                    tanggalBayar = tanggalBayar ?? DateTime.now();
                                    sisaController.text = '0';
                                  }
                                  setModalState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              if (status.toLowerCase() == 'lunas')
                                _DatePickerField(
                                  label: 'Tanggal Bayar',
                                  selectedDate: tanggalBayar ?? DateTime.now(),
                                  onDateSelected: (picked) {
                                    tanggalBayar = picked;
                                    setModalState(() {});
                                  },
                                ),
                              const SizedBox(height: 24),
                              const Text('Detail Barang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              ...detailEntries.asMap().entries.map((entry) {
                                final index = entry.key;
                                final detail = entry.value;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: detail.barang?.id,
                                                decoration: const InputDecoration(labelText: 'Pilih Barang'),
                                                items: barangList
                                                    .map(
                                                      (barang) => DropdownMenuItem(
                                                        value: barang.id,
                                                        child: Text(barang.namaBarang),
                                                      ),
                                                    )
                                                    .toList(),
                                                validator: (val) => (val == null || val.isEmpty) ? 'Wajib pilih barang' : null,
                                                onChanged: (value) {
                                                  if (value == null || barangList.isEmpty) return;
                                                  final selected = barangList.firstWhere(
                                                    (barang) => barang.id == value,
                                                    orElse: () => barangList.first,
                                                  );
                                                  detail.barang = selected;
                                                  recalculateTotals(setModalState);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            if (detailEntries.length > 1)
                                              IconButton(
                                                onPressed: () {
                                                  detailEntries.removeAt(index);
                                                  if (detailEntries.isEmpty) {
                                                    detailEntries.add(_DetailEntry());
                                                  }
                                                  recalculateTotals(setModalState);
                                                },
                                                icon: const Icon(Icons.delete_outline),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: detail.jumlah.toString(),
                                                decoration: const InputDecoration(labelText: 'Jumlah'),
                                                keyboardType: TextInputType.number,
                                                validator: (val) => (val == null || val.isEmpty) ? 'Masukkan jumlah' : null,
                                                onChanged: (val) {
                                                  final parsed = int.tryParse(val) ?? 0;
                                                  detail.jumlah = parsed;
                                                  recalculateTotals(setModalState);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                _currency.format(detail.subTotal),
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              TextButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    detailEntries.add(_DetailEntry());
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Tambah Barang'),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: totalController,
                                decoration: const InputDecoration(labelText: 'Total'),
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: bayarController,
                                decoration: const InputDecoration(labelText: 'Bayar'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (val) => recalculateTotals(setModalState),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: sisaController,
                                decoration: const InputDecoration(labelText: 'Sisa'),
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: keteranganController,
                                decoration: const InputDecoration(labelText: 'Keterangan (opsional)'),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate()) return;
                                    final validDetails = detailEntries.where((detail) => detail.barang != null && detail.jumlah > 0).toList();
                                    if (validDetails.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Minimal tambahkan satu detail barang.')),
                                      );
                                      return;
                                    }

                                    final total = double.tryParse(totalController.text) ?? 0;
                                    final bayar = double.tryParse(bayarController.text) ?? 0;
                                    double sisa = double.tryParse(sisaController.text) ?? (total - bayar);
                                    if (sisa < 0) sisa = 0;

                                    final transaksi = Transaksi(
                                      id: '',
                                      nama: namaController.text,
                                      tanggal: tanggal,
                                      total: total,
                                      bayar: bayar,
                                      sisa: status.toLowerCase() == 'lunas' ? 0 : sisa,
                                      status: status,
                                      tanggalBayar: status.toLowerCase() == 'lunas'
                                          ? (tanggalBayar ?? DateTime.now())
                                          : tanggalBayar,
                                      keterangan: keteranganController.text,
                                    );

                                    final detailPayload = validDetails
                                        .map(
                                          (detail) => DetailTransaksiForm(
                                            idBarang: FirebaseFirestore.instance.collection('barang').doc(detail.barang!.id),
                                            jumlah: detail.jumlah,
                                            subTotal: detail.subTotal,
                                          ),
                                        )
                                        .toList();

                                    await transaksiProvider.createTransaksiWithDetails(
                                      transaksi: transaksi,
                                      detailItems: detailPayload,
                                    );

                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Transaksi berhasil dibuat.')),
                                    );
                                  },
                                  child: const Text('Simpan Transaksi'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showAddDetailSheet(BuildContext context, Transaksi transaksi) async {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    Barang? selectedBarang;
    int jumlah = 1;
    double subTotal = 0;

    void recalcSubtotal() {
      final harga = selectedBarang?.harga ?? 0;
      subTotal = harga * jumlah;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.55,
                maxChildSize: 0.75,
                minChildSize: 0.4,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: StreamBuilder<List<Barang>>(
                      stream: barangProvider.getBarang(),
                      builder: (context, snapshot) {
                        final barangList = snapshot.data ?? [];
                        return Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text('Tambah Detail Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: selectedBarang?.id,
                                decoration: const InputDecoration(labelText: 'Pilih Barang'),
                                items: barangList
                                    .map(
                                      (barang) => DropdownMenuItem(
                                        value: barang.id,
                                        child: Text(barang.namaBarang),
                                      ),
                                    )
                                    .toList(),
                                validator: (val) => (val == null || val.isEmpty) ? 'Wajib pilih barang' : null,
                                onChanged: (value) {
                                  if (value == null || barangList.isEmpty) return;
                                  final found = barangList.firstWhere((barang) => barang.id == value, orElse: () => barangList.first);
                                  selectedBarang = found;
                                  recalcSubtotal();
                                  setModalState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: jumlah.toString(),
                                decoration: const InputDecoration(labelText: 'Jumlah'),
                                keyboardType: TextInputType.number,
                                validator: (val) => (val == null || val.isEmpty) ? 'Masukkan jumlah' : null,
                                onChanged: (val) {
                                  jumlah = int.tryParse(val) ?? 1;
                                  if (jumlah <= 0) jumlah = 1;
                                  recalcSubtotal();
                                  setModalState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              Text('Subtotal: ${_currency.format(subTotal)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate()) return;
                                    if (selectedBarang == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Pilih barang terlebih dahulu.')),
                                      );
                                      return;
                                    }

                                    recalcSubtotal();

                                    await transaksiProvider.addDetailToTransaksi(
                                      transaksi.id,
                                      DetailTransaksiForm(
                                        idBarang: FirebaseFirestore.instance.collection('barang').doc(selectedBarang!.id),
                                        jumlah: jumlah,
                                        subTotal: subTotal,
                                      ),
                                    );

                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Detail transaksi ditambahkan.')),
                                    );
                                  },
                                  child: const Text('Simpan Detail'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showUpdateStatusSheet(Transaksi transaksi) async {
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    String status = transaksi.status;
    DateTime? tanggalBayar = transaksi.tanggalBayar;
    final bayarController = TextEditingController(text: transaksi.bayar.toStringAsFixed(0));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Atur Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(labelText: 'Status Pembayaran'),
                        items: const [
                          DropdownMenuItem(value: 'Lunas', child: Text('Lunas')),
                          DropdownMenuItem(value: 'Belum Lunas', child: Text('Belum Lunas')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          status = value;
                          if (status.toLowerCase() == 'lunas') {
                            tanggalBayar = tanggalBayar ?? DateTime.now();
                            bayarController.text = transaksi.total.toStringAsFixed(0);
                          }
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: bayarController,
                        decoration: const InputDecoration(labelText: 'Nominal Bayar'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => (val == null || val.isEmpty) ? 'Nominal wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      if (status.toLowerCase() == 'lunas')
                        _DatePickerField(
                          label: 'Tanggal Bayar',
                          selectedDate: tanggalBayar ?? DateTime.now(),
                          onDateSelected: (picked) {
                            tanggalBayar = picked;
                            setModalState(() {});
                          },
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            final bayar = double.tryParse(bayarController.text) ?? transaksi.bayar;
                            double sisa = transaksi.total - bayar;
                            if (sisa < 0) sisa = 0;

                            await transaksiProvider.updateStatus(
                              transaksiId: transaksi.id,
                              status: status,
                              bayar: bayar,
                              sisa: status.toLowerCase() == 'lunas' ? 0 : sisa,
                              tanggalBayar: status.toLowerCase() == 'lunas' ? (tanggalBayar ?? DateTime.now()) : null,
                            );

                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Status pembayaran diperbarui.')),
                            );
                          },
                          child: const Text('Simpan Perubahan'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteTransaksi(Transaksi transaksi) async {
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Anda yakin ingin menghapus transaksi "${transaksi.nama}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await transaksiProvider.deleteTransaksi(transaksi.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi dihapus.')),
      );
    }
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        onDateSelected(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate)),
            const Icon(Icons.calendar_today_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
