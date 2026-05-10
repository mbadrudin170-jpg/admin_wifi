// path: lib/halaman/pembantu/halaman_poin.dart
import 'package:flutter/material.dart';
import 'package:admin_wifi/debug/log.dart';

// Enum untuk mengontrol tab yang aktif
enum MenuPoin { penukaran, riwayat }

class HalamanPoin extends StatefulWidget {
  final String idPelanggan;

  const HalamanPoin({super.key, required this.idPelanggan});

  @override
  State<HalamanPoin> createState() => _HalamanPoinState();
}

class _HalamanPoinState extends State<HalamanPoin> {
  MenuPoin _menuPilihan = MenuPoin.penukaran;

  // Placeholder data
  final int _totalPoin = 1250; // Contoh total poin pelanggan

  @override
  void initState() {
    super.initState();
    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman HalamanPoin');
    Log.info('ID Pelanggan: ${widget.idPelanggan}');
    Log.info('Menu default: Penukaran');
    Log.info('Total poin (placeholder): $_totalPoin');
    Log.info('========================================');
    Log.info('Memanggil _loadDataPoin() untuk memuat data poin pelanggan.');
    _loadDataPoin();
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman HalamanPoin');
    Log.info('ID Pelanggan: ${widget.idPelanggan}');
    Log.info('Membersihkan resource halaman poin.');
    Log.info('========================================');
    super.dispose();
  }

  Future<void> _loadDataPoin() async {
    Log.info('========================================');
    Log.info('MEMUAT DATA POIN PELANGGAN');
    Log.info('ID Pelanggan: ${widget.idPelanggan}');
    Log.info('========================================');
    Log.info(
      'TODO: Implementasikan logika untuk memuat total poin, riwayat, dan daftar hadiah dari database.',
    );
    Log.info(
      'Saat ini menggunakan data placeholder (total poin: $_totalPoin).',
    );

    if (!mounted) {
      Log.warning(
        'Widget sudah tidak mounted saat _loadDataPoin() dipanggil. Membatalkan proses.',
      );
      return;
    }

    Log.info(
      'Widget masih mounted. Memperbarui state untuk memicu rebuild UI.',
    );
    setState(() {
      // TODO: Update state dengan data dari database setelah implementasi
    });
    Log.info(
      'State berhasil diperbarui. Data poin saat ini menggunakan nilai placeholder.',
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI HalamanPoin');
    Log.info('ID Pelanggan: ${widget.idPelanggan}');
    Log.info(
      'Menu aktif: ${_menuPilihan == MenuPoin.penukaran ? "Penukaran Hadiah" : "Riwayat Poin"}',
    );
    Log.info('Total poin ditampilkan: $_totalPoin');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text('Poin: ${widget.idPelanggan}'),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'NAVIGASI: Tombol Kembali ditekan. Kembali ke halaman sebelumnya.',
            );
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          _buildInfoPoinHeader(),
          _buildSegmentedControl(),
          Expanded(child: _buildContentView()),
        ],
      ),
    );
  }

  // Widget untuk menampilkan informasi total poin
  Widget _buildInfoPoinHeader() {
    Log.info('Membangun header informasi total poin. Total: $_totalPoin');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).primaryColor.withAlpha(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Total Poin Anda',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            '$_totalPoin',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol segment (Penukaran/Riwayat)
  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<MenuPoin>(
        segments: const [
          ButtonSegment<MenuPoin>(
            value: MenuPoin.penukaran,
            label: Text('Tukar Hadiah'),
            icon: Icon(Icons.card_giftcard),
          ),
          ButtonSegment<MenuPoin>(
            value: MenuPoin.riwayat,
            label: Text('Riwayat Poin'),
            icon: Icon(Icons.history),
          ),
        ],
        selected: {_menuPilihan},
        onSelectionChanged: (Set<MenuPoin> newSelection) {
          final selection = newSelection.first;
          Log.info('SEGMENTED CONTROL: Tab dipilih berubah.');
          Log.info(
            '  - Tab sebelumnya: ${_menuPilihan == MenuPoin.penukaran ? "Penukaran Hadiah" : "Riwayat Poin"}',
          );
          Log.info(
            '  - Tab baru: ${selection == MenuPoin.penukaran ? "Penukaran Hadiah" : "Riwayat Poin"}',
          );
          setState(() {
            _menuPilihan = selection;
          });
          Log.info(
            'State _menuPilihan berhasil diperbarui. UI akan menampilkan konten tab yang dipilih.',
          );
        },
      ),
    );
  }

  // Widget untuk menampilkan konten berdasarkan tab yang dipilih
  Widget _buildContentView() {
    Log.info(
      'Membangun konten untuk tab: ${_menuPilihan == MenuPoin.penukaran ? "Penukaran Hadiah" : "Riwayat Poin"}',
    );

    switch (_menuPilihan) {
      case MenuPoin.penukaran:
        return _buildDaftarHadiah();
      case MenuPoin.riwayat:
        return _buildRiwayatPoin();
    }
  }

  // Placeholder untuk daftar hadiah
  Widget _buildDaftarHadiah() {
    Log.info('Membangun daftar hadiah yang tersedia untuk ditukar.');

    final List<Map<String, dynamic>> daftarHadiah = [
      {'nama': 'Voucher Pulsa Rp 5.000', 'poin': 500},
      {'nama': 'Voucher Pulsa Rp 10.000', 'poin': 950},
      {'nama': 'Merchandise Topi', 'poin': 1200},
      {'nama': 'Gratis Langganan 1 Bulan', 'poin': 2500},
    ];

    Log.info('Jumlah hadiah tersedia: ${daftarHadiah.length}');
    for (var hadiah in daftarHadiah) {
      final cukupPoin = _totalPoin >= hadiah['poin'];
      Log.info(
        '  - ${hadiah['nama']}: ${hadiah['poin']} poin (Status: ${cukupPoin ? "DAPAT DITUKAR" : "POIN KURANG (butuh ${hadiah['poin'] - _totalPoin} poin lagi)"})',
      );
    }

    return ListView.builder(
      itemCount: daftarHadiah.length,
      itemBuilder: (context, index) {
        final hadiah = daftarHadiah[index];
        final cukupPoin = _totalPoin >= hadiah['poin'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(hadiah['nama']),
            subtitle: Text('${hadiah['poin']} Poin'),
            trailing: ElevatedButton(
              onPressed: cukupPoin
                  ? () {
                      Log.info('========================================');
                      Log.info('AKSI: Tombol "Tukar" ditekan');
                      Log.info('Hadiah: ${hadiah['nama']}');
                      Log.info('Poin dibutuhkan: ${hadiah['poin']}');
                      Log.info('Poin tersedia: $_totalPoin');
                      Log.info(
                        'Sisa poin setelah penukaran: ${_totalPoin - hadiah['poin']}',
                      );
                      Log.info(
                        'TODO: Implementasikan logika penukaran poin ke database.',
                      );
                      Log.info('========================================');
                      // TODO: Implementasi logika penukaran poin
                    }
                  : null,
              child: const Text('Tukar'),
            ),
          ),
        );
      },
    );
  }

  // Placeholder untuk riwayat poin
  Widget _buildRiwayatPoin() {
    Log.info('Membangun daftar riwayat poin pelanggan.');

    final List<Map<String, dynamic>> riwayatPoin = [
      {
        'keterangan': 'Aktivasi Paket Hemat',
        'poin': '+100',
        'tanggal': '05 Mei 2024',
      },
      {
        'keterangan': 'Aktivasi Paket Gaming',
        'poin': '+150',
        'tanggal': '01 Mei 2024',
      },
      {
        'keterangan': 'Tukar Voucher Pulsa',
        'poin': '-500',
        'tanggal': '28 Apr 2024',
      },
      {'keterangan': 'Login Harian', 'poin': '+5', 'tanggal': '27 Apr 2024'},
    ];

    Log.info('Jumlah riwayat poin: ${riwayatPoin.length}');
    for (var riwayat in riwayatPoin) {
      final String poinStr = riwayat['poin'];
      final isPenambahan = poinStr.startsWith('+');
      Log.info(
        '  - ${riwayat['tanggal']}: ${riwayat['keterangan']} (${isPenambahan ? "PENAMBAHAN" : "PENGURANGAN"} $poinStr poin)',
      );
    }

    return ListView.builder(
      itemCount: riwayatPoin.length,
      itemBuilder: (context, index) {
        final riwayat = riwayatPoin[index];
        final String poinStr = riwayat['poin'];
        final isPenambahan = poinStr.startsWith('+');

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: Icon(
              isPenambahan
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color: isPenambahan ? Colors.green : Colors.red,
            ),
            title: Text(riwayat['keterangan']),
            subtitle: Text(riwayat['tanggal']),
            trailing: Text(
              poinStr,
              style: TextStyle(
                color: isPenambahan ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
