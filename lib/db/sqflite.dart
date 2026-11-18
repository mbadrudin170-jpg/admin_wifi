// path: lib/db/sqflite.dart

import 'dart:io';

import 'package:admin_wifi/db/oncreate_sqflite.dart';
import 'package:admin_wifi/db/onupgrade_sqflite.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // dinaikkan ke 43 untuk memaksa migrasi ulang yang aman dan idempoten
  static const int _databaseVersion = 43;

  DatabaseHelper._internal() {
    Log.info('DatabaseHelper instance dibuat (singleton _internal).');
  }

  Future<Database> get database async {
    Log.info('Memulai proses akses properti database getter.');
    if (_database != null) {
      Log.info('Instance database sudah ada di memori, mengembalikan...');
      return _database!;
    }

    Log.info('Instance database belum ada, memanggil _initDB().');
    try {
      _database = await _initDB();
      Log.info('Database berhasil diinisialisasi dan di-cache.');
      return _database!;
    } catch (e, st) {
      Log.error(
        'Gagal total mendapatkan instance database.',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<Database> _initDB() async {
    Log.info('Memulai inisialisasi database (_initDB).');
    try {
      if (kIsWeb) {
        // sqflite_common_ffi_web diinisialisasi di main() (kIsWeb);
        // di web, path database hanyalah nama (disimpan di IndexedDB).
        Log.info('Mode Web terdeteksi. Menggunakan database Web (IndexedDB).');
        return await openDatabase(
          'mydatabase.db',
          version: _databaseVersion,
          onCreate: onCreateSqflite,
          onUpgrade: onUpgradeSqflite,
        );
      }
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        Log.info('Mode TEST terdeteksi. Menggunakan database in-memory.');
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        return await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: onCreateSqflite,
            onUpgrade: onUpgradeSqflite,
          ),
        );
      }

      Log.info('Mode PRODUKSI/DEBUG. Menggunakan database fisik.');
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'mydatabase.db');
      Log.info('Path database: $path');

      Log.info('Membuka database dengan versi $_databaseVersion...');
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: onCreateSqflite,
        onUpgrade: onUpgradeSqflite,
      );
    } catch (e, st) {
      Log.error(
        'Gagal membuka atau membuat database.',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Delegasi ke `onCreateSqflite` — dipertahankan agar pemanggil lama
  /// (mis. `DatabaseHelper.instance.createTables(db, 1)` pada test) tetap jalan.
  Future<void> createTables(Database db, int version) async {
    await onCreateSqflite(db, version);
  }
}
