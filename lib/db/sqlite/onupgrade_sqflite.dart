// path: lib/db/sqlite/onupgrade_sqflite.dart

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
      'Berhasil menambahkan kolom `$columnName` ke tabel `$tableName`.',
    );
  } else {
    L.i(
      'Kolom `$columnName` sudah ada di tabel `$tableName`, dilewati.',
    );
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
      await _renameColumnIfNecessary(db, 'dompet', 'namaDompet', 'nama_dompet');
      await _renameColumnIfNecessary(db, 'dompet', 'isDeleted', 'is_deleted');

      await _renameColumnIfNecessary(db, 'paket', 'jumlahPoin', 'jumlah_poin');
      await _renameColumnIfNecessary(db, 'paket', 'isDeleted', 'is_deleted');
      await _renameColumnIfNecessary(db, 'paket', 'isPublic', 'is_public');

      await _renameColumnIfNecessary(db, 'pelanggan', 'isDeleted', 'is_deleted');

      await _renameColumnIfNecessary(db, 'pelanggan_aktif', 'isDeleted', 'is_deleted');

      await _renameColumnIfNecessary(db, 'transaksi', 'isDeleted', 'is_deleted');

      await _renameColumnIfNecessary(db, 'kategori', 'isDeleted', 'is_deleted');

      await _renameColumnIfNecessary(db, 'sub_kategori', 'isDeleted', 'is_deleted');

      await _renameColumnIfNecessary(db, 'versi_apk_user', 'isDeleted', 'is_deleted');

      await _renameColumnIfNecessary(db, 'pesanan', 'isDeleted', 'is_deleted');

      await _renameColumnIfNecessary(db, 'kritik_saran', 'userId', 'user_id');
    }

    // Versi 31: Tambah kolom tanggal_mulai dan tanggal_berakhir ke pelanggan_aktif
    if (oldVersion < 32) {
      await _addColumnIfNotExists(
        db,
        'pelanggan_aktif',
        'tanggal_mulai',
        'TEXT',
      );
      await _addColumnIfNotExists(
        db,
        'pelanggan_aktif',
        'tanggal_berakhir',
        'TEXT',
      );
    }

    // Versi 32-44: (versi kosong - tidak ada perubahan skema, hanya peningkatan versi)
    // Tambahkan blok if (oldVersion < N) di sini untuk migrasi masa depan.

    L.i('Upgrade database selesai dari versi $oldVersion ke $newVersion');
  } catch (e, st) {
    L.e('Gagal upgrade database dari versi $oldVersion ke $newVersion: $e $st');
    rethrow;
  }
}
