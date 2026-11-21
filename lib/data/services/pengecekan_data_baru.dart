// path: lib/data/services/pengecekan_data_baru.dart
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:share_global_saya/src/utils/l.dart';

class PengecekanDataBaruService {
  PengecekanDataBaruService() {
    L.i('Inisialisasi PengecekanDataBaruService berhasil (Firebase dihapus).');
  }

  Future<bool> apakahSqliteAdaDataBaru() async {
    L.i('Memulai prosedur pengecekan data lokal di SQLite.');

    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'status_aplikasi',
        where: 'id = ?',
        whereArgs: const ['perlu_unggah'],
      );
      final bool hasil = result.isNotEmpty && result.first['value'] == '1';

      if (hasil) {
        L.i('Ditemukan data baru yang harus diunggah ke server.');
      } else {
        L.i('Tidak ada perubahan data lokal yang perlu diunggah.');
      }
      return hasil;
    } catch (e, s) {
      L.e(
        'Gagal melakukan pengecekan status perlu_unggah pada SQLite. Error: $e $s',
      );
      return false;
    }
  }

  Future<bool> apakahFirebaseAdaDataBaru({
    required String namaKoleksi,
    required String idDokumen,
  }) async {
    L.i(
      'Firebase dihapus; tidak ada pengecekan data server. Mengembalikan false.',
    );
    return false;
  }
}
