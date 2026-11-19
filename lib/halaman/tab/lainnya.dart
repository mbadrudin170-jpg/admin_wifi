// path: lib/halaman/tab/lainnya.dart
import 'dart:async';

import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/fitur/kategori/screens/kategori.dart';
import 'package:admin_wifi/fitur/kritik_saran/screens/kritik_saran.dart';
import 'package:admin_wifi/fitur/pengaturan/screens/pengaturan.dart';
import 'package:admin_wifi/fitur/riwayat_langganan/screens/riwayat_aktivasi_paket.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

// import '../../data/services/notifikasi_servis.dart';
import '../../dummy/dummy_screen.dart'; // ditambahkan: Import layar Data Dummy
import '../../fitur/paket/screens/paket.dart';
import '../../fitur/pelanggan/screens/pelanggan.dart';
import '../../fitur/versi_apk_user/screens/versi_apk_user.dart';
import '../../migrasi/halaman_migrasi.dart'; // ditambahkan: Import halaman migrasi
import '../lainnya/tentang_aplikasi.dart';
import 'pesanan.dart';

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
    L.i('Navigasi ke halaman: $pageName');
    unawaited(
      Nav.to(context, page).catchError((Object e, StackTrace s) {
        L.e('Navigasi gagal: $e $s');
        return null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI untuk Halaman Lainnya.');
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan & Lainnya')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNavigationButton(
            title: 'Daftar Pesanan',
            icon: Icons.shopping_cart,
            onTap: () =>
                _handleNavigation('Daftar Pesanan', const HalamanPesan()),
          ),
          _buildNavigationButton(
            title: 'Kelola Kategori',
            icon: Icons.category,
            onTap: () =>
                _handleNavigation('Kelola Kategori', const KategoriPage()),
          ),
          _buildNavigationButton(
            title: 'Kritik & Saran',
            icon: Icons.feedback,
            onTap: () async {
              L.i('Memulai proses untuk membuka halaman Kritik & Saran.');

              L.i('Mengunduh data Kritik & Saran dari Firebase.');
              final dataFromFirebase =
                  await KritikSaranOperasi.unduhDataDariFirebase();
              L.i('Berhasil mengunduh ${dataFromFirebase.length} data.');

              if (dataFromFirebase.isNotEmpty) {
                final operasi = KritikSaranOperasi();
                L.i('Menyimpan/Memperbarui data ke database lokal.');
                await operasi.sisipkanAtauPerbaruiBatch(dataFromFirebase);
                L.i('Data berhasil disimpan/diperbarui.');
              }

              if (!mounted) return;
              await Nav.to(context, const KritikSaranPage());
            },
          ),
          _buildNavigationButton(
            title: 'Kelola Paket WiFi',
            icon: Icons.wifi,
            onTap: () =>
                _handleNavigation('Kelola Paket WiFi', const PaketPage()),
          ),
          _buildNavigationButton(
            title: 'Daftar Pelanggan',
            icon: Icons.people,
            onTap: () =>
                _handleNavigation('Daftar Pelanggan', const PelangganPage()),
          ),
          _buildNavigationButton(
            title: 'Riwayat Aktivasi Paket',
            icon: Icons.history,
            onTap: () => _handleNavigation(
              'Riwayat Aktivasi Paket',
              const RiwayatAktivasiPaketPage(),
            ),
          ),
          _buildNavigationButton(
            title: 'Versi Aplikasi Pengguna',
            icon: Icons.system_update,
            onTap: () => _handleNavigation(
              'Versi Aplikasi Pengguna',
              const VersiApkUserPage(),
            ),
          ),
          _buildNavigationButton(
            title: 'Pengaturan Aplikasi',
            icon: Icons.settings,
            onTap: () => _handleNavigation(
              'Pengaturan Aplikasi',
              const PengaturanPage(),
            ),
          ),
          _buildNavigationButton(
            title: 'Tentang Aplikasi',
            icon: Icons.info,
            onTap: () => _handleNavigation(
              'Tentang Aplikasi',
              const TentangAplikasiPage(),
            ),
          ),
          // ditambahkan: Navigasi ke halaman migrasi
          const Divider(height: 32),
          _buildNavigationButton(
            title: '[DEBUG] Alat Migrasi Data',
            icon: Icons.construction,
            onTap: () =>
                _handleNavigation('Alat Migrasi Data', const HalamanMigrasi()),
          ),
          _buildNavigationButton(
            title: '[DEBUG] Data Dummy',
            icon: Icons.science,
            onTap: () => _handleNavigation('Data Dummy', const DummyScreen()),
          ),
        ],
      ),
    );
  }
}
