// path: lib/data/sqlite.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Kelas ini berfungsi sebagai pusat pengelolaan koneksi dan skema database SQLite.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper.internal();
  static Database? _database;

  DatabaseHelper.internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Menginisialisasi database.
  Future<Database> _initDB() async {
    // untuk testing
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      return await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 25, // diubah: Versi dinaikkan untuk memicu onUpgrade
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    }

    // untuk production
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'mydatabase.db');
    return await openDatabase(
      path,
      version: 25, // diubah: Versi dinaikkan untuk memicu onUpgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createVersiApkUserTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 23) {
      await _createVersiApkUserTable(db);
    }
    if (oldVersion < 24) {
      await db.execute(
        'ALTER TABLE pelanggan ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0',
      );
    }
    // ditambah: Logika migrasi untuk menambahkan kolom baru ke tabel transaksi
    if (oldVersion < 25) {
      await db.execute('ALTER TABLE transaksi ADD COLUMN id_dompet_tujuan TEXT');
      await db.execute('ALTER TABLE transaksi ADD COLUMN nama_dompet_tujuan TEXT');
    }
  }

  Future<void> _createTables(Database db) async {
    await _createKategoriTable(db);
    await _createSubKategoriTable(db);
    await _createPaketTable(db);
    await _createPelangganTable(db);
    await _createPelangganAktifTable(db);
    await _createTransaksiTable(db);
    await _createDompetTable(db);
    await _createKritikSaranTable(db);
    await _createRiwayatLanggananTable(db);
    await _createPesananTable(db);
  }

  Future<void> _createVersiApkUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE versi_apk_user(
        id TEXT PRIMARY KEY,
        catatan_rilis TEXT NOT NULL,
        nomor_build_terbaru TEXT NOT NULL,
        tautan_unduhan TEXT NOT NULL,
        versi_terbaru TEXT NOT NULL,
        wajib_update INTEGER NOT NULL,
        youtube_tutorial TEXT NOT NULL,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        diperbarui TEXT
      )
    ''');
  }

  Future<void> _createKategoriTable(Database db) async {
    await db.execute('''
      CREATE TABLE kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        tipe TEXT NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''');
  }

  Future<void> _createSubKategoriTable(Database db) async {
    await db.execute('''
      CREATE TABLE sub_kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        id_kategori TEXT NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_kategori) REFERENCES kategori (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createPaketTable(Database db) async {
    await db.execute('''
      CREATE TABLE paket(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        harga INTEGER NOT NULL,
        durasi INTEGER NOT NULL,
        tipe TEXT NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''');
  }

  Future<void> _createPelangganTable(Database db) async {
    await db.execute('''
      CREATE TABLE pelanggan(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        telepon TEXT NOT NULL,
        alamat TEXT NOT NULL,
        password TEXT NOT NULL,
        mac_address TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'aktif', 
        diperbarui TEXT,      
        diarsipkan TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0       
      )
    ''');
  }

  Future<void> _createPelangganAktifTable(Database db) async {
    await db.execute('''
      CREATE TABLE pelanggan_aktif(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        tanggalMulai TEXT NOT NULL,
        tanggalBerakhir TEXT NOT NULL,
        status TEXT NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  Future<void> _createTransaksiTable(Database db) async {
    await db.execute('''
      CREATE TABLE transaksi(
        id TEXT PRIMARY KEY,
        keterangan TEXT NOT NULL,
        jumlah REAL NOT NULL,
        tanggal TEXT NOT NULL,
        tipe TEXT NOT NULL,
        id_dompet TEXT,
        nama_dompet TEXT,
        id_kategori TEXT,
        nama_kategori TEXT,
        id_sub_kategori TEXT,
        nama_sub_kategori TEXT,
        id_pelanggan TEXT,
        nama_pelanggan TEXT,
        id_paket TEXT,
        nama_paket TEXT,
        diperbarui TEXT,
        diarsipkan TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createDompetTable(Database db) async {
    await db.execute('''
      CREATE TABLE dompet(
        id TEXT PRIMARY KEY,
        namaDompet TEXT NOT NULL,
        saldo REAL NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''');
  }

  Future<void> _createKritikSaranTable(Database db) async {
    await db.execute('''
      CREATE TABLE kritik_saran(
        id TEXT PRIMARY KEY,
        isi TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        userId TEXT NOT NULL,
        diperbarui TEXT,
        FOREIGN KEY (userId) REFERENCES pelanggan (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createRiwayatLanggananTable(Database db) async {
    await db.execute('''
      CREATE TABLE riwayat_langganan(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        nama_paket TEXT NOT NULL,
        harga_paket INTEGER NOT NULL,
        durasi_paket INTEGER NOT NULL,
        tipe_durasi_paket TEXT NOT NULL,
        tanggal_mulai TEXT NOT NULL,
        tanggal_berakhir TEXT NOT NULL,
        status TEXT NOT NULL,
        diperbarui TEXT,
        diarsipkan TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createPesananTable(Database db) async {
    await db.execute('''
      CREATE TABLE pesanan(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        status TEXT,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE
      )
    ''');
  }
}