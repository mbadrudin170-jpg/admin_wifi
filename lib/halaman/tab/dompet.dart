// path: lib/halaman/tab/dompet.dart
// File ini menampilkan halaman dompet yang berisi ringkasan keuangan (pemasukan, pengeluaran, total)
// dan daftar semua dompet yang tersedia. Pengguna dapat menambahkan dompet baru melalui
// tombol floating action.

import 'package:admin_wifi/utils/format_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_dompet.dart';
import 'package:admin_wifi/halaman/form/form_dompet.dart';
import 'package:admin_wifi/model/dompet_model.dart';

class DompetPage extends StatefulWidget {
  const DompetPage({super.key});

  @override
  State<DompetPage> createState() => _DompetPageState();
}

class _DompetPageState extends State<DompetPage> {
  final DompetOperasi _dompetOperasi = DompetOperasi();
  final GlobalKey<_RingkasanKeuanganState> _ringkasanKey = GlobalKey();
  late Future<List<DompetModel>> _listaDompetFuture;

  @override
  void initState() {
    super.initState();
    _loadDompet();
  }

  // Fungsi untuk memuat ulang data dompet dan ringkasan keuangan
  void _loadDompet() {
    setState(() {
      _listaDompetFuture = _dompetOperasi.getDompet();
      _ringkasanKey.currentState?.refresh();
    });
  }

  // Fungsi untuk menavigasi ke halaman tambah dompet
  void _tambahDompet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormDompet()),
    );
    if (!mounted) return;
    if (result == true) {
      _loadDompet();
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi sebelum menghapus semua dompet
  void _tampilkanDialogHapusSemua() async {
    final dompetList = await _dompetOperasi.getDompet();
    if (!mounted) return;

    if (dompetList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada dompet untuk dihapus.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua dompet? Tindakan ini tidak dapat diurungkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog sebelum operasi
                _hapusSemuaDompet();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi pengarsipan satu dompet
  void _showDialogHapusSatu(DompetModel dompet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan dompet "${dompet.namaDompet}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog sebelum operasi
                _hapusSatuDompet(dompet);
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengarsipkan satu dompet
  void _hapusSatuDompet(DompetModel dompet) async {
    try {
      await _dompetOperasi.arsipkanSatuDompet(dompet.id);
      _loadDompet(); // Muat ulang data
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dompet berhasil diarsipkan.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengarsipkan dompet: $e')));
    }
  }

  // Fungsi untuk menghapus semua dompet secara permanen
  void _hapusSemuaDompet() async {
    try {
      await _dompetOperasi.hapusSemuaDompet();
      _loadDompet(); // Muat ulang data
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua dompet berhasil dihapus.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus dompet: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _tampilkanDialogHapusSemua,
            tooltip: 'Hapus Semua Dompet',
          ),
        ],
      ),
      body: Column(
        children: [
          RingkasanKeuangan(key: _ringkasanKey),
          Expanded(
            child: FutureBuilder<List<DompetModel>>(
              future: _listaDompetFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada dompet ditemukan.'),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final dompet = snapshot.data![index];
                      return DompetCard(
                        dompet: dompet,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailDompet(dompet: dompet),
                            ),
                          );
                          if (!mounted) return;
                          _loadDompet();
                        },
                        onLongPress: () => _showDialogHapusSatu(dompet),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahDompet,
        tooltip: 'Tambah Dompet',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RingkasanKeuangan extends StatefulWidget {
  const RingkasanKeuangan({super.key});

  @override
  State<RingkasanKeuangan> createState() => _RingkasanKeuanganState();
}

class _RingkasanKeuanganState extends State<RingkasanKeuangan> {
  final DompetOperasi _dompetOperasi = DompetOperasi();
  late Future<List<double>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  void _loadSummary() {
    _summaryFuture = Future.wait([
      _dompetOperasi.getTotalSaldoPositif(),
      _dompetOperasi.getTotalSaldoNegatif(),
      _dompetOperasi.getTotalSaldo(),
    ]);
  }

  // Metode ini bisa dipanggil dari parent untuk refresh
  void refresh() {
    setState(() {
      _loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<double>>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        double pemasukan = 0.0;
        double pengeluaran = 0.0;
        double total = 0.0;

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final result = snapshot.data!;
          pemasukan = result[0];
          pengeluaran = result[1].abs(); // Tampilkan sebagai angka positif
          total = result[2];
        }

        return Card(
          margin: const EdgeInsets.all(12.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfo('Pemasukan', pemasukan, Colors.green),
                      _buildInfo('Pengeluaran', pengeluaran, Colors.red),
                      _buildInfo(
                        'Total',
                        total,
                        Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(String label, double jumlah, Color warna) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          FormatUang.formatMataUang(jumlah),
          style: TextStyle(
            color: warna,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class DompetCard extends StatelessWidget {
  final DompetModel dompet;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DompetCard({
    super.key,
    required this.dompet,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(
          Icons.account_balance_wallet,
          size: 40,
          color: Colors.blueAccent,
        ),
        title: Text(
          dompet.namaDompet,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Saldo: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(dompet.saldo)}',
          style: TextStyle(
            fontSize: 16,
            color: dompet.saldo < 0 ? Colors.red : Colors.black54,
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
