// path: lib/fitur/dompet/screens/dompet.dart
// File ini menampilkan halaman dompet yang berisi ringkasan keuangan (pemasukan, pengeluaran, total)
// dan daftar semua dompet yang tersedia. Pengguna dapat menambahkan dompet baru melalui
// tombol floating action.

import 'dart:async';

import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/dompet/screens/detail_dompet.dart';
import 'package:admin_wifi/fitur/dompet/screens/form_dompet.dart';
import 'package:admin_wifi/widget/info_ringkasan_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';
import 'package:share_global_saya/src/widget/toast_widget.dart';

class DompetPage extends ConsumerStatefulWidget {
  const DompetPage({super.key});

  @override
  ConsumerState<DompetPage> createState() => _DompetPageState();
}

class _DompetPageState extends ConsumerState<DompetPage> {
  late final DompetNotifier _dompetOperasi;
  final GlobalKey<_RingkasanKeuanganState> _ringkasanKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _dompetOperasi = ref.read(dompetProvider.notifier);
    _loadDompet();
  }

  Future<void> _loadDompet() async {
    try {
      await ref.read(dompetProvider.notifier).muatUlang();
    } catch (e, s) {
      L.e('Gagal memuat ulang dompet: $e $s');
    }
    _ringkasanKey.currentState?.refresh();
  }

  // Fungsi untuk menavigasi ke halaman tambah dompet
  void _tambahDompet() {
    unawaited(
      Nav.to(context, const FormDompet()).catchError((Object e, StackTrace s) {
        L.e('Gagal navigasi tambah dompet: $e $s');
        return null;
      }),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi sebelum menghapus semua dompet
  void _tampilkanDialogHapusSemua() async {
    final dompetList = await _dompetOperasi.getDompet();
    if (!mounted) return;

    if (dompetList.isEmpty) {
      AppToast.warning(context, 'Tidak ada dompet untuk dihapus.');
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
              onPressed: () => Nav.pop(context),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Nav.pop(context);
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
              onPressed: () => Nav.pop(context),
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                Nav.pop(context);
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
      await _loadDompet();
      if (!mounted) return;
      AppToast.sukses(context, 'Dompet berhasil diarsipkan.');
    } catch (e, s) {
      if (!mounted) return;
      L.e('Gagal mengarsipkan dompet: "${dompet.namaDompet}". Error: $e $s');
      AppToast.gagal(context, 'Gagal mengarsipkan dompet: $e');
    }
  }

  // Fungsi untuk menghapus semua dompet secara permanen
  void _hapusSemuaDompet() async {
    try {
      await _dompetOperasi.hapusSemuaDompet();
      await _loadDompet();
      if (!mounted) return;
      AppToast.sukses(context, 'Semua dompet berhasil dihapus.');
    } catch (e, s) {
      if (!mounted) return;
      L.e('Gagal menghapus semua dompet. Error: $e $s');
      AppToast.gagal(context, 'Gagal menghapus dompet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncDompet = ref.watch(dompetProvider);

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
            child: asyncDompet.isLoading
                ? const Center(child: CircularProgressIndicator())
                : asyncDompet.hasError
                ? Center(child: Text('Error: ${asyncDompet.error}'))
                : (asyncDompet.requireValue.listDompet.isEmpty
                      ? const Center(child: Text('Tidak ada dompet ditemukan.'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: asyncDompet.requireValue.listDompet.length,
                          itemBuilder: (context, index) {
                            final dompet =
                                asyncDompet.requireValue.listDompet[index];
                            return DompetCard(
                              dompet: dompet,
                              onTap: () async {
                                await Nav.to(
                                  context,
                                  DetailDompet(dompet: dompet),
                                );
                                if (!mounted) return;
                                await _loadDompet();
                              },
                              onLongPress: () => _showDialogHapusSatu(dompet),
                            );
                          },
                        )),
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

class RingkasanKeuangan extends ConsumerStatefulWidget {
  const RingkasanKeuangan({super.key});

  @override
  ConsumerState<RingkasanKeuangan> createState() => _RingkasanKeuanganState();
}

class _RingkasanKeuanganState extends ConsumerState<RingkasanKeuangan> {
  late final DompetNotifier _dompetOperasi;
  late Future<List<double>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _dompetOperasi = ref.read(dompetProvider.notifier);
    _loadSummary();
  }

  void _loadSummary() {
    _summaryFuture = Future.wait([
      _dompetOperasi.getTotalSaldoPositif(),
      _dompetOperasi.getTotalSaldoNegatif(),
      _dompetOperasi.getTotalSaldo(),
    ]);
  }

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
        leading: Icon(
          Icons.account_balance_wallet,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          dompet.namaDompet,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Saldo: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(dompet.saldo)}',
          style: TextStyle(
            fontSize: 16,
            color: dompet.saldo < 0
                ? Colors.red
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
