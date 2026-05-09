import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/halaman/form/form_dompet.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/widget/info_ringkasan_widget.dart';
import 'package:admin_wifi/widget/transaksi_list_widgets.dart';
import 'package:flutter/material.dart';

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
  // diubah: Hanya satu future untuk semua data
  late Future<DetailDompetData> _futureDetailData;

  late final DompetOperasi _dompetOperasi;
  late final TransaksiOperasi _transaksiOperasi;

  @override
  void initState() {
    super.initState();
    _dompetOperasi = widget.dompetOperasi ?? DompetOperasi();
    _transaksiOperasi = widget.transaksiOperasi ?? TransaksiOperasi();
    // diubah: Memanggil fungsi _loadData untuk future
    _futureDetailData = _loadData();
  }

  // diubah: Fungsi untuk memuat semua data dalam satu pemanggilan
  Future<DetailDompetData> _loadData() async {
    final results = await Future.wait([
      _dompetOperasi.getDompetById(widget.dompet.id),
      _transaksiOperasi.ambilTransaksiByDompetId(widget.dompet.id),
    ]);

    final dompetTerbaru = results[0] as DompetModel?;
    final daftarTransaksi = results[1] as List<TransaksiModel>;

    if (dompetTerbaru == null) {
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

    return DetailDompetData(
      dompet: dompetTerbaru,
      transaksi: daftarTransaksi,
      totalPemasukan: pemasukan,
      totalPengeluaran: pengeluaran,
    );
  }

  // diubah: Fungsi muat ulang hanya me-reassign future
  void _muatUlangData() {
    setState(() {
      _futureDetailData = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ditambahkan: Key untuk AppBar
        key: const Key('appBar'),
        title: Text(widget.dompet.namaDompet),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormDompet(dompet: widget.dompet),
                ),
              );
              if (result == true) {
                _muatUlangData();
              }
            },
          ),
        ],
      ),
      // diubah: Seluruh body dibungkus dengan FutureBuilder
      body: FutureBuilder<DetailDompetData>(
        future: _futureDetailData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
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
                    // diubah: Menggunakan widget _buildTransaksiList yang baru
                    : _buildTransaksiList(transaksiList),
              ),
            ],
          );
        },
      ),
    );
  }

  // ditambahkan: Fungsi untuk membangun daftar transaksi yang dikelompokkan
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
              (transaksi) => bangunItemTransaksi(
                context,
                transaksi,
                _muatUlangData,
                _transaksiOperasi, // Diubah: Menambahkan parameter yang hilang
              ),
            ),
          ],
        );
      },
    );
  }
}
