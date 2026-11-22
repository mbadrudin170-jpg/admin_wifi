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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart'
    hide FormatTanggal, FormatUang;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        L.i(
          'DetailTransaksiPage Scaffold pertama kali tampil: ${DateTime.now().toIso8601String()}',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    L.i('DetailTransaksiPage build mulai: ${DateTime.now().toIso8601String()}');
    final transaksi = widget.transaksi;
    final asyncDompet = ref.watch(dompetProvider);
    final asyncKategori = ref.watch(kategoriProvider);
    final asyncPelanggan = ref.watch(pelangganProvider);
    final asyncPaket = ref.watch(paketProvider);

    L.i(
      'DetailTransaksiPage providers siap: ${DateTime.now().toIso8601String()}',
    );

    // Loading gabungan: jika salah satu provider masih loading, tampilkan indikator.
    if (asyncDompet.isLoading ||
        asyncKategori.isLoading ||
        asyncPelanggan.isLoading ||
        asyncPaket.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Error per provider, ditangani secara terpisah dengan tombol retry.
    String? errorLabel;
    VoidCallback? errorOnRetry;
    String? errorPesan;

    if (asyncDompet.hasError) {
      errorLabel = 'Dompet';
      errorOnRetry = () => ref.refresh(dompetProvider);
      errorPesan = asyncDompet.error.toString();
    } else if (asyncKategori.hasError) {
      errorLabel = 'Kategori';
      errorOnRetry = () => ref.refresh(kategoriProvider);
      errorPesan = asyncKategori.error.toString();
    } else if (asyncPelanggan.hasError) {
      errorLabel = 'Pelanggan';
      errorOnRetry = () => ref.refresh(pelangganProvider);
      errorPesan = asyncPelanggan.error.toString();
    } else if (asyncPaket.hasError) {
      errorLabel = 'Paket';
      errorOnRetry = () => ref.refresh(paketProvider);
      errorPesan = asyncPaket.error.toString();
    }

    if (errorLabel != null) {
      return _buildError(
        'Gagal memuat $errorLabel: $errorPesan',
        errorOnRetry!,
      );
    }
    L.i(
      'DetailTransaksiPage error provider: $errorLabel, pesan: $errorPesan, waktu: ${DateTime.now().toIso8601String()}',
    );
    final dompetState = asyncDompet.requireValue;
    final kategoriState = asyncKategori.requireValue;
    final pelangganState = asyncPelanggan.requireValue;
    final paketState = asyncPaket.requireValue;

    final idDompetTujuan = transaksi.idDompetTujuan;
    final idSubKategori = transaksi.idSubKategori;
    final idPelanggan = transaksi.idPelanggan;
    final idPaket = transaksi.idPaket;
    final tanggalMulai = transaksi.tanggalMulai;
    final tanggalBerakhir = transaksi.tanggalBerakhir;

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
            _buildDetailRow('Tipe', transaksi.tipe.label),
            _buildDetailRowSync(
              'Dompet',
              dompetState.getById(transaksi.idDompet)?.namaDompet,
            ),
            if (idDompetTujuan != null && idDompetTujuan.isNotEmpty)
              _buildDetailRowSync(
                'Dompet Tujuan',
                dompetState.getById(idDompetTujuan)?.namaDompet,
              ),

            _buildDetailRowSync(
              'Kategori',
              kategoriState.getById(transaksi.idKategori)?.nama,
            ),

            if (idSubKategori != null && idSubKategori.isNotEmpty)
              _buildDetailRowSync(
                'Sub Kategori',
                kategoriState.getSubKategoriById(idSubKategori)?.nama,
              ),

            if (idPelanggan != null && idPelanggan.isNotEmpty)
              _buildDetailRowSync(
                'Pelanggan',
                pelangganState.getById(idPelanggan)?.nama,
              ),

            if (idPaket != null && idPaket.isNotEmpty)
              _buildDetailRowSync(
                'Paket',
                paketState.getPaketById(idPaket)?.nama,
              ),

            _buildDetailRow(
              'Status Pembayaran',
              transaksi.statusPembayaran.label,
            ),
            _buildDetailRow(
              'Poin Dihasilkan',
              transaksi.poinYangDihasilkan.toString(),
            ),
            _buildDetailRow(
              'Poin Digunakan',
              transaksi.poinYangDigunakan.toString(),
            ),

            if (tanggalMulai != null)
              _buildDetailRow(
                'Masa Aktif Mulai',
                FormatTanggal.formatTanggalDanJam(tanggalMulai),
              ),
            if (tanggalBerakhir != null)
              _buildDetailRow(
                'Masa Aktif Berakhir',
                FormatTanggal.formatTanggalDanJam(tanggalBerakhir),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildError(String pesan, VoidCallback onRetry) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(pesan),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
