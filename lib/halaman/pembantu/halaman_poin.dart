// path: lib/halaman/pembantu/halaman_poin.dart
import 'dart:developer' as developer;
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_riwayat_langganan.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:flutter/material.dart';

enum MenuPoin { penukaran, riwayat }

class HalamanPoin extends StatefulWidget {
  final String idPelanggan;

  const HalamanPoin({super.key, required this.idPelanggan});

  @override
  State<HalamanPoin> createState() => _HalamanPoinState();
}

class _HalamanPoinState extends State<HalamanPoin> {
  final String fileName = 'halaman_poin.dart';
  final transaksiOperasi = TransaksiOperasi();
  final paketOperasi = PaketOperasi();

  int totalPoin = 0;
  bool isLoading = true;
  List<PaketModel> daftarPaket = [];
  MenuPoin menuAktif = MenuPoin.riwayat;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      developer.log(
        '🔄 Memuat data poin dan paket untuk pelanggan: ${widget.idPelanggan}',
        name: fileName,
      );

      final hasilPoin = await transaksiOperasi.getTotalPoin(widget.idPelanggan);
      final hasilPaket = await paketOperasi.getPaket();

      if (!mounted) return;

      setState(() {
        totalPoin = hasilPoin;
        daftarPaket = hasilPaket;
        isLoading = false;
      });

      developer.log(
        '✅ Data berhasil dimuat. Total Poin: $totalPoin, Jumlah Paket: ${daftarPaket.length}',
        name: fileName,
      );
    } catch (e) {
      developer.log(
        '❌ Gagal memuat data di HalamanPoin: $e',
        name: fileName,
        error: e,
      );
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Poin')),
      body: Column(
        children: [
          _infoPoin(context, totalPoin),

          // Tab Switcher dengan rasio 50:50
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    label: 'Penukaran',
                    aktif: menuAktif == MenuPoin.penukaran,
                    onTap: () {
                      developer.log(
                        '🔘 Pindah ke tab Penukaran',
                        name: fileName,
                      );
                      setState(() => menuAktif = MenuPoin.penukaran);
                    },
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    label: 'Riwayat',
                    aktif: menuAktif == MenuPoin.riwayat,
                    onTap: () {
                      developer.log('🔘 Pindah ke tab Riwayat', name: fileName);
                      setState(() => menuAktif = MenuPoin.riwayat);
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: menuAktif == MenuPoin.riwayat
                ? _riwayatTransaksi(context, widget.idPelanggan, fileName)
                : _listPaket(context, totalPoin, daftarPaket, fileName),
          ),
        ],
      ),
    );
  }

  Widget _infoPoin(BuildContext context, int poin) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Total Poin Anda', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 30),
                const SizedBox(width: 10),
                Text(
                  '$poin',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTabButton({
  required String label,
  required bool aktif,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: aktif ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        boxShadow: aktif
            ? [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: aktif ? Colors.black : Colors.grey.shade600,
        ),
      ),
    ),
  );
}

double _hitungProgressPencapaian(int poinDimiliki, int poinDibutuhkan) {
  if (poinDibutuhkan <= 0) return 0.0;
  return (poinDimiliki / poinDibutuhkan).clamp(0.0, 1.0);
}

Widget _listPaket(
  BuildContext context,
  int totalPoinPelanggan,
  List<PaketModel> daftarPaket,
  String fileName,
) {
  if (daftarPaket.isEmpty) {
    return const Center(child: Text('Belum ada paket penukaran'));
  }

  return ListView.builder(
    padding: const EdgeInsets.only(bottom: 20),
    itemCount: daftarPaket.length,
    itemBuilder: (context, index) {
      final paket = daftarPaket[index];
      final bool bisaDitukar = totalPoinPelanggan >= paket.poinPenukaran;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: bisaDitukar
                ? Colors.green.shade100
                : Colors.blue.shade100,
            child: Icon(
              Icons.card_giftcard,
              color: bisaDitukar ? Colors.green : Colors.blue,
            ),
          ),
          title: Text(
            paket.nama,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Butuh ${paket.poinPenukaran} Poin'),
              const SizedBox(height: 8),
              if (paket.isPublic)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _hitungProgressPencapaian(
                      totalPoinPelanggan,
                      paket.poinPenukaran,
                    ),
                    backgroundColor: Colors.grey.shade300,
                    color: bisaDitukar ? Colors.green : Colors.blue,
                    minHeight: 8,
                  ),
                )
              else
                const Text(
                  '⚠️ Paket khusus (Internal)',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          trailing: bisaDitukar && paket.isPublic
              ? ElevatedButton(
                  onPressed: () {
                    developer.log(
                      '🎁 Mencoba menukar paket: ${paket.nama}',
                      name: fileName,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tukar'),
                )
              : null,
        ),
      );
    },
  );
}

Widget _riwayatTransaksi(
  BuildContext context,
  String idPelanggan,
  String fileName,
) {
  final transaksiOperasi = TransaksiOperasi();

  return FutureBuilder<List<TransaksiModel>>(
    future: transaksiOperasi.ambilTransaksiByPelangganId(idPelanggan),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        developer.log(
          '❌ Error snapshot riwayat: ${snapshot.error}',
          name: fileName,
        );
        return const Center(child: Text('Terjadi kesalahan data'));
      }

      final daftarTransaksi = snapshot.data ?? [];

      if (daftarTransaksi.isEmpty) {
        return const Center(child: Text('Belum ada riwayat transaksi'));
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: daftarTransaksi.length,
        itemBuilder: (context, index) {
          final transaksi = daftarTransaksi[index];
          final selisih =
              transaksi.poinYangDihasilkan - transaksi.poinYangDigunakan;
          final color = selisih > 0
              ? Colors.green
              : (selisih < 0 ? Colors.red : Colors.grey);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(
              selisih > 0
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color: color,
            ),
            title: Text(transaksi.keterangan),
            subtitle: Text(transaksi.id, style: const TextStyle(fontSize: 10)),
            trailing: Text(
              '${selisih >= 0 ? '+' : ''}$selisih Poin',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: () {
              developer.log(
                '🔍 Melihat detail transaksi: ${transaksi.id}',
                name: fileName,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailLanggananTransaksiPage(idTransaksi: transaksi.id),
                ),
              );
            },
          );
        },
      );
    },
  );
}
