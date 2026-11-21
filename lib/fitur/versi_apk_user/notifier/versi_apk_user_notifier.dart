// path: lib/fitur/versi_apk_user/notifier/versi_apk_user_notifier.dart
// diubah: Memindahkan logika dari VersiApkUserOperasi ke notifier ini.

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:admin_wifi/fitur/versi_apk_user/state/versi_apk_user_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'versi_apk_user_notifier.g.dart';

@Riverpod(keepAlive: true)
class VersiApkUserNotifier extends _$VersiApkUserNotifier {
  @override
  Future<VersiApkUserState> build() async {
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang versi APK user: $e $s');
      rethrow;
    }
  }

  Future<VersiApkUserState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil('versi_apk_user');
    final daftar = maps.map(VersiApkUserModel.fromSqlite).toList();
    return VersiApkUserState(
      listVersiApkUser: daftar,
      jumlahVersiApkUser: daftar.length,
    );
  }

  Future<void> tambahVersiApkUser(VersiApkUserModel versiApkUser) async {
    L.i('Menambah versi APK user baru - ID: ${versiApkUser.id}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.tambah('versi_apk_user', versiApkUser.toSqlite());
      L.i('Versi APK user berhasil ditambahkan - ID: ${versiApkUser.id}');
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal menambah versi APK user - ID: ${versiApkUser.id} Error: $e $s');
      rethrow;
    }
  }

  Future<void> perbaruiVersiApkUser(VersiApkUserModel versiApkUser) async {
    L.i('Memperbarui versi APK user - ID: ${versiApkUser.id}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.ubah('versi_apk_user', versiApkUser.toSqlite(), id: versiApkUser.id);
      L.i('Versi APK user berhasil diperbarui - ID: ${versiApkUser.id}');
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal memperbarui versi APK user - ID: ${versiApkUser.id} Error: $e $s');
      rethrow;
    }
  }

  Future<void> arsipkanVersiApkUser(String id) async {
    L.i('Mengarsipkan versi APK user - ID: $id');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil('versi_apk_user', where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        final model = VersiApkUserModel.fromSqlite(maps.first);
        final modelDiarsipkan = model.copyWith(isDeleted: true, diarsipkan: DateTime.now());
        await operasiSqlite.ubah('versi_apk_user', modelDiarsipkan.toSqlite(), id: id);
        L.i('Versi APK user berhasil diarsipkan - ID: $id');
      }
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal mengarsipkan versi APK user - ID: $id Error: $e $s');
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<VersiApkUserModel> daftarModel) async {
    L.i('Memulai operasi batch sisipkan/perbarui - Jumlah data: ${daftarModel.length}');
    if (daftarModel.isEmpty) return;
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final daftarMap = daftarModel.map((m) => m.toSqlite()).toList();
      await operasiSqlite.tambahBatch('versi_apk_user', daftarMap);
      L.i('Operasi batch berhasil - ${daftarMap.length} data diproses');
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal melakukan operasi batch - Jumlah data: ${daftarModel.length} Error: $e $s');
      rethrow;
    }
  }

  Future<List<VersiApkUserModel>> ambilSemuaVersiApk() async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil('versi_apk_user', orderBy: 'diperbarui DESC');
      return maps.map(VersiApkUserModel.fromSqlite).toList();
    } catch (e, s) {
      L.e('Gagal mengambil semua data versi APK Error: $e $s');
      rethrow;
    }
  }

  Future<List<VersiApkUserModel>> ambilSemuaVersiApkAktif() async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'versi_apk_user',
        where: 'is_deleted = ?',
        whereArgs: const [0],
        orderBy: 'diperbarui DESC',
      );
      return maps.map(VersiApkUserModel.fromSqlite).toList();
    } catch (e, s) {
      L.e('Gagal mengambil versi APK aktif Error: $e $s');
      rethrow;
    }
  }

  Future<VersiApkUserModel?> ambilVersiApkTerbaru() async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'versi_apk_user',
        where: 'is_deleted = ?',
        whereArgs: const [0],
        orderBy: 'diperbarui DESC',
        limit: 1,
      );
      if (maps.isNotEmpty) return VersiApkUserModel.fromSqlite(maps.first);
      return null;
    } catch (e, s) {
      L.e('Gagal mengambil versi APK terbaru Error: $e $s');
      rethrow;
    }
  }

  Future<VersiApkUserModel?> ambilVersiApkById(String id) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'versi_apk_user',
        where: 'id = ? AND is_deleted = ?',
        whereArgs: [id, 0],
      );
      if (maps.isNotEmpty) return VersiApkUserModel.fromSqlite(maps.first);
      return null;
    } catch (e, s) {
      L.e('Gagal mengambil versi APK by ID Error: $e $s');
      rethrow;
    }
  }
}

/// Kontainer global
final ProviderContainer _versiApkUserGlobalContainer = ProviderContainer();

VersiApkUserNotifier get versiApkUserNotifierGlobal =>
    _versiApkUserGlobalContainer.read(versiApkUserProvider.notifier);