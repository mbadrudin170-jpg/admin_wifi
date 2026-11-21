// path: lib/fitur/pengaturan/notifier/pengaturan_notifier.dart
// diubah: Memindahkan logika dari PengaturanOperasi ke notifier ini.

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/fitur/pengaturan/model/pengaturan_model.dart';
import 'package:admin_wifi/fitur/pengaturan/state/pengaturan_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'pengaturan_notifier.g.dart';

/// Provider untuk DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

@Riverpod(keepAlive: true)
class PengaturanNotifier extends _$PengaturanNotifier {
  @override
  Future<PengaturanState> build() async {
    L.i('Memuat data pengaturan dari database');
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang pengaturan: $e $s');
      rethrow;
    }
  }

  Future<PengaturanState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil('pengaturan', limit: 1);
    if (maps.isNotEmpty) {
      final model = PengaturanModel.fromSqlite(maps.first);
      return PengaturanState(pengaturan: model);
    }
    final pengaturanDefault = PengaturanModel();
    await simpanAtauPerbaruiPengaturan(pengaturanDefault);
    return PengaturanState(pengaturan: pengaturanDefault);
  }

  Future<PengaturanModel> getPengaturan() async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil('pengaturan', limit: 1);
      if (maps.isNotEmpty) {
        return PengaturanModel.fromSqlite(maps.first);
      }
      final pengaturanDefault = PengaturanModel();
      await simpanAtauPerbaruiPengaturan(pengaturanDefault);
      return pengaturanDefault;
    } catch (e, s) {
      L.e('Gagal mengambil data pengaturan: $e $s');
      return PengaturanModel();
    }
  }

  Future<void> simpanAtauPerbaruiPengaturan(PengaturanModel pengaturan) async {
    try {
      final dataPengaturan = pengaturan.toSqlite();
      final dbHelper = ref.read(databaseHelperProvider);
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete('pengaturan');
        await txn.insert('pengaturan', dataPengaturan);
      });
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal menyimpan pengaturan: $e $s');
      rethrow;
    }
  }
}

/// Kontainer global
final ProviderContainer _pengaturanGlobalContainer = ProviderContainer();

PengaturanNotifier get pengaturanNotifierGlobal =>
    _pengaturanGlobalContainer.read(pengaturanProvider.notifier);