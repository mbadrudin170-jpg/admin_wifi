// path: lib/data/operasi/pelanggan_aktif_operasi.dart
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';

import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/services/notifikasi/notifikasi_servis.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/whatsapp/info_paket.dart';

const uuid = Uuid();

class PelangganAktifOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();
  late final NotifikasiServis notifikasiServis;
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  PelangganAktifOperasi({NotifikasiServis? notifikasiServis}) {
    this.notifikasiServis = notifikasiServis ?? NotifikasiServis();
    developer.log(
      '🔧 [LOKAL] PelangganAktifOperasi diinisialisasi.',
      name: 'PelangganAktifOperasi',
    );
  }

  Future<PelangganAktifModel> createPelangganAktif(
    PelangganAktifModel pelangganAktif,
  ) async {
    try {
      final pelangganUntukDisimpan = pelangganAktif.copyWith(
        id: pelangganAktif.id.isEmpty ? uuid.v4() : pelangganAktif.id,
        diperbarui: DateTime.now(),
      );

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final data = pelangganUntukDisimpan.toSqlite();
        developer.log(
          '📝 [LOKAL] Mencoba membuat pelanggan aktif dengan ID: ${pelangganUntukDisimpan.id}',
          name: 'PelangganAktifOperasi',
        );

        await txn.insert(
          'pelanggan_aktif',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await _jadwalkanNotifikasi(pelangganUntukDisimpan);
        await PesanInfoPaket.kirimRincianPaket(pelangganUntukDisimpan);
      });

      developer.log(
        '✅ [LOKAL] Pelanggan aktif (ID: ${pelangganUntukDisimpan.id}) berhasil dibuat.',
        name: 'PelangganAktifOperasi',
      );

      return pelangganUntukDisimpan;
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal membuat pelanggan aktif. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<PelangganAktifModel>> ambilSemuaPelangganAktif() async {
    try {
      final db = await dbHelper.database;

      developer.log(
        '🔍 [LOKAL] Mengambil semua pelanggan aktif (isDeleted = 0)',
        name: 'PelangganAktifOperasi',
      );

      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan_aktif',
        where: 'isDeleted = ?',
        whereArgs: [0],
      );

      developer.log(
        '✅ [LOKAL] Berhasil mengambil ${maps.length} pelanggan aktif.',
        name: 'PelangganAktifOperasi',
      );

      return List.generate(
        maps.length,
        (i) => PelangganAktifModel.fromSqlite(maps[i]),
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal mengambil semua pelanggan aktif. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<PelangganAktifModel?> ambilSatuPelangganAktif(String id) async {
    try {
      final db = await dbHelper.database;

      developer.log(
        '🔍 [LOKAL] Mencari pelanggan aktif dengan ID: $id',
        name: 'PelangganAktifOperasi',
      );

      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan_aktif',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        developer.log(
          '✅ [LOKAL] Pelanggan aktif dengan ID: $id ditemukan.',
          name: 'PelangganAktifOperasi',
        );
        return PelangganAktifModel.fromSqlite(maps.first);
      }

      developer.log(
        '⚠️ [LOKAL] Pelanggan aktif dengan ID: $id tidak ditemukan.',
        name: 'PelangganAktifOperasi',
      );
      return null;
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal mengambil pelanggan aktif dengan ID: $id. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updatePelangganAktif(PelangganAktifModel pelangganAktif) async {
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final data = pelangganAktif.toSqlite();

        developer.log(
          '📝 [LOKAL] Memperbarui pelanggan aktif dengan ID: ${pelangganAktif.id}',
          name: 'PelangganAktifOperasi',
        );

        await txn.update(
          'pelanggan_aktif',
          data,
          where: 'id = ?',
          whereArgs: [pelangganAktif.id],
        );

        await _jadwalkanNotifikasi(pelangganAktif);
        await PesanInfoPaket.kirimRincianPaket(pelangganAktif);
      });

      developer.log(
        '✅ [LOKAL] Pelanggan aktif (ID: ${pelangganAktif.id}) berhasil diperbarui.',
        name: 'PelangganAktifOperasi',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal memperbarui pelanggan aktif (ID: ${pelangganAktif.id}). Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _jadwalkanNotifikasi(PelangganAktifModel pelangganAktif) async {
    try {
      developer.log(
        '🔔 [LOKAL] Menjadwalkan notifikasi untuk pelanggan aktif (ID: ${pelangganAktif.id})',
        name: 'PelangganAktifOperasi',
      );

      final pelanggan = await _pelangganOperasi.getPelangganById(
        pelangganAktif.idPelanggan,
      );
      final namaPelanggan = pelanggan?.nama ?? 'Tanpa Nama';

      // Batalkan notifikasi lama (ID HashCode dasar, +1, dan +2 untuk yang baru)
      await notifikasiServis.batalNotifikasi(pelangganAktif.id.hashCode);
      await notifikasiServis.batalNotifikasi((pelangganAktif.id.hashCode + 1));
      await notifikasiServis.batalNotifikasi(
        (pelangganAktif.id.hashCode + 2), 
      ); 

      // --- 1. NOTIFIKASI TEPAT SAAT BERAKHIR (Paling Penting) ---
      final jadwalTepatWaktu = pelangganAktif.tanggalBerakhir;
      if (jadwalTepatWaktu.isAfter(DateTime.now())) {
        await notifikasiServis.jadwalNotifikasi(
          id:
              (pelangganAktif.id.hashCode +
              2), // Gunakan offset +2 agar tidak bentrok
          title: 'Masa Aktif Habis!',
          body: 'Paket WiFi untuk $namaPelanggan telah berakhir sekarang.',
          jadwal: jadwalTepatWaktu,
        );
        developer.log(
          '✅ [LOKAL] Notifikasi TEPAT WAKTU dijadwalkan untuk ${jadwalTepatWaktu.toIso8601String()}',
          name: 'PelangganAktifOperasi',
        );
      } else {
        developer.log(
          '⏭️ [LOKAL] Notifikasi tepat waktu dilewati karena sudah kadaluarsa.',
          name: 'PelangganAktifOperasi',
        );
      }

      // --- 2. NOTIFIKASI H-1 ---
      final jadwalNotifikasiH1 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 1),
      );
      if (jadwalNotifikasiH1.isAfter(DateTime.now())) {
        await notifikasiServis.jadwalNotifikasi(
          id: pelangganAktif.id.hashCode,
          title: 'Paket Akan Segera Berakhir',
          body: 'Paket untuk pelanggan $namaPelanggan akan berakhir besok.',
          jadwal: jadwalNotifikasiH1,
        );
        developer.log(
          '✅ [LOKAL] Notifikasi H-1 dijadwalkan.',
          name: 'PelangganAktifOperasi',
        );
      }

      // --- 3. NOTIFIKASI H-3 ---
      final jadwalNotifikasiH3 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 3),
      );
      if (jadwalNotifikasiH3.isAfter(DateTime.now())) {
        await notifikasiServis.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 1),
          title: 'Pengingat Paket',
          body:
              'Paket untuk pelanggan $namaPelanggan akan berakhir dalam 3 hari.',
          jadwal: jadwalNotifikasiH3,
        );
        developer.log(
          '✅ [LOKAL] Notifikasi H-3 dijadwalkan.',
          name: 'PelangganAktifOperasi',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal menjadwalkan notifikasi. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<PelangganAktifModel> items,
  ) async {
    try {
      developer.log(
        '📦 [LOKAL] Memproses batch ${items.length} pelanggan aktif.',
        name: 'PelangganAktifOperasi',
      );
      final data = items.map((item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch('pelanggan_aktif', data);

      developer.log(
        '✅ [LOKAL] Batch ${items.length} pelanggan aktif berhasil diproses.',
        name: 'PelangganAktifOperasi',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal memproses batch pelanggan aktif. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> arsipkanPelangganAktif(String id) async {
    try {
      developer.log(
        '📦 [LOKAL] Mencoba mengarsipkan pelanggan aktif dengan ID: $id',
        name: 'PelangganAktifOperasi',
      );

      final pelangganAktif = await ambilSatuPelangganAktif(id);
      if (pelangganAktif == null) {
        developer.log(
          '⚠️ [LOKAL] Pelanggan aktif dengan ID: $id tidak ditemukan untuk diarsipkan.',
          name: 'PelangganAktifOperasi',
        );
        return;
      }

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final pelangganDiarsipkan = pelangganAktif.copyWith(
          isDeleted: true,
          diarsipkan: DateTime.now(),
        );

        await txn.update(
          'pelanggan_aktif',
          pelangganDiarsipkan.toSqlite(),
          where: 'id = ?',
          whereArgs: [id],
        );

        await notifikasiServis.batalNotifikasi(id.hashCode);
        await notifikasiServis.batalNotifikasi((id.hashCode + 1));
        await notifikasiServis.batalNotifikasi((id.hashCode + 2));
      });

      developer.log(
        '✅ [LOKAL] Pelanggan aktif (ID: $id) berhasil diarsipkan.',
        name: 'PelangganAktifOperasi',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal mengarsipkan pelanggan aktif (ID: $id). Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> hapusPermanenPelangganYangDiArsipkan() async {
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final batasWaktu = DateTime.now().subtract(const Duration(days: 30));

        developer.log(
          '🧹 [LOKAL] Mencari pelanggan diarsipkan sebelum ${batasWaktu.toIso8601String()}',
          name: 'PelangganAktifOperasi',
        );

        final List<Map<String, dynamic>> pelangganKadaluarsa = await txn.query(
          'pelanggan_aktif',
          where: 'diarsipkan IS NOT NULL AND diarsipkan < ?',
          whereArgs: [batasWaktu.toIso8601String()],
        );

        if (pelangganKadaluarsa.isEmpty) {
          developer.log(
            'ℹ️ [LOKAL] Tidak ada pelanggan aktif yang diarsipkan lebih dari 30 hari untuk dihapus.',
            name: 'PelangganAktifOperasi',
          );
          return;
        }

        final idsUntukDihapus = pelangganKadaluarsa
            .map((map) => map['id'] as String)
            .toList();

        developer.log(
          '🗑️ [LOKAL] Menghapus ${idsUntukDihapus.length} pelanggan diarsipkan.',
          name: 'PelangganAktifOperasi',
        );

        final count = await txn.delete(
          'pelanggan_aktif',
          where: 'id IN (${List.filled(idsUntukDihapus.length, '?').join(',')})',
          whereArgs: idsUntukDihapus,
        );

        developer.log(
          '🧹 [LOKAL] $count pelanggan aktif yang diarsipkan lebih dari 30 hari telah dihapus permanen.',
          name: 'PelangganAktifOperasi',
        );
      });
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal menghapus permanen pelanggan diarsipkan. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> hapusSemuaPelangganAktif() async {
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        developer.log(
          '⚠️ [LOKAL] Menghapus SEMUA pelanggan aktif secara permanen!',
          name: 'PelangganAktifOperasi',
        );

        await txn.delete('pelanggan_aktif');

        developer.log(
          '🗑️ [LOKAL] Semua pelanggan aktif telah dihapus permanen.',
          name: 'PelangganAktifOperasi',
        );
      });
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal menghapus semua pelanggan aktif. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<int> arsipkanPelangganKadaluarsa() async {
    try {
      developer.log(
        '🔍 [LOKAL] Memeriksa pelanggan kadaluarsa untuk diarsipkan.',
        name: 'PelangganAktifOperasi',
      );
      final db = await dbHelper.database;
      final sekarang = DateTime.now();

      final List<Map<String, dynamic>> pelangganKadaluarsa = await db.query(
        'pelanggan_aktif',
        where: 'tanggal_berakhir < ? AND isDeleted = 0',
        whereArgs: [sekarang.toIso8601String()],
      );

      if (pelangganKadaluarsa.isEmpty) {
        developer.log(
          'ℹ️ [LOKAL] Tidak ada pelanggan kadaluarsa untuk diarsipkan.',
          name: 'PelangganAktifOperasi',
        );
        return 0;
      }

      final idsToArchive = pelangganKadaluarsa.map((p) => p['id'] as String).toList();

      developer.log(
        '📦 [LOKAL] Ditemukan ${idsToArchive.length} pelanggan kadaluarsa. Mulai mengarsipkan...',
        name: 'PelangganAktifOperasi',
      );

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final now = DateTime.now().toIso8601String();
        await txn.update(
          'pelanggan_aktif',
          {'isDeleted': 1, 'diarsipkan': now, 'diperbarui': now},
          where: 'id IN (${List.filled(idsToArchive.length, '?').join(',')})',
          whereArgs: idsToArchive,
        );

        for (final id in idsToArchive) {
          await notifikasiServis.batalNotifikasi(id.hashCode);
          await notifikasiServis.batalNotifikasi((id.hashCode + 1));
          await notifikasiServis.batalNotifikasi((id.hashCode + 2));
        }
      });

      developer.log(
        '🗂️ [LOKAL] ${idsToArchive.length} pelanggan kadaluarsa telah diarsipkan.',
        name: 'PelangganAktifOperasi',
      );

      return idsToArchive.length;
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal mengarsipkan pelanggan kadaluarsa. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<int> arsipkanSemuaPelangganAktif() async {
    try {
      developer.log(
        '📦 [LOKAL] Mengarsipkan semua pelanggan aktif.',
        name: 'PelangganAktifOperasi',
      );

      final semuaPelanggan = await ambilSemuaPelangganAktif();

      if (semuaPelanggan.isEmpty) {
        developer.log(
          'ℹ️ [LOKAL] Tidak ada pelanggan aktif untuk diarsipkan.',
          name: 'PelangganAktifOperasi',
        );
        return 0;
      }

      final idsToArchive = semuaPelanggan.map((p) => p.id).toList();

      developer.log(
        '📊 [LOKAL] Mengarsipkan ${idsToArchive.length} pelanggan aktif...',
        name: 'PelangganAktifOperasi',
      );

      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final now = DateTime.now().toIso8601String();
        await txn.update(
          'pelanggan_aktif',
          {'isDeleted': 1, 'diarsipkan': now, 'diperbarui': now},
          where: 'id IN (${List.filled(idsToArchive.length, '?').join(',')})',
          whereArgs: idsToArchive,
        );

        for (final id in idsToArchive) {
          await notifikasiServis.batalNotifikasi(id.hashCode);
          await notifikasiServis.batalNotifikasi((id.hashCode + 1));
          await notifikasiServis.batalNotifikasi((id.hashCode + 2));
        }
      });

      developer.log(
        '🗂️ [LOKAL] ${idsToArchive.length} pelanggan aktif telah diarsipkan.',
        name: 'PelangganAktifOperasi',
      );

      return idsToArchive.length;
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal mengarsipkan semua pelanggan aktif. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<PelangganAktifModel>> getPelangganAktifByIds(
    List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        developer.log(
          'ℹ️ [LOKAL] getPelangganAktifByIds dipanggil dengan list ID kosong.',
          name: 'PelangganAktifOperasi',
        );
        return [];
      }

      final db = await dbHelper.database;

      developer.log(
        '🔍 [LOKAL] Mencari ${ids.length} pelanggan aktif berdasarkan IDs.',
        name: 'PelangganAktifOperasi',
      );

      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan_aktif',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      developer.log(
        '✅ [LOKAL] Ditemukan ${maps.length} dari ${ids.length} pelanggan aktif yang dicari.',
        name: 'PelangganAktifOperasi',
      );

      return List.generate(maps.length, (i) {
        return PelangganAktifModel.fromSqlite(maps[i]);
      });
    } catch (e, stackTrace) {
      developer.log(
        '❌ [LOKAL] Gagal mengambil pelanggan aktif berdasarkan IDs. Error: $e',
        name: 'PelangganAktifOperasi',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
