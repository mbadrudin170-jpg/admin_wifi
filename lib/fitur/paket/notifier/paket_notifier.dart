// path: lib/fitur/paket/notifier/paket_notifier.dart
// diubah: Memindahkan logika dari PaketOperasi ke notifier ini.

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/state/paket_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'paket_notifier.g.dart';

@Riverpod(keepAlive: true)
class PaketNotifier extends _$PaketNotifier {
  final _tabel = PaketSkema.tabel;

  @override
  Future<PaketState> build() async {
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang paket: $e $s');
      rethrow;
    }
  }

  Future<PaketState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      _tabel,
      where: '${PaketSkema.isDeleted} = ?',
      whereArgs: const [0],
      orderBy:
          "CASE tipe WHEN 'jam' THEN durasi WHEN 'hari' THEN durasi * 24 WHEN 'bulan' THEN durasi * 24 * 30 ELSE 999999 END ASC",
    );
    final daftar = maps.map(PaketModel.fromSqlite).toList();
    return PaketState(listPaket: daftar, jumlahPaket: daftar.length);
  }

  /// Membuat paket baru.
  Future<void> tambah(PaketModel model) async {
    L.i('Memulai pembuatan paket, id: ${model.id}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final now = DateTime.now();
      final data = model.copyWith(diperbarui: now).toSqlite();

      await operasiSqlite.sisipkan(_tabel, data);
      L.i('Berhasil membuat paket, id: ${model.id}');
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal membuat paket, id: ${model.id}, error: $e $s');
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui batch paket.
  Future<void> tambahBatch(List<PaketModel> models) async {
    L.i(
      'Mendelegasikan proses batch ke OperasiDasar untuk ${models.length} item paket, method: sisipkanAtauPerbaruiBatch',
    );
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final dataList = models.map((item) => item.toSqlite()).toList();
      await operasiSqlite.sisipkanAtauPerbaruiBatch(_tabel, dataList);
      L.i(
        'Berhasil menyelesaikan proses batch untuk ${models.length} item paket.',
      );
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal melakukan proses batch paket, error: $e $s');
      rethrow;
    }
  }

  /// Memperbarui paket.
  Future<void> ubah(PaketModel model) async {
    L.i('Memperbarui paket, id: ${model.id}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final now = DateTime.now();
      final data = model.copyWith(diperbarui: now).toSqlite();

      await operasiSqlite.perbarui(_tabel, data, model.id);
      L.i('Berhasil memperbarui paket, id: ${model.id}');
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memperbarui paket, id: ${model.id}, error: $e $s');
      rethrow;
    }
  }

  /// Menghapus paket (hard delete).
  Future<void> hapus(String id) async {
    L.i('Menghapus paket, id: $id');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.hapus(_tabel, id: id);
      L.i('Berhasil menghapus paket, id: $id');
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus paket, id: $id, error: $e $s');
      rethrow;
    }
  }

  /// Mengambil semua paket (tanpa filter is_deleted).
  Future<List<PaketModel>> getAllPaket() async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        _tabel,
        orderBy:
            "CASE tipe WHEN 'jam' THEN durasi WHEN 'hari' THEN durasi * 24 WHEN 'bulan' THEN durasi * 24 * 30 ELSE 999999 END ASC",
      );

      if (maps.isNotEmpty) {
        L.i('Berhasil mengambil ${maps.length} data paket');
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e('Gagal mengambil semua data paket, error: $e $s');
      rethrow;
    }
  }

  /// Mengambil semua paket aktif (is_deleted = 0).
  Future<List<PaketModel>> getPaket() async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        _tabel,
        where: '${PaketSkema.isDeleted} = ?',
        whereArgs: const [0],
        orderBy:
            "CASE tipe WHEN 'jam' THEN durasi WHEN 'hari' THEN durasi * 24 WHEN 'bulan' THEN durasi * 24 * 30 ELSE 999999 END ASC",
      );

      if (maps.isNotEmpty) {
        L.i('Berhasil mengambil ${maps.length} data paket aktif');
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e('Gagal mengambil semua data paket aktif, error: $e $s');
      rethrow;
    }
  }

  /// Mengambil semua paket publik (is_deleted = 0 dan is_public = 1).
  Future<List<PaketModel>> getPaketByIsPublic() async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        _tabel,
        where: '${PaketSkema.isDeleted} = ? AND ${PaketSkema.isPublic} = ?',
        whereArgs: const [0, 1],
        orderBy:
            "CASE tipe WHEN 'jam' THEN durasi WHEN 'hari' THEN durasi * 24 WHEN 'bulan' THEN durasi * 24 * 30 ELSE 999999 END ASC",
      );

      if (maps.isNotEmpty) {
        L.i('Berhasil mengambil ${maps.length} data paket publik');
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e('Gagal mengambil semua data paket publik, error: $e $s');
      rethrow;
    }
  }

  Future<void> hapusSemuaPaket() async {
    try {
      final dbHelper = ref.read(databaseHelperProvider);
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        int count = await txn.delete(_tabel);
        L.i('Berhasil menghapus semua data paket. Total terhapus: $count');
        return count;
      });
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus semua data paket, error: $e $s');
      rethrow;
    }
  }

  /// Mengambil perubahan paket sejak timestamp tertentu.
  Future<List<PaketModel>> getPerubahan(DateTime since) async {
    L.i('Memulai pengambilan perubahan paket sejak ${since.toIso8601String()}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        _tabel,
        where: '${PaketSkema.diperbarui} > ?',
        whereArgs: [since.toIso8601String()],
      );
      if (maps.isNotEmpty) {
        L.i('Ditemukan ${maps.length} perubahan paket');
      } else {
        L.i(
          'Tidak ada perubahan paket ditemukan sejak ${since.toIso8601String()}',
        );
      }
      return List.generate(maps.length, (i) => PaketModel.fromSqlite(maps[i]));
    } catch (e, s) {
      L.e('Gagal mengambil perubahan paket, error: $e $s');
      rethrow;
    }
  }

}

/// Kontainer global untuk mengakses [PaketNotifier] di luar konteks Riverpod.
final ProviderContainer _paketGlobalContainer = ProviderContainer();

PaketNotifier get paketNotifierGlobal =>
    _paketGlobalContainer.read(paketProvider.notifier);

/// Akses state paket global (sinkron) dari luar konteks Riverpod.
PaketState? get paketStateGlobal => _paketGlobalContainer.read(paketProvider).value;
