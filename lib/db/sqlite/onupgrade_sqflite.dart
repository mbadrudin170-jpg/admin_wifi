// path: lib/db/sqlite/onupgrade_sqflite.dart

import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:share_global_saya/src/utils/l.dart';

/// Fungsi utilitas aman untuk menambahkan kolom jika belum ada.
/// Mencegah error 'duplicate column'.
Future<void> _addColumnIfNotExists(
  Database db,
  String tableName,
  String columnName,
  String columnType,
) async {
  final dbClient = db;
  final List<Map<String, dynamic>> tableInfo = await dbClient.rawQuery(
    'PRAGMA table_info($tableName)',
  );
  bool columnExists = tableInfo.any((column) => column['name'] == columnName);

  if (!columnExists) {
    await dbClient.execute(
      'ALTER TABLE $tableName ADD COLUMN $columnName $columnType',
    );
    L.i('Berhasil menambahkan kolom `$columnName` ke tabel `$tableName`.');
  } else {
    L.i('Kolom `$columnName` sudah ada di tabel `$tableName`, dilewati.');
  }
}

/// Utilitas aman untuk mengganti nama kolom (camelCase -> snake_case) bila
/// kolom lama ada dan kolom baru belum ada.
Future<void> _renameColumnIfNecessary(
  Database db,
  String tableName,
  String oldColumnName,
  String newColumnName,
) async {
  final List<Map<String, dynamic>> tableInfo = await db.rawQuery(
    'PRAGMA table_info($tableName)',
  );
  final bool oldExists = tableInfo.any(
    (column) => column['name'] == oldColumnName,
  );
  final bool newExists = tableInfo.any(
    (column) => column['name'] == newColumnName,
  );

  if (oldExists && !newExists) {
    await db.execute(
      'ALTER TABLE $tableName RENAME COLUMN $oldColumnName TO $newColumnName',
    );
    L.i(
      'Kolom `$oldColumnName` pada tabel `$tableName` diganti menjadi `$newColumnName`.',
    );
  } else {
    L.i(
      'Kolom `$newColumnName` sudah ada atau `$oldColumnName` tidak ditemukan pada tabel `$tableName`, dilewati.',
    );
  }
}

Future<void> onUpgradeSqflite(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  L.i('Memulai upgrade database dari versi $oldVersion ke $newVersion');

  try {
    // Versi 1-30: Migrasi kolom camelCase ke snake_case
    if (oldVersion < 31) {
      await _renameColumnIfNecessary(
        db,
        DompetSkema.tabel,
        'namaDompet',
        DompetSkema.namaDompet,
      );
      await _renameColumnIfNecessary(
        db,
        DompetSkema.tabel,
        'isDeleted',
        DompetSkema.isDeleted,
      );

      await _renameColumnIfNecessary(
        db,
        PaketSkema.tabel,
        'jumlahPoin',
        PaketSkema.jumlahPoin,
      );
      await _renameColumnIfNecessary(
        db,
        PaketSkema.tabel,
        'isDeleted',
        PaketSkema.isDeleted,
      );
      await _renameColumnIfNecessary(
        db,
        PaketSkema.tabel,
        'isPublic',
        PaketSkema.isPublic,
      );

      await _renameColumnIfNecessary(
        db,
        PelangganSkema.tabel,
        'isDeleted',
        PelangganSkema.isDeleted,
      );

      await _renameColumnIfNecessary(
        db,
        PelangganAktifSkema.tabel,
        'isDeleted',
        PelangganAktifSkema.isDeleted,
      );

      await _renameColumnIfNecessary(
        db,
        TransaksiSkema.tabel,
        'isDeleted',
        TransaksiSkema.isDeleted,
      );

      await _renameColumnIfNecessary(
        db,
        KategoriSkema.tabel,
        'isDeleted',
        KategoriSkema.isDeleted,
      );

      await _renameColumnIfNecessary(
        db,
        SubKategoriSkema.tabel,
        'isDeleted',
        SubKategoriSkema.isDeleted,
      );

      await _renameColumnIfNecessary(
        db,
        VersiApkUserSkema.tabel,
        'isDeleted',
        VersiApkUserSkema.isDeleted,
      );

      await _renameColumnIfNecessary(
        db,
        PesananSkema.tabel,
        'isDeleted',
        PesananSkema.isDeleted,
      );

      await _renameColumnIfNecessary(
        db,
        KritikSaranSkema.tabel,
        'userId',
        KritikSaranSkema.userId,
      );
    }

    // Versi 31: Tambah kolom tanggal_mulai dan tanggal_berakhir ke pelanggan_aktif
    if (oldVersion < 32) {
      await _addColumnIfNotExists(
        db,
        PelangganAktifSkema.tabel,
        PelangganAktifSkema.tanggalMulai,
        'TEXT',
      );
      await _addColumnIfNotExists(
        db,
        PelangganAktifSkema.tabel,
        PelangganAktifSkema.tanggalBerakhir,
        'TEXT',
      );
    }

    // Versi 45: Tambah kolom poin_awal ke pelanggan
    if (oldVersion < 45) {
      await _addColumnIfNotExists(
        db,
        PelangganSkema.tabel,
        PelangganSkema.poinAwal,
        'REAL NOT NULL DEFAULT 0',
      );
    }

    L.i('Upgrade database selesai dari versi $oldVersion ke $newVersion');
  } catch (e, st) {
    L.e('Gagal upgrade database dari versi $oldVersion ke $newVersion: $e $st');
    rethrow;
  }
}
