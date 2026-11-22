// path: lib/fitur/transaksi/screens/detail_transaksi.dart
// Halaman ini menampilkan detail dari satu transaksi.

import 'dart:async';

import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/screens/form_transaksi.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

class DetailTransaksiPage extends ConsumerStatefulWidget {
  final TransaksiModel transaksi;

  const DetailTransaksiPage({super.key, required this.transaksi});

  @override
  ConsumerState<DetailTransaksiPage> createState() =>
      _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends ConsumerState<DetailTransaksiPage> {
  void _bukaFormEdit() {
    unawaited(
      Nav.to(
        context,
        FormTransaksiPage(transaksi: widget.transaksi),
      ).catchError((Object e, StackTrace s) {
        L.e('Gagal membuka form edit transaksi: $e $s');
        return null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transaksi = widget.transaksi;
    final asyncDompet = ref.watch(dompetProvider);
    final asyncKategori = ref.watch(kategoriProvider);
    final asyncPelanggan = ref.watch(pelangganProvider);
    final asyncPaket = ref.watch(paketProvider);

    // Loading gabungan: jika salah satu provider masih loading, tampilkan indikator.
    if (asyncDompet.isLoading ||
        asyncKategori.isLoading ||
        asyncPelanggan.isLoading ||
        asyncPaket.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Error per provider, ditangani secara terpisah dengan tombol retry.
    if (asyncDompet.hasError) {
      return _buildErrorRetry(
        'Dompet',
        () => ref.refresh(dompetProvider),
        asyncDompet.error.toString(),
      );
    }
    if (asyncKategori.hasError) {
      return _buildErrorRetry(
        'Kategori',
        () => ref.refresh(kategoriProvider),
        asyncKategori.error.toString(),
      );
    }
    if (asyncPelanggan.hasError) {
      return _buildErrorRetry(
        'Pelanggan',
        () => ref.refresh(pelangganProvider),
        asyncPelanggan.error.toString(),
      );
    }
    if (asyncPaket.hasError) {
      return _buildErrorRetry(
        'Paket',
        () => ref.refresh(paketProvider),
        asyncPaket.error.toString(),
      );
    }

    final dompetState = asyncDompet.requireValue;
    final kategoriState = asyncKategori.requireValue;
    final pelangganState = asyncPelanggan.requireValue;
    final paketState = asyncPaket.requireValue;

    final idDompetTujuan = transaksi.idDompetTujuan;
    final idSubKategori = transaksi.idSubKategori;
    final idPelanggan = transaksi.idPelanggan;
    final idPaket = transaksi.idPaket;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Transaksi',
            onPressed: _bukaFormEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('ID', transaksi.id),
            _buildDetailRow('Keterangan', transaksi.keterangan),
            _buildDetailRow(
              'Tanggal',
              FormatTanggal.formatTanggalDanJam(transaksi.tanggal),
            ),
            _buildDetailRow(
              'Jumlah',
              FormatUang.formatMataUang(transaksi.jumlah),
            ),
            _buildDetailRow('Tipe', transaksi.tipe.name.toUpperCase()),
            _buildDetailRowSync(
              'Dompet',
              dompetState.listDompet
                  .firstWhereOrNull((d) => d.id == transaksi.idDompet)
                  ?.namaDompet,
            ),
            if (idDompetTujuan != null && idDompetTujuan.isNotEmpty)
              _buildDetailRowSync(
                'Dompet Tujuan',
                dompetState.listDompet
                    .firstWhereOrNull((d) => d.id == idDompetTujuan)
                    ?.namaDompet,
              ),

            _buildDetailRowSync(
              'Kategori',
              kategoriState.getById(transaksi.idKategori)?.nama,
            ),

            if (idSubKategori != null && idSubKategori.isNotEmpty)
              _buildDetailRowSync(
                'Sub Kategori',
                kategoriState.listKategori
                    .expand((k) => k.subKategori)
                    .firstWhereOrNull((sk) => sk.id == idSubKategori)
                    ?.nama,
              ),

            if (idPelanggan != null && idPelanggan.isNotEmpty)
              _buildDetailRowSync(
                'Pelanggan',
                pelangganState.listPelanggan
                    .firstWhereOrNull((p) => p.id == idPelanggan)
                    ?.nama,
              ),

            if (idPaket != null && idPaket.isNotEmpty)
              _buildDetailRowSync(
                'Paket',
                paketState.getPaketById(idPaket)?.nama,
              ),

            _buildDetailRow(
              'Status Pembayaran',
              transaksi.statusPembayaran.name.toUpperCase(),
            ),
            _buildDetailRow(
              'Poin Dihasilkan',
              transaksi.poinYangDihasilkan.toString(),
            ),
            _buildDetailRow(
              'Poin Digunakan',
              transaksi.poinYangDigunakan.toString(),
            ),

            if (transaksi.tanggalMulai != null)
              _buildDetailRow(
                'Masa Aktif Mulai',
                FormatTanggal.formatTanggalDanJam(transaksi.tanggalMulai!),
              ),
            if (transaksi.tanggalBerakhir != null)
              _buildDetailRow(
                'Masa Aktif Berakhir',
                FormatTanggal.formatTanggalDanJam(transaksi.tanggalBerakhir!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    L.i('Membangun baris detail - $label: $value');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildDetailRowSync(String label, String? value) {
    return _buildDetailRow(label, value ?? '-');
  }

  Widget _buildErrorRetry(
    String label,
    void Function() onRefresh,
    String errorMessage,
  ) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text('Gagal memuat $label: $errorMessage'),
            FilledButton(onPressed: onRefresh, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
