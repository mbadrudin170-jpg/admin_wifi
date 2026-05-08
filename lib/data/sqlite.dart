// path: lib/data/sqlite.dart
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Kelas ini berfungsi sebagai pusat pengelolaan koneksi dan skema database SQLite.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // diubah: Versi database dinaikkan untuk migrasi tabel transaksi (penambahan poin).
  static const int _databaseVersion = 32;

  DatabaseHelper._internal();

  // ditambah: Definisi skema tabel menjadi publik agar bisa diakses dari file test.
  static const String tabelVersiApkUser = '''
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
    ''';

  // ditambah: Skema tabel dompet dipublikasikan.
  static const String tabelDompet = '''
      CREATE TABLE dompet(
        id TEXT PRIMARY KEY,
        namaDompet TEXT NOT NULL,
        saldo REAL NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''';

  // diubah: Menambahkan kolom poin_yang_dihasilkan dan poin_yang_digunakan.
  static const String tabelTransaksi = '''
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
        isDeleted INTEGER NOT NULL DEFAULT 0,
        id_dompet_tujuan TEXT,
        nama_dompet_tujuan TEXT,
        poin_yang_dihasilkan INTEGER NOT NULL DEFAULT 0,
        poin_yang_digunakan INTEGER NOT NULL DEFAULT 0
      )
    ''';

  // ditambah: Skema tabel status unggah dipublikasikan.
  static const String tabelStatusUnggah = '''
    CREATE TABLE status_unggah(
      tabel TEXT PRIMARY KEY,
      status INTEGER NOT NULL,
      ids TEXT NOT NULL
    )
  ''';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  @visibleForTesting
  void stubDb(Database db) {
    _database = db;
  }

  Future<Database> _initDB() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      return await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: (db, version) async {
            await createTables(db);
          },
          onUpgrade: _onUpgrade,
        ),
      );
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'mydatabase.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await createTables(db);
      },
      onUpgrade: _onUpgrade,
    );
  }

  // diubah: Menambahkan logika upgrade untuk tabel transaksi.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log('Memulai upgrade database dari versi $oldVersion ke $newVersion');
    // ... (logika upgrade yang sudah ada)

    if (oldVersion < 32) {
      try {
        log('Menjalankan upgrade untuk versi < 32: Menambahkan kolom poin pada tabel transaksi.');
        await db.execute('ALTER TABLE transaksi ADD COLUMN poin_yang_dihasilkan INTEGER NOT NULL DEFAULT 0');
        await db.execute('ALTER TABLE transaksi ADD COLUMN poin_yang_digunakan INTEGER NOT NULL DEFAULT 0');
        log('Kolom poin berhasil ditambahkan ke tabel transaksi.');
      } catch (e) {
        log('Error saat menambahkan kolom poin ke tabel transaksi: $e');
        // Pertimbangkan untuk menangani error, misalnya dengan membuat ulang tabel
        // atau memberikan notifikasi kepada pengguna.
      }
    }

    log('Upgrade database selesai.');
  }


  // diekspos: Metode ini dibuat publik untuk digunakan dalam pengujian
  Future<void> createTables(Database db) async {
    await db.execute(_tabelKategori);
    await db.execute(_tabelSubKategori);
    await db.execute(_tabelPaket);
    await db.execute(_tabelPelanggan);
    await db.execute(_tabelPelangganAktif);
    await db.execute(tabelTransaksi);
    await db.execute(tabelDompet);
    await db.execute(_tabelKritikSaran);
    await db.execute(_tabelRiwayatLangganan);
    await db.execute(_tabelPesanan);
    await db.execute(tabelVersiApkUser);
    await db.execute(_tabelPengaturan);
    await db.execute(tabelStatusUnggah);
  }

  static const String _tabelPengaturan = '''
    CREATE TABLE pengaturan(
      interval_sinkronisasi_otomatis INTEGER NOT NULL DEFAULT 24,
      hapus_otomatis_data_arsip INTEGER NOT NULL DEFAULT 30,
      diperbarui TEXT,
      mode_pemeliharaan INTEGER NOT NULL DEFAULT 0,
      info_pemeliharaan TEXT
    )
  ''';

  static const String _tabelKategori = '''
      CREATE TABLE kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        tipe TEXT NOT NULL,
        id_sub_kategori TEXT,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''';

  static const String _tabelSubKategori = '''
      CREATE TABLE sub_kategori(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        id_kategori TEXT NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_kategori) REFERENCES kategori (id) ON DELETE CASCADE
      )
    ''';

  static const String _tabelPaket = '''
      CREATE TABLE paket(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        harga INTEGER NOT NULL,
        durasi INTEGER NOT NULL,
        tipe TEXT NOT NULL,
        jumlahPoin INTEGER NOT NULL DEFAULT 0,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT
      )
    ''';

  static const String _tabelPelanggan = '''
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
    ''';

  static const String _tabelPelangganAktif = '''
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
    ''';

  static const String _tabelKritikSaran = '''
      CREATE TABLE kritik_saran(
        id TEXT PRIMARY KEY,
        isi TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        userId TEXT NOT NULL,
        diperbarui TEXT,
        FOREIGN KEY (userId) REFERENCES pelanggan (id) ON DELETE CASCADE
      )
    ''';

  static const String _tabelRiwayatLangganan = '''
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
        jumlah_poin_diperoleh INTEGER NOT NULL DEFAULT 0,
        diperbarui TEXT,
        diarsipkan TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE
      )
    ''';

  static const String _tabelPesanan = '''
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
    ''';
}
