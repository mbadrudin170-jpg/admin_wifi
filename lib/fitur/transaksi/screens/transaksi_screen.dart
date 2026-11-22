// path: lib/fitur/transaksi/screens/transaksi_screen.dart
// diubah: Urutan impor alfabetis menurut path lengkap (penamaan-konvensi #17) dan
// penanganan error pada `_tambahTransaksi` (try/catch + L.e + AppToast + mounted).

import 'dart:async';

import 'package:admin_wifi/fitur/transaksi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/screens/form_transaksi.dart';
import 'package:admin_wifi/widget/info_ringkasan_widget.dart';
import 'package:admin_wifi/widget/transaksi_list_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';

class RingkasanTransaksi extends StatelessWidget {
  final double pemasukan;
  final double pengeluaran;
  final double total;

  const RingkasanTransaksi({
    super.key,
    required this.pemasukan,
    required this.pengeluaran,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              warna: total >= 0
                  ? Theme.of(context).colorScheme.primary
                  : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class TransaksiScreens extends ConsumerStatefulWidget {
  const TransaksiScreens({super.key});

  @override
  ConsumerState<TransaksiScreens> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends ConsumerState<TransaksiScreens> {
  Future<void> _muatUlang() async {
    try {
      await ref.read(transaksiProvider.notifier).muatUlang();
    } catch (e, s) {
      L.e('Gagal memuat ulang transaksi: $e $s');
      if (mounted) {
        AppToast.gagal(context, 'Gagal memuat data transaksi.');
      }
    }
  }

  void _tambahTransaksi() {
    unawaited(
      Nav.to(context, const FormTransaksiPage()).catchError((
        Object e,
        StackTrace s,
      ) {
        L.e('Gagal menambah transaksi: $e $s');
        return null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncTransaksi = ref.watch(transaksiProvider);

    if (asyncTransaksi.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (asyncTransaksi.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaksi')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                const Icon(Icons.error_outline, size: 48),
                Text(
                  'Gagal memuat data transaksi: ${asyncTransaksi.error}',
                  textAlign: TextAlign.center,
                ),
                FilledButton(
                  onPressed: () => ref.refresh(transaksiProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final state = asyncTransaksi.requireValue;
    final transaksiData = state.listTransaksi;
    final pemasukan = state.totalPemasukan;
    final pengeluaran = state.totalPengeluaran;
    final total = state.netTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            onPressed: () {
              AppToast.info(context, 'Fitur hapus semua belum tersedia.');
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Column(
        children: [
          RingkasanTransaksi(
            key: const Key('ringkasan_transaksi'),
            pemasukan: pemasukan,
            pengeluaran: pengeluaran,
            total: total,
          ),
          Expanded(
            child: transaksiData.isEmpty
                ? EmptyStateView(
                    ikon: CupertinoIcons.list_bullet,
                    judul: 'Belum ada transaksi',
                    deskripsi: 'Catat transaksi pertama Anda untuk memulai.',
                    ctaLabel: 'Tambah Transaksi',
                    onCta: _tambahTransaksi,
                  )
                : _buildTransaksiList(transaksiData),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahTransaksi,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransaksiList(List<TransaksiModel> transaksiData) {
    final groupedTransaksi = groupTransaksiByDate(transaksiData);

    return ListView.builder(
      itemCount: groupedTransaksi.length,
      itemBuilder: (context, index) {
        final entry = groupedTransaksi.entries.elementAt(index);
        final tanggal = entry.key;
        final transaksiPadaTanggal = entry.value;
        final totalPadaTanggal = transaksiPadaTanggal.fold<double>(
          0.0,
          (sum, item) =>
              sum +
              (item.tipe == TipeTransaksi.pemasukan
                  ? item.jumlah
                  : -item.jumlah),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bangunHeaderSeksi(context, tanggal, totalPadaTanggal),
            ...transaksiPadaTanggal.map(
              (transaksi) =>
                  bangunItemTransaksi(context, transaksi, () => _muatUlang()),
            ),
          ],
        );
      },
    );
  }
}
