// path: lib/fitur/kritik_saran/notifier/kritik_saran_notifier.dart
// diubah: Memindahkan logika dari KritikSaranOperasi ke notifier ini.

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/db/supabase/supabase.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/fitur/kritik_saran/state/kritik_saran_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'kritik_saran_notifier.g.dart';

/// Provider untuk DatabaseHelper (untuk operasi kompleks yang butuh transaksi manual)
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

@Riverpod(keepAlive: true)
class KritikSaranNotifier extends _$KritikSaranNotifier {
  @override
  Future<KritikSaranState> build() async {
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang kritik dan saran: $e $s');
      rethrow;
    }
  }

  Future<KritikSaranState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      KritikSaranSkema.tabel,
      orderBy: '${KritikSaranSkema.tanggal} DESC',
    );
    final daftar = maps.map(KritikSaranModel.fromSqlite).toList();
    return KritikSaranState(
      listKritikSaran: daftar,
      jumlahKritikSaran: daftar.length,
    );
  }

  /// Membuat kritik dan saran baru.
  Future<void> createKritikSaran(KritikSaranModel kritikSaran) async {
    L.i('Memulai createKritikSaran untuk data: ${kritikSaran.toSqlite()}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final now = DateTime.now();
      final data = kritikSaran.toSqlite()
        ..['diperbarui'] = now.toIso8601String();

      await operasiSqlite.tambah('kritik_saran', data);
      L.i('Berhasil membuat kritik_saran dengan ID: ${kritikSaran.id}');
      // Refresh state after creation
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat createKritikSaran Error: $e $st');
      rethrow;
    }
  }

  /// Mengambil kritik dan saran berdasarkan ID.
  Future<KritikSaranModel> getKritikSaranById(String id) async {
    L.i('Memulai getKritikSaranById untuk ID: $id');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
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

  /// Mengambil perubahan kritik dan saran sejak timestamp terakhir.
  Future<List<KritikSaranModel>> getPerubahan(DateTime lastSync) async {
    L.i(
      'Memulai getPerubahan kritik_saran sejak: ${lastSync.toIso8601String()}',
    );
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'kritik_saran',
        where: 'diperbarui > ?',
        whereArgs: [lastSync.toIso8601String()],
      );
      final listKritik = maps.map(KritikSaranModel.fromSqlite).toList();
      L.i(
        'Ditemukan ${listKritik.length} perubahan kritik_saran sejak ${lastSync.toIso8601String()}.',
      );
      return listKritik;
    } catch (e, st) {
      L.e('Gagal saat getPerubahan kritik_saran Error: $e $st');
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui batch kritik dan saran.
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
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = daftarKritikSaran.map((item) => item.toSqlite()).toList();
      await operasiSqlite.tambahBatch('kritik_saran', data);
      L.i(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${daftarKritikSaran.length} item.',
      );
      // Refresh state after batch operation
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat sisipkanAtauPerbaruiBatch kritik_saran Error: $e $st');
      rethrow;
    }
  }

  /// Menghapus kritik dan saran (hard delete) berdasarkan ID.
  Future<void> hapusKritikSaran(String id) async {
    L.w('PERINGATAN: Memulai hapusKritikSaran (hard delete) untuk ID: $id');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.hapus('kritik_saran', id: id);
      L.i('Berhasil menghapus permanen kritik_saran dengan ID: $id.');
      // Refresh state after delete
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat hapusKritikSaran untuk ID: $id Error: $e $st');
      rethrow;
    }
  }

  /// Menghapus semua kritik dan saran (operasi destruktif).
  Future<void> hapusSemuaKritikSaran() async {
    L.w(
      'PERINGATAN: Memulai hapusSemuaKritikSaran. Ini adalah operasi destruktif yang akan menghapus semua kritik & saran secara permanen.',
    );
    try {
      final dbHelper = ref.read(databaseHelperProvider);
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        int count = await txn.delete('kritik_saran');
        L.i(
          'Berhasil hapusSemuaKritikSaran. Total baris yang dihapus permanen: $count',
        );
        return count;
      });
      // Refresh state after delete all
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat hapusSemuaKritikSaran Error: $e $st');
      rethrow;
    }
  }

  /// Menghapus semua kritik dan saran dari user tertentu (hard delete).
  Future<void> hapusByUserId(String userId) async {
    L.w(
      'PERINGATAN: Memulai hapusByUserId (hard delete) untuk semua kritik & saran dari userId: $userId',
    );
    try {
      final dbHelper = ref.read(databaseHelperProvider);
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        final deletedCount = await txn.delete(
          'kritik_saran',
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        L.i(
          'Berhasil menghapus $deletedCount kritik & saran dari user: $userId',
        );
        return deletedCount;
      });
      // Refresh state after delete
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat hapusByUserId untuk userId: $userId Error: $e $st');
      rethrow;
    }
  }

  /// Mengunduh data kritik dan saran dari Supabase.
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
      rethrow;
    }
  }

  /// Mengambil kritik dan saran berdasarkan daftar ID.
  Future<List<KritikSaranModel>> getKritikSaranByIds(List<String> ids) async {
    L.i('Memulai getKritikSaranByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      L.w(
        'List ID untuk getKritikSaranByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final placeholders = List.filled(ids.length, '?').join(',');
      final maps = await operasiSqlite.ambil(
        'kritik_saran',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      final listKritik = maps.map(KritikSaranModel.fromSqlite).toList();
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

/// Kontainer global untuk mengakses [KritikSaranNotifier] di luar konteks Riverpod.
final ProviderContainer _kritikSaranGlobalContainer = ProviderContainer();

KritikSaranNotifier get kritikSaranNotifierGlobal =>
    _kritikSaranGlobalContainer.read(kritikSaranProvider.notifier);
