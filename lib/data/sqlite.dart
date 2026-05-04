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

  // Menginisialisasi database.
  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'mydatabase.db');
    return await openDatabase(
      path,
      // diubah: Versi dinaikkan ke 22 untuk migrasi ke ID berbasis UUID (String).
      version: 22,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Membuat tabel saat database pertama kali dibuat.
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  // Menangani migrasi database saat versi berubah.
  // diubah: Logika onUpgrade disederhanakan. Saat ada perubahan skema besar seperti ini,
  // membuat ulang tabel adalah cara paling bersih untuk memastikan konsistensi.
  // PERHATIAN: Ini akan menghapus semua data yang ada saat upgrade.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 22) {
      // Hapus semua tabel lama
      await _dropAllTables(db);
      // Buat ulang semua tabel dengan skema baru
      await _createTables(db);
    }
  }
  
  // diubah: Menghapus semua tabel yang ada
  Future<void> _dropAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS kategori');
    await db.execute('DROP TABLE IF EXISTS sub_kategori');
    await db.execute('DROP TABLE IF EXISTS paket');
    await db.execute('DROP TABLE IF EXISTS pelanggan');
    await db.execute('DROP TABLE IF EXISTS pelanggan_aktif');
    await db.execute('DROP TABLE IF EXISTS transaksi');
    await db.execute('DROP TABLE IF EXISTS dompet');
    await db.execute('DROP TABLE IF EXISTS kritik_saran');
    await db.execute('DROP TABLE IF EXISTS riwayat_langganan');
    await db.execute('DROP TABLE IF EXISTS pesanan');
  }


  // Membuat semua tabel yang diperlukan dalam database.
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

  // Membuat tabel kategori
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

  // Membuat tabel sub_kategori
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

  // Membuat tabel paket
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

  // Membuat tabel pelanggan
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

  // Membuat tabel pelanggan_aktif
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

  // Membuat tabel transaksi
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

  // Membuat tabel dompet
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

  // Membuat tabel kritik_saran
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

  // Membuat tabel riwayat_langganan
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

  // Membuat tabel pesanan
  // diubah: Tipe data id diubah dari INTEGER menjadi TEXT untuk mendukung UUID.
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
