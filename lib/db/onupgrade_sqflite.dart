// path: lib/db/onupgrade_sqflite.dart

import 'package:admin_wifi/debug/log.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
    Log.info(
      '[MIGRASI SUKSES] Berhasil menambahkan kolom `$columnName` ke tabel `$tableName`.',
    );
  } else {
    Log.info(
      '[MIGRASI DILEWATI] Kolom `$columnName` sudah ada di tabel `$tableName`.',
    );
  }
}

Future<void> onUpgradeSqflite(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  Log.info('========================================');
  Log.info('MEMULAI PROSES UPGRADE DATABASE (IDEMPOTEN)');
  Log.info('Versi database lama: $oldVersion');
  Log.info('Versi database baru: $newVersion');
  Log.info('========================================');

  try {
    // Pendekatan idempoten: pastikan semua kolom yang diperlukan ada,
    // tanpa mempedulikan versi lama secara spesifik.
    // Ini menyelesaikan masalah migrasi yang terjebak atau tidak lengkap.
    await _addColumnIfNotExists(
      db,
      'pelanggan_aktif',
      'tanggal_berakhir',
      'TEXT',
    );
    await _addColumnIfNotExists(db, 'pelanggan_aktif', 'tanggal_mulai', 'TEXT');

    // Tambahkan pengecekan kolom lain di masa depan di sini jika perlu.

    Log.info('========================================');
    Log.info('PROSES UPGRADE DATABASE SELESAI');
    Log.info(
      'Database berhasil diupgrade dari versi $oldVersion ke versi $newVersion.',
    );
    Log.info('========================================');
  } catch (e, st) {
    Log.error(
      'Gagal melakukan upgrade database dari versi $oldVersion ke versi $newVersion.',
      error: e,
      stackTrace: st,
    );
    rethrow;
  }
}
