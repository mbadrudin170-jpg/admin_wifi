// path: lib/halaman/detail/detail_riwayat_langganan.dart
// diubah: File ini sekarang menampilkan detail transaksi langganan dari TransaksiModel.
// ditambahkan: Widget untuk menampilkan informasi poin yang dihasilkan dan digunakan.

import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';

class DetailLanggananTransaksiPage extends ConsumerStatefulWidget {
  final String idTransaksi;

  const DetailLanggananTransaksiPage({super.key, required this.idTransaksi});

  @override
  ConsumerState<DetailLanggananTransaksiPage> createState() =>
      _DetailLanggananTransaksiPageState();
}

class _DetailLanggananTransaksiPageState
    extends ConsumerState<DetailLanggananTransaksiPage> {
  @override
  void initState() {
    super.initState();
    L.i(
      'Memulai inisialisasi halaman detail langganan untuk ID transaksi: ${widget.idTransaksi}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI halaman detail langganan transaksi.');
    final transaksiAsync = ref.watch(transaksiProvider);

    if (transaksiAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Langganan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (transaksiAsync.hasError) {
      L.e('Gagal memuat transaksi: ${transaksiAsync.error}');
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Langganan')),
        body: Center(child: Text('Error: ${transaksiAsync.error}')),
      );
    }

    final transaksi = transaksiAsync.requireValue.getTransaksiById(
      widget.idTransaksi,
    );

    if (transaksi == null) {
      L.w('Data transaksi tidak ditemukan di database.');
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Langganan')),
        body: const Center(child: Text('Transaksi tidak ditemukan')),
      );
    }
    L.i('Berhasil memuat data transaksi dengan ID: ${transaksi.id}.');

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Langganan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            if (transaksi.idPelanggan != null)
              _buildInfoCard('Informasi Pelanggan', [
                _buildDetailRow(
                  'Nama Pelanggan',
                  ref
                          .watch(pelangganProvider)
                          .value
                          ?.getById(transaksi.idPelanggan!)
                          ?.nama ??
                      'Tidak Diketahui',
                ),
              ]),
            const SizedBox(height: 16),
            if (transaksi.idPaket != null)
              _buildInfoCard('Informasi Paket', [
                _buildDetailRow(
                  'Nama Paket',
                  ref
                          .watch(paketProvider)
                          .value
                          ?.getPaketById(transaksi.idPaket!)
                          ?.nama ??
                      'Tidak Diketahui',
                ),
                _buildDetailRow(
                  'Harga',
                  FormatUang.formatMataUang(
                    ref
                            .watch(paketProvider)
                            .value
                            ?.getPaketById(transaksi.idPaket!)
                            ?.harga
                            .toDouble() ??
                        0,
                  ),
                ),
                _buildDetailRow(
                  'Durasi',
                  '${ref.watch(paketProvider).value?.getPaketById(transaksi.idPaket!)?.durasi ?? 0} ${ref.watch(paketProvider).value?.getPaketById(transaksi.idPaket!)?.tipe.name ?? ""}',
                ),
              ]),
            const SizedBox(height: 16),
            _buildInfoPoin(transaksi),
            const SizedBox(height: 16),
            if (transaksi.tanggalMulai != null &&
                transaksi.tanggalBerakhir != null)
              _buildInfoCard('Waktu Langganan', [
                _buildDetailRow(
                  'Tanggal Mulai',
                  FormatTanggal.formatTanggalDanJam(
                    transaksi.tanggalMulai!,
                  ),
                ),
                _buildDetailRow(
                  'Tanggal Berakhir',
                  FormatTanggal.formatTanggalDanJam(
                    transaksi.tanggalBerakhir!,
                  ),
                ),
              ]),
            const SizedBox(height: 16),
            _buildInfoCard('Status', [
              _buildDetailRow(
                'Status Pembayaran',
                transaksi.statusPembayaran.name.toUpperCase(),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ditambahkan: Widget untuk menampilkan informasi poin
  Widget _buildInfoPoin(TransaksiModel transaksi) {
    L.i('Membangun widget informasi poin transaksi.');

    // Jika tidak ada perubahan poin, tidak perlu menampilkan widget
    if (transaksi.poinYangDihasilkan == 0 && transaksi.poinYangDigunakan == 0) {
      L.i('Tidak ada perubahan poin pada transaksi ini.');
      return const SizedBox.shrink();
    }

    final isPenambahan =
        transaksi.poinYangDihasilkan > transaksi.poinYangDigunakan;
    final selisihPoin =
        transaksi.poinYangDihasilkan - transaksi.poinYangDigunakan;

    L.i(
      'Poin dihasilkan: ${transaksi.poinYangDihasilkan}, '
      'Poin digunakan: ${transaksi.poinYangDigunakan}, '
      'Selisih: $selisihPoin poin (${isPenambahan ? "PENAMBAHAN" : "PENGURANGAN"}).',
    );

    return _buildInfoCard('Informasi Poin', [
      // Poin yang dihasilkan
      _buildDetailRowWithColor(
        'Poin Dihasilkan',
        '+${transaksi.poinYangDihasilkan} Poin',
        transaksi.poinYangDihasilkan > 0 ? Colors.green : null,
        transaksi.poinYangDihasilkan > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      // Poin yang digunakan
      _buildDetailRowWithColor(
        'Poin Digunakan',
        '-${transaksi.poinYangDigunakan} Poin',
        transaksi.poinYangDigunakan > 0 ? Colors.red : null,
        transaksi.poinYangDigunakan > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      const Divider(height: 16),
      // Total perubahan poin
      _buildDetailRowWithColor(
        isPenambahan ? 'Total Poin Bertambah' : 'Total Poin Berkurang',
        '${selisihPoin >= 0 ? "+" : ""}$selisihPoin Poin',
        isPenambahan ? Colors.green : Colors.red,
        FontWeight.bold,
        fontSize: 16,
      ),
    ]);
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    L.i('Membangun info card dengan judul: $title.');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    L.i('Membangun detail row dengan label: $label dan value: $value.');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ditambahkan: Widget detail row dengan kustomisasi warna dan style
  Widget _buildDetailRowWithColor(
    String label,
    String value,
    Color? valueColor,
    FontWeight fontWeight, {
    double fontSize = 14,
  }) {
    L.i(
      'Membangun detail row berwarna dengan label: $label dan value: $value.',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: fontWeight,
                color: valueColor,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
