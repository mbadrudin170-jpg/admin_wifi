// path: lib/halaman/tab/lainnya.dart
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/server/migrasi_timestamp.dart';
import 'package:flutter/material.dart';
// import '../../data/services/notifikasi_servis.dart';
import '../lainnya/kategori.dart';
import '../lainnya/kritik_saran.dart';
import '../lainnya/paket.dart';
import '../lainnya/pelanggan.dart';
import '../lainnya/riwayat_aktivasi_paket.dart';
import '../lainnya/tentang_aplikasi.dart';
import '../lainnya/versi_apk_user.dart';
import 'pesanan.dart';
import '../lainnya/pengaturan.dart'; // ditambahkan: Import halaman pengaturan

class LainnyaPage extends StatefulWidget {
  const LainnyaPage({super.key});

  @override
  State<LainnyaPage> createState() => _LainnyaTabState();
}

class _LainnyaTabState extends State<LainnyaPage> {
  // Fungsi bantuan untuk membuat tombol navigasi
  Widget _buildNavigationButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _handleNavigation(String pageName, Widget page) {
    Log.info('Navigasi ke halaman: $pageName');
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI untuk Halaman Lainnya.');
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan & Lainnya')),
      // diubah: Menggunakan ListView untuk menghindari overflow
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNavigationButton(
            title: 'Daftar Pesanan',
            icon: Icons.shopping_cart,
            onTap: () => _handleNavigation('Daftar Pesanan', const HalamanPesan()),
          ),
          _buildNavigationButton(
            title: 'Kelola Kategori',
            icon: Icons.category,
            onTap: () => _handleNavigation('Kelola Kategori', const KategoriPage()),
          ),
          _buildNavigationButton(
            title: 'Kritik & Saran',
            icon: Icons.feedback,
            onTap: () async {
              Log.info('Memulai proses untuk membuka halaman Kritik & Saran.');
              // diubah: Ambil navigator sebelum operasi async
              final navigator = Navigator.of(context);

              // 1. Unduh data dari Firebase
              Log.info('Mengunduh data Kritik & Saran dari Firebase.');
              final dataFromFirebase = await KritikSaranOperasi.unduhDataDariFirebase();
              Log.info('Berhasil mengunduh ${dataFromFirebase.length} data.');

              // 2. Simpan data ke database lokal (jika ada)
              if (dataFromFirebase.isNotEmpty) {
                final operasi = KritikSaranOperasi();
                Log.info('Menyimpan/Memperbarui data ke database lokal.');
                await operasi.sisipkanAtauPerbaruiBatch(dataFromFirebase);
                Log.info('Data berhasil disimpan/diperbarui.');
              }

              // 3. Setelah semua selesai, periksa mounted dan navigasi
              if (!mounted) return;
              await navigator.push(
                MaterialPageRoute(
                  builder: (context) => const KritikSaranPage(),
                ),
              );
            },
          ),
          _buildNavigationButton(
            title: 'Kelola Paket WiFi',
            icon: Icons.wifi,
            onTap: () => _handleNavigation('Kelola Paket WiFi', const PaketPage()),
          ),
          _buildNavigationButton(
            title: 'Daftar Pelanggan',
            icon: Icons.people,
            onTap: () => _handleNavigation('Daftar Pelanggan', const PelangganPage()),
          ),
          _buildNavigationButton(
            title: 'Riwayat Aktivasi Paket',
            icon: Icons.history,
            onTap: () => _handleNavigation(
                'Riwayat Aktivasi Paket', const RiwayatAktivasiPaketPage()),
          ),
          // _buildNavigationButton(
          //   title: 'Ubah Data',
          //   icon: Icons.edit,
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => const UbahDataPage()),
          //   ),
          // ),
          // ditambahkan: Navigasi ke Halaman Versi Aplikasi Pengguna
          _buildNavigationButton(
            title: 'Versi Aplikasi Pengguna',
            icon: Icons.system_update,
            onTap: () => _handleNavigation(
                'Versi Aplikasi Pengguna', const VersiApkUserPage()),
          ),
          // ditambahkan: Tombol untuk navigasi ke halaman pengaturan
          _buildNavigationButton(
            title: 'Pengaturan Aplikasi',
            icon: Icons.settings,
            onTap: () => _handleNavigation('Pengaturan Aplikasi', const PengaturanPage()),
          ),
          _buildNavigationButton(
            title: 'Tentang Aplikasi',
            icon: Icons.info,
            onTap: () =>
                _handleNavigation('Tentang Aplikasi', const TentangAplikasiPage()),
          ),
          // ditambahkan: Alat migrasi data
          const Divider(height: 32),
          Card(
            color: Colors.yellow.shade100,
            child: ExpansionTile(
              leading: Icon(Icons.construction, color: Colors.orange.shade800),
              title: Text('[DEBUG] Alat Migrasi Data', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
              subtitle: Text('Hanya untuk developer', style: TextStyle(color: Colors.grey.shade700)),
              children: [
                _buildMigrationButton('paket'),
                _buildMigrationButton('pelanggan'),
                _buildMigrationButton('dompet'),
                _buildMigrationButton('transaksi'),
                _buildMigrationButton('sub_kategori'),
                _buildMigrationButton('kritik_saran'),
                _buildMigrationButton('pesan'),
                // Tambahkan koleksi lain jika perlu
              ],
            ),
          ),
        ],
      ),
    );
  }

    // ditambahkan: Widget untuk tombol migrasi
  Widget _buildMigrationButton(String collectionName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          final bool? konfirmasi = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Konfirmasi Migrasi'),
              content: Text('Anda yakin ingin menjalankan migrasi untuk koleksi "$collectionName"? Tindakan ini akan mengubah data di server Firebase.'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
                TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Jalankan')),
              ],
            ),
          );

          if (konfirmasi == true) {
            Log.info('Memulai migrasi manual untuk koleksi: $collectionName');
            await MigrasiTimestamp.migrasiStringKeTimestamp(collectionName);
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Migrasi untuk "$collectionName" telah dimulai. Periksa log untuk detail.')),
              );
            }
          }
        },
        child: Text('Migrasi Koleksi "$collectionName"'),
      ),
    );
  }
}
