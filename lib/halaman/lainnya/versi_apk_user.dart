// path: lib/halaman/lainnya/versi_apk_user.dart

import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';

// untuk menampilkan halaman detail informasi versi APK
class VersiApkUserPage extends StatefulWidget {
  const VersiApkUserPage({super.key});

  @override
  State<VersiApkUserPage> createState() => _VersiApkUserPageState();
}

class _VersiApkUserPageState extends State<VersiApkUserPage> {
  final VersiApkUserOperasi _versiApkUserOperasi = VersiApkUserOperasi();
  late Future<VersiApkUserModel> _versiApkUserFuture;

  @override
  void initState() {
    super.initState();
    _versiApkUserFuture = _versiApkUserOperasi.ambilVersiApkUser();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Versi APK')),
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
        onPressed: () {
          // Navigasi ke halaman form edit
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
