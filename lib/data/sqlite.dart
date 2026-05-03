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
      version: 18, // diubah: Versi dinaikkan untuk sinkronisasi model Dompet
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
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

    // ditambah: Migrasi untuk mengubah sync_status menjadi TEXT
    if (oldVersion < 17) {
      await db.execute("DROP TABLE IF EXISTS transaksi");
      await _createTransaksiTable(db);
    }
    
    // ditambah: Migrasi untuk menambahkan kolom sync_status ke tabel dompet
    if (oldVersion < 18) {
      try {
        await db.execute("ALTER TABLE dompet ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'synced'");
      } catch (e) {
        // Jika gagal (misalnya, tabel belum ada), buat ulang tabel
        await _createDompetTable(db);
      }
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

  // ... (metode pembuatan tabel lainnya tidak berubah)

  Future<void> _createKategoriTable(Database db) async {
    await db.execute('''
      CREATE TABLE kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        tipe TEXT NOT NULL,
        diperbarui TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSubKategoriTable(Database db) async {
    await db.execute('''
      CREATE TABLE sub_kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        id_kategori TEXT NOT NULL,
        diperbarui TEXT NOT NULL,
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
        diperbarui TEXT NOT NULL
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
        status TEXT NOT NULL, 
        diperbarui TEXT,      
        diarsipkan TEXT       
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
        diperbarui TEXT NOT NULL,
        status_sinkronisasi TEXT NOT NULL DEFAULT 'SINKRON',
        sync_status TEXT NOT NULL DEFAULT 'synced',
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  // diubah: Menggunakan TEXT untuk sync_status
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
        sync_status TEXT NOT NULL DEFAULT 'write'
      )
    ''');
  }

  Future<void> _createDompetTable(Database db) async {
    await db.execute('''
      CREATE TABLE dompet(
        id TEXT PRIMARY KEY,
        namaDompet TEXT NOT NULL,
        saldo REAL NOT NULL,
        diperbarui TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced'
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
        diperbarui TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES pelanggan (id) ON DELETE CASCADE
      )
    ''');
  }

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
          FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE
        )
    ''');
  }

  Future<void> _createPesananTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pesanan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE
      )
    ''');
  }
}
