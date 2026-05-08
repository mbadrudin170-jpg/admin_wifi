// path: lib/halaman/pembantu/halaman_poin.dart
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:flutter/material.dart';

class HalamanPoin extends StatefulWidget {
  final String idPelanggan;

  const HalamanPoin({super.key, required this.idPelanggan});

  @override
  State<HalamanPoin> createState() => _HalamanPoinState();
}

class _HalamanPoinState extends State<HalamanPoin> {
  final transaksiOperasi = TransaksiOperasi();

  int totalPoin = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPoin();
  }

  // Fungsi ini bertujuan untuk memuat total poin pelanggan.
  Future<void> _loadPoin() async {
    final hasil = await transaksiOperasi.getTotalPoin(widget.idPelanggan);

    if (!mounted) return;

    setState(() {
      totalPoin = hasil;
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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              TextButton(onPressed: () {}, child: const Text('Penukaran')),

              TextButton(onPressed: () {}, child: const Text('Riwayat')),
            ],
          ),

          Text(widget.idPelanggan),

          const Text('data'),
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

  Widget _daftarRiwayat() {
    return Container(child: const Text('data'));
  }

  Widget _daftarReward() {
    return Container(child: const Text('data'));
  }
}
