import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:admin_wifi/debug/log.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  static const int _databaseVersion = 40;

  DatabaseHelper._internal() {
    Log.info('DatabaseHelper instance dibuat (singleton _internal).');
  }

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

  static const String _tabelStatusAplikasi = '''
    CREATE TABLE status_aplikasi(
      id TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  static const String _tabelPesan = '''
    CREATE TABLE pesan(
      id TEXT PRIMARY KEY,
      isi TEXT NOT NULL,
      tanggal TEXT NOT NULL,
      status TEXT NOT NULL
    )
  ''';

  Future<Database> get database async {
    Log.info('Memulai proses akses properti database getter.');
    Log.info('Memeriksa apakah instance database (_database) sudah ada sebelumnya.');
    
    if (_database != null) {
      Log.info('Instance database sudah ada di memori. Mengembalikan instance yang sudah terinisialisasi tanpa membuat koneksi baru.');
      return _database!;
    }
    
    Log.info('Instance database belum ada (null). Akan memanggil metode _initDB() untuk membuat atau membuka koneksi database baru.');
    
    try {
      Log.info('Memanggil _initDB() untuk inisialisasi database.');
      _database = await _initDB();
      Log.info('Database berhasil diinisialisasi dan disimpan di variabel _database. Koneksi database siap digunakan.');
      return _database!;
    } catch (e, st) {
      Log.error(
        'Gagal total mendapatkan instance database. Database tidak dapat diinisialisasi atau dibuka. '
        'Aplikasi mungkin tidak dapat berfungsi dengan baik tanpa akses database.',
        error: e,
        stackTrace: st
      );
      rethrow;
    }
  }

  Future<Database> _initDB() async {
    Log.info('Memulai proses inisialisasi database (_initDB).');
    Log.info('Memeriksa environment untuk menentukan mode database (TEST atau PRODUKSI/DEBUG).');
    
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        Log.info('Environment variable FLUTTER_TEST terdeteksi. Aplikasi berjalan dalam mode pengujian (TEST).');
        Log.info('Menginisialisasi sqflite_ffi untuk database SQLite di environment test.');
        sqfliteFfiInit();
        
        Log.info('Mengganti databaseFactory standar dengan databaseFactoryFfi untuk mode test.');
        databaseFactory = databaseFactoryFfi;
        
        Log.info('Membuka database in-memory menggunakan databaseFactoryFfi. Database hanya akan ada selama sesi pengujian berlangsung.');
        return await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: createTables,
            onUpgrade: _onUpgrade,
          ),
        );
      }

      Log.info('Mode Produksi/Debug terdeteksi. Akan menggunakan database fisik yang disimpan di perangkat.');
      Log.info('Mendapatkan direktori dokumen aplikasi untuk menyimpan file database.');
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      
      Log.info('Direktori dokumen berhasil didapatkan: ${documentsDirectory.path}');
      String path = join(documentsDirectory.path, 'mydatabase.db');
      Log.info('Path lengkap file database yang akan digunakan: $path');
      
      Log.info('Memeriksa apakah file database sudah ada di path tersebut.');
      bool dbExists = await File(path).exists();
      Log.info('Status keberadaan file database: ${dbExists ? "Sudah ada" : "Belum ada, akan dibuat baru"}.');
      
      Log.info('Membuka koneksi database dengan konfigurasi versi $_databaseVersion dan callback onCreate serta onUpgrade.');
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: createTables,
        onUpgrade: _onUpgrade,
      );
    } catch (e, st) {
      Log.error(
        'Gagal membuka atau membuat database. Proses inisialisasi database mengalami kegagalan. '
        'Pastikan perangkat memiliki ruang penyimpanan yang cukup dan izin akses penyimpanan telah diberikan.',
        error: e,
        stackTrace: st
      );
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Log.info('========================================');
    Log.info('MEMULAI PROSES UPGRADE DATABASE');
    Log.info('Versi database lama: $oldVersion');
    Log.info('Versi database baru: $newVersion');
    Log.info('========================================');
    
    Log.info('Membuat batch operation untuk menjalankan multiple query migrasi secara atomik.');
    final batch = db.batch();

    try {
      if (oldVersion < 39) {
        Log.info('Detected: oldVersion ($oldVersion) < 39. Melakukan migrasi struktur database untuk mencapai versi 39.');
        
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

        Log.info('Total ${migrations.length} query migrasi akan dieksekusi untuk versi < 39.');
        
        int successCount = 0;
        int warningCount = 0;
        
        for (int i = 0; i < migrations.length; i++) {
          final sql = migrations[i];
          Log.info('Menjalankan migrasi ke-${i + 1}/${migrations.length}: $sql');
          try {
            batch.execute(sql);
            successCount++;
            Log.info('Migrasi ke-${i + 1} berhasil ditambahkan ke batch: $sql');
          } catch (e) {
            warningCount++;
            Log.warning(
              'Gagal mengeksekusi migrasi ke-${i + 1}: $sql. '
              'Kemungkinan kolom atau index sudah ada sebelumnya. Error detail: $e. '
              'Melanjutkan ke migrasi berikutnya.'
            );
          }
        }
        
        Log.info('Ringkasan migrasi versi < 39: $successCount berhasil, $warningCount warning/gagal (mungkin sudah ada).');
        
        Log.info('Menghapus tabel usang riwayat_langganan yang sudah tidak digunakan.');
        batch.execute('DROP TABLE IF EXISTS riwayat_langganan');
        Log.info('Query DROP TABLE IF EXISTS riwayat_langganan ditambahkan ke batch.');
      } else {
        Log.info('oldVersion ($oldVersion) >= 39. Tidak perlu menjalankan migrasi untuk versi < 39.');
      }

      if (oldVersion < 40) {
        Log.info('Detected: oldVersion ($oldVersion) < 40. Melakukan migrasi untuk mencapai versi 40.');
        Log.info('Membuat tabel status_aplikasi untuk menyimpan status aplikasi (key-value pairs).');
        batch.execute(_tabelStatusAplikasi);
        Log.info('Query CREATE TABLE status_aplikasi ditambahkan ke batch.');
        
        Log.info('Membuat tabel pesan untuk menyimpan notifikasi atau pesan sistem.');
        batch.execute(_tabelPesan);
        Log.info('Query CREATE TABLE pesan ditambahkan ke batch.');
      } else {
        Log.info('oldVersion ($oldVersion) >= 40. Tidak perlu menjalankan migrasi untuk versi < 40.');
      }

      Log.info('Melakukan commit seluruh batch operation. Semua query migrasi akan dieksekusi secara atomik.');
      await batch.commit(noResult: true);
      Log.info('Batch commit berhasil. Semua migrasi telah diterapkan ke database.');
      Log.info('========================================');
      Log.info('PROSES UPGRADE DATABASE SELESAI');
      Log.info('Database berhasil diupgrade dari versi $oldVersion ke versi $newVersion.');
      Log.info('========================================');
    } catch (e, st) {
      Log.error(
        'Gagal melakukan upgrade database dari versi $oldVersion ke versi $newVersion. '
        'Proses migrasi database mengalami error fatal. '
        'Kemungkinan penyebab: query SQL tidak valid, constraint violation, atau database corrupt.',
        error: e,
        stackTrace: st
      );
      rethrow;
    }
  }

  Future<void> createTables(Database db, int version) async {
    Log.info('========================================');
    Log.info('MEMULAI PEMBUATAN TABEL DATABASE (onCreate)');
    Log.info('Versi database yang akan dibuat: $version');
    Log.info('========================================');
    
    try {
      Log.info('Membuat tabel kategori untuk menyimpan data kategori transaksi (pemasukan/pengeluaran).');
      await db.execute(_tabelKategori);
      Log.info('Tabel kategori berhasil dibuat.');
      
      Log.info('Membuat tabel sub_kategori untuk menyimpan sub kategori dari kategori utama.');
      await db.execute(_tabelSubKategori);
      Log.info('Tabel sub_kategori berhasil dibuat.');
      
      Log.info('Membuat tabel paket untuk menyimpan data paket layanan/langganan yang tersedia.');
      await db.execute(_tabelPaket);
      Log.info('Tabel paket berhasil dibuat.');
      
      Log.info('Membuat tabel pelanggan untuk menyimpan data pelanggan beserta informasi login mereka.');
      await db.execute(_tabelPelanggan);
      Log.info('Tabel pelanggan berhasil dibuat.');
      
      Log.info('Membuat tabel pelanggan_aktif untuk melacak pelanggan yang sedang memiliki langganan aktif.');
      await db.execute(_tabelPelangganAktif);
      Log.info('Tabel pelanggan_aktif berhasil dibuat.');
      
      Log.info('Membuat tabel transaksi untuk menyimpan semua riwayat transaksi keuangan.');
      await db.execute(tabelTransaksi);
      Log.info('Tabel transaksi berhasil dibuat.');
      
      Log.info('Membuat tabel dompet untuk menyimpan data dompet/akun keuangan.');
      await db.execute(tabelDompet);
      Log.info('Tabel dompet berhasil dibuat.');
      
      Log.info('Membuat tabel kritik_saran untuk menyimpan feedback dari pengguna.');
      await db.execute(_tabelKritikSaran);
      Log.info('Tabel kritik_saran berhasil dibuat.');
      
      Log.info('Membuat tabel pesanan untuk menyimpan data pemesanan/pembelian paket oleh pelanggan.');
      await db.execute(_tabelPesanan);
      Log.info('Tabel pesanan berhasil dibuat.');
      
      Log.info('Membuat tabel versi_apk_user untuk manajemen versi aplikasi dan update.');
      await db.execute(tabelVersiApkUser);
      Log.info('Tabel versi_apk_user berhasil dibuat.');
      
      Log.info('Membuat tabel pengaturan untuk menyimpan konfigurasi/preferensi aplikasi.');
      await db.execute(_tabelPengaturan);
      Log.info('Tabel pengaturan berhasil dibuat.');
      
      Log.info('Membuat tabel status_unggah untuk melacak status sinkronisasi data ke server.');
      await db.execute(_tabelStatusUnggah);
      Log.info('Tabel status_unggah berhasil dibuat.');
      
      Log.info('Membuat tabel status_aplikasi untuk menyimpan berbagai status internal aplikasi dalam format key-value.');
      await db.execute(_tabelStatusAplikasi);
      Log.info('Tabel status_aplikasi berhasil dibuat.');
      
      Log.info('Membuat tabel pesan untuk menyimpan pesan atau notifikasi yang diterima.');
      await db.execute(_tabelPesan);
      Log.info('Tabel pesan berhasil dibuat.');
      
      Log.info('Semua tabel utama (total 14 tabel) berhasil dibuat.');
      Log.info('');
      Log.info('MEMULAI PEMBUATAN INDEX DATABASE');
      Log.info('Index digunakan untuk mempercepat query pencarian dan pengurutan data.');
      
      Log.info('Membuat index idx_transaksi_dompet pada kolom id_dompet di tabel transaksi untuk mempercepat pencarian transaksi berdasarkan dompet.');
      await db.execute(
        'CREATE INDEX idx_transaksi_dompet ON transaksi(id_dompet)',
      );
      Log.info('Index idx_transaksi_dompet berhasil dibuat.');
      
      Log.info('Membuat index idx_transaksi_dompet_tujuan pada kolom id_dompet_tujuan di tabel transaksi untuk mempercepat pencarian transaksi transfer antar dompet.');
      await db.execute(
        'CREATE INDEX idx_transaksi_dompet_tujuan ON transaksi(id_dompet_tujuan)',
      );
      Log.info('Index idx_transaksi_dompet_tujuan berhasil dibuat.');
      
      Log.info('Membuat index idx_transaksi_isDeleted pada kolom isDeleted di tabel transaksi untuk mempercepat filter data yang belum dihapus.');
      await db.execute(
        'CREATE INDEX idx_transaksi_isDeleted ON transaksi(isDeleted)',
      );
      Log.info('Index idx_transaksi_isDeleted berhasil dibuat.');
      
      Log.info('Semua index (total 3 index) berhasil dibuat.');
      Log.info('========================================');
      Log.info('PROSES PEMBUATAN TABEL DAN INDEX SELESAI');
      Log.info('Database versi $version berhasil dibuat dengan semua tabel dan index yang diperlukan.');
      Log.info('========================================');
    } catch (e, st) {
      Log.error(
        'Gagal total saat membuat tabel atau index database. '
        'Proses pembuatan struktur database awal mengalami kegagalan. '
        'Kemungkinan penyebab: query SQL tidak valid, constraint violation, atau masalah izin akses file.',
        error: e,
        stackTrace: st
      );
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