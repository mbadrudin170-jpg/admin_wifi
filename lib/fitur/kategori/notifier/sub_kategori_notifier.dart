// path: lib/fitur/kategori/notifier/sub_kategori_notifier.dart
// diubah: Memindahkan logika dari SubKategoriOperasi ke notifier ini.

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/state/sub_kategori_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'sub_kategori_notifier.g.dart';

@Riverpod(keepAlive: true)
class SubKategoriNotifier extends _$SubKategoriNotifier {
  @override
  Future<SubKategoriState> build() async {
    L.i('Memuat daftar sub kategori dari database');
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang sub kategori: $e $s');
      rethrow;
    }
  }

  Future<SubKategoriState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      'sub_kategori',
      where: '${SubKategoriSkema.isDeleted} = ?',
      whereArgs: const [0],
    );
    final daftar = maps.map(SubKategoriModel.fromSqlite).toList();
    return SubKategoriState(
      listSubKategori: daftar,
      jumlahSubKategori: daftar.length,
    );
  }

  Future<void> createSubKategori(SubKategoriModel subKategori) async {
    L.i('Memulai createSubKategori untuk data: ${subKategori.toSqlite()}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final now = DateTime.now();
      final data = subKategori.copyWith(diperbarui: now).toSqlite();
      await operasiSqlite.tambah('sub_kategori', data);
      L.i('Berhasil membuat sub kategori dengan ID: ${subKategori.id}');
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal saat createSubKategori Error: $e $s');
      rethrow;
    }
  }

  Future<List<SubKategoriModel>> getAllSubKategori() async {
    L.i('Memulai getAllSubKategori');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'sub_kategori',
        where: '${SubKategoriSkema.isDeleted} = ?',
        whereArgs: const [0],
      );
      return maps.map(SubKategoriModel.fromSqlite).toList();
    } catch (e, s) {
      L.e('Gagal saat getAllSubKategori Error: $e $s');
      rethrow;
    }
  }

  Future<List<SubKategoriModel>> getSubKategoriByKategoriId(
    String idKategori,
  ) async {
    L.i('Memulai getSubKategoriByKategoriId untuk idKategori: $idKategori');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'sub_kategori',
        where:
            '${SubKategoriSkema.idKategori} = ? AND ${SubKategoriSkema.isDeleted} = ?',
        whereArgs: [idKategori, 0],
      );
      return maps.map(SubKategoriModel.fromSqlite).toList();
    } catch (e, s) {
      L.e('Gagal saat getSubKategoriByKategoriId Error: $e $s');
      rethrow;
    }
  }

  Future<SubKategoriModel?> getSubKategoriById(String id) async {
    L.i('Memulai getSubKategoriById untuk ID: $id');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'sub_kategori',
        where: '${SubKategoriSkema.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return SubKategoriModel.fromSqlite(maps.first);
      }
      return null;
    } catch (e, s) {
      L.e('Gagal saat getSubKategoriById Error: $e $s');
      rethrow;
    }
  }

  Future<void> updateSubKategori(SubKategoriModel subKategori) async {
    L.i('Memulai updateSubKategori untuk ID: ${subKategori.id}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final now = DateTime.now();
      final data = subKategori.copyWith(diperbarui: now).toSqlite();
      await operasiSqlite.ubah('sub_kategori', data, id: subKategori.id);
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal saat updateSubKategori Error: $e $s');
      rethrow;
    }
  }

  Future<void> deleteSubKategori(String id, {bool softDelete = true}) async {
    L.i('Memulai deleteSubKategori untuk ID: $id, softDelete: $softDelete');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      if (softDelete) {
        await operasiSqlite.ubah(
          'sub_kategori',
          {
            SubKategoriSkema.isDeleted: 1,
            SubKategoriSkema.diperbarui: DateTime.now().toIso8601String(),
          },
          id: id,
        );
      } else {
        await operasiSqlite.hapus('sub_kategori', id: id);
      }
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal saat deleteSubKategori Error: $e $s');
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<SubKategoriModel> items) async {
    L.i(
      'Memulai sisipkanAtauPerbaruiBatch untuk ${items.length} item sub kategori.',
    );
    if (items.isEmpty) {
      L.w('List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = items
          .map((item) => item.copyWith(diperbarui: DateTime.now()).toSqlite())
          .toList();
      await operasiSqlite.tambahBatch('sub_kategori', data);
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal saat sisipkanAtauPerbaruiBatch sub kategori Error: $e $s');
      rethrow;
    }
  }

  Future<List<SubKategoriModel>> getSubKategoriByIds(List<String> ids) async {
    L.i('Memulai getSubKategoriByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      L.w('List ID untuk getSubKategoriByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final placeholders = List.filled(ids.length, '?').join(',');
      final maps = await operasiSqlite.ambil(
        'sub_kategori',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      return maps.map(SubKategoriModel.fromSqlite).toList();
    } catch (e, s) {
      L.e('Gagal saat getSubKategoriByIds Error: $e $s');
      rethrow;
    }
  }
}

/// Kontainer global untuk mengakses [SubKategoriNotifier] di luar konteks Riverpod.
final ProviderContainer _subKategoriGlobalContainer = ProviderContainer();

SubKategoriNotifier get subKategoriNotifierGlobal =>
    _subKategoriGlobalContainer.read(subKategoriProvider.notifier);