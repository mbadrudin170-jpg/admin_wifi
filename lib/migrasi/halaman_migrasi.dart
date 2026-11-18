// path: lib/migrasi/halaman_migrasi.dart
import 'migrasi_timestamp.dart';
import 'package:admin_wifi/migrasi/migrasi_diarsipkan.dart';
import 'package:flutter/material.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

class HalamanMigrasi extends StatefulWidget {
  const HalamanMigrasi({super.key});

  @override
  State<HalamanMigrasi> createState() => _HalamanMigrasiState();
}

class _HalamanMigrasiState extends State<HalamanMigrasi> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  // diubah: Daftar koleksi diperbarui sesuai analisis skema database
  // Daftar ini berisi nama koleksi di Firebase yang memiliki field 'diperbarui' & 'diarsipkan'
  final List<String> _daftarKoleksi = const [
    'versi_apk_user',
    'dompet',
    'transaksi',
    'kategori',
    'sub_kategori',
    'paket',
    'pelanggan',
    'pelanggan_aktif',
    'pesanan', // Nama tabel di SQLite adalah 'pesanan', disesuaikan untuk Firebase
  ];

  @override
  void dispose() {
    L.i('HalamanMigrasi di-dispose. Membersihkan ValueNotifier.');
    _isLoading.dispose();
    super.dispose();
  }

  /// Fungsi generik untuk menjalankan semua jenis migrasi.
  Future<void> _jalankanMigrasi({
    required String namaMigrasi,
    required Future<void> Function(String) fungsiMigrasi,
  }) async {
    L.i('Menampilkan dialog konfirmasi untuk "$namaMigrasi".');
    final bool? konfirmasi = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Migrasi: $namaMigrasi'),
        content: Text(
          'Anda yakin ingin menjalankan "$namaMigrasi" untuk SEMUA koleksi? Tindakan ini akan mengubah data di server Firebase dan tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              L.i('Pengguna menekan Batal pada dialog konfirmasi.');
              Nav.pop(context, false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              L.i('Pengguna menekan Jalankan pada dialog konfirmasi.');
              Nav.pop(context, true);
            },
            child: const Text('Ya, Jalankan'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) {
      L.i('Migrasi "$namaMigrasi" dibatalkan oleh pengguna.');
      return;
    }

    L.i('Konfirmasi diterima. Memulai proses migrasi "$namaMigrasi".');
    _isLoading.value = true;
    try {
      L.i('Memulai proses $namaMigrasi untuk koleksi: $_daftarKoleksi');
      for (final koleksi in _daftarKoleksi) {
        L.i('[$namaMigrasi] Memproses koleksi: $koleksi...');
        await fungsiMigrasi(koleksi);
        L.i('[$namaMigrasi] Selesai memproses koleksi: $koleksi.');
      }
      L.i('SUKSES: Proses $namaMigrasi telah selesai untuk semua koleksi.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$namaMigrasi berhasil dijalankan untuk semua koleksi.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, s) {
      L.e('FATAL: Gagal menjalankan $namaMigrasi Error: $e $s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan saat menjalankan $namaMigrasi. Periksa log.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        L.i('Proses migrasi selesai. Mengatur _isLoading ke false.');
        _isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI Halaman Migrasi Data');
    return Scaffold(
      appBar: AppBar(
        title: const Text('[DEBUG] Alat Migrasi Data'),
        backgroundColor: Colors.orange.shade100,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                color: Colors.yellow.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange.shade800,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'PERINGATAN: Fitur ini akan memodifikasi data langsung di server. Gunakan dengan hati-hati.',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tombol untuk migrasi 'diperbarui'
              ElevatedButton.icon(
                icon: const Icon(Icons.timer_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Migrasi Field "diperbarui"'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading.value
                    ? null
                    : () {
                        L.i('Tombol "Migrasi Field diperbarui" ditekan.');
                        _jalankanMigrasi(
                          namaMigrasi: 'Migrasi Timestamp',
                          fungsiMigrasi:
                              MigrasiTimestamp.migrasiStringKeTimestamp,
                        );
                      },
              ),
              const SizedBox(height: 16),
              // Tombol untuk migrasi 'diarsipkan'
              ElevatedButton.icon(
                icon: const Icon(Icons.archive_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Migrasi Field "diarsipkan"'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading.value
                    ? null
                    : () {
                        L.i('Tombol "Migrasi Field diarsipkan" ditekan.');
                        _jalankanMigrasi(
                          namaMigrasi: 'Migrasi Diarsipkan',
                          fungsiMigrasi:
                              MigrasiDiarsipkan.migrasiKolomDiarsipkan,
                        );
                      },
              ),
            ],
          ),
          // Loading Overlay
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, child) {
              if (!isLoading) return const SizedBox.shrink();
              return Container(
                color: Colors.black.withAlpha((255 * 0.6).round()),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Menjalankan migrasi di semua koleksi...\nMohon tunggu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
