// path: lib/data/sqlite.dart

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:admin_wifi/debug/log.dart'; // ditambah: import custom logger

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // diubah: Versi dinaikkan ke 40 untuk memicu migrasi pembuatan tabel baru.
  static const int _databaseVersion = 40;

  DatabaseHelper._internal();

  // --- DEFINISI TABEL ---

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
        id_kategori TEXT,
        id_sub_kategori TEXT,
        id_pelanggan TEXT,
        id_paket TEXT,
        diperbarui TEXT,
        diarsipkan TEXT,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        id_dompet_tujuan TEXT,
        poin_yang_dihasilkan INTEGER NOT NULL DEFAULT 0,
        poin_yang_digunakan INTEGER NOT NULL DEFAULT 0,
        status_pembayaran TEXT,
        durasi_paket INTEGER,
        tipe_durasi_paket TEXT,
        tanggal_mulai TEXT,
        tanggal_berakhir TEXT,
        aktivasi_paket INTEGER DEFAULT 0
      )
    ''';

  static const String _tabelStatusUnggah = '''
    CREATE TABLE status_unggah(
      tabel TEXT PRIMARY KEY,
      status INTEGER NOT NULL,
      ids TEXT NOT NULL,
      diperbarui TEXT
    )
  ''';

  // ditambah: tabel untuk status aplikasi
  static const String _tabelStatusAplikasi = '''
    CREATE TABLE status_aplikasi(
      id TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  // ditambah: tabel untuk pesan
  static const String _tabelPesan = '''
    CREATE TABLE pesan(
      id TEXT PRIMARY KEY,
      isi TEXT NOT NULL,
      tanggal TEXT NOT NULL,
      status TEXT NOT NULL
    )
  ''';

  // diubah: ditambah logging info dan error
  Future<Database> get database async {
    Log.info('Memulai akses database.');
    if (_database != null) {
      Log.info('Database sudah ada, mengembalikan instance yang ada.');
      return _database!;
    }
    try {
      Log.info('Database belum diinisialisasi, memanggil _initDB.');
      _database = await _initDB();
      Log.info('Inisialisasi database berhasil.');
      return _database!;
    } catch (e, st) {
      Log.error('Gagal total mendapatkan instance database.', error: e, stackTrace: st);
      rethrow;
    }
  }

  // diubah: ditambah logging info dan error
  Future<Database> _initDB() async {
    Log.info('Memulai proses inisialisasi database (_initDB).');
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        Log.info('Mode TEST terdeteksi. Menggunakan database in-memory (sqflite_ffi).');
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        return await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: createTables,
            onUpgrade: _onUpgrade,
          ),
        );
      }

      Log.info('Mode Produksi/Debug. Menggunakan database fisik.');
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'mydatabase.db');
      Log.info('Path database: $path');
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: createTables,
        onUpgrade: _onUpgrade,
      );
    } catch (e, st) {
      Log.error('Gagal membuka atau membuat database.', error: e, stackTrace: st);
      rethrow;
    }
  }

  // diubah: diganti log lama dengan custom logger
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Log.info('Memulai proses upgrade database dari versi $oldVersion ke $newVersion.');
    final batch = db.batch();

    try {
      if (oldVersion < 39) {
        Log.info('Melakukan migrasi untuk versi < 39.');
        final List<String> migrations = [
          'ALTER TABLE status_unggah ADD COLUMN diperbarui TEXT',
          'ALTER TABLE pelanggan_aktif ADD COLUMN id_transaksi TEXT',
          'CREATE INDEX IF NOT EXISTS idx_transaksi_dompet ON transaksi(id_dompet)',
          'CREATE INDEX IF NOT EXISTS idx_transaksi_dompet_tujuan ON transaksi(id_dompet_tujuan)',
          'CREATE INDEX IF NOT EXISTS idx_transaksi_isDeleted ON transaksi(isDeleted)',
          'ALTER TABLE transaksi ADD COLUMN status_pembayaran TEXT',
          'ALTER TABLE transaksi ADD COLUMN durasi_paket INTEGER',
          'ALTER TABLE transaksi ADD COLUMN tipe_durasi_paket TEXT',
          'ALTER TABLE transaksi ADD COLUMN tanggal_mulai TEXT',
          'ALTER TABLE transaksi ADD COLUMN tanggal_berakhir TEXT',
          'ALTER TABLE transaksi ADD COLUMN aktivasi_paket INTEGER DEFAULT 0',
        ];

        for (final sql in migrations) {
          try {
            Log.info('Eksekusi migrasi: $sql');
            batch.execute(sql);
          } catch (e) {
            Log.warning('Gagal mengeksekusi migrasi (mungkin sudah ada): $sql. Error: $e');
          }
        }
        Log.info('Menghapus tabel usang: riwayat_langganan.');
        batch.execute('DROP TABLE IF EXISTS riwayat_langganan');
      }

      if (oldVersion < 40) {
        Log.info('Melakukan migrasi untuk versi < 40. Membuat tabel _tabelStatusAplikasi dan _tabelPesan.');
        batch.execute(_tabelStatusAplikasi);
        batch.execute(_tabelPesan);
      }

      await batch.commit(noResult: true);
      Log.info('Proses upgrade database berhasil diselesaikan.');
    } catch (e, st) {
      Log.error('Gagal melakukan upgrade database.', error: e, stackTrace: st);
      rethrow;
    }
  }

  // diubah: ditambah logging info dan error
  Future<void> createTables(Database db, int version) async {
    Log.info('Memulai pembuatan tabel-tabel database (onCreate).');
    try {
      await db.execute(_tabelKategori);
      await db.execute(_tabelSubKategori);
      await db.execute(_tabelPaket);
      await db.execute(_tabelPelanggan);
      await db.execute(_tabelPelangganAktif);
      await db.execute(tabelTransaksi);
      await db.execute(tabelDompet);
      await db.execute(_tabelKritikSaran);
      await db.execute(_tabelPesanan);
      await db.execute(tabelVersiApkUser);
      await db.execute(_tabelPengaturan);
      await db.execute(_tabelStatusUnggah);
      await db.execute(_tabelStatusAplikasi); // ditambah: Eksekusi pembuatan tabel baru
      await db.execute(_tabelPesan); // ditambah: Eksekusi pembuatan tabel baru
      Log.info('Semua tabel utama berhasil dibuat.');

      Log.info('Membuat indexes...');
      // Indexes
      await db.execute(
        'CREATE INDEX idx_transaksi_dompet ON transaksi(id_dompet)',
      );
      await db.execute(
        'CREATE INDEX idx_transaksi_dompet_tujuan ON transaksi(id_dompet_tujuan)',
      );
      await db.execute(
        'CREATE INDEX idx_transaksi_isDeleted ON transaksi(isDeleted)',
      );
      Log.info('Indexes berhasil dibuat.');
      Log.info('Pembuatan tabel dan index selesai.');

    } catch (e, st) {
      Log.error('Gagal total saat membuat tabel atau index database.', error: e, stackTrace: st);
      rethrow;
    }
  }


  // --- STATIC STRINGS UNTUK TABEL LAIN ---
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
