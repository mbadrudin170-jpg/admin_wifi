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
import 'dart:developer' as developer; // Tambahkan import developer

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

  @override
  void initState() {
    super.initState();
    developer.log('[DetailTransaksi] 🔍 : Membuka detail untuk ID: ${widget.transaksi.id}');
  }

  Future<String?> _getNama(
    Future<dynamic> Function(String) getModel,
    String id,
    String konteks, // Tambahkan konteks untuk logging
  ) async {
    if (id.isEmpty) return null;
    try {
      developer.log('[DetailTransaksi] 📡 : Mengambil data $konteks dengan ID: $id');
      final model = await getModel(id);
      
      if (model != null) {
        // diubah: Logika ini sekarang lebih fleksibel untuk menangani properti nama yang berbeda.
        if (model.nama is String) {
          developer.log('[DetailTransaksi] ✅ : Data $konteks ditemukan: ${model.nama}');
          return model.nama;
        }
        if (model.namaDompet is String) {
          developer.log('[DetailTransaksi] ✅ : Data $konteks ditemukan: ${model.namaDompet}');
          return model.namaDompet;
        }
      }
      developer.log('[DetailTransaksi] ⚠️ : Data $konteks tidak ditemukan untuk ID: $id');
    } catch (e, stackTrace) {
      developer.log(
        '[DetailTransaksi] ❌ : Error saat mengambil $konteks',
        name: 'detail_transaksi.getNama',
        error: e,
        stackTrace: stackTrace,
      );
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
            developer.log('[DetailTransaksi] ⬅️ : Kembali dari detail');
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
            _buildDetailRow('Tipe', transaksi.tipe.name.toUpperCase()),
            
            _buildFutureDetailRow(
              'Dompet',
              _getNama(
                (id) => _dompetOperasi.getDompetById(id),
                transaksi.idDompet,
                'Dompet',
              ),
            ),
            
            if (transaksi.idDompetTujuan != null && transaksi.idDompetTujuan!.isNotEmpty)
              _buildFutureDetailRow(
                'Dompet Tujuan',
                _getNama(
                  (id) => _dompetOperasi.getDompetById(id),
                  transaksi.idDompetTujuan!,
                  'Dompet Tujuan',
                ),
              ),
              
            _buildFutureDetailRow(
              'Kategori',
              _getNama(
                (id) => _kategoriOperasi.getKategoriById(id),
                transaksi.idKategori,
                'Kategori',
              ),
            ),
            
            if (transaksi.idSubKategori != null && transaksi.idSubKategori!.isNotEmpty)
              _buildFutureDetailRow(
                'Sub Kategori',
                _getNama(
                  (id) => _subKategoriOperasi.getSubKategoriById(id),
                  transaksi.idSubKategori!,
                  'Sub-Kategori',
                ),
              ),
              
            if (transaksi.idPelanggan != null && transaksi.idPelanggan!.isNotEmpty)
              _buildFutureDetailRow(
                'Pelanggan',
                _getNama(
                  (id) => _pelangganOperasi.getPelangganById(id),
                  transaksi.idPelanggan!,
                  'Pelanggan',
                ),
              ),
              
            if (transaksi.idPaket != null && transaksi.idPaket!.isNotEmpty)
              _buildFutureDetailRow(
                'Paket',
                _getNama(
                  (id) => _paketOperasi.getPaketById(id),
                  transaksi.idPaket!,
                  'Paket',
                ),
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
          return _buildDetailRow(label, 'Error Data');
        }
        return _buildDetailRow(label, snapshot.data ?? '-');
      },
    );
  }
}