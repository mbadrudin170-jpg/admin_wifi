// path: lib/fitur/kategori/notifier/kategori_notifier.dart

import 'package:admin_wifi/db/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/state/kategori_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'kategori_notifier.g.dart';

@Riverpod(keepAlive: true)
class KategoriNotifier extends _$KategoriNotifier {
  @override
  Future<KategoriState> build() async {
    L.i('Memuat daftar kategori dari database');
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
}
