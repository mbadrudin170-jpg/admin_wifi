// path: lib/data/operasi/kategori_operasi.dart
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/db/sqflite.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:share_global_saya/src/utils/l.dart';

class KategoriOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  Future<KategoriModel> createKategori(KategoriModel kategori) async {
    L.i('Memulai createKategori untuk kategori: ${kategori.toSqlite()}');
    try {
      final kategoriBaru = kategori.copyWith(diperbarui: DateTime.now());
      final data = kategoriBaru.toSqlite();

      await _operasiDasar.sisipkan('kategori', data);
      L.i('Berhasil membuat kategori baru dengan ID: ${kategoriBaru.id}');
      return kategoriBaru;
    } catch (e, st) {
      L.e('Gagal saat createKategori Error: $e $st');
      rethrow;
    }
  }

  Future<List<KategoriModel>> getKategori() async {
    L.i(
      'Memulai getKategori (mengambil semua kategori yang tidak diarsipkan).',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'diarsipkan IS NULL',
      );
      final listKategori = List.generate(
        maps.length,
        (i) => KategoriModel.fromSqlite(maps[i]),
      );
      L.i('Berhasil mengambil ${listKategori.length} data kategori.');
      return listKategori;
    } catch (e, st) {
      L.e('Gagal saat getKategori Error: $e $st');
      rethrow;
    }
  }

  Future<KategoriModel> getKategoriById(String id) async {
    L.i('Memulai getKategoriById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final kategori = KategoriModel.fromSqlite(maps.first);
        L.i('Kategori dengan ID: $id ditemukan. Data: ${kategori.toSqlite()}');
        return kategori;
      } else {
        L.e('Kategori dengan ID $id tidak ditemukan di database.');
        throw Exception('Kategori dengan ID $id tidak ditemukan.');
      }
    } catch (e, st) {
      L.e('Gagal saat getKategoriById untuk ID: $id Error: $e $st');
      rethrow;
    }
  }

  Future<List<KategoriModel>> getKategoriByTipe(TipeKategori tipe) async {
    L.i('Memulai getKategoriByTipe untuk tipe: ${tipe.name}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'tipe = ? AND diarsipkan IS NULL',
        whereArgs: [tipe.name],
      );
      final listKategori = List.generate(
        maps.length,
        (i) => KategoriModel.fromSqlite(maps[i]),
      );
      L.i(
        'Berhasil mengambil ${listKategori.length} data kategori untuk tipe ${tipe.name}.',
      );
      return listKategori;
    } catch (e, st) {
      L.e(
        'Gagal saat getKategoriByTipe untuk tipe: ${tipe.name} Error: $e $st',
      );
      rethrow;
    }
  }

  Future<void> update(KategoriModel kategori) async {
    L.i('Memulai update untuk kategori: ${kategori.toSqlite()}');
    try {
      final data = kategori.copyWith(diperbarui: DateTime.now()).toSqlite();
      await _operasiDasar.perbarui('kategori', data, kategori.id);
      L.i('Berhasil update kategori untuk ID: ${kategori.id}.');
    } catch (e, st) {
      L.e('Gagal saat update kategori ID: ${kategori.id} Error: $e $st');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    L.w(
      'PERINGATAN: Memulai operasi delete (hard delete) untuk kategori ID: $id',
    );
    try {
      await _operasiDasar.hapus('kategori', id);
      L.i('Berhasil delete kategori ID: $id.');
    } catch (e, st) {
      L.e('Gagal saat delete kategori ID: $id Error: $e $st');
      rethrow;
    }
  }

  Future<void> arsipkanSatuKategori(String id) async {
    L.i('Memulai arsipkanSatuKategori (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now();
      final Map<String, dynamic> dataToUpdate = {
        'diarsipkan': now.toIso8601String(),
        'diperbarui': now.toIso8601String(),
        'isDeleted': 1,
      };

      await _operasiDasar.perbarui('kategori', dataToUpdate, id);

      L.i('Berhasil arsipkanSatuKategori untuk ID: $id.');
    } catch (e, st) {
      L.e('Gagal saat arsipkanSatuKategori untuk ID: $id Error: $e $st');
      rethrow;
    }
  }

  Future<void> bersihkanDanSisipkanSemua(List<KategoriModel> items) async {
    L.w(
      'PERINGATAN: Memulai bersihkanDanSisipkanSemua. Ini akan menghapus semua kategori dan menggantinya dengan ${items.length} item baru.',
    );
    if (items.isEmpty) {
      L.w(
        'List item untuk bersihkanDanSisipkanSemua kosong, hanya operasi pembersihan yang akan dilakukan.',
      );
    }
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        await txn.delete('kategori');
        L.i('Tabel kategori berhasil dibersihkan.');
        for (var item in items) {
          await txn.insert('kategori', item.toSqlite());
        }
        L.i(
          'Berhasil menyisipkan ${items.length} item baru ke tabel kategori.',
        );
      });
    } catch (e, st) {
      L.e('Gagal saat menjalankan bersihkanDanSisipkanSemua Error: $e $st');
      rethrow;
    }
  }

  Future<List<KategoriModel>> getPerubahan(DateTime since) async {
    L.i(
      'Memulai getPerubahan untuk kategori sejak: ${since.toIso8601String()}',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      final listKategori = List.generate(
        maps.length,
        (i) => KategoriModel.fromSqlite(maps[i]),
      );
      L.i(
        'Berhasil menemukan ${listKategori.length} perubahan kategori sejak ${since.toIso8601String()}.',
      );
      return listKategori;
    } catch (e, st) {
      L.e('Gagal saat getPerubahan kategori Error: $e $st');
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<KategoriModel> items) async {
    L.i(
      'Memulai sisipkanAtauPerbaruiBatch untuk ${items.length} item kategori.',
    );
    if (items.isEmpty) {
      L.w('List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final data = items.map((item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch('kategori', data);
      L.i(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${items.length} item kategori.',
      );
    } catch (e, st) {
      L.e(
        'Gagal saat menjalankan sisipkanAtauPerbaruiBatch kategori Error: $e $st',
      );
      rethrow;
    }
  }

  Future<List<KategoriModel>> getKategoriByIds(List<String> ids) async {
    L.i('Memulai getKategoriByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      L.w('List ID untuk getKategoriByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      final listKategori = List.generate(
        maps.length,
        (i) => KategoriModel.fromSqlite(maps[i]),
      );
      L.i(
        'Berhasil mengambil ${listKategori.length} kategori dari ${ids.length} ID yang diminta.',
      );
      return listKategori;
    } catch (e, st) {
      L.e('Gagal saat getKategoriByIds Error: $e $st');
      rethrow;
    }
  }
}
