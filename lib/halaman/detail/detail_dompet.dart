// path: lib/halaman/detail/detail_dompet.dart
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/halaman/form/form_dompet.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/widget/info_ringkasan_widget.dart';
import 'package:admin_wifi/widget/transaksi_list_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

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

  // Tambahkan variabel lokal untuk melacak nama dompet di AppBar
  String? _namaDompetTerbaru;

  @override
  void initState() {
    super.initState();
    _dompetOperasi = widget.dompetOperasi ?? DompetOperasi();
    _transaksiOperasi = widget.transaksiOperasi ?? TransaksiOperasi();

    developer.log('--- [Lifecycle: initState] DetailDompet ---');
    _futureDetailData = _loadData();
  }

  Future<DetailDompetData> _loadData() async {
    developer.log(
      '[DetailDompet] 📡 Memulai _loadData() untuk ID: ${widget.dompet.id}',
    );

    try {
      final results = await Future.wait([
        _dompetOperasi.getDompetById(widget.dompet.id),
        _transaksiOperasi.ambilTransaksiByDompetId(widget.dompet.id),
      ]);

      final dompetTerbaru = results[0] as DompetModel?;
      final daftarTransaksi = results[1] as List<TransaksiModel>;

      if (dompetTerbaru == null) {
        developer.log('[DetailDompet] ⚠️ Dompet null di DB');
        throw Exception('Dompet tidak ditemukan.');
      }

      // Update variabel lokal agar AppBar sinkron
      if (mounted) {
        setState(() {
          _namaDompetTerbaru = dompetTerbaru.namaDompet;
        });
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
        '[DetailDompet] ✅ Data Berhasil Dimuat (Nama: ${dompetTerbaru.namaDompet}, Trx: ${daftarTransaksi.length})',
      );

      return DetailDompetData(
        dompet: dompetTerbaru,
        transaksi: daftarTransaksi,
        totalPemasukan: pemasukan,
        totalPengeluaran: pengeluaran,
      );
    } catch (e, s) {
      developer.log(
        '[DetailDompet] ❌ Gagal memuat data',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  void _muatUlangData() {
    developer.log('[DetailDompet] 🔄 Memicu _muatUlangData() via setState');
    setState(() {
      _futureDetailData = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log('--- [Lifecycle: build] DetailDompet ---');
    return Scaffold(
      appBar: AppBar(
        // PERBAIKAN: Gunakan nama terbaru, jika belum ada gunakan dari widget
        title: Text(_namaDompetTerbaru ?? widget.dompet.namaDompet),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            developer.log('[DetailDompet] ⬅️ Kembali ke Home');
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              developer.log('[DetailDompet] 📝 Menuju FormDompet (Edit)');

              // PERBAIKAN: Kirim data dompet TERBARU ke form agar inputnya sinkron
              // Jika _namaDompetTerbaru ada, kita buat instance temporary untuk dikirim
              final dompetUntukEdit = _namaDompetTerbaru != null
                  ? widget.dompet.copyWith(namaDompet: _namaDompetTerbaru)
                  : widget.dompet;

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormDompet(dompet: dompetUntukEdit),
                ),
              );

              developer.log(
                '[DetailDompet] 📥 Kembali dari Form, Result: $result',
              );

              if (result == true) {
                developer.log(
                  '[DetailDompet] ✨ Result TRUE, memanggil refresh...',
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
            developer.log('[DetailDompet] ⏳ FutureBuilder: Waiting...');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            developer.log('[DetailDompet] ❌ FutureBuilder: Error');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            developer.log('[DetailDompet] ❓ FutureBuilder: No Data');
            return const Center(child: Text('Data Kosong'));
          }

          final data = snapshot.data!;
          developer.log('[DetailDompet] 🎨 Membangun UI dengan data terbaru');

          return Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    bangunInfoRingkasan(
                      context: context,
                      label: 'Pemasukan',
                      jumlah: data.totalPemasukan,
                      warna: Colors.green,
                    ),
                    bangunInfoRingkasan(
                      context: context,
                      label: 'Pengeluaran',
                      jumlah: data.totalPengeluaran,
                      warna: Colors.red,
                    ),
                    bangunInfoRingkasan(
                      context: context,
                      label: 'Saldo',
                      jumlah: data.dompet.saldo, // Pakai data dari snapshot
                      warna: data.dompet.saldo >= 0 ? Colors.blue : Colors.red,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: data.transaksi.isEmpty
                    ? const Center(child: Text('Belum ada transaksi.'))
                    : _buildTransaksiList(data.transaksi),
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

        final totalHarian = transaksiPadaTanggal.fold(
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
            bangunHeaderSeksi(tanggal, totalHarian),
            ...transaksiPadaTanggal.map(
              (transaksi) => bangunItemTransaksi(context, transaksi, () {
                developer.log('[DetailDompet] 🔄 Refresh dari ItemTransaksi');
                _muatUlangData();
              }, _transaksiOperasi),
            ),
          ],
        );
      },
    );
  }
}
