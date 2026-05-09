// path: lib/halaman/detail/detail_versi_apk_user.dart

import 'dart:developer' as developer; // Tambahkan import ini
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Data',
            onPressed: () async {
              developer.log(
                '📝 [DetailVersiApkUser] -> [onPressed Edit] -> Menuju form edit untuk versi: ${versiApk.versiTerbaru}',
                name: 'DetailVersiApkUser.Navigation',
              );

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
                developer.log(
                  '✅ [DetailVersiApkUser] -> [onPressed Edit] -> Berhasil edit data, mengirim sinyal refresh ke daftar.',
                  name: 'DetailVersiApkUser.Callback',
                );
                Navigator.pop(
                  context,
                  true,
                ); // Kembali & kirim 'true' ke halaman daftar
              } else {
                developer.log(
                  'ℹ️ [DetailVersiApkUser] -> [onPressed Edit] -> Kembali tanpa perubahan data.',
                  name: 'DetailVersiApkUser.Callback',
                );
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
            (entry) => _buildInfoRow(entry.key.name, entry.value.toString()),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tautan Unduhan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...versiApk.tautanUnduhan.entries.map(
            (entry) => _buildInfoRow(entry.key.name, entry.value),
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
