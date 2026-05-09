// path: lib/halaman/pembantu/halaman_poin.dart
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

  // Fungsi ini bertujuan untuk memuat total poin pelanggan.
  Future<void> _loadData() async {
    final hasilPoin = await transaksiOperasi.getTotalPoin(widget.idPelanggan);
    final hasilPaket = await paketOperasi.getPaket();
    if (!mounted) return;

    setState(() {
      totalPoin = hasilPoin;
      daftarPaket = hasilPaket;
      isLoading = false;
    });
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              // //saya pinginnya kedua tombol ini bisa mendapatkan rasio 50:50 lebar nya dari parent
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // // mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: _buildTabButton(
                    label: 'Penukaran',
                    aktif: menuAktif == MenuPoin.penukaran,
                    onTap: () {
                      setState(() {
                        menuAktif = MenuPoin.penukaran;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    label: 'Riwayat',
                    aktif: menuAktif == MenuPoin.riwayat,
                    onTap: () {
                      setState(() {
                        menuAktif = MenuPoin.riwayat;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: menuAktif == MenuPoin.riwayat
                ? _riwayatTransaksi(context, widget.idPelanggan)
                : _listPaket(context, totalPoin, daftarPaket),
          ),
        ],
      ),
    );
  }

  Widget _infoPoin(BuildContext context, int poin) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Total Poin'),
            Text(
              '$poin',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: aktif ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        boxShadow: aktif
            ? [const BoxShadow(color: Colors.black12, blurRadius: 6)]
            : null,
      ),
      child: Text(
        textAlign: TextAlign.center,
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: aktif ? Colors.black : Colors.grey,
        ),
      ),
    ),
  );
}

double _hitungProgressPencapaian(int poinDimiliki, int poinDibutuhkan) {
  // Hindari pembagian dengan nol jika total poin tidak valid.
  if (poinDibutuhkan <= 0) {
    return 0.0;
  }
  final double rasio = poinDimiliki / poinDibutuhkan;
  return rasio.clamp(0.0, 1.0);
}

Widget _listPaket(
  BuildContext context,
  int totalPoinPelanggan,
  List<PaketModel> daftarPaket,
) {
  if (daftarPaket.isEmpty) {
    return const Center(child: Text('Belum ada paket'));
  }

  return ListView.builder(
    itemCount: daftarPaket.length,
    itemBuilder: (context, index) {
      final paket = daftarPaket[index];
      final bool bisaDitukar = totalPoinPelanggan >= paket.poinPenukaran;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

        child: ListTile(
          title: Text(paket.nama),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Poin: ${paket.poinPenukaran}'),
              const SizedBox(height: 5),

              if (paket.isPublic)
                LinearProgressIndicator(
                  value: _hitungProgressPencapaian(
                    totalPoinPelanggan,
                    paket.poinPenukaran,
                  ),
                  backgroundColor: Colors.grey.shade300,
                  color: bisaDitukar
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                  minHeight: 6,
                )
              else
                // ditambah: Pesan ini muncul jika paket tidak publik.
                const Text(
                  'Paket tidak dapat ditukar',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

int _selisihPoin(TransaksiModel t) {
  return t.poinYangDihasilkan - t.poinYangDigunakan;
}

Color _warnaPoin(int selisih) {
  if (selisih > 0) {
    return Colors.green;
  } else if (selisih < 0) {
    return Colors.red;
  } else {
    return Colors.grey;
  }
}

Widget _riwayatTransaksi(BuildContext context, String idPelanggan) {
  final transaksiOperasi = TransaksiOperasi();

  return FutureBuilder(
    future: transaksiOperasi.ambilTransaksiByPelangganId(idPelanggan),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Terjadi error: ${snapshot.error}'));
      }

      final daftarTransaksi = snapshot.data ?? [];

      if (daftarTransaksi.isEmpty) {
        return const Center(child: Text('Belum ada riwayat transaksi'));
      }

      return ListView.builder(
        itemCount: daftarTransaksi.length,
        itemBuilder: (context, index) {
          final transaksi = daftarTransaksi[index];
          final selisih = _selisihPoin(transaksi);
          return ListTile(
            title: Text(transaksi.keterangan),
            subtitle: Text(transaksi.id),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selisih > 0
                      ? Icons.arrow_upward
                      : selisih < 0
                      ? Icons.arrow_downward
                      : Icons.remove,
                  color: _warnaPoin(selisih),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${selisih >= 0 ? '+' : ''}$selisih poin',
                  style: TextStyle(
                    color: _warnaPoin(selisih),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () {
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
