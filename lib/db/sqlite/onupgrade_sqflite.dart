// path: lib/db/onupgrade_sqflite.dart

import 'package:share_global_saya/src/utils/l.dart';
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
    L.i(
      '[MIGRASI SUKSES] Berhasil menambahkan kolom `$columnName` ke tabel `$tableName`.',
    );
  } else {
    L.i(
      '[MIGRASI DILEWATI] Kolom `$columnName` sudah ada di tabel `$tableName`.',
    );
  }
}

Future<void> onUpgradeSqflite(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  L.i('========================================');
  L.i('MEMULAI PROSES UPGRADE DATABASE (IDEMPOTEN)');
  L.i('Versi database lama: $oldVersion');
  L.i('Versi database baru: $newVersion');
  L.i('========================================');

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

    L.i('========================================');
    L.i('PROSES UPGRADE DATABASE SELESAI');
    L.i(
      'Database berhasil diupgrade dari versi $oldVersion ke versi $newVersion.',
    );
    L.i('========================================');
  } catch (e, st) {
    L.e(
      'Gagal melakukan upgrade database dari versi $oldVersion ke versi $newVersion. Error: $e $st',
    );
    rethrow;
  }
}
