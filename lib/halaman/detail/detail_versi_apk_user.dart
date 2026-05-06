// path: lib/halaman/detail/detail_versi_apk_user.dart

import 'package:admin_wifi/halaman/form/form_versi_apk_user.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:flutter/material.dart';

// untuk menampilkan detail dari sebuah versi apk
class DetailVersiApkUser extends StatelessWidget {
  final VersiApkUserModel versiApk;

  const DetailVersiApkUser({super.key, required this.versiApk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Versi APK'),
        // ditambah: tombol aksi untuk mengedit
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Data',
            onPressed: () async {
              // Navigasi ke form dengan membawa data yang ada
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  // Mengirim data ke FormVersiApkUser
                  builder: (context) =>
                      FormVersiApkUser(versiApkUser: versiApk),
                ),
              );

              // Jika ada perubahan (form disimpan), kembali ke halaman daftar
              // dan kirim sinyal untuk refresh
              if (result == true && context.mounted) {
                Navigator.pop(
                  context,
                  true,
                ); // Kembali & kirim 'true' ke halaman daftar
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoRow('Versi Terbaru', versiApk.versiTerbaru),
          _buildInfoRow('Wajib Update', versiApk.wajibUpdate ? 'Ya' : 'Tidak'),
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
  }

  // untuk membangun baris informasi
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
          Flexible(child: Text(value)),
        ],
      ),
    );
  }
}
