// path: lib/halaman/detail/detail_versi_apk_user.dart

import 'package:admin_wifi/fitur/versi_apk_user/screens/form_versi_apk_user.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

// untuk menampilkan detail dari sebuah versi apk
class DetailVersiApkUser extends StatelessWidget {
  final VersiApkUserModel versiApk;

  const DetailVersiApkUser({super.key, required this.versiApk});

  @override
  Widget build(BuildContext context) {
    L.i(
      'Membangun halaman detail versi APK dengan versi terbaru: ${versiApk.versiTerbaru}.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Versi APK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Data',
            onPressed: () async {
              L.i(
                'Pengguna menekan tombol edit untuk versi APK: ${versiApk.versiTerbaru}.',
              );

              final result = await Nav.to<bool>(
                context,
                FormVersiApkUser(versiApkUser: versiApk),
              );

              L.i(
                'Halaman form edit versi APK selesai ditutup dengan hasil: $result.',
              );

              if (result == true && context.mounted) {
                L.i(
                  'Berhasil edit data versi APK dan mengirim sinyal refresh ke halaman sebelumnya.',
                );

                Nav.pop(context, true);

                L.i(
                  'Berhasil kembali ke halaman sebelumnya dengan status refresh.',
                );
              } else {
                L.w(
                  'Tidak ada perubahan data versi APK atau widget sudah tidak mounted.',
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
          ...versiApk.nomorBuildTerbaru.entries.map((entry) {
            L.i(
              'Menampilkan nomor build untuk arsitektur: ${entry.key.name} dengan nilai: ${entry.value}.',
            );

            return _buildInfoRow(entry.key.name, entry.value.toString());
          }),
          const SizedBox(height: 16),
          const Text(
            'Tautan Unduhan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...versiApk.tautanUnduhan.entries.map((entry) {
            L.i(
              'Menampilkan tautan unduhan untuk arsitektur: ${entry.key.name}.',
            );

            return _buildInfoRow(entry.key.name, entry.value);
          }),
          const SizedBox(height: 16),
          _buildInfoRow('Youtube Tutorial', versiApk.youtubeTutorial),
        ],
      ),
    );
  }

  // untuk membangun baris informasi
  Widget _buildInfoRow(String label, String value) {
    L.i('Membangun info row dengan label: $label dan value: $value.');

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
