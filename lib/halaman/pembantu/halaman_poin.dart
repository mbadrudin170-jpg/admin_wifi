// path: lib/halaman/pembantu/halaman_poin.dart

import 'dart:developer' as developer;
import 'package:flutter/material.dart';

// Fungsi ini bertujuan untuk membuat halaman yang menampilkan poin reward dan transaksi.
class HalamanPoin extends StatefulWidget {
  const HalamanPoin({super.key});

  @override
  State<HalamanPoin> createState() => _HalamanPoinState();
}

// diubah: Menggunakan SingleTickerProviderStateMixin untuk TabController.
class _HalamanPoinState extends State<HalamanPoin> with SingleTickerProviderStateMixin {
  // ditambah: TabController untuk mengelola tab.
  late TabController _tabController;

  final int _poinSaatIni = 2450;

  late final List<_ModelReward> _dataReward;
  late final List<_ModelTransaksi> _dataTransaksi;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    developer.log('initState: Menginisialisasi HalamanPoin.', name: 'HalamanPoin');

    try {
      developer.log('initState: Mengisi data reward.', name: 'HalamanPoin');
      _dataReward = [
        const _ModelReward(ikon: '🛍️', judul: 'Voucher Belanja', poin: 500),
        const _ModelReward(ikon: '📱', judul: 'Pulsa Rp 50rb', poin: 1200),
        const _ModelReward(ikon: '💳', judul: 'Saldo E-Wallet', poin: 2500),
        const _ModelReward(ikon: '🚚', judul: 'Potongan Ongkir', poin: 300),
      ];
      developer.log('initState: Jumlah reward berhasil dimuat: ${_dataReward.length}', name: 'HalamanPoin');

      developer.log('initState: Mengisi data transaksi.', name: 'HalamanPoin');
      _dataTransaksi = [
        const _ModelTransaksi(judul: 'Langganan Netflix', kategori: 'Hiburan', jumlah: '- Rp 186.000', isPemasukan: false),
        const _ModelTransaksi(judul: 'Gaji Bulanan', kategori: 'Pemasukan', jumlah: '+ Rp 8.450.000', isPemasukan: true),
      ];
      developer.log('initState: Jumlah transaksi berhasil dimuat: ${_dataTransaksi.length}', name: 'HalamanPoin');

    } catch (e, stackTrace) {
      developer.log('initState: Gagal memuat data.', name: 'HalamanPoin', error: e, stackTrace: stackTrace, level: 1000);
    }
  }

  @override
  void dispose() {
    developer.log('dispose: Membersihkan HalamanPoin.', name: 'HalamanPoin');
    _tabController.dispose();
    super.dispose();
  }

  // diubah: Menggunakan UI baru untuk dialog informasi.
  void _tampilkanInfoPoin() {
    developer.log('_tampilkanInfoPoin: Menampilkan dialog informasi poin.', name: 'HalamanPoin');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
            ),
            const SizedBox(height: 24),
            const Text('Tentang Poin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(
              'Kumpulkan poin dari setiap transaksi yang kamu lakukan. Poin dapat ditukarkan dengan berbagai reward menarik dari merchant pilihan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  _InfoRow(color: Colors.purple, text: '1.000 Poin = Rp 10.000'),
                  SizedBox(height: 12),
                  _InfoRow(color: Colors.amber, text: 'Reward diperbarui setiap minggu'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                    developer.log('onPressed: Tombol Mengerti ditekan.', name: 'HalamanPoin');
                    Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    developer.log('build: Membangun UI utama HalamanPoin.', name: 'HalamanPoin');
    // diubah: Menggunakan UI baru dari permintaan.
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB), // amber-50
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C), // purple-900
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Reward', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _bangunKartuPoin(),
            const SizedBox(height: 32),
            TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.purple.shade700,
              indicatorWeight: 4,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade400,
              labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Lainnya'),
                Tab(text: 'Transaksi'),
              ],
            ),
            const SizedBox(height: 20),
            // diubah: Menggunakan TabBarView untuk konten.
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _bangunGridReward(),
                  _bangunDaftarTransaksi(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // diubah: Menggunakan UI baru untuk kartu poin.
  Widget _bangunKartuPoin() {
    developer.log('_bangunKartuPoin: Membangun kartu poin.', name: 'HalamanPoin');
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.amber.shade200, Colors.yellow.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            // diperbaiki: Mengganti withOpacity dengan withAlpha.
            color: Colors.amber.shade200.withAlpha((255 * 0.5).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: -50,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.monetization_on, size: 200, color: Colors.amber.shade900),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // diperbaiki: Mengganti withOpacity dengan withAlpha.
                    color: Colors.white.withAlpha((255 * 0.3).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.monetization_on, size: 32, color: Colors.amber.shade900),
                ),
                const SizedBox(height: 12),
                Text(
                  'Saldo Poin Saya'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    // diperbaiki: Mengganti withOpacity dengan withAlpha.
                    color: Colors.amber.shade900.withAlpha((255 * 0.6).round()),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '$_poinSaatIni Pts',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: _tampilkanInfoPoin,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // diperbaiki: Mengganti withOpacity dengan withAlpha.
                  color: Colors.white.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // diubah: Menggunakan UI baru untuk grid reward.
  Widget _bangunGridReward() {
    developer.log('_bangunGridReward: Menampilkan grid reward.', name: 'HalamanPoin');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _dataReward.length,
      itemBuilder: (context, index) {
        final item = _dataReward[index];
        final progress = (_poinSaatIni / item.poin).clamp(0.0, 1.0);
        final remaining = (item.poin - _poinSaatIni).clamp(0, 9999);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            // diperbaiki: Mengganti withOpacity dengan withAlpha.
            border: Border.all(color: Colors.amber.shade100.withAlpha((255 * 0.5).round())),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.ikon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Expanded(
                child: Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.poin} PTS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.amber.shade700),
                  ),
                  if (remaining > 0)
                    Text('-$remaining', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  color: progress >= 1.0 ? Colors.green : Colors.amber,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // diubah: Menggunakan UI baru untuk daftar transaksi.
  Widget _bangunDaftarTransaksi() {
    developer.log('_bangunDaftarTransaksi: Menampilkan daftar transaksi.', name: 'HalamanPoin');
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dataTransaksi.length,
      // diperbaiki: Menghapus underscore ganda yang tidak perlu.
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _dataTransaksi[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            // diperbaiki: Mengganti withOpacity dengan withAlpha.
            border: Border.all(color: Colors.amber.shade100.withAlpha((255 * 0.5).round())),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(item.kategori, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Text(
                item.jumlah,
                style: TextStyle(fontWeight: FontWeight.bold, color: item.isPemasukan ? Colors.green : Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ditambah: Widget helper untuk baris info di modal.
class _InfoRow extends StatelessWidget {
  final Color color;
  final String text;

  const _InfoRow({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
      ],
    );
  }
}


/// Model untuk data reward.
class _ModelReward {
  final String ikon;
  final String judul;
  final int poin;

  const _ModelReward({
    required this.ikon,
    required this.judul,
    required this.poin,
  });
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
