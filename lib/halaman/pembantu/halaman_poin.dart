// path: lib/halaman/pembantu/halaman_poin.dart

import 'dart:developer' as developer;
import 'package:flutter/material.dart';

// Fungsi ini bertujuan untuk membuat halaman yang menampilkan poin reward dan transaksi.
class HalamanPoin extends StatefulWidget {
  // diubah: Menggunakan const constructor.
  const HalamanPoin({super.key});

  @override
  State<HalamanPoin> createState() => _HalamanPoinState();
}

class _HalamanPoinState extends State<HalamanPoin> {
  // diubah: Penamaan variabel menggunakan Bahasa Indonesia.
  bool _tampilkanReward = false;
  final int _poinSaatIni = 2450;

  // ditambah: Data dipisahkan dari UI.
  late final List<_ModelTransaksi> _dataTransaksi;
  late final List<_ModelReward> _dataReward;

  // Fungsi ini bertujuan untuk inisialisasi state awal.
  @override
  void initState() {
    super.initState();
    developer.log('initState: Menginisialisasi state untuk HalamanPoin.',
        name: 'HalamanPoin');

    // ditambah: Mengisi data model saat inisialisasi.
    _dataTransaksi = [
      const _ModelTransaksi(
          judul: 'Langganan Netflix',
          kategori: 'Hiburan',
          jumlah: '- Rp 186.000',
          isPemasukan: false),
      const _ModelTransaksi(
          judul: 'Gaji Bulanan',
          kategori: 'Pemasukan',
          jumlah: '+ Rp 8.450.000',
          isPemasukan: true),
    ];

    _dataReward = [
      const _ModelReward(ikon: '🛍️', judul: 'Voucher Belanja', poin: 500),
      const _ModelReward(ikon: '📱', judul: 'Pulsa Rp 50rb', poin: 1200),
      const _ModelReward(ikon: '💳', judul: 'Saldo E-Wallet', poin: 2500),
      const _ModelReward(ikon: '🚚', judul: 'Potongan Ongkir', poin: 300),
    ];

    developer.log(
        'initState: Data transaksi dan reward berhasil dimuat ke dalam model.',
        name: 'HalamanPoin');
  }

  // Fungsi ini bertujuan untuk membangun UI utama halaman.
  @override
  Widget build(BuildContext context) {
    developer.log('build: Membangun widget HalamanPoin.', name: 'HalamanPoin');
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB), // Amber 50
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header Reward
              _bangunHeader(),
              const SizedBox(height: 24),
              // Kartu Poin
              _bangunKartuPoin(),
              const SizedBox(height: 32),
              // Tombol Pilihan Tampilan
              _bangunPilihanTampilan(),
              const SizedBox(height: 16),
              // Konten Dinamis (Reward atau Transaksi)
              // diubah: Kondisi berdasarkan variabel _tampilkanReward.
              _tampilkanReward ? _bangunGridReward() : _bangunDaftarTransaksi(),
            ],
          ),
        ),
      ),
    );
  }

  /// Fungsi ini bertujuan untuk membangun widget header halaman.
  Widget _bangunHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF4C1D95), // Deep Purple 900
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              // diubah: Menggunakan .withAlpha sebagai pengganti .withOpacity
              color: Colors.purple.withAlpha((255 * 0.2).round()),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: const Text('Reward',
          style: TextStyle(
              fontSize: 32,
              // diubah: FontWeight.black diganti menjadi FontWeight.w900
              fontWeight: FontWeight.w900,
              color: Colors.white)),
    );
  }

  /// Fungsi ini bertujuan untuk membangun widget kartu informasi poin.
  Widget _bangunKartuPoin() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFEAB308)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                  // diubah: Menggunakan .withAlpha sebagai pengganti .withOpacity
                  color: Colors.amber.withAlpha((255 * 0.3).round()),
                  blurRadius: 20,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    // diubah: Menggunakan .withAlpha sebagai pengganti .withOpacity
                    color: Colors.white.withAlpha((255 * 0.25).round()),
                    borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.monetization_on,
                    color: Color(0xFF78350F), size: 32),
              ),
              const SizedBox(height: 16),
              const Text('SALDO POIN SAYA',
                  style: TextStyle(
                      color: Color(0x9978350F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              Text('$_poinSaatIni Pts',
                  style: const TextStyle(
                      fontSize: 32,
                      // diubah: FontWeight.black diganti menjadi FontWeight.w900
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF451A03))),
            ],
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: InkWell(
            onTap: () {
              developer.log('onTap: Tombol info poin ditekan.',
                  name: 'HalamanPoin');
              _tampilkanInfoPoin(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  // diubah: Menggunakan .withAlpha sebagai pengganti .withOpacity
                  color: Colors.white.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.info_outline,
                  color: Color(0xFF451A03), size: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Fungsi ini bertujuan untuk membangun tombol pilihan tampilan (Reward/Transaksi).
  Widget _bangunPilihanTampilan() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.4,
              child: TextButton(
                onPressed: () {
                  developer.log('onPressed: Beralih ke tampilan Reward.',
                      name: 'HalamanPoin');
                  setState(() => _tampilkanReward = true);
                },
                child: Text('Lainnya',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _tampilkanReward ? Colors.black : Colors.grey)),
              ),
            ),
            SizedBox(
              width: constraints.maxWidth * 0.4,
              child: TextButton(
                onPressed: () {
                  developer.log('onPressed: Beralih ke tampilan Transaksi.',
                      name: 'HalamanPoin');
                  setState(() => _tampilkanReward = false);
                },
                child: Text('Transaksi',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: !_tampilkanReward ? Colors.black : Colors.grey)),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Fungsi ini bertujuan untuk membangun daftar transaksi dari data model.
  Widget _bangunDaftarTransaksi() {
    developer.log('Membangun daftar transaksi.', name: 'HalamanPoin');
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dataTransaksi.length,
      itemBuilder: (context, index) {
        final transaksi = _dataTransaksi[index];
        return _bangunItemTransaksi(
          judul: transaksi.judul,
          deskripsi: transaksi.kategori,
          jumlah: transaksi.jumlah,
          warnaTeks: transaksi.isPemasukan ? Colors.green : Colors.red,
        );
      },
    );
  }

  /// Fungsi ini bertujuan untuk membangun grid reward dari data model.
  Widget _bangunGridReward() {
    developer.log('Membangun grid reward.', name: 'HalamanPoin');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _dataReward.length,
      itemBuilder: (context, index) {
        final reward = _dataReward[index];
        return _bangunItemReward(reward.ikon, reward.judul, reward.poin);
      },
    );
  }

  /// Fungsi ini bertujuan untuk membangun satu item reward.
  Widget _bangunItemReward(String ikon, String judul, int poin) {
    double progress = (_poinSaatIni / poin).clamp(0.0, 1.0);
    int sisa = (poin - _poinSaatIni).clamp(0, poin);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              // diubah: Menggunakan .withAlpha sebagai pengganti .withOpacity
              color: Colors.black.withAlpha((255 * 0.02).round()),
              blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ikon, style: const TextStyle(fontSize: 32)),
          const Spacer(),
          Text(judul,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, height: 1.1)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$poin Pts',
                  style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
              if (sisa > 0)
                Text('-$sisa',
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade400,
              valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? Colors.green : Colors.amber),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Fungsi ini bertujuan untuk membangun satu item transaksi.
  Widget _bangunItemTransaksi({
    required String judul,
    required String deskripsi,
    required String jumlah,
    required Color warnaTeks,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(deskripsi,
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Text(jumlah,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: warnaTeks,
                  fontSize: 14)),
        ],
      ),
    );
  }

  /// Fungsi ini bertujuan untuk menampilkan dialog informasi tentang poin.
  void _tampilkanInfoPoin(BuildContext context) {
    developer.log('Menampilkan dialog informasi poin.', name: 'HalamanPoin');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber, size: 48),
            const SizedBox(height: 16),
            const Text('Tentang Poin',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Kumpulkan poin dari setiap transaksi yang kamu lakukan. Poin dapat ditukarkan dengan berbagai reward menarik.',
                style: TextStyle(color: Colors.grey, height: 1.4)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  developer.log('onPressed: Tombol "Mengerti" di dialog ditekan.',
                      name: 'HalamanPoin');
                  Navigator.pop(context);
                },
                child: const Text('Mengerti',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model untuk data reward.
class _ModelReward {
  final String ikon;
  final String judul;
  final int poin;

  const _ModelReward(
      {required this.ikon, required this.judul, required this.poin});
}

/// Model untuk data transaksi.
class _ModelTransaksi {
  final String judul;
  final String kategori;
  final String jumlah;
  final bool isPemasukan;

  const _ModelTransaksi({
    required this.judul,
    required this.kategori,
    required this.jumlah,
    required this.isPemasukan,
  });
}
