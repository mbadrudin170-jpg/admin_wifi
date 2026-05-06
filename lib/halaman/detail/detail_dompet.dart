// path: lib/halaman/detail/detail_dompet.dart
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_transaksi.dart';
import 'package:admin_wifi/halaman/form/form_dompet.dart';
import 'package:admin_wifi/halaman/form/form_transaksi.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  void _goToEditForm(DompetModel dompet) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormDompet(dompet: dompet),
      ),
    );

    if (result == true) {
      _muatUlangData();
    }
  }

  void _arsipkanTransaksi(String transaksiId) async {
    if (!mounted) return;
    await _transaksiOperasi.arsipkanTransaksi(transaksiId);
    _muatUlangData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dompet.namaDompet),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
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

          final double saldoSaatIni = dompetSaatIni.saldo;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Saldo Saat Ini:',
                              style: TextStyle(fontSize: 18)),
                          IconButton(
                              onPressed: () => _goToEditForm(dompetSaatIni),
                              icon: const Icon(Icons.edit)),
                        ]),
                    Text(
                      key: const Key('totalSaldo'), // ditambahkan: Key untuk total saldo
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(saldoSaatIni),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            saldoSaatIni >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pemasukan'),
                            Text(
                              key: const Key('totalPemasukan'), // ditambahkan: Key untuk total pemasukan
                              FormatUang.formatMataUang(data.totalPemasukan),
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Pengeluaran'),
                            Text(
                              key: const Key('totalPengeluaran'), // ditambahkan: Key untuk total pengeluaran
                              FormatUang.formatMataUang(
                                  data.totalPengeluaran),
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
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
                    ? const Center(
                        child: Text('Tidak ada riwayat transaksi.'))
                    : ListView.builder(
                        itemCount: transaksiList.length,
                        itemBuilder: (context, index) {
                          final transaksi = transaksiList[index];
                          final isPemasukan =
                              transaksi.tipe == TipeTransaksi.pemasukan;

                          return ListTile(
                            leading: Icon(
                              isPemasukan
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color:
                                  isPemasukan ? Colors.green : Colors.red,
                            ),
                            title: Text(transaksi.keterangan),
                            subtitle: Text(
                              FormatTanggal.formatTanggalDanJam(
                                  transaksi.tanggal),
                            ),
                            trailing: Text(
                              FormatUang.formatMataUang(transaksi.jumlah),
                              style: TextStyle(
                                color: isPemasukan
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailTransaksiPage(
                                      transaksi: transaksi),
                                ),
                              );
                              if (result == true) {
                                _muatUlangData();
                              }
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Opsi'),
                                  content: const Text(
                                    'Apa yang ingin Anda lakukan dengan transaksi ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(
                                            context); // Tutup dialog
                                        final result =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FormTransaksiPage(
                                              transaksi: transaksi,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _muatUlangData();
                                        }
                                      },
                                      child: const Text('Edit'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Tutup dialog
                                        _arsipkanTransaksi(transaksi.id);
                                      },
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
