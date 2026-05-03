// path: lib/data/sqlite.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Kelas ini berfungsi sebagai pusat pengelolaan koneksi dan skema database SQLite.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'mydatabase.db');
    return await openDatabase(
      path,
      // diubah: Versi dinaikkan untuk sinkronisasi skema dengan semua model.
      version: 19,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  // diubah: Logika migrasi diperbarui untuk menangani beberapa versi dan skema baru.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrasi yang sudah ada
    if (oldVersion < 15) {
      await db.execute(
        'UPDATE pelanggan_aktif SET sync_status = \'synced\' WHERE sync_status IS NULL',
      );
      await db.execute(
        "ALTER TABLE pelanggan ADD COLUMN status TEXT NOT NULL DEFAULT 'aktif'",
      );
      await db.execute("ALTER TABLE pelanggan ADD COLUMN diarsipkan TEXT");
    }

    if (oldVersion < 16) {
      await db.execute("DROP TABLE IF EXISTS transaksi");
      await _createTransaksiTable(db);
    }

    if (oldVersion < 17) {
      await db.execute("DROP TABLE IF EXISTS transaksi");
      await _createTransaksiTable(db);
    }
    
    if (oldVersion < 18) {
      try {
        await db.execute("ALTER TABLE dompet ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'synced'");
      } catch (e) {
        await _createDompetTable(db);
      }
    }

    // ditambah: Migrasi untuk v19, menambahkan kolom isDeleted dan diarsipkan ke semua tabel yang relevan.
    if (oldVersion < 19) {
      Future<void> addColumn(String table, String columnDefinition) async {
        try {
          await db.execute('ALTER TABLE $table ADD COLUMN $columnDefinition');
        } catch (e) {
          print('Error adding column $columnDefinition to $table: $e');
        }
      }

      // Migrasi untuk setiap tabel
      await addColumn('dompet', 'isDeleted INTEGER NOT NULL DEFAULT 0');
      await addColumn('dompet', 'diarsipkan TEXT');
      await addColumn('kategori', 'isDeleted INTEGER NOT NULL DEFAULT 0');
      await addColumn('kategori', 'diarsipkan TEXT');
      await addColumn('sub_kategori', 'isDeleted INTEGER NOT NULL DEFAULT 0');
      await addColumn('sub_kategori', 'diarsipkan TEXT');
      await addColumn('pesanan', 'status TEXT');
      await addColumn('pesanan', 'diperbarui TEXT');
      await addColumn('pesanan', 'isDeleted INTEGER NOT NULL DEFAULT 0');
      await addColumn('pesanan', 'diarsipkan TEXT');
      await addColumn('paket', 'isDeleted INTEGER NOT NULL DEFAULT 0');
      await addColumn('paket', 'diarsipkan TEXT');
      await addColumn('pelanggan_aktif', 'isDeleted INTEGER NOT NULL DEFAULT 0');
      await addColumn('pelanggan_aktif', 'diarsipkan TEXT');
      await addColumn('transaksi', 'isDeleted INTEGER NOT NULL DEFAULT 0');
      await addColumn('riwayat_langganan', 'isDeleted INTEGER NOT NULL DEFAULT 0');
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

  // diubah: Skema tabel disesuaikan dengan model terbaru.
  Future<void> _createKategoriTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        tipe TEXT NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''');
  }

  // diubah: Skema tabel disesuaikan dengan model terbaru.
  Future<void> _createSubKategoriTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sub_kategori(
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

  // diubah: Skema tabel disesuaikan dengan model terbaru.
  Future<void> _createPaketTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS paket(
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
      CREATE TABLE IF NOT EXISTS pelanggan(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        telepon TEXT NOT NULL,
        alamat TEXT NOT NULL,
        password TEXT NOT NULL,
        mac_address TEXT NOT NULL,
        status TEXT NOT NULL, 
        diperbarui TEXT,      
        diarsipkan TEXT       
      )
    ''');
  }

  // diubah: Skema tabel disesuaikan dengan model terbaru.
  Future<void> _createPelangganAktifTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pelanggan_aktif(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        tanggalMulai TEXT NOT NULL,
        tanggalBerakhir TEXT NOT NULL,
        status TEXT NOT NULL,
        diperbarui TEXT,
        status_sinkronisasi TEXT NOT NULL DEFAULT 'SINKRON',
        sync_status TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  // diubah: Skema tabel disesuaikan dengan model terbaru.
  Future<void> _createTransaksiTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transaksi(
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
        sync_status TEXT NOT NULL DEFAULT 'write',
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // diubah: Skema tabel disesuaikan dengan model terbaru.
  Future<void> _createDompetTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dompet(
        id TEXT PRIMARY KEY,
        namaDompet TEXT NOT NULL,
        saldo REAL NOT NULL,
        diperbarui TEXT,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''');
  }

  Future<void> _createKritikSaranTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kritik_saran(
        id TEXT PRIMARY KEY,
        isi TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        userId TEXT NOT NULL,
        diperbarui TEXT,
        FOREIGN KEY (userId) REFERENCES pelanggan (id) ON DELETE CASCADE
      )
    ''');
  }

  // diubah: Skema tabel disesuaikan dengan model terbaru.
  Future<void> _createRiwayatLanggananTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS riwayat_langganan(
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

  // diubah: Skema tabel disesuaikan dengan model terbaru.
  Future<void> _createPesananTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pesanan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
