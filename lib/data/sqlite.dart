// path: lib/data/sqlite.dart
// diubah: Menambahkan kolom 'diperbarui' ke tabel 'status_unggah' dan menaikkan versi database.
// diubah: Menambahkan kolom id_transaksi ke tabel pelanggan_aktif dan menaikkan versi database.
// diubah: Menambahkan indeks pada tabel transaksi untuk performa query dan menaikkan versi database.

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

  // diubah: Versi dinaikkan dari 36 ke 37 untuk menambahkan indeks pada tabel transaksi.
  static const int _databaseVersion = 37;

  DatabaseHelper._internal();

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
        poin_yang_digunakan INTEGER NOT NULL DEFAULT 0,
        status_pembayaran TEXT
      )
    ''';

  // diubah: Menambahkan kolom 'diperbarui'.
  static const String tabelStatusUnggah = '''
    CREATE TABLE status_unggah(
      tabel TEXT PRIMARY KEY,
      status INTEGER NOT NULL,
      ids TEXT NOT NULL,
      diperbarui TEXT
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

  // diubah: Menambahkan logika upgrade untuk membuat indeks pada tabel transaksi.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log('Memulai upgrade database dari versi $oldVersion ke $newVersion');

    if (oldVersion < 34) {
      try {
        log('Menjalankan upgrade untuk versi < 34: Menambahkan kolom status_pembayaran pada tabel transaksi.');
        await db.execute('ALTER TABLE transaksi ADD COLUMN status_pembayaran TEXT');
        log('Kolom status_pembayaran berhasil ditambahkan ke tabel transaksi.');
      } catch (e) {
        log('Error saat menambahkan kolom status_pembayaran ke tabel transaksi: $e');
      }
    }

    if (oldVersion < 35) {
      try {
        log('Menjalankan upgrade untuk versi < 35: Menambahkan kolom diperbarui pada tabel status_unggah.');
        await db.execute('ALTER TABLE status_unggah ADD COLUMN diperbarui TEXT');
        log('Kolom diperbarui berhasil ditambahkan ke tabel status_unggah.');
      } catch (e) {
        log('Error saat menambahkan kolom diperbarui ke tabel status_unggah: $e');
      }
    }

    if (oldVersion < 36) {
      try {
        log('Menjalankan upgrade untuk versi < 36: Menambahkan kolom id_transaksi pada tabel pelanggan_aktif.');
        await db.execute('ALTER TABLE pelanggan_aktif ADD COLUMN id_transaksi TEXT');
        log('Kolom id_transaksi berhasil ditambahkan ke tabel pelanggan_aktif.');
      } catch (e) {
        log('Error saat menambahkan kolom id_transaksi ke tabel pelanggan_aktif: $e');
      }
    }
    
    // ditambah: Logika untuk membuat indeks pada tabel transaksi untuk meningkatkan performa query.
    if (oldVersion < 37) {
      try {
        log('Menjalankan upgrade untuk versi < 37: Membuat indeks pada tabel transaksi.');
        await db.execute('CREATE INDEX idx_transaksi_dompet ON transaksi(id_dompet);');
        await db.execute('CREATE INDEX idx_transaksi_dompet_tujuan ON transaksi(id_dompet_tujuan);');
        await db.execute('CREATE INDEX idx_transaksi_isDeleted ON transaksi(isDeleted);');
        log('Indeks berhasil dibuat pada tabel transaksi.');
      } catch (e) {
        log('Error saat membuat indeks pada tabel transaksi: $e');
      }
    }

    log('Upgrade database selesai.');
  }

  // ditambah: Menambahkan perintah pembuatan indeks setelah tabel transaksi dibuat.
  Future<void> createTables(Database db) async {
    await db.execute(_tabelKategori);
    await db.execute(_tabelSubKategori);
    await db.execute(_tabelPaket);
    await db.execute(_tabelPelanggan);
    await db.execute(_tabelPelangganAktif);
    await db.execute(tabelTransaksi);
    // Membuat indeks untuk performa query yang lebih cepat pada tabel transaksi.
    await db.execute('CREATE INDEX idx_transaksi_dompet ON transaksi(id_dompet);');
    await db.execute('CREATE INDEX idx_transaksi_dompet_tujuan ON transaksi(id_dompet_tujuan);');
    await db.execute('CREATE INDEX idx_transaksi_isDeleted ON transaksi(isDeleted);');
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
        diarsipkan TEXT,
        poin_hadiah INTEGER NOT NULL DEFAULT 0,
        poin_penukaran INTEGER NOT NULL DEFAULT 0,
        isPublic INTEGER NOT NULL DEFAULT 1
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

  // diubah: Menambahkan kolom id_transaksi dan foreign key
  static const String _tabelPelangganAktif = '''
      CREATE TABLE pelanggan_aktif(
        id TEXT PRIMARY KEY,
        id_pelanggan TEXT NOT NULL,
        id_paket TEXT NOT NULL,
        id_transaksi TEXT,
        tanggalMulai TEXT NOT NULL,
        tanggalBerakhir TEXT NOT NULL,
        status TEXT NOT NULL,
        diperbarui TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        diarsipkan TEXT,
        FOREIGN KEY (id_pelanggan) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_paket) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (id_transaksi) REFERENCES transaksi (id) ON DELETE SET NULL
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
