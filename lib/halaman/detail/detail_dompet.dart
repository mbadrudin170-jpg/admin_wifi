import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/halaman/form/form_dompet.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/widget/info_ringkasan_widget.dart';
import 'package:admin_wifi/widget/transaksi_list_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer; // Tambahkan ini

// ditambahkan: Data class untuk menampung hasil data dari Future
class DetailDompetData {
  final DompetModel dompet;
  final List<TransaksiModel> transaksi;
  final double totalPemasukan;
  final double totalPengeluaran;

  DetailDompetData({
    required this.dompet,
    required this.transaksi,
    required this.totalPemasukan,
    required this.totalPengeluaran,
  });
}

class DetailDompet extends StatefulWidget {
  final DompetModel dompet;
  final DompetOperasi? dompetOperasi;
  final TransaksiOperasi? transaksiOperasi;

  const DetailDompet({
    super.key,
    required this.dompet,
    this.dompetOperasi,
    this.transaksiOperasi,
  });

  @override
  State<DetailDompet> createState() => _DetailDompetState();
}

class _DetailDompetState extends State<DetailDompet> {
  late Future<DetailDompetData> _futureDetailData;
  late final DompetOperasi _dompetOperasi;
  late final TransaksiOperasi _transaksiOperasi;

  @override
  void initState() {
    super.initState();
    developer.log('initState dipanggil', name: 'detail_dompet.dart');
    _dompetOperasi = widget.dompetOperasi ?? DompetOperasi();
    _transaksiOperasi = widget.transaksiOperasi ?? TransaksiOperasi();
    _futureDetailData = _loadData();
  }

  Future<DetailDompetData> _loadData() async {
    developer.log(
      'Memulai memuat data untuk dompet ID: ${widget.dompet.id}',
      name: 'detail_dompet.dart',
    );
    try {
      final results = await Future.wait([
        _dompetOperasi.getDompetById(widget.dompet.id),
        _transaksiOperasi.ambilTransaksiByDompetId(widget.dompet.id),
      ]);

      final dompetTerbaru = results[0] as DompetModel?;
      final daftarTransaksi = results[1] as List<TransaksiModel>;

      if (dompetTerbaru == null) {
        developer.log('Error: Dompet terbaru null', name: 'detail_dompet.dart');
        throw Exception('Gagal memuat data dompet.');
      }

      double pemasukan = 0;
      double pengeluaran = 0;
      for (var trx in daftarTransaksi) {
        if (trx.tipe == TipeTransaksi.pemasukan) {
          pemasukan += trx.jumlah;
        } else if (trx.tipe == TipeTransaksi.pengeluaran) {
          pengeluaran += trx.jumlah;
        }
      }

      developer.log(
        'Sukses memuat data: ${daftarTransaksi.length} transaksi ditemukan',
        name: 'detail_dompet.dart',
      );

      return DetailDompetData(
        dompet: dompetTerbaru,
        transaksi: daftarTransaksi,
        totalPemasukan: pemasukan,
        totalPengeluaran: pengeluaran,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error pada _loadData: $e',
        name: 'detail_dompet.dart',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _muatUlangData() {
    developer.log(
      'Memperbarui tampilan (_muatUlangData)',
      name: 'detail_dompet.dart',
    );
    setState(() {
      _futureDetailData = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('appBar'),
        title: Text(widget.dompet.namaDompet),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            developer.log(
              'Navigasi kembali dari DetailDompet',
              name: 'detail_dompet.dart',
            );
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              developer.log(
                'Membuka FormDompet untuk edit',
                name: 'detail_dompet.dart',
              );
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormDompet(dompet: widget.dompet),
                ),
              );
              if (result == true) {
                developer.log(
                  'Data berhasil diedit, memicu muat ulang',
                  name: 'detail_dompet.dart',
                );
                _muatUlangData();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DetailDompetData>(
        future: _futureDetailData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            developer.log(
              'FutureBuilder menangkap error: ${snapshot.error}',
              name: 'detail_dompet.dart',
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            developer.log(
              'FutureBuilder: Data kosong',
              name: 'detail_dompet.dart',
            );
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final data = snapshot.data!;
          final dompetSaatIni = data.dompet;
          final transaksiList = data.transaksi;
          final double total = dompetSaatIni.saldo;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        bangunInfoRingkasan(
                          context: context,
                          label: 'Pemasukan',
                          jumlah: data.totalPemasukan,
                          warna: Colors.green,
                          textKey: const Key('totalPemasukan'),
                        ),
                        bangunInfoRingkasan(
                          context: context,
                          label: 'Pengeluaran',
                          jumlah: data.totalPengeluaran,
                          warna: Colors.red,
                          textKey: const Key('totalPengeluaran'),
                        ),
                        bangunInfoRingkasan(
                          context: context,
                          label: 'Total',
                          jumlah: total,
                          warna: total >= 0 ? Colors.blue : Colors.red,
                          textKey: const Key('totalSaldo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  'Riwayat Transaksi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: transaksiList.isEmpty
                    ? const Center(child: Text('Tidak ada riwayat transaksi.'))
                    : _buildTransaksiList(transaksiList),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransaksiList(List<TransaksiModel> transaksiData) {
    final groupedTransaksi = groupTransaksiByDate(transaksiData);

    return ListView.builder(
      itemCount: groupedTransaksi.length,
      itemBuilder: (context, index) {
        final tanggal = groupedTransaksi.keys.elementAt(index);
        final transaksiPadaTanggal = groupedTransaksi[tanggal]!;
        final totalPadaTanggal = transaksiPadaTanggal.fold(
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
            bangunHeaderSeksi(tanggal, totalPadaTanggal),
            ...transaksiPadaTanggal.map(
              (transaksi) => bangunItemTransaksi(context, transaksi, () {
                developer.log(
                  'Callback hapus/edit transaksi dipicu',
                  name: 'detail_dompet.dart',
                );
                _muatUlangData();
              }, _transaksiOperasi),
            ),
          ],
        );
      },
    );
  }
}
