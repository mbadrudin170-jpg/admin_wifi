// path: lib/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart
// diubah: Memindahkan logika dari PelangganAktifOperasi ke notifier ini.

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/state/pelanggan_aktif_state.dart';
import 'package:admin_wifi/services/notifikasi/notifikasi_servis.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'pengguna_aktif_notifier.g.dart';

/// Kontrak jumlah/kunci jadwal notifikasi pelanggan aktif.
/// Kode dan test WAJIB mengacu pada konstanta ini, bukan angka literal.
const notifikasiPelangganAktif = <String>['tepat_waktu', 'h_min_1', 'h_min_3'];

@Riverpod(keepAlive: true)
class PenggunaAktifNotifier extends _$PenggunaAktifNotifier {
  final NotifikasiServis _notifikasiServis = NotifikasiServis();

  @override
  Future<PelangganAktifState> build() async {
    L.i('Memuat daftar pelanggan aktif dari database');
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<PelangganAktifState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      PelangganAktifSkema.tabel,
      where: '${PelangganAktifSkema.isDeleted} = ?',
      whereArgs: const [0],
    );
    final daftar = maps.map(PelangganAktifModel.fromSqlite).toList();
    return PelangganAktifState(
      listPelangganAktif: daftar,
      jumlahPelangganAktif: daftar.length,
    );
  }

  /// Mengambil semua pelanggan aktif.
  Future<List<PelangganAktifModel>> ambilSemuaPelangganAktif() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      PelangganAktifSkema.tabel,
      where: '${PelangganAktifSkema.isDeleted} = ?',
      whereArgs: const [0],
    );
    return maps.map(PelangganAktifModel.fromSqlite).toList();
  }

  /// Menambahkan pelanggan aktif baru dan jadwalkan notifikasi.
  Future<PelangganAktifModel> tambah(PelangganAktifModel model) async {
    try {
      final pelangganUntukDisimpan = model.copyWith(
        diperbarui: DateTime.now().toUtc(),
      );

      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.tambah(
        PelangganAktifSkema.tabel,
        pelangganUntukDisimpan.toSqlite(),
      );

      await _jadwalkanNotifikasi(pelangganUntukDisimpan);

      state = AsyncValue.data(await _ambilSemua());
      return pelangganUntukDisimpan;
    } catch (e, s) {
      L.e('Gagal menambahkan pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<void> tambahBatch(List<PelangganAktifModel> models) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = models.map((item) => item.toSqlite()).toList();
      await operasiSqlite.tambahBatch(PelangganAktifSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan batch pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<PelangganAktifModel> ubah(PelangganAktifModel model) async {
    try {
      final pelangganUntukDisimpan = model.copyWith(
        diperbarui: DateTime.now().toUtc(),
      );

      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.ubah(
        PelangganAktifSkema.tabel,
        pelangganUntukDisimpan.toSqlite(),
        id: pelangganUntukDisimpan.id,
      );

      await _jadwalkanNotifikasi(pelangganUntukDisimpan);

      state = AsyncValue.data(await _ambilSemua());
      return pelangganUntukDisimpan;
    } catch (e, s) {
      L.e('Gagal mengubah pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<void> hapus(String id) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        PelangganAktifSkema.tabel,
        where: '${PelangganAktifSkema.id} = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        L.i('Pelanggan aktif ID: $id tidak ditemukan, tidak dapat menghapus');
        return;
      }
      final pelangganAktif = PelangganAktifModel.fromSqlite(maps.first);

      final now = DateTime.now().toUtc();
      final pelangganDiarsipkan = pelangganAktif.copyWith(
        isDeleted: true,
        diarsipkan: now,
        diperbarui: now,
      );
      await operasiSqlite.ubah(
        PelangganAktifSkema.tabel,
        pelangganDiarsipkan.toSqlite(),
        id: id,
      );

      await _notifikasiServis.batalNotifikasi(id.hashCode);
      await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
      await _notifikasiServis.batalNotifikasi((id.hashCode + 2));

      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  /// Mengambil satu pelanggan aktif berdasarkan ID.
  Future<PelangganAktifModel?> ambilSatuPelangganAktif(String id) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final List<Map<String, dynamic>> maps = await operasiSqlite.ambil(
        PelangganAktifSkema.tabel,
        where: '${PelangganAktifSkema.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final pelangganAktif = PelangganAktifModel.fromSqlite(maps.first);
        L.i(
          'Pelanggan aktif ID: $id ditemukan - ID Pelanggan: ${pelangganAktif.idPelanggan}, ID Paket: ${pelangganAktif.idPaket}',
        );
        return pelangganAktif;
      }

      L.i('Pelanggan aktif ID: $id tidak ditemukan di database');
      return null;
    } catch (e, stackTrace) {
      L.e('Gagal mengambil pelanggan aktif ID: $id Error: $e $stackTrace');
      rethrow;
    }
  }

  Future<void> _jadwalkanNotifikasi(PelangganAktifModel pelangganAktif) async {
    try {
      L.i(
        'Menjadwalkan notifikasi untuk pelanggan aktif ID: ${pelangganAktif.id}',
      );

      final operasiSqlite = ref.read(operasiSqliteProvider);
      final pelangganMaps = await operasiSqlite.ambil(
        'pelanggan',
        where: 'id = ?',
        whereArgs: [pelangganAktif.idPelanggan],
      );
      final namaPelanggan = pelangganMaps.isNotEmpty
          ? (pelangganMaps.first['nama'] as String? ?? 'Tanpa Nama')
          : 'Tanpa Nama';

      await _notifikasiServis.batalNotifikasi(pelangganAktif.id.hashCode);
      await _notifikasiServis.batalNotifikasi((pelangganAktif.id.hashCode + 1));
      await _notifikasiServis.batalNotifikasi((pelangganAktif.id.hashCode + 2));

      final jadwalTepatWaktu = pelangganAktif.tanggalBerakhir;
      if (jadwalTepatWaktu.isAfter(DateTime.now())) {
        await _notifikasiServis.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 2),
          title: 'Masa Aktif Habis!',
          body: 'Paket WiFi untuk $namaPelanggan telah berakhir sekarang.',
          jadwal: jadwalTepatWaktu,
        );
      }

      final jadwalNotifikasiH1 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 1),
      );
      if (jadwalNotifikasiH1.isAfter(DateTime.now())) {
        await _notifikasiServis.jadwalNotifikasi(
          id: pelangganAktif.id.hashCode,
          title: 'Paket Akan Segera Berakhir',
          body: 'Paket untuk pelanggan $namaPelanggan akan berakhir besok.',
          jadwal: jadwalNotifikasiH1,
        );
      }

      final jadwalNotifikasiH3 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 3),
      );
      if (jadwalNotifikasiH3.isAfter(DateTime.now())) {
        await _notifikasiServis.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 1),
          title: 'Pengingat Paket',
          body:
              'Paket untuk pelanggan $namaPelanggan akan berakhir dalam 3 hari.',
          jadwal: jadwalNotifikasiH3,
        );
      }
    } catch (e, st) {
      L.e(
        'Gagal menjadwalkan notifikasi untuk pelanggan aktif ID: ${pelangganAktif.id} Error: $e $st',
      );
    }
  }

  /// Mengarsipkan pelanggan aktif (soft delete) dan batalkan notifikasi.
  Future<void> arsipkanPelangganAktif(String id) async {
    try {
      L.i('Mengarsipkan pelanggan aktif ID: $id');

      final pelangganAktif = await ambilSatuPelangganAktif(id);
      if (pelangganAktif == null) {
        L.i(
          'Pelanggan aktif ID: $id tidak ditemukan, tidak dapat mengarsipkan',
        );
        return;
      }

      L.i(
        'Data sebelum arsip - ID Pelanggan: ${pelangganAktif.idPelanggan}, ID Paket: ${pelangganAktif.idPaket}, Berakhir: ${pelangganAktif.tanggalBerakhir.toIso8601String()}',
      );

      final operasiSqlite = ref.read(operasiSqliteProvider);
      final now = DateTime.now().toUtc();
      final pelangganDiarsipkan = pelangganAktif.copyWith(
        isDeleted: true,
        diarsipkan: now,
        diperbarui: now,
      );

      L.i(
        'Menandai isDeleted=true, diarsipkan=${pelangganDiarsipkan.diarsipkan?.toIso8601String()}',
      );
      await operasiSqlite.ubah(
        PelangganAktifSkema.tabel,
        pelangganDiarsipkan.toSqlite(),
        id: id,
      );

      L.i('Membatalkan notifikasi terkait...');
      await _notifikasiServis.batalNotifikasi(id.hashCode);
      await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
      await _notifikasiServis.batalNotifikasi((id.hashCode + 2));

      state = AsyncValue.data(await _ambilSemua());

      L.i(
        'Pelanggan aktif ID: $id berhasil diarsipkan dengan notifikasi dibatalkan',
      );
    } catch (e, stackTrace) {
      L.e('Gagal mengarsipkan pelanggan aktif ID: $id Error: $e $stackTrace');
      rethrow;
    }
  }

  /// Menghapus permanen pelanggan yang sudah diarsipkan lebih dari 30 hari.
  Future<void> hapusPermanenPelangganYangDiArsipkan() async {
    try {
      final dbHelper = ref.read(databaseHelperProvider);
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        // Menggunakan UTC untuk konsistensi
        final batasWaktu = DateTime.now().toUtc().subtract(
          const Duration(days: 30),
        );
        L.i(
          'Mencari pelanggan diarsipkan sebelum ${batasWaktu.toIso8601String()} (30 hari yang lalu)',
        );

        final List<Map<String, dynamic>> pelangganKadaluarsa = await txn.query(
          PelangganAktifSkema.tabel,
          where:
              '${PelangganAktifSkema.diarsipkan} IS NOT NULL AND ${PelangganAktifSkema.diarsipkan} < ?',
          whereArgs: [batasWaktu.toIso8601String()],
        );

        if (pelangganKadaluarsa.isEmpty) {
          L.i('Tidak ada pelanggan aktif diarsipkan lebih dari 30 hari');
          return;
        }

        final idsUntukDihapus = pelangganKadaluarsa
            .map((map) => map['id'] as String)
            .toList();

        L.i(
          'Ditemukan ${idsUntukDihapus.length} pelanggan diarsipkan kadaluarsa, menghapus permanen...',
        );

        final count = await txn.delete(
          PelangganAktifSkema.tabel,
          where:
              'id IN (${List.filled(idsUntukDihapus.length, '?').join(',')})',
          whereArgs: idsUntukDihapus,
        );

        L.i(
          '$count pelanggan aktif diarsipkan lebih dari 30 hari telah dihapus permanen',
        );
      });

      state = AsyncValue.data(await _ambilSemua());
    } catch (e, stackTrace) {
      L.e(
        'Gagal menghapus permanen pelanggan diarsipkan Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  /// Menghapus semua pelanggan aktif secara permanen.
  Future<void> hapusSemuaPelangganAktif() async {
    try {
      L.i('PERINGATAN: Menghapus SEMUA pelanggan aktif secara permanen');

      final dbHelper = ref.read(databaseHelperProvider);
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete(PelangganAktifSkema.tabel);
        L.i('Semua data di tabel pelanggan_aktif telah dihapus permanen');
      });

      state = AsyncValue.data(await _ambilSemua());

      L.i('Operasi hapus semua pelanggan aktif selesai');
    } catch (e, stackTrace) {
      L.e('Gagal menghapus semua pelanggan aktif Error: $e $stackTrace');
      rethrow;
    }
  }

  /// Mengarsipkan pelanggan kadaluarsa (berakhir sebelum sekarang dan belum diarsipkan).
  Future<int> arsipkanPelangganKadaluarsa() async {
    try {
      L.i('Memeriksa pelanggan kadaluarsa untuk diarsipkan');
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final sekarang = DateTime.now()
          .toUtc(); // Menggunakan UTC untuk konsistensi

      final List<Map<String, dynamic>>
      pelangganKadaluarsa = await operasiSqlite.ambil(
        PelangganAktifSkema.tabel,
        where:
            '${PelangganAktifSkema.tanggalBerakhir} < ? AND ${PelangganAktifSkema.isDeleted} = 0',
        whereArgs: [sekarang.toIso8601String()],
      );

      if (pelangganKadaluarsa.isEmpty) {
        L.i('Tidak ada pelanggan kadaluarsa yang perlu diarsipkan');
        return 0;
      }

      final idsToArchive = pelangganKadaluarsa
          .map((p) => p['id'] as String)
          .toList();
      L.i(
        'Ditemukan ${idsToArchive.length} pelanggan kadaluarsa (berakhir sebelum ${sekarang.toIso8601String()})',
      );

      final now = DateTime.now().toUtc().toIso8601String(); // simpan dalam UTC
      L.i(
        'Menandai ${idsToArchive.length} pelanggan sebagai isDeleted=1, diarsipkan=$now',
      );

      await operasiSqlite.ubah(
        PelangganAktifSkema.tabel,
        {'is_deleted': 1, 'diarsipkan': now, 'diperbarui': now},
        where: 'id IN (${List.filled(idsToArchive.length, '?').join(',')})',
        whereArgs: idsToArchive,
      );

      L.i(
        'Membatalkan notifikasi untuk ${idsToArchive.length} pelanggan kadaluarsa...',
      );
      for (final id in idsToArchive) {
        await _notifikasiServis.batalNotifikasi(id.hashCode);
        await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
        await _notifikasiServis.batalNotifikasi((id.hashCode + 2));
      }

      state = AsyncValue.data(await _ambilSemua());

      L.i('${idsToArchive.length} pelanggan kadaluarsa telah diarsipkan');
      return idsToArchive.length;
    } catch (e, stackTrace) {
      L.e('Gagal mengarsipkan pelanggan kadaluarsa Error: $e $stackTrace');
      rethrow;
    }
  }

  /// Mengarsipkan semua pelanggan aktif.
  Future<int> arsipkanSemuaPelangganAktif() async {
    try {
      L.i('Mengarsipkan SEMUA pelanggan aktif');
      final semuaPelanggan = await ambilSemuaPelangganAktif();

      if (semuaPelanggan.isEmpty) {
        L.i('Tidak ada pelanggan aktif untuk diarsipkan');
        return 0;
      }

      final idsToArchive = semuaPelanggan.map((p) => p.id).toList();
      L.i('Mengarsipkan ${idsToArchive.length} pelanggan aktif');

      final now = DateTime.now().toUtc().toIso8601String(); // simpan dalam UTC
      L.i(
        'Menandai ${idsToArchive.length} pelanggan sebagai isDeleted=1, diarsipkan=$now',
      );

      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.ubah(
        PelangganAktifSkema.tabel,
        {'is_deleted': 1, 'diarsipkan': now, 'diperbarui': now},
        where: 'id IN (${List.filled(idsToArchive.length, '?').join(',')})',
        whereArgs: idsToArchive,
      );

      L.i('Membatalkan notifikasi untuk ${idsToArchive.length} pelanggan...');
      for (final id in idsToArchive) {
        await _notifikasiServis.batalNotifikasi(id.hashCode);
        await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
        await _notifikasiServis.batalNotifikasi((id.hashCode + 2));
      }

      state = AsyncValue.data(await _ambilSemua());

      L.i('${idsToArchive.length} pelanggan aktif telah diarsipkan');
      return idsToArchive.length;
    } catch (e, stackTrace) {
      L.e('Gagal mengarsipkan semua pelanggan aktif Error: $e $stackTrace');
      rethrow;
    }
  }

  /// Mengambil daftar pelanggan aktif berdasarkan daftar ID.
  Future<List<PelangganAktifModel>> getPelangganAktifByIds(
    List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        L.i(
          'getPelangganAktifByIds dipanggil dengan list ID kosong, mengembalikan list kosong',
        );
        return [];
      }

      final operasiSqlite = ref.read(operasiSqliteProvider);
      L.i('Mencari ${ids.length} pelanggan aktif berdasarkan IDs');

      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await operasiSqlite.ambil(
        PelangganAktifSkema.tabel,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      L.i(
        'Ditemukan ${maps.length} dari ${ids.length} pelanggan aktif yang dicari (${ids.length - maps.length} tidak ditemukan)',
      );

      return List.generate(maps.length, (i) {
        return PelangganAktifModel.fromSqlite(maps[i]);
      });
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengambil pelanggan aktif berdasarkan IDs (${ids.length} ID) Error: $e $stackTrace',
      );
      rethrow;
    }
  }
}

/// Kontainer global untuk mengakses [PenggunaAktifNotifier] di luar konteks Riverpod.
final ProviderContainer _penggunaAktifGlobalContainer = ProviderContainer();

PenggunaAktifNotifier get penggunaAktifNotifierGlobal =>
    _penggunaAktifGlobalContainer.read(penggunaAktifProvider.notifier);
