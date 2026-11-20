// path: lib/data/operasi/kritik_saran_operasi.dart
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/db/supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_global_saya/src/utils/l.dart';

class KritikSaranOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  Future<void> createKritikSaran(KritikSaranModel kritikSaran) async {
    L.i('Memulai createKritikSaran untuk data: ${kritikSaran.toSqlite()}');
    try {
      final now = DateTime.now();
      final data = kritikSaran.toSqlite()
        ..['diperbarui'] = now.toIso8601String();

      await _operasiDasar.sisipkan('kritik_saran', data);
      L.i('Berhasil membuat kritik_saran dengan ID: ${kritikSaran.id}');
    } catch (e, st) {
      L.e('Gagal saat createKritikSaran Error: $e $st');
      rethrow;
    }
  }

  Future<List<KritikSaranModel>> getKritikSaran() async {
    L.i(
      'Memulai getKritikSaran (mengambil semua, diurutkan berdasarkan tanggal terbaru).',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        orderBy: 'tanggal DESC',
      );
      final listKritik = List.generate(
        maps.length,
        (i) => KritikSaranModel.fromSqlite(maps[i]),
      );
      L.i('Berhasil mengambil ${listKritik.length} data kritik_saran.');
      return listKritik;
    } catch (e, st) {
      L.e('Gagal saat getKritikSaran Error: $e $st');
      rethrow;
    }
  }

  Future<KritikSaranModel> getKritikSaranById(String id) async {
    L.i('Memulai getKritikSaranById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final data = KritikSaranModel.fromSqlite(maps.first);
        L.i(
          'Kritik & saran dengan ID: $id ditemukan. Data: ${data.toSqlite()}',
        );
        return data;
      } else {
        L.e('Kritik & saran dengan ID $id tidak ditemukan.');
        throw Exception('ID $id tidak ditemukan');
      }
    } catch (e, st) {
      L.e('Gagal saat getKritikSaranById untuk ID: $id Error: $e $st');
      rethrow;
    }
  }

  Future<List<KritikSaranModel>> getPerubahan(DateTime lastSync) async {
    L.i(
      'Memulai getPerubahan kritik_saran sejak: ${lastSync.toIso8601String()}',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'diperbarui > ?',
        whereArgs: [lastSync.toIso8601String()],
      );
      final listKritik = List.generate(
        maps.length,
        (i) => KritikSaranModel.fromSqlite(maps[i]),
      );
      L.i(
        'Ditemukan ${listKritik.length} perubahan kritik_saran sejak ${lastSync.toIso8601String()}.',
      );
      return listKritik;
    } catch (e, st) {
      L.e('Gagal saat getPerubahan kritik_saran Error: $e $st');
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<KritikSaranModel> daftarKritikSaran,
  ) async {
    L.i(
      'Memulai sisipkanAtauPerbaruiBatch untuk ${daftarKritikSaran.length} item kritik_saran.',
    );
    if (daftarKritikSaran.isEmpty) {
      L.w('List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final data = daftarKritikSaran.map((item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch('kritik_saran', data);
      L.i(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${daftarKritikSaran.length} item.',
      );
    } catch (e, st) {
      L.e('Gagal saat sisipkanAtauPerbaruiBatch kritik_saran Error: $e $st');
      rethrow;
    }
  }

  Future<void> hapusKritikSaran(String id) async {
    L.w('PERINGATAN: Memulai hapusKritikSaran (hard delete) untuk ID: $id');
    try {
      await _operasiDasar.hapus('kritik_saran', id);
      L.i('Berhasil menghapus permanen kritik_saran dengan ID: $id.');
    } catch (e, st) {
      L.e('Gagal saat hapusKritikSaran untuk ID: $id Error: $e $st');
      rethrow;
    }
  }

  Future<void> hapusSemuaKritikSaran() async {
    L.w(
      'PERINGATAN: Memulai hapusSemuaKritikSaran. Ini adalah operasi destruktif yang akan menghapus semua kritik & saran secara permanen.',
    );
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        int count = await txn.delete('kritik_saran');
        L.i(
          'Berhasil hapusSemuaKritikSaran. Total baris yang dihapus permanen: $count',
        );
        return count;
      });
    } catch (e, st) {
      L.e('Gagal saat hapusSemuaKritikSaran Error: $e $st');
      rethrow;
    }
  }

  Future<void> hapusByUserId(String userId) async {
    L.w(
      'PERINGATAN: Memulai hapusByUserId (hard delete) untuk semua kritik & saran dari userId: $userId',
    );
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final deletedCount = await txn.delete(
          'kritik_saran',
          where: 'userId = ?',
          whereArgs: [userId],
        );
        L.i(
          'Berhasil menghapus $deletedCount kritik & saran dari user: $userId',
        );
        return deletedCount;
      });
    } catch (e, st) {
      L.e('Gagal saat hapusByUserId untuk userId: $userId Error: $e $st');
      rethrow;
    }
  }

  static Future<List<KritikSaranModel>> unduhDataDariSupabase() async {
    L.i('Memulai pengunduhan data dari Supabase tabel: kritik_saran.');
    try {
      final rows = await SupabaseKlien.instance.client
          .from('kritik_saran')
          .select();
      final List<KritikSaranModel> data = rows
          .map(
            (row) => KritikSaranModel.fromSupabase(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList();

      L.i(
        'Berhasil mengunduh ${data.length} data kritik dan saran dari Supabase.',
      );
      return data;
    } catch (e, st) {
      L.e('Gagal mengunduh data kritik dan saran dari Supabase Error: $e $st');
      return [];
    }
  }

  Future<List<KritikSaranModel>> getKritikSaranByIds(List<String> ids) async {
    L.i('Memulai getKritikSaranByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      L.w(
        'List ID untuk getKritikSaranByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      final listKritik = List.generate(
        maps.length,
        (i) => KritikSaranModel.fromSqlite(maps[i]),
      );
      L.i(
        'Berhasil mengambil ${listKritik.length} data kritik_saran dari ${ids.length} ID yang diminta.',
      );
      return listKritik;
    } catch (e, st) {
      L.e('Gagal saat getKritikSaranByIds Error: $e $st');
      rethrow;
    }
  }
}
