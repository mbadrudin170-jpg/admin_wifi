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
  final _tabel = KritikSaranSkema.tabel;

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
      _tabel,
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

      await operasiSqlite.sisipkan(_tabel, data);
      L.i('Berhasil membuat kritik_saran dengan ID: ${kritikSaran.id}');
      // Refresh state after creation
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat createKritikSaran Error: $e $st');
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
      await operasiSqlite.sisipkanAtauPerbaruiBatch(_tabel, data);
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
      await operasiSqlite.hapus(_tabel, id: id);
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
        int count = await txn.delete(_tabel);
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
          _tabel,
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
          .from(KritikSaranSkema.tabel)
          .select();
      final List<KritikSaranModel> data = rows.map((row) {
        return KritikSaranModel.fromSupabase(
          Map<String, dynamic>.from(row),
        );
      }).toList();

      L.i(
        'Berhasil mengunduh ${data.length} data kritik dan saran dari Supabase.',
      );
      return data;
    } catch (e, st) {
      L.e('Gagal mengunduh data kritik dan saran dari Supabase Error: $e $st');
      rethrow;
    }
  }
}

/// Kontainer global untuk mengakses [KritikSaranNotifier] di luar konteks Riverpod.
final ProviderContainer _kritikSaranGlobalContainer = ProviderContainer();

KritikSaranNotifier get kritikSaranNotifierGlobal =>
    _kritikSaranGlobalContainer.read(kritikSaranProvider.notifier);
