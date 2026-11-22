// path: lib/halaman/detail/detail_transaksi.dart
// Halaman ini menampilkan detail dari satu transaksi.

import 'dart:async';

import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/screens/form_transaksi.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  @override
  void initState() {
    super.initState();
  }

  // DIUBAH: Logika diperkuat dengan pengecekan tipe eksplisit untuk mencegah error.
  String? _getNama(
    dynamic Function(String) getModel,
    String id,
    String konteks,
  ) {
    if (id.isEmpty) {
      L.i('ID $konteks kosong, mengembalikan null');
      return null;
    }

    try {
      L.i('Mengambil data $konteks dengan ID: $id');
      final model = getModel(id);

      if (model != null) {
        String? nama;
        if (model is DompetModel) {
          nama = model.namaDompet;
        } else if (model is KategoriModel) {
          nama = model.nama;
        } else if (model is SubKategoriModel) {
          nama = model.nama;
        } else if (model is PelangganModel) {
          nama = model.nama;
        } else if (model is PaketModel) {
          nama = model.nama;
        }

        if (nama != null) {
          L.i('Data $konteks ID: $id ditemukan: $nama');
          return nama;
        } else {
          L.w(
            'Model untuk $konteks ID: $id ditemukan, tetapi properti nama yang relevan tidak dapat diakses atau null. Tipe model: ${model.runtimeType}',
          );
          return 'Nama tidak tersedia';
        }
      }

      L.w('Data $konteks dengan ID: $id tidak ditemukan di database');
      return 'Data tidak ditemukan';
    } catch (e, stackTrace) {
      L.e('Gagal mengambil data $konteks dengan ID: $id Error: $e $stackTrace');
      return 'Error Memuat';
    }
  }

  // diubah: me-refresh data transaksi setelah kembali dari halaman edit
  void _bukaFormEdit() {}

  @override
  Widget build(BuildContext context) {
    final idDompetTujuan = transaksi.idDompetTujuan;
    final idSubKategori = transaksi.idSubKategori;
    final idPelanggan = transaksi.idPelanggan;
    final idPaket = transaksi.idPaket;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            L.i(
              'Kembali ke halaman sebelumnya dari Detail Transaksi ID: ${transaksi.id}',
            );
            Nav.pop(context);
          },
        ),
        // ditambah: tombol aksi untuk edit
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _bukaFormEdit,
            tooltip: 'Edit Transaksi',
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
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
              ).format(transaksi.jumlah),
            ),
            _buildDetailRow('Tipe', transaksi.tipe.name.toUpperCase()),

            _buildDetailRowSync(
              'Dompet',
              _getNama(
                (id) {
                  final state = ref.read(dompetProvider).value;
                  return state?.listDompet.firstWhereOrNull((d) => d.id == id);
                },
                transaksi.idDompet,
                'Dompet',
              ),
            ),

            if (idDompetTujuan != null && idDompetTujuan.isNotEmpty)
              _buildDetailRowSync(
                'Dompet Tujuan',
                _getNama(
                  (id) {
                    final state = ref.read(dompetProvider).value;
                    return state?.listDompet.firstWhereOrNull(
                      (d) => d.id == id,
                    );
                  },
                  idDompetTujuan,
                  'Dompet Tujuan',
                ),
              ),

            _buildDetailRowSync(
              'Kategori',
              _getNama(
                (id) {
                  final state = ref.read(kategoriProvider).value;
                  return state?.listKategori.firstWhereOrNull(
                    (k) => k.id == id,
                  );
                },
                transaksi.idKategori,
                'Kategori',
              ),
            ),

            if (idSubKategori != null && idSubKategori.isNotEmpty)
              _buildDetailRowSync(
                'Sub Kategori',
                _getNama(
                  (id) {
                    final state = ref.read(kategoriProvider).value;
                    for (final k in state?.listKategori ?? <dynamic>[]) {
                      final found = (k as dynamic).subKategori.firstWhereOrNull(
                        (sk) => sk.id == id,
                      );
                      if (found != null) return found;
                    }
                    return null;
                  },
                  idSubKategori,
                  'Sub-Kategori',
                ),
              ),

            if (idPelanggan != null && idPelanggan.isNotEmpty)
              _buildDetailRowSync(
                'Pelanggan',
                _getNama(
                  (id) {
                    final state = ref.read(pelangganProvider).value;
                    return state?.listPelanggan.firstWhereOrNull(
                      (p) => p.id == id,
                    );
                  },
                  idPelanggan,
                  'Pelanggan',
                ),
              ),

            if (idPaket != null && idPaket.isNotEmpty)
              _buildDetailRowSync(
                'Paket',
                _getNama(
                  (id) {
                    final state = ref.read(paketProvider).value;
                    return state?.getPaketById(id);
                  },
                  idPaket,
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
    L.i('Membangun baris detail - $label: $value');
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

  Widget _buildDetailRowSync(String label, String? value) {
    return _buildDetailRow(label, value ?? '-');
  }
}
