// path: lib/fitur/dompet/screens/dompet.dart
// File ini menampilkan halaman dompet yang berisi ringkasan keuangan (pemasukan, pengeluaran, total)
// dan daftar semua dompet yang tersedia. Pengguna dapat menambahkan dompet baru melalui
// tombol floating action.

import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
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
  Future<void> _tampilkanDialogHapusSemua(List<DompetModel> listDompet) async {
    if (!mounted) return;

    if (listDompet.isEmpty) {
      AppToast.warning(context, 'Tidak ada dompet untuk dihapus.');
      return;
    }

    final konfirmasi = await showOkCancelAlertDialog(
      context: context,
      title: 'Konfirmasi',
      message:
          'Apakah Anda yakin ingin menghapus semua dompet? Tindakan ini tidak dapat diurungkan.',
      okLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructiveAction: true,
    );

    if (konfirmasi != OkCancelResult.ok) return;
    if (!mounted) return;

    try {
      await _dompetOperasi.hapusSemuaDompet();
      await ref.read(dompetProvider.notifier).muatUlang();
      _ringkasanKey.currentState?.refresh();
      if (!mounted) return;
      AppToast.sukses(context, 'Semua dompet berhasil dihapus.');
    } catch (e, s) {
      if (!mounted) return;
      L.e('Gagal menghapus semua dompet. Error: $e $s');
      AppToast.gagal(context, 'Gagal menghapus dompet: $e');
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi pengarsipan satu dompet
  Future<void> _showDialogHapusSatu(DompetModel dompet) async {
    final konfirmasi = await showOkCancelAlertDialog(
      context: context,
      title: 'Konfirmasi Arsip',
      message:
          'Apakah Anda yakin ingin mengarsipkan dompet "${dompet.namaDompet}"?',
      okLabel: 'Arsipkan',
      cancelLabel: 'Batal',
    );

    if (konfirmasi != OkCancelResult.ok) return;
    if (!mounted) return;

    try {
      await _dompetOperasi.arsipkanSatuDompet(dompet.id);
      await ref.read(dompetProvider.notifier).muatUlang();
      _ringkasanKey.currentState?.refresh();
      if (!mounted) return;
      AppToast.sukses(context, 'Dompet berhasil diarsipkan.');
    } catch (e, s) {
      if (!mounted) return;
      L.e('Gagal mengarsipkan dompet: "${dompet.namaDompet}". Error: $e $s');
      AppToast.gagal(context, 'Gagal mengarsipkan dompet: $e');
    }
  }

  Widget _buildTampilanError(Object? error, VoidCallback onRetry) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dompet')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Icon(Icons.error_outline, size: 48),
              Text(
                'Gagal memuat data dompet: $error',
                textAlign: TextAlign.center,
              ),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncDompet = ref.watch(dompetProvider);

    if (asyncDompet.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (asyncDompet.hasError) {
      return _buildTampilanError(
        asyncDompet.error,
        () => ref.refresh(dompetProvider),
      );
    }

    final dompetState = asyncDompet.requireValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _tampilkanDialogHapusSemua(dompetState.listDompet),
            tooltip: 'Hapus Semua Dompet',
          ),
        ],
      ),
      body: Column(
        children: [
          RingkasanKeuangan(key: _ringkasanKey),
          Expanded(
            child: dompetState.listDompet.isEmpty
                ? const Center(child: Text('Tidak ada dompet ditemukan.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: dompetState.listDompet.length,
                    itemBuilder: (context, index) {
                      final dompet = dompetState.listDompet[index];
                      return DompetCard(
                        dompet: dompet,
                        onTap: () async {
                          await Nav.to(context, DetailDompet(dompet: dompet));
                          if (!mounted) return;
                          try {
                            await ref.read(dompetProvider.notifier).muatUlang();
                          } catch (e, s) {
                            L.e('Gagal memuat ulang dompet: $e $s');
                          }
                          _ringkasanKey.currentState?.refresh();
                        },
                        onLongPress: () => _showDialogHapusSatu(dompet),
                      );
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

class RingkasanKeuangan extends ConsumerStatefulWidget {
  const RingkasanKeuangan({super.key});

  @override
  ConsumerState<RingkasanKeuangan> createState() => _RingkasanKeuanganState();
}

class _RingkasanKeuanganState extends ConsumerState<RingkasanKeuangan> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dompetState = ref.watch(dompetProvider);

    if (dompetState.isLoading) {
      return const Card(
        margin: EdgeInsets.all(12.0),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (dompetState.hasError) {
      return Card(
        margin: const EdgeInsets.all(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(child: Text('Error: ${dompetState.error}')),
        ),
      );
    }

    double pemasukan = 0.0;
    double pengeluaran = 0.0;
    double total = 0.0;

    final state = dompetState.requireValue;
    pemasukan = state.getTotalSaldoPositif();
    pengeluaran = state.getTotalSaldoNegatif().abs();
    total = state.getTotalSaldo();

    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
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
