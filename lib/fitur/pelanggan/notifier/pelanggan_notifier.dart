// path: lib/fitur/pelanggan/notifier/pelanggan_notifier.dart
// diubah: Memindahkan logika dari PelangganOperasi ke notifier ini.

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan/state/pelanggan_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'pelanggan_notifier.g.dart';

@Riverpod(keepAlive: true)
class PelangganNotifier extends _$PelangganNotifier {
  @override
  Future<PelangganState> build() async {
    L.i('Memuat daftar pelanggan dari database');
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang pelanggan: $e\n$s');
      rethrow;
    }
  }

  Future<PelangganState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      PelangganSkema.tabel,
      where:
          '${PelangganSkema.diarsipkan} IS NULL AND ${PelangganSkema.isDeleted} = ?',
      whereArgs: const [0],
    );
    final daftar = maps.map(PelangganModel.fromSqlite).toList();
    return PelangganState(
      listPelanggan: daftar,
      jumlahPelanggan: daftar.length,
    );
  }

  /// Membuat pelanggan baru.
  Future<void> tambah(PelangganModel model) async {
    L.i('Memulai pembuatan pelanggan dengan ID: ${model.id}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final pelangganUntukDisimpan = model.copyWith(
        diperbarui: DateTime.now(),
      );
      final data = pelangganUntukDisimpan.toSqlite();

      await operasiSqlite.tambah(PelangganSkema.tabel, data);

      L.i(
        'Pelanggan (ID: ${pelangganUntukDisimpan.id}) berhasil dibuat di database lokal.',
      );
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal membuat pelanggan. Error: $e $s');
      rethrow;
    }
  }

  /// Mengambil semua pelanggan yang aktif (tidak diarsipkan dan tidak dihapus).
  Future<List<PelangganModel>> getPelanggan() async {
    L.i(
      'Mengambil semua pelanggan yang aktif (tidak diarsipkan dan tidak dihapus).',
    );
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final List<Map<String, dynamic>> maps = await operasiSqlite.ambil(
        PelangganSkema.tabel,
        where: '${PelangganSkema.diarsipkan} IS NULL AND ${PelangganSkema.isDeleted} = ?',
        whereArgs: [0],
      );

      L.i('Berhasil mengambil ${maps.length} pelanggan aktif.');
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e('Gagal mengambil pelanggan aktif. Error: $e $s');
      rethrow;
    }
  }

  /// Mengambil SEMUA data pelanggan dari database lokal.
  Future<List<PelangganModel>> getAllPelanggan() async {
    L.i('Mengambil SEMUA data pelanggan dari database lokal.');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final List<Map<String, dynamic>> maps = await operasiSqlite.ambil(
        PelangganSkema.tabel,
      );

      L.i('Berhasil mengambil total ${maps.length} pelanggan.');
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e('Gagal mengambil semua data pelanggan. Error: $e $s');
      rethrow;
    }
  }

  /// Mencari pelanggan berdasarkan ID.
  Future<PelangganModel?> getPelangganById(String id) async {
    L.i('Mencari pelanggan berdasarkan ID: $id');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final List<Map<String, dynamic>> maps = await operasiSqlite.ambil(
        PelangganSkema.tabel,
        where: '${PelangganSkema.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        L.i('Pelanggan dengan ID: $id ditemukan.');
        return PelangganModel.fromSqlite(maps.first);
      }
      L.w('Pelanggan dengan ID: $id tidak ditemukan.');
      return null;
    } catch (e, s) {
      L.e('Gagal mencari pelanggan berdasarkan ID. Error: $e $s');
      rethrow;
    }
  }

  /// Memperbarui pelanggan.
  Future<void> ubah(PelangganModel model) async {
    L.i('Memulai pembaruan untuk pelanggan ID: ${model.id}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = model.copyWith(diperbarui: DateTime.now()).toSqlite();

      await operasiSqlite.ubah(PelangganSkema.tabel, data, id: model.id);

      L.i('Berhasil memperbarui pelanggan ID: ${model.id}.');
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memperbarui pelanggan. Error: $e $s');
      rethrow;
    }
  }

  /// Menghapus pelanggan (soft delete default, atau hard delete).
  Future<void> hapus(String id, {bool softDelete = true}) async {
    L.i(
      'Memulai proses penghapusan untuk pelanggan ID: $id (softDelete: $softDelete)',
    );
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      if (softDelete) {
        await operasiSqlite.ubah(PelangganSkema.tabel, {
          'is_deleted': 1,
          'diperbarui': DateTime.now().toIso8601String(),
        }, id: id);
        L.i('Berhasil melakukan soft delete pada pelanggan ID: $id.');
      } else {
        await operasiSqlite.hapus(PelangganSkema.tabel, id: id);
        L.w(
          'Berhasil melakukan hard delete (penghapusan permanen) pada pelanggan ID: $id.',
        );
      }
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus pelanggan. Error: $e $s');
      rethrow;
    }
  }

  /// Mengambil perubahan pelanggan sejak waktu tertentu.
  Future<List<PelangganModel>> getPerubahan(DateTime since) async {
    L.i('Mengambil perubahan pelanggan sejak: ${since.toIso8601String()}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final List<Map<String, dynamic>> maps = await operasiSqlite.ambil(
        PelangganSkema.tabel,
        where: '${PelangganSkema.diperbarui} > ?',
        whereArgs: [since.toIso8601String()],
      );
      L.i(
        'Ditemukan ${maps.length} perubahan pelanggan sejak waktu yang ditentukan.',
      );
      return List.generate(
        maps.length,
        (i) => PelangganModel.fromSqlite(maps[i]),
      );
    } catch (e, s) {
      L.e('Gagal mengambil perubahan pelanggan. Error: $e $s');
      rethrow;
    }
  }

  /// Mengarsipkan pelanggan.
  Future<void> arsipkanPelanggan(String id) async {
    L.i('Mengarsipkan pelanggan ID: $id');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final now = DateTime.now();
      await operasiSqlite.ubah(PelangganSkema.tabel, {
        'isDeleted': 1,
        'diarsipkan': now.toIso8601String(),
        'diperbarui': now.toIso8601String(),
      }, id: id);
      L.i('Berhasil mengarsipkan pelanggan ID: $id.');
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal mengarsipkan pelanggan. Error: $e $s');
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui batch pelanggan.
  Future<void> tambahBatch(List<PelangganModel> models) async {
    if (models.isEmpty) {
      L.i('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    L.i('Memulai batch insert/update untuk ${models.length} pelanggan.');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = models.map((item) {
        final itemToSave = item.copyWith(diperbarui: DateTime.now());
        return itemToSave.toSqlite();
      }).toList();

      await operasiSqlite.tambahBatch(PelangganSkema.tabel, data);
      L.i(
        'Berhasil menyelesaikan operasi batch untuk ${models.length} pelanggan.',
      );
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menjalankan operasi batch. Error: $e $s');
      rethrow;
    }
  }

  /// Mengambil data pelanggan untuk list ID.
  Future<List<PelangganModel>> getPelangganByIds(List<String> ids) async {
    if (ids.isEmpty) {
      L.i('List ID kosong, tidak ada pelanggan yang diambil.');
      return [];
    }
    L.i('Mengambil data pelanggan untuk ${ids.length} ID.');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await operasiSqlite.ambil(
        PelangganSkema.tabel,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      L.i(
        'Berhasil mengambil ${maps.length} pelanggan berdasarkan list ID yang diberikan.',
      );
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e('Gagal mengambil pelanggan berdasarkan list ID. Error: $e $s');
      rethrow;
    }
  }
}

/// Kontainer global untuk mengakses [PelangganNotifier] di luar konteks Riverpod.
final ProviderContainer _pelangganGlobalContainer = ProviderContainer();

PelangganNotifier get pelangganNotifierGlobal =>
    _pelangganGlobalContainer.read(pelangganProvider.notifier);
