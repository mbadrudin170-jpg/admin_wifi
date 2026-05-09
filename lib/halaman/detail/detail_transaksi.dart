// path: lib/halaman/detail/detail_transaksi.dart
// Halaman ini menampilkan detail dari satu transaksi.
// diubah: Mengubah menjadi StatefulWidget untuk mengambil data nama secara asinkron.
// diubah: Memperbaiki kesalahan pemanggilan dengan menggunakan SubKategoriOperasi yang benar.

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/sub_kategori_operasi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';

class DetailTransaksiPage extends StatefulWidget {
  final TransaksiModel transaksi;

  const DetailTransaksiPage({super.key, required this.transaksi});

  @override
  State<DetailTransaksiPage> createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  final DompetOperasi _dompetOperasi = DompetOperasi();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final SubKategoriOperasi _subKategoriOperasi = SubKategoriOperasi();

  Future<String?> _getNama(
    Future<dynamic> Function(String) getModel,
    String id,
  ) async {
    if (id.isEmpty) return null;
    try {
      final model = await getModel(id);
      if (model != null) {
        // diubah: Logika ini sekarang lebih fleksibel untuk menangani properti nama yang berbeda.
        if (model.nama is String) return model.nama;
        if (model.namaDompet is String) return model.namaDompet;
      }
    } catch (e) {
      return 'Error: $e';
    }
    return 'Tidak Ditemukan';
  }

  @override
  Widget build(BuildContext context) {
    final TransaksiModel transaksi = widget.transaksi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
              ).format(transaksi.jumlah),
            ),
            _buildDetailRow('Tipe', transaksi.tipe.name),
            _buildFutureDetailRow(
              'Dompet',
              _getNama(
                (id) => _dompetOperasi.getDompetById(id),
                transaksi.idDompet,
              ),
            ),
            if (transaksi.idDompetTujuan != null &&
                transaksi.idDompetTujuan!.isNotEmpty)
              _buildFutureDetailRow(
                'Dompet Tujuan',
                _getNama(
                  (id) => _dompetOperasi.getDompetById(id),
                  transaksi.idDompetTujuan!,
                ),
              ),
            _buildFutureDetailRow(
              'Kategori',
              _getNama(
                (id) => _kategoriOperasi.getKategoriById(id),
                transaksi.idKategori,
              ),
            ),
            if (transaksi.idSubKategori != null &&
                transaksi.idSubKategori!.isNotEmpty)
              _buildFutureDetailRow(
                'Sub Kategori',
                _getNama(
                  (id) => _subKategoriOperasi.getSubKategoriById(id),
                  transaksi.idSubKategori!,
                ),
              ),
            if (transaksi.idPelanggan != null &&
                transaksi.idPelanggan!.isNotEmpty)
              _buildFutureDetailRow(
                'Pelanggan',
                _getNama(
                  (id) => _pelangganOperasi.getPelangganById(id),
                  transaksi.idPelanggan!,
                ),
              ),
            if (transaksi.idPaket != null && transaksi.idPaket!.isNotEmpty)
              _buildFutureDetailRow(
                'Paket',
                _getNama(
                  (id) => _paketOperasi.getPaketById(id),
                  transaksi.idPaket!,
                ),
              ),
            _buildDetailRow(
              'Status Pembayaran',
              transaksi.statusPembayaran.name,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildFutureDetailRow(String label, Future<String?> future) {
    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDetailRow(label, 'Memuat...');
        }
        if (snapshot.hasError) {
          return _buildDetailRow(label, 'Error');
        }
        return _buildDetailRow(label, snapshot.data ?? '-');
      },
    );
  }
}
