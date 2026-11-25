// path: lib/fitur/riwayat_langganan/screens/riwayat_aktivasi_paket.dart

import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/fitur/riwayat_langganan/screens/detail_riwayat_langganan.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/widget/nama_paket.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/core_shared.dart';

enum OpsiUrutkan { berakhirHariIni, terbaru, terlama, lunas, belumLunas }

class RiwayatAktivasiPaketPage extends ConsumerStatefulWidget {
  const RiwayatAktivasiPaketPage({super.key});

  @override
  ConsumerState<RiwayatAktivasiPaketPage> createState() =>
      _RiwayatAktivasiPaketPageState();
}

class _RiwayatAktivasiPaketPageState
    extends ConsumerState<RiwayatAktivasiPaketPage> {
  OpsiUrutkan _urutanAktif = OpsiUrutkan.terbaru;

  @override
  void initState() {
    super.initState();
    L.i('Menginisialisasi halaman Riwayat Aktivasi Paket');
  }

  Future<void> _muatUlang() async {
    try {
      await ref.read(transaksiProvider.notifier).muatUlang();
    } catch (e, s) {
      L.e('Gagal memuat ulang transaksi: $e $s');
    }
  }

  void _urutkanList(List<TransaksiModel> list, OpsiUrutkan pilihan) {
    L.i(
      'Mengurutkan ${list.length} data transaksi berdasarkan: ${pilihan.name}',
    );
    int Function(TransaksiModel, TransaksiModel) comparator;

    switch (pilihan) {
      case OpsiUrutkan.terbaru:
        comparator = (a, b) =>
            (b.diperbarui ?? b.tanggal).compareTo(a.diperbarui ?? a.tanggal);
        L.i('Pengurutan: Terbaru (berdasarkan waktu update/tanggal)');
        break;
      case OpsiUrutkan.terlama:
        comparator = (a, b) =>
            (a.diperbarui ?? a.tanggal).compareTo(b.diperbarui ?? b.tanggal);
        L.i('Pengurutan: Terlama (berdasarkan waktu update/tanggal)');
        break;
      case OpsiUrutkan.lunas:
        comparator = (a, b) {
          final isLunasA = a.statusPembayaran == StatusPembayaranEnum.lunas;
          final isLunasB = b.statusPembayaran == StatusPembayaranEnum.lunas;
          if (isLunasA == isLunasB) {
            L.i(
              'Status sama (${isLunasA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isLunasA ? -1 : 1;
          L.i(
            'Memindahkan transaksi ${isLunasA ? "lunas" : "belum lunas"} ke ${isLunasA ? "atas" : "bawah"}',
          );
          return result;
        };
        L.i('Pengurutan: Lunas di atas, Belum Lunas di bawah');
        break;
      case OpsiUrutkan.belumLunas:
        comparator = (a, b) {
          final isLunasA = a.statusPembayaran == StatusPembayaranEnum.lunas;
          final isLunasB = b.statusPembayaran == StatusPembayaranEnum.lunas;
          if (isLunasA == isLunasB) {
            L.i(
              'Status sama (${isLunasA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isLunasA ? 1 : -1;
          L.i(
            'Memindahkan transaksi ${isLunasA ? "lunas" : "belum lunas"} ke ${isLunasA ? "bawah" : "atas"}',
          );
          return result;
        };
        L.i('Pengurutan: Belum Lunas di atas, Lunas di bawah');
        break;
      case OpsiUrutkan.berakhirHariIni:
        comparator = (a, b) {
          final sekarang = DateTime.now();
          final tanggalSekarangStr = FormatTanggal.formatDasar(sekarang);

          bool isHariIni(DateTime? tanggal) {
            if (tanggal == null) return false;
            return tanggal.year == sekarang.year &&
                tanggal.month == sekarang.month &&
                tanggal.day == sekarang.day;
          }

          final aHariIni = isHariIni(a.tanggalBerakhir);
          final bHariIni = isHariIni(b.tanggalBerakhir);

          if (aHariIni == bHariIni) {
            L.i(
              'Status berakhir hari ini sama ($aHariIni), posisi tidak berubah',
            );
            return 0;
          }

          final result = aHariIni ? -1 : 1;
          L.i(
            'Transaksi ${aHariIni ? "berakhir $tanggalSekarangStr" : "tidak berakhir hari ini"} dipindahkan ke ${aHariIni ? "atas" : "bawah"}',
          );
          return result;
        };
        L.i(
          'Pengurutan: Berakhir Hari Ini (${FormatTanggal.formatSingkat(DateTime.now())}) di atas',
        );
        break;
    }

    list.sort(comparator);

    // Log 5 data teratas setelah pengurutan
    L.i('5 data teratas setelah pengurutan ${pilihan.name}:');
    for (int i = 0; i < (list.length < 5 ? list.length : 5); i++) {
      final t = list[i];
      L.i(
        '  ${i + 1}. ID: ${t.id} - Status: ${t.statusPembayaran.name} - Berakhir: ${t.tanggalBerakhir != null ? FormatTanggal.formatSingkat(t.tanggalBerakhir!) : "N/A"}',
      );
    }

    L.i('Proses pengurutan selesai, ${list.length} data telah diurutkan');
  }

  void _showUrutkanDialog() async {
    L.i(
      'Menampilkan dialog opsi pengurutan, urutan saat ini: ${_urutanAktif.name}',
    );
    final OpsiUrutkan? pilihan = await showDialog<OpsiUrutkan>(
      context: context,
      builder: (BuildContext context) {
        Widget buildOption(String text, OpsiUrutkan value) {
          final bool isSelected = _urutanAktif == value;
          return SimpleDialogOption(
            onPressed: () {
              L.i(
                'User memilih opsi urutkan: ${value.name} (${isSelected ? "sudah aktif" : "berubah"} dari ${_urutanAktif.name})',
              );
              Nav.pop(context, value);
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
            buildOption('Status (Lunas di Atas)', OpsiUrutkan.lunas),
            buildOption('Status (Belum Lunas di Atas)', OpsiUrutkan.belumLunas),
          ],
        );
      },
    );

    if (pilihan != null && pilihan != _urutanAktif) {
      L.i(
        'Menerapkan perubahan urutan dari ${_urutanAktif.name} ke ${pilihan.name}',
      );
      setState(() {
        _urutanAktif = pilihan;
      });
      L.i('Urutan berhasil diubah ke ${pilihan.name}');
    } else if (pilihan == _urutanAktif) {
      L.i(
        'User memilih urutan yang sama (${_urutanAktif.name}), tidak ada perubahan',
      );
    } else {
      L.i('Dialog urutkan ditutup tanpa memilih opsi');
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i(
      'Membangun UI halaman Riwayat Aktivasi Paket, urutan aktif: ${_urutanAktif.name}',
    );
    final asyncTransaksi = ref.watch(transaksiProvider);

    if (asyncTransaksi.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Langganan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (asyncTransaksi.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Langganan')),
        body: Center(child: Text('Error: ${asyncTransaksi.error}')),
      );
    }

    final state = asyncTransaksi.requireValue;
    final list = List<TransaksiModel>.from(state.getTransaksiByAktivasiPaket());
    _urutkanList(list, _urutanAktif);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            L.i('Kembali ke halaman sebelumnya dari Riwayat Aktivasi Paket');
            Nav.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showUrutkanDialog,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: list.isEmpty
          ? const Center(child: Text('Tidak ada riwayat langganan ditemukan.'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final transaksi = list[index];
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
                      L.i(
                        'Navigasi ke halaman Detail Transaksi ID: ${transaksi.id}, Pelanggan ID: ${transaksi.idPelanggan ?? "N/A"}',
                      );
                      final result = await Nav.to(
                        context,
                        DetailLanggananTransaksiPage(idTransaksi: transaksi.id),
                      );
                      if (result == true) {
                        L.i(
                          'Kembali dari Detail Transaksi ID: ${transaksi.id} dengan perubahan data, menyegarkan daftar',
                        );
                        await _muatUlang();
                      } else {
                        L.i(
                          'Kembali dari Detail Transaksi ID: ${transaksi.id} tanpa perubahan data',
                        );
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
                            'Aktif: ${FormatTanggal.formatSingkat(transaksi.tanggalMulai!)} - ${FormatTanggal.formatSingkat(transaksi.tanggalBerakhir!)}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
