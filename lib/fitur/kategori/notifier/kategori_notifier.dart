// path: lib/fitur/kategori/notifier/kategori_notifier.dart
// diubah: Memindahkan logika dari KategoriOperasi ke notifier ini.

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/state/kategori_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'kategori_notifier.g.dart';

/// Provider untuk DatabaseHelper (untuk operasi kompleks yang butuh transaksi manual)
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

@Riverpod(keepAlive: true)
class KategoriNotifier extends _$KategoriNotifier {
  @override
  Future<KategoriState> build() async {
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang kategori: $e $s');
      rethrow;
    }
  }

  Future<KategoriState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      KategoriSkema.tabel,
      where: '${KategoriSkema.diarsipkan} IS NULL',
    );
    final daftar = maps.map(KategoriModel.fromSqlite).toList();
    return KategoriState(listKategori: daftar, jumlahKategori: daftar.length);
  }

  /// Membuat kategori baru.
  Future<KategoriModel> createKategori(KategoriModel kategori) async {
    L.i('Memulai createKategori untuk kategori: ${kategori.toSqlite()}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final kategoriBaru = kategori.copyWith(diperbarui: DateTime.now());
      final data = kategoriBaru.toSqlite();

      await operasiSqlite.sisipkan('kategori', data);
      L.i('Berhasil membuat kategori baru dengan ID: ${kategoriBaru.id}');
      // Refresh state after creation
      await muatUlang();
      return kategoriBaru;
    } catch (e, st) {
      L.e('Gagal saat createKategori Error: $e $st');
      rethrow;
    }
  }

  /// Mengambil semua kategori yang tidak diarsipkan.
  Future<List<KategoriModel>> getKategori() async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'kategori',
        where: 'diarsipkan IS NULL',
      );
      final listKategori = maps.map(KategoriModel.fromSqlite).toList();
      L.i('Berhasil mengambil ${listKategori.length} data kategori.');
      return listKategori;
    } catch (e, st) {
      L.e('Gagal saat getKategori Error: $e $st');
      rethrow;
    }
  }

  /// Memperbarui kategori.
  Future<void> perbarui(KategoriModel kategori) async {
    L.i('Memulai perbarui untuk kategori: ${kategori.toSqlite()}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = kategori.copyWith(diperbarui: DateTime.now()).toSqlite();
      await operasiSqlite.perbarui('kategori', data, kategori.id);
      L.i('Berhasil perbarui kategori untuk ID: ${kategori.id}.');
      // Refresh state after update
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat perbarui kategori ID: ${kategori.id} Error: $e $st');
      rethrow;
    }
  }

  /// Menghapus kategori (hard delete).
  Future<void> delete(String id) async {
    L.w(
      'PERINGATAN: Memulai operasi delete (hard delete) untuk kategori ID: $id',
    );
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.hapus('kategori', id: id);
      L.i('Berhasil delete kategori ID: $id.');
      // Refresh state after delete
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat delete kategori ID: $id Error: $e $st');
      rethrow;
    }
  }

  /// Mengarsipkan satu kategori (soft delete).
  Future<void> arsipkanSatuKategori(String id) async {
    L.i('Memulai arsipkanSatuKategori (soft delete) untuk ID: $id');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final now = DateTime.now();
      final dataToUpdate = {
        'diarsipkan': now.toIso8601String(),
        'diperbarui': now.toIso8601String(),
        'is_deleted': 1,
      };

      await operasiSqlite.perbarui('kategori', dataToUpdate, id);

      L.i('Berhasil arsipkanSatuKategori untuk ID: $id.');
      // Refresh state after archive
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat arsipkanSatuKategori untuk ID: $id Error: $e $st');
      rethrow;
    }
  }

  /// Membersihkan tabel dan menyisipkan semua item baru.
  Future<void> bersihkanDanSisipkanSemua(List<KategoriModel> items) async {
    L.w(
      'PERINGATAN: Memulai bersihkanDanSisipkanSemua. Ini akan menghapus semua kategori dan menggantinya dengan ${items.length} item baru.',
    );
    if (items.isEmpty) {
      return;
    }
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.sisipkanAtauPerbaruiBatch('kategori', [
        // First delete all
        // We'll use a custom approach since operasiSqlite doesn't have a clear method
        // We'll need to use the database directly for this complex operation
      ]);
      // For complex operations, we need to use the database directly
      // This is a special case that requires transaction
      final dbHelper = ref.read(databaseHelperProvider);
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete('kategori');
        for (var item in items) {
          await txn.insert('kategori', item.toSqlite());
        }
        L.i(
          'Berhasil menyisipkan ${items.length} item baru ke tabel kategori.',
        );
      });
      // Refresh state after operation
      await muatUlang();
    } catch (e, st) {
      L.e('Gagal saat menjalankan bersihkanDanSisipkanSemua Error: $e $st');
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui batch kategori.
  Future<void> sisipkanAtauPerbaruiBatch(List<KategoriModel> items) async {
    L.i(
      'Memulai sisipkanAtauPerbaruiBatch untuk ${items.length} item kategori.',
    );
    if (items.isEmpty) {
      return;
    }
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = items.map((item) => item.toSqlite()).toList();
      await operasiSqlite.sisipkanAtauPerbaruiBatch('kategori', data);
      L.i(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${items.length} item kategori.',
      );
      // Refresh state after batch operation
      await muatUlang();
    } catch (e, st) {
      L.e(
        'Gagal saat menjalankan sisipkanAtauPerbaruiBatch kategori Error: $e $st',
      );
      rethrow;
    }
  }
}

/// Kontainer global untuk mengakses [KategoriNotifier] di luar konteks Riverpod.
final ProviderContainer _kategoriGlobalContainer = ProviderContainer();

KategoriNotifier get kategoriNotifierGlobal =>
    _kategoriGlobalContainer.read(kategoriProvider.notifier);
