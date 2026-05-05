// lib/data/operasi/kategori_operasi.dart
// diubah: Memperbaiki bug timestamp di createKategori.
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class KategoriOperasi {
  // dihapus: Variabel instance 'now' yang menyebabkan timestamp tidak update.
  // final now = DateTime.now();

  // diubah: Memindahkan DateTime.now() ke dalam method.
  Future<KategoriModel> createKategori(KategoriModel kategori) async {
    final db = await DatabaseHelper.instance.database;
    final kategoriBaru = kategori.copyWith(
      id: kategori.id,
      // diubah: Menggunakan DateTime.now() untuk mendapatkan timestamp terbaru setiap kali.
      diperbarui: DateTime.now(),
    );
    final data = kategoriBaru.toMap();

    await db.insert(
      'kategori',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return kategoriBaru;
  }

  Future<List<KategoriModel>> getKategori() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('kategori');
    return List.generate(maps.length, (i) {
      return KategoriModel.fromMap(maps[i]);
    });
  }

  Future<List<KategoriModel>> getKategoriByTipe(TipeKategori tipe) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'tipe = ?',
      whereArgs: [tipe.name],
    );
    return List.generate(maps.length, (i) {
      return KategoriModel.fromMap(maps[i]);
    });
  }

  // diubah: Logika 'diperbarui' tetap sama, sudah benar.
  Future<void> update(KategoriModel kategori) async {
    final db = await DatabaseHelper.instance.database;
    // ditambah: Menyisipkan 'diperbarui' dengan waktu saat ini.
    final data = kategori.copyWith(diperbarui: DateTime.now()).toMap();
    await db.update(
      'kategori',
      data,
      where: 'id = ?',
      whereArgs: [kategori.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('kategori', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> bersihkanDanSisipkanSemua(List<KategoriModel> items) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete('kategori'); // Hapus semua data lama
      for (var item in items) {
        await txn.insert('kategori', item.toMap()); // Sisipkan data baru
      }
    });
  }

  // == METODE BARU UNTUK SINKRONISASI INKREMENTAL ==

  /// Mengambil record yang berubah (dibuat atau diperbarui) setelah waktu [since].
  Future<List<KategoriModel>> getPerubahan(DateTime since) async {
    final db = await DatabaseHelper.instance.database;
    // Pastikan Anda memiliki kolom 'diperbarui' di tabel Anda
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'diperbarui > ?',
      whereArgs: [since.toIso8601String()],
    );
    return List.generate(maps.length, (i) => KategoriModel.fromMap(maps[i]));
  }

  /// Menyisipkan atau memperbarui batch data dari Firebase.
  /// Menggunakan `ConflictAlgorithm.replace` untuk melakukan "UPSERT".
  Future<void> sisipkanAtauPerbaruiBatch(List<KategoriModel> items) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    for (var item in items) {
      // Pastikan model Anda memiliki ID yang unik untuk proses ini
      batch.insert(
        'kategori',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
