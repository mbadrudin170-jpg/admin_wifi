// path: lib/fitur/dompet/screens/dompet.dart
// File ini menampilkan halaman dompet yang berisi ringkasan keuangan (pemasukan, pengeluaran, total)
// dan daftar semua dompet yang tersedia. Pengguna dapat menambahkan dompet baru melalui
// tombol floating action.

import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/dompet/screens/detail_dompet.dart';
import 'package:admin_wifi/fitur/dompet/screens/form_dompet.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/widget/info_ringkasan_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

class DompetPage extends StatefulWidget {
  const DompetPage({super.key});

  @override
  State<DompetPage> createState() => _DompetPageState();
}

class _DompetPageState extends State<DompetPage> {
  final DompetNotifier _dompetOperasi = dompetNotifierGlobal;
  final GlobalKey<_RingkasanKeuanganState> _ringkasanKey = GlobalKey();
  late Future<List<DompetModel>> _listaDompetFuture;

  @override
  void initState() {
    super.initState();
    L.i('Halaman Dompet sedang diinisialisasi.');
    _loadDompet();
  }

  // Fungsi untuk memuat ulang data dompet dan ringkasan keuangan
  void _loadDompet() {
    L.i('Memulai pemuatan data dompet dan ringkasan keuangan.');
    setState(() {
      _listaDompetFuture = _dompetOperasi.getDompet();
      _ringkasanKey.currentState?.refresh();
    });
    L.i('Pemuatan data dompet dan ringkasan keuangan telah dijadwalkan.');
  }

  // Fungsi untuk menavigasi ke halaman tambah dompet
  void _tambahDompet() async {
    L.i('Navigasi ke halaman tambah dompet.');
    final result = await Nav.to(context, const FormDompet());
    if (!mounted) return;
    if (result == true) {
      L.i('Berhasil menambahkan dompet baru, memuat ulang data.');
      _loadDompet();
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi sebelum menghapus semua dompet
  void _tampilkanDialogHapusSemua() async {
    L.i('Menampilkan dialog konfirmasi hapus semua dompet.');
    final dompetList = await _dompetOperasi.getDompet();
    if (!mounted) return;

    if (dompetList.isEmpty) {
      L.w('Tidak ada dompet untuk dihapus.');
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
                L.i('Pengguna membatalkan penghapusan semua dompet.');
                Nav.pop(context);
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                L.w('Pengguna mengkonfirmasi penghapusan semua dompet.');
                Nav.pop(context); // Tutup dialog sebelum operasi
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
    L.i(
      'Menampilkan dialog konfirmasi pengarsipan untuk dompet: "${dompet.namaDompet}".',
    );
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
                L.i(
                  'Pengguna membatalkan pengarsipan dompet: "${dompet.namaDompet}".',
                );
                Nav.pop(context);
              },
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                L.w(
                  'Pengguna mengkonfirmasi pengarsipan dompet: "${dompet.namaDompet}".',
                );
                Nav.pop(context); // Tutup dialog sebelum operasi
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
    L.i('Memulai pengarsipan dompet: "${dompet.namaDompet}".');
    try {
      await _dompetOperasi.arsipkanSatuDompet(dompet.id);
      _loadDompet(); // Muat ulang data
      if (!mounted) return;
      L.i('Dompet "${dompet.namaDompet}" berhasil diarsipkan.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dompet berhasil diarsipkan.')),
      );
    } catch (e, s) {
      if (!mounted) return;
      L.e('Gagal mengarsipkan dompet: "${dompet.namaDompet}". Error: $e $s');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengarsipkan dompet: $e')));
    }
  }

  // Fungsi untuk menghapus semua dompet secara permanen
  void _hapusSemuaDompet() async {
    L.i('Memulai penghapusan semua dompet.');
    try {
      await _dompetOperasi.hapusSemuaDompet();
      _loadDompet(); // Muat ulang data
      if (!mounted) return;
      L.i('Semua dompet berhasil dihapus.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua dompet berhasil dihapus.')),
      );
    } catch (e, s) {
      if (!mounted) return;
      L.e('Gagal menghapus semua dompet. Error: $e $s');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus dompet: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI untuk Halaman Dompet.');
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
                  L.i('Menunggu data dompet...');
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  L.e(
                    'Error saat memuat data dompet. Error: $snapshot.error $snapshot.stackTrace',
                  );
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  L.i('Tidak ada data dompet ditemukan.');
                  return const Center(
                    child: Text('Tidak ada dompet ditemukan.'),
                  );
                } else {
                  L.i(
                    'Berhasil memuat ${snapshot.data!.length} dompet, membangun daftar.',
                  );
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final dompet = snapshot.data![index];
                      return DompetCard(
                        dompet: dompet,
                        onTap: () async {
                          L.i(
                            'Navigasi ke detail dompet: "${dompet.namaDompet}".',
                          );
                          await Nav.to(context, DetailDompet(dompet: dompet));
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
  final DompetNotifier _dompetOperasi = dompetNotifierGlobal;
  late Future<List<double>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    L.i('Menginisialisasi widget Ringkasan Keuangan.');
    _loadSummary();
  }

  void _loadSummary() {
    L.i('Memuat data ringkasan keuangan.');
    _summaryFuture = Future.wait([
      _dompetOperasi.getTotalSaldoPositif(),
      _dompetOperasi.getTotalSaldoNegatif(),
      _dompetOperasi.getTotalSaldo(),
    ]);
  }

  // Metode ini bisa dipanggil dari parent untuk refresh
  void refresh() {
    L.i('Memuat ulang data ringkasan keuangan atas permintaan parent.');
    setState(() {
      _loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI untuk widget Ringkasan Keuangan.');
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
          L.i(
            'Ringkasan keuangan berhasil dihitung: Pemasukan=$pemasukan, Pengeluaran=$pengeluaran, Total=$total',
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          L.i('Menunggu data ringkasan keuangan...');
        } else if (snapshot.hasError) {
          L.e(
            'Gagal memuat ringkasan keuangan Error: $snapshot.error $snapshot.stackTrace',
          );
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
                      bangunInfoRingkasan(
                        context: context,
                        label: 'Pemasukan',
                        jumlah: pemasukan,
                        warna: Colors.green,
                      ),
                      bangunInfoRingkasan(
                        context: context,
                        label: 'Pengeluaran',
                        jumlah: pengeluaran,
                        warna: Colors.red,
                      ),
                      bangunInfoRingkasan(
                        context: context,
                        label: 'Total',
                        jumlah: total,
                        warna: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
          ),
        );
      },
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
