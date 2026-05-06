
// path: lib/halaman/lainnya/versi_apk_user.dart

// ditambah: import untuk service kontrol aplikasi dan developer log
import 'package:admin_wifi/services/kontrol_aplikasi_service.dart';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
// diubah: Nama kelas yang benar adalah FormVersiApkUser
import 'package:admin_wifi/halaman/form/form_versi_apk_user.dart';


// untuk menampilkan halaman detail informasi versi APK
class VersiApkUserPage extends StatefulWidget {
  const VersiApkUserPage({super.key});

  @override
  State<VersiApkUserPage> createState() => _VersiApkUserPageState();
}

class _VersiApkUserPageState extends State<VersiApkUserPage> {
  final VersiApkUserOperasi _versiApkUserOperasi = VersiApkUserOperasi();
  late Future<VersiApkUserModel> _versiApkUserFuture;

  // ditambah: State untuk kontrol maintenance
  final KontrolAplikasiService _kontrolAplikasiService = KontrolAplikasiService();
  bool _isMaintenanceMode = false;
  bool _isLoadingMaintenance = true;

  @override
  void initState() {
    super.initState();
    _versiApkUserFuture = _versiApkUserOperasi.ambilVersiApkUser();
    // ditambah: Memuat status maintenance saat halaman pertama kali dibuka
    _loadMaintenanceStatus();
  }

  // ditambah: Fungsi untuk memuat status dari Firestore
  Future<void> _loadMaintenanceStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMaintenance = true;
    });

    final status = await _kontrolAplikasiService.dapatkanStatusMaintenance();
    
    if (!mounted) return;
    setState(() {
      _isMaintenanceMode = status;
      _isLoadingMaintenance = false;
    });
  }

  // ditambah: Fungsi untuk mengubah status maintenance
  Future<void> _toggleMaintenanceMode(bool value) async {
    if (!mounted) return;
    
    setState(() {
      _isMaintenanceMode = value;
    });

    try {
      await _kontrolAplikasiService.aturStatusMaintenance(value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mode maintenance berhasil diubah.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, s) {
      developer.log('Gagal mengubah mode maintenance', error: e, stackTrace: s);
      if (!mounted) return;
      setState(() {
        _isMaintenanceMode = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengubah mode maintenance. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  // untuk membangun tampilan informasi versi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ditambah: Widget untuk kontrol maintenance
  Widget _buildMaintenanceControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Divider(),
        ),
        Text(
          'Kontrol Aplikasi Pengguna',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _isLoadingMaintenance
            ? const ListTile(
                leading: Icon(Icons.sync),
                title: Text('Memuat status maintenance...'),
                trailing: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              )
            : SwitchListTile(
                title: const Text('Mode Maintenance'),
                subtitle: const Text('Aktifkan untuk menampilkan halaman gangguan di aplikasi pengguna.'),
                value: _isMaintenanceMode,
                onChanged: _toggleMaintenanceMode,
                secondary: const Icon(Icons.construction),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi & Kontrol APK')), // diubah: judul appbar
      body: FutureBuilder<VersiApkUserModel>(
        future: _versiApkUserFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final versiApk = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ditambah: Panggil widget kontrol maintenance
                  _buildMaintenanceControl(),
                  
                  // diubah: Tambahkan pemisah untuk bagian informasi versi
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Divider(),
                  ),
                  Text(
                    'Informasi Versi APK',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  
                  _buildInfoRow('Versi Terbaru', versiApk.versiTerbaru),
                  _buildInfoRow(
                    'Wajib Update',
                    versiApk.wajibUpdate ? 'Ya' : 'Tidak',
                  ),
                  _buildInfoRow('Catatan Rilis', versiApk.catatanRilis),
                  const SizedBox(height: 16),
                  const Text(
                    'Nomor Build Terbaru',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ...versiApk.nomorBuildTerbaru.entries.map(
                    (entry) => _buildInfoRow(entry.key, entry.value.toString()),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tautan Unduhan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ...versiApk.tautanUnduhan.entries.map(
                    (entry) => _buildInfoRow(entry.key, entry.value),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Youtube Tutorial', versiApk.youtubeTutorial),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Tidak ada data'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // diubah: Navigasi ke halaman form edit
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormVersiApkUser(
                versiApkUser: _versiApkUserFuture as VersiApkUserModel?,
              ),
            ),
          );
          if (result == true) {
            setState(() {
              _versiApkUserFuture = _versiApkUserOperasi.ambilVersiApkUser();
            });
          }
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
