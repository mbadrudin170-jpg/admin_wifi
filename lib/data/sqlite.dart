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

  // untuk menginisialisasi database dengan path dan versi
  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'mydatabase.db');
    return await openDatabase(
      path,
      // diubah: Versi dinaikkan untuk menghapus kolom status_sinkronisasi dari tabel pelanggan_aktif.
      version: 21, // dinaikkan dari 20
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // untuk membuat tabel saat database pertama kali dibuat
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  // diubah: Logika migrasi diperbarui untuk menghapus status_sinkronisasi.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ... (migrasi sebelumnya tetap ada)

    // ditambah: Migrasi untuk v20, menghapus kolom sync_status yang tidak lagi digunakan.
    if (oldVersion < 20) {
      // Buat tabel temporer tanpa kolom sync_status
      await _createDompetTableV20(db);
      await _createPelangganAktifTableV20(db);
      await _createTransaksiTableV20(db);

      // Salin data dari tabel lama ke tabel baru
      await db.execute(
        'INSERT INTO dompet_v20 SELECT id, namaDompet, saldo, diperbarui, isDeleted, diarsipkan FROM dompet',
      );
      await db.execute(
        'INSERT INTO pelanggan_aktif_v20 SELECT id, id_pelanggan, id_paket, tanggalMulai, tanggalBerakhir, status, diperbarui, status_sinkronisasi, isDeleted, diarsipkan FROM pelanggan_aktif',
      );
      await db.execute(
        'INSERT INTO transaksi_v20 SELECT id, keterangan, jumlah, tanggal, tipe, id_dompet, nama_dompet, id_kategori, nama_kategori, id_sub_kategori, nama_sub_kategori, id_pelanggan, nama_pelanggan, id_paket, nama_paket, diperbarui, diarsipkan, isDeleted FROM transaksi',
      );

      // Hapus tabel lama
      await db.execute('DROP TABLE dompet');
      await db.execute('DROP TABLE pelanggan_aktif');
      await db.execute('DROP TABLE transaksi');

      // Ganti nama tabel baru menjadi nama tabel asli
      await db.execute('ALTER TABLE dompet_v20 RENAME TO dompet');
      await db.execute(
        'ALTER TABLE pelanggan_aktif_v20 RENAME TO pelanggan_aktif',
      );
      await db.execute('ALTER TABLE transaksi_v20 RENAME TO transaksi');
    }

    // ditambah: Migrasi untuk v21, menghapus kolom status_sinkronisasi dari tabel pelanggan_aktif.
    if (oldVersion < 21) {
      // Buat tabel temporer tanpa kolom status_sinkronisasi
      await _createPelangganAktifTableV21(db);

      // Salin data dari tabel lama ke tabel baru tanpa kolom status_sinkronisasi
      await db.execute(
        'INSERT INTO pelanggan_aktif_v21 SELECT id, id_pelanggan, id_paket, tanggalMulai, tanggalBerakhir, status, diperbarui, isDeleted, diarsipkan FROM pelanggan_aktif',
      );

      // Hapus tabel lama
      await db.execute('DROP TABLE pelanggan_aktif');

      // Ganti nama tabel baru menjadi nama tabel asli
      await db.execute(
        'ALTER TABLE pelanggan_aktif_v21 RENAME TO pelanggan_aktif',
      );
    }
  }

  // untuk membuat semua tabel
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

  // diubah: Kolom status_sinkronisasi dihapus sesuai dengan model terbaru.
  // untuk membuat tabel pelanggan_aktif
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
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  // diubah: Skema tabel disesuaikan dengan model terbaru (tanpa sync_status).
  // untuk membuat tabel transaksi
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
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // diubah: Skema tabel disesuaikan dengan model terbaru (tanpa sync_status).
  // untuk membuat tabel dompet
  Future<void> _createDompetTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dompet(
        id TEXT PRIMARY KEY,
        namaDompet TEXT NOT NULL,
        saldo REAL NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''');
  }

  // Fungsi helper untuk migrasi v20
  // untuk membuat tabel temporer dompet_v20
  Future<void> _createDompetTableV20(Database db) async {
    await db.execute('''
      CREATE TABLE dompet_v20(
        id TEXT PRIMARY KEY,
        namaDompet TEXT NOT NULL,
        saldo REAL NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''');
  }

  // untuk membuat tabel temporer pelanggan_aktif_v20
  Future<void> _createPelangganAktifTableV20(Database db) async {
    await db.execute('''
      CREATE TABLE pelanggan_aktif_v20(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        tanggalMulai TEXT NOT NULL,
        tanggalBerakhir TEXT NOT NULL,
        status TEXT NOT NULL,
        diperbarui TEXT,
        status_sinkronisasi TEXT NOT NULL DEFAULT 'SINKRON',
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  // untuk membuat tabel temporer transaksi_v20
  Future<void> _createTransaksiTableV20(Database db) async {
    await db.execute('''
      CREATE TABLE transaksi_v20(
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

  // ditambah: Fungsi helper untuk migrasi v21
  // untuk membuat tabel temporer pelanggan_aktif_v21 tanpa kolom status_sinkronisasi
  Future<void> _createPelangganAktifTableV21(Database db) async {
    await db.execute('''
      CREATE TABLE pelanggan_aktif_v21(
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

  // untuk membuat tabel kategori
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

  // untuk membuat tabel sub_kategori
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

  // untuk membuat tabel paket
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

  // untuk membuat tabel pelanggan
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

  // untuk membuat tabel kritik_saran
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

  // untuk membuat tabel riwayat_langganan
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

  // untuk membuat tabel pesanan
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
