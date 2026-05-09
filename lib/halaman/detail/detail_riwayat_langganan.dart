// path: lib/halaman/detail/detail_riwayat_langganan.dart
// diubah: File ini sekarang menampilkan detail transaksi langganan dari TransaksiModel.

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer; // Tambahkan import developer

class DetailLanggananTransaksiPage extends StatefulWidget {
  final String idTransaksi;

  const DetailLanggananTransaksiPage({super.key, required this.idTransaksi});
  @override
  State<DetailLanggananTransaksiPage> createState() =>
      _DetailLanggananTransaksiPageState();
}

class _DetailLanggananTransaksiPageState
    extends State<DetailLanggananTransaksiPage> {
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  late Future<TransaksiModel?> _transaksiFuture;

  @override
  void initState() {
    super.initState();
    developer.log('[DetailLangganan] 🚀 : Inisialisasi halaman untuk ID Transaksi: ${widget.idTransaksi}');
    _transaksiFuture = _transaksiOperasi.getTransaksiById(widget.idTransaksi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Langganan')),
      body: FutureBuilder<TransaksiModel?>(
        future: _transaksiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            developer.log('[DetailLangganan] ❌ : Error saat mengambil data transaksi', error: snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transaksi = snapshot.data;

          if (transaksi == null) {
            developer.log('[DetailLangganan] ⚠️ : Data transaksi tidak ditemukan di database');
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }

          developer.log('[DetailLangganan] ✅ : Berhasil memuat Transaksi: ${transaksi.id}');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                if (transaksi.idPelanggan != null)
                  _buildFutureInfoCard<PelangganModel>(
                    'Informasi Pelanggan',
                    _pelangganOperasi.getPelangganById(transaksi.idPelanggan!),
                    'Pelanggan',
                    (pelanggan) => [
                      _buildDetailRow(
                        'Nama Pelanggan',
                        pelanggan?.nama ?? 'Tidak Diketahui',
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (transaksi.idPaket != null)
                  _buildFutureInfoCard<PaketModel>(
                    'Informasi Paket',
                    _paketOperasi.getPaketById(transaksi.idPaket!),
                    'Paket',
                    (paket) => [
                      _buildDetailRow('Nama Paket', paket?.nama ?? 'Tidak Diketahui'),
                      _buildDetailRow(
                        'Harga',
                        FormatUang.formatMataUang(paket?.harga.toDouble() ?? 0),
                      ),
                      _buildDetailRow(
                        'Durasi',
                        '${paket?.durasi ?? 0} ${paket?.tipe.name ?? ""}',
                      ),
                    ],
                  ),
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
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
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

  Widget _buildFutureInfoCard<T>(
    String title,
    Future<T?> future,
    String tag, // Tag untuk membedakan log
    List<Widget> Function(T? data) builder,
  ) {
    return FutureBuilder<T?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildInfoCard(title, [
            const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )),
          ]);
        }
        if (snapshot.hasError) {
          developer.log('[DetailLangganan] ❌ : Gagal memuat data $tag', error: snapshot.error);
          return _buildInfoCard(title, [const Text('Gagal memuat data')]);
        }

        if (snapshot.hasData) {
          developer.log('[DetailLangganan] 📡 : Data $tag berhasil diambil secara asinkron');
        }

        return _buildInfoCard(title, builder(snapshot.data));
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
}