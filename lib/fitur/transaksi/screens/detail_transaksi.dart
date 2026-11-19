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
  late TransaksiModel _transaksiSaatIni;

  @override
  void initState() {
    super.initState();
    _transaksiSaatIni =
        widget.transaksi; // ditambah: Inisialisasi dengan data awal
    L.i('Membuka halaman Detail Transaksi ID: ${_transaksiSaatIni.id}');
    L.i(
      'Ringkasan transaksi - Tipe: ${_transaksiSaatIni.tipe.name}, Jumlah: ${_transaksiSaatIni.jumlah}, Tanggal: ${_transaksiSaatIni.tanggal.toIso8601String()}, Status: ${_transaksiSaatIni.statusPembayaran.name}',
    );
    L.i(
      'Relasi transaksi - Dompet: ${_transaksiSaatIni.idDompet}, Kategori: ${_transaksiSaatIni.idKategori}, SubKategori: ${_transaksiSaatIni.idSubKategori ?? "N/A"}, Pelanggan: ${_transaksiSaatIni.idPelanggan ?? "N/A"}, Paket: ${_transaksiSaatIni.idPaket ?? "N/A"}',
    );
  }

  // DIUBAH: Logika diperkuat dengan pengecekan tipe eksplisit untuk mencegah error.
  Future<String?> _getNama(
    Future<dynamic> Function(String) getModel,
    String id,
    String konteks,
  ) async {
    if (id.isEmpty) {
      L.i('ID $konteks kosong, mengembalikan null');
      return null;
    }

    try {
      L.i('Mengambil data $konteks dengan ID: $id');
      final model = await getModel(id);

      if (model != null) {
        String? nama;
        // diubah: Menggunakan pengecekan tipe eksplisit (is) untuk keamanan akses properti.
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
  void _bukaFormEdit() {
    L.i(
      'Navigasi ke FormTransaksiPage mode edit untuk ID: ${_transaksiSaatIni.id}',
    );
    unawaited(
      Nav.to<TransaksiModel>(
            context,
            FormTransaksiPage(transaksi: _transaksiSaatIni),
          )
          .then((transaksiYangDiperbarui) {
            if (transaksiYangDiperbarui != null) {
              L.i(
                'Kembali dari form edit, data telah berubah. Memperbarui UI.',
              );
              setState(() {
                _transaksiSaatIni = transaksiYangDiperbarui;
              });
            } else {
              L.i('Kembali dari form edit, tidak ada perubahan data.');
            }
          })
          .catchError((Object e, StackTrace s) {
            L.e('Navigasi gagal: $e $s');
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TransaksiModel transaksi =
        _transaksiSaatIni; // diubah: Menggunakan data dari state
    final idDompetTujuan = transaksi.idDompetTujuan;
    final idSubKategori = transaksi.idSubKategori;
    final idPelanggan = transaksi.idPelanggan;
    final idPaket = transaksi.idPaket;
    L.i('Membangun UI Detail Transaksi ID: ${transaksi.id}');

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

            _buildFutureDetailRow(
              'Dompet',
              _getNama(
                (id) async {
                  final state = await ref.read(dompetProvider.future);
                  return state.listDompet.firstWhereOrNull((d) => d.id == id);
                },
                transaksi.idDompet,
                'Dompet',
              ),
            ),

            if (idDompetTujuan != null && idDompetTujuan.isNotEmpty)
              _buildFutureDetailRow(
                'Dompet Tujuan',
                _getNama(
                  (id) async {
                    final state = await ref.read(dompetProvider.future);
                    return state.listDompet.firstWhereOrNull((d) => d.id == id);
                  },
                  idDompetTujuan,
                  'Dompet Tujuan',
                ),
              ),

            _buildFutureDetailRow(
              'Kategori',
              _getNama(
                (id) async {
                  final state = await ref.read(kategoriProvider.future);
                  return state.listKategori.firstWhereOrNull((k) => k.id == id);
                },
                transaksi.idKategori,
                'Kategori',
              ),
            ),

            if (idSubKategori != null && idSubKategori.isNotEmpty)
              _buildFutureDetailRow(
                'Sub Kategori',
                _getNama(
                  (id) async {
                    final state = await ref.read(kategoriProvider.future);
                    for (final k in state.listKategori) {
                      final found = k.subKategori.firstWhereOrNull(
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
              _buildFutureDetailRow(
                'Pelanggan',
                _getNama(
                  (id) async {
                    final state = await ref.read(pelangganProvider.future);
                    return state.listPelanggan.firstWhereOrNull(
                      (p) => p.id == id,
                    );
                  },
                  idPelanggan,
                  'Pelanggan',
                ),
              ),

            if (idPaket != null && idPaket.isNotEmpty)
              _buildFutureDetailRow(
                'Paket',
                _getNama(
                  (id) async {
                    final state = await ref.read(paketProvider.future);
                    return state.listPaket.firstWhereOrNull((p) => p.id == id);
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

  Widget _buildFutureDetailRow(String label, Future<String?> future) {
    L.i('Membangun FutureBuilder untuk: $label');
    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          L.i('FutureBuilder $label: masih loading');
          return _buildDetailRow(label, 'Memuat...');
        }
        if (snapshot.hasError) {
          L.e(
            'FutureBuilder $label: error Error: $snapshot.error $snapshot.stackTrace',
          );
          return _buildDetailRow(label, 'Error Data');
        }
        final data = snapshot.data ?? '-';
        L.i('FutureBuilder $label: selesai dengan data "$data"');
        return _buildDetailRow(label, data);
      },
    );
  }
}
