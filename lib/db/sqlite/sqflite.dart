// path: lib/db/sqlite/sqflite.dart

import 'dart:io' if (dart.library.js_interop) 'io_stub.dart';

import 'package:admin_wifi/db/sqlite/oncreate_sqflite.dart';
import 'package:admin_wifi/db/sqlite/onupgrade_sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.js_interop) 'sqflite_ffi_stub.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // dinaikkan ke 45 untuk menambahkan kolom poin_awal ke tabel pelanggan
  static const int _databaseVersion = 45;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    try {
      _database = await _initDB();
      return _database!;
    } catch (e, st) {
      L.e('Gagal total mendapatkan instance database. Error: $e $st');
      rethrow;
    }
  }

  Future<Database> _initDB() async {
    try {
      if (kIsWeb) {
        // sqflite_common_ffi_web diinisialisasi di main() (kIsWeb);
        // di web, path database hanyalah nama (disimpan di IndexedDB).
        return await openDatabase(
          'mydatabase.db',
          version: _databaseVersion,
          onCreate: onCreateSqflite,
          onUpgrade: onUpgradeSqflite,
        );
      }
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        return await databaseFactory.openDatabase(
          ':memory:',
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: onCreateSqflite,
            onUpgrade: onUpgradeSqflite,
          ),
        );
      }

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'mydatabase.db');
      L.i('Path database: $path');

      L.i('Membuka database dengan versi $_databaseVersion...');
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: onCreateSqflite,
        onUpgrade: onUpgradeSqflite,
      );
    } catch (e, st) {
      L.e('Gagal membuka atau membuat database. Error: $e $st');
      rethrow;
    }
  }

  /// Delegasi ke `onCreateSqflite` — dipertahankan agar pemanggil lama
  /// (mis. `DatabaseHelper.instance.createTables(db, 1)` pada test) tetap jalan.
  Future<void> createTables(Database db, int version) async {
    await onCreateSqflite(db, version);
  }
}
