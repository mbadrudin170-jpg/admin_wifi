// path: lib/halaman/lainnya/riwayat_aktivasi_paket.dart

import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_riwayat_langganan.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/widget/nama_paket.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'dart:developer' as developer;

enum OpsiUrutkan { berakhirHariIni, terbaru, terlama, lunas, belumLunas }

class RiwayatAktivasiPaketPage extends StatefulWidget {
  const RiwayatAktivasiPaketPage({super.key});

  @override
  State<RiwayatAktivasiPaketPage> createState() =>
      _RiwayatAktivasiPaketPageState();
}

class _RiwayatAktivasiPaketPageState extends State<RiwayatAktivasiPaketPage> {
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  late Future<List<TransaksiModel>> _listTransaksiFuture;
  OpsiUrutkan _urutanAktif = OpsiUrutkan.terbaru;

  @override
  void initState() {
    super.initState();
    developer.log('[RiwayatAktivasiPaketPage]-[initState] 🏁 : Menginisialisasi halaman riwayat', name: 'RiwayatAktivasiPaket');
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    developer.log('[RiwayatAktivasiPaketPage]-[_loadRiwayat] 🔄 : Memulai fetch data transaksi aktivasi paket', name: 'RiwayatAktivasiPaket');
    setState(() {
      _listTransaksiFuture = _transaksiOperasi
          .getTransaksiByAktivasiPaket()
          .then((list) {
            developer.log('[RiwayatAktivasiPaketPage]-[_loadRiwayat] 📥 : Berhasil mengambil ${list.length} data transaksi', name: 'RiwayatAktivasiPaket');
            _urutkanList(list, _urutanAktif);
            return list;
          }).catchError((error) {
            developer.log('[RiwayatAktivasiPaketPage]-[_loadRiwayat] ❌ : Error saat mengambil data', error: error, name: 'RiwayatAktivasiPaket');
            throw error;
          });
    });
  }

  void _urutkanList(List<TransaksiModel> list, OpsiUrutkan pilihan) {
    developer.log('[RiwayatAktivasiPaketPage]-[_urutkanList] ⚖️ : Mengurutkan list berdasarkan $pilihan', name: 'RiwayatAktivasiPaket');
    int Function(TransaksiModel, TransaksiModel) comparator;

    switch (pilihan) {
      case OpsiUrutkan.terbaru:
        comparator = (a, b) =>
            (b.diperbarui ?? b.tanggal).compareTo(a.diperbarui ?? a.tanggal);
        break;
      case OpsiUrutkan.terlama:
        comparator = (a, b) =>
            (a.diperbarui ?? a.tanggal).compareTo(b.diperbarui ?? b.tanggal);
        break;
      case OpsiUrutkan.lunas:
      case OpsiUrutkan.belumLunas:
        comparator = (a, b) {
          final isLunasA = a.statusPembayaran == StatusPembayaranEnum.lunas;
          final isLunasB = b.statusPembayaran == StatusPembayaranEnum.lunas;
          if (isLunasA == isLunasB) return 0;
          return (pilihan == OpsiUrutkan.lunas)
              ? (isLunasA ? -1 : 1)
              : (isLunasA ? 1 : -1);
        };
        break;
      case OpsiUrutkan.berakhirHariIni:
        comparator = (a, b) {
          final sekarang = DateTime.now();

          bool isHariIni(DateTime? tanggal) {
            if (tanggal == null) return false;

            return tanggal.year == sekarang.year &&
                tanggal.month == sekarang.month &&
                tanggal.day == sekarang.day;
          }

          final aHariIni = isHariIni(a.tanggalBerakhir);
          final bHariIni = isHariIni(b.tanggalBerakhir);

          if (aHariIni == bHariIni) return 0;

          return aHariIni ? -1 : 1;
        };
        break;
    }
    list.sort(comparator);
    developer.log('[RiwayatAktivasiPaketPage]-[_urutkanList] ✅ : Proses pengurutan selesai', name: 'RiwayatAktivasiPaket');
  }

  void _showUrutkanDialog() async {
    developer.log('[RiwayatAktivasiPaketPage]-[_showUrutkanDialog] 🗣️ : Menampilkan dialog urutkan', name: 'RiwayatAktivasiPaket');
    final OpsiUrutkan? pilihan = await showDialog<OpsiUrutkan>(
      context: context,
      builder: (BuildContext context) {
        Widget buildOption(String text, OpsiUrutkan value) {
          final bool isSelected = _urutanAktif == value;
          return SimpleDialogOption(
            onPressed: () {
              developer.log('[RiwayatAktivasiPaketPage]-[_showUrutkanDialog] 👆 : User memilih opsi $value', name: 'RiwayatAktivasiPaket');
              Navigator.pop(context, value);
            },
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            buildOption('Berakhir Hari Ini', OpsiUrutkan.berakhirHariIni),
            buildOption('Terbaru', OpsiUrutkan.terbaru),
            buildOption('Terlama', OpsiUrutkan.terlama),
            buildOption('Status (Lunas)', OpsiUrutkan.lunas),
            buildOption('Status (Belum Lunas)', OpsiUrutkan.belumLunas),
          ],
        );
      },
    );

    if (pilihan != null) {
      developer.log('[RiwayatAktivasiPaketPage]-[_showUrutkanDialog] 🔃 : Memproses perubahan urutan ke $pilihan', name: 'RiwayatAktivasiPaket');
      final list = await _listTransaksiFuture;
      setState(() {
        _urutanAktif = pilihan;
        _urutkanList(list, pilihan);
        _listTransaksiFuture = Future.value(list);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('[RiwayatAktivasiPaketPage]-[build] 🏗️ : Membangun UI riwayat', name: 'RiwayatAktivasiPaket');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showUrutkanDialog,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: FutureBuilder<List<TransaksiModel>>(
        future: _listTransaksiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            developer.log('[RiwayatAktivasiPaketPage]-[FutureBuilder] ⚠️ : Menampilkan error di UI', error: snapshot.error, name: 'RiwayatAktivasiPaket');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            developer.log('[RiwayatAktivasiPaketPage]-[FutureBuilder] 📭 : Data kosong/null', name: 'RiwayatAktivasiPaket');
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final transaksi = snapshot.data![index];
                final statusPembayaranColor =
                    transaksi.statusPembayaran == StatusPembayaranEnum.lunas
                    ? Colors.green
                    : Colors.red;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: ListTile(
                    onTap: () async {
                      developer.log('[RiwayatAktivasiPaketPage]-[ListView] 🔍 : Menuju detail transaksi ID: ${transaksi.id}', name: 'RiwayatAktivasiPaket');
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailLanggananTransaksiPage(
                            idTransaksi: transaksi.id,
                          ),
                        ),
                      );
                      if (result == true) {
                        developer.log('[RiwayatAktivasiPaketPage]-[ListView] 🔄 : Kembali dari detail, me-refresh data', name: 'RiwayatAktivasiPaket');
                        _loadRiwayat();
                      }
                    },
                    title: NamaPelangganWidget(
                      idPelanggan: transaksi.idPelanggan ?? ' ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NamaPaketWidget(idPaket: transaksi.idPaket ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${transaksi.statusPembayaran.name}',
                          style: TextStyle(
                            color: statusPembayaranColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (transaksi.tanggalMulai != null &&
                            transaksi.tanggalBerakhir != null)
                          Text(
                            'Aktif: ${FormatTanggal.formatTanggalBasic(transaksi.tanggalMulai!)} - ${FormatTanggal.formatTanggalBasic(transaksi.tanggalBerakhir!)}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}