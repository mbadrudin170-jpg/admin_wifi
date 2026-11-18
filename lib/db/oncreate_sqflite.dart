// path: lib/db/oncreate_sqflite.dart

import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// --- DEFINISI SKEMA TABEL ---

const String _tabelVersiApkUser = '''
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

const String _tabelDompet = '''
    CREATE TABLE dompet(
      id TEXT PRIMARY KEY,
      namaDompet TEXT NOT NULL,
      saldo REAL NOT NULL,
      diperbarui TEXT,
      isDeleted INTEGER NOT NULL DEFAULT 0,
      diarsipkan TEXT
    )
  ''';

const String _tabelTransaksi = '''
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

const String _tabelStatusUnggah = '''
  CREATE TABLE status_unggah(
    tabel TEXT PRIMARY KEY,
    status INTEGER NOT NULL,
    ids TEXT NOT NULL,
    diperbarui TEXT
  )
''';

const String _tabelStatusAplikasi = '''
  CREATE TABLE status_aplikasi(
    id TEXT PRIMARY KEY,
    value TEXT NOT NULL
  )
''';

const String _tabelPesan = '''
  CREATE TABLE pesan(
    id TEXT PRIMARY KEY,
    isi TEXT NOT NULL,
    tanggal TEXT NOT NULL,
    status TEXT NOT NULL
  )
''';

const String _tabelPengaturan = '''
  CREATE TABLE pengaturan(
    interval_sinkronisasi_otomatis INTEGER NOT NULL DEFAULT 24,
    hapus_otomatis_data_arsip INTEGER NOT NULL DEFAULT 30,
    diperbarui TEXT,
    mode_pemeliharaan INTEGER NOT NULL DEFAULT 0,
    info_pemeliharaan TEXT
  )
''';

const String _tabelKategori = '''
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

const String _tabelSubKategori = '''
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

const String _tabelPaket = '''
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

const String _tabelPelanggan = '''
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

final String _tabelPelangganAktif =
    '''
    CREATE TABLE ${PelangganAktifSkema.tabel}(
      ${PelangganAktifSkema.id} TEXT PRIMARY KEY,
      ${PelangganAktifSkema.idPelanggan} TEXT NOT NULL,
      ${PelangganAktifSkema.idPaket} TEXT NOT NULL,
      ${PelangganAktifSkema.idTransaksi} TEXT,
      ${PelangganAktifSkema.tanggalMulai} TEXT,
      ${PelangganAktifSkema.tanggalBerakhir} TEXT,
      ${PelangganAktifSkema.status} TEXT NOT NULL,
      ${PelangganAktifSkema.diperbarui} TEXT,
      ${PelangganAktifSkema.isDeleted} INTEGER NOT NULL DEFAULT 0,
      ${PelangganAktifSkema.diarsipkan} TEXT,
      FOREIGN KEY (${PelangganAktifSkema.idPelanggan}) REFERENCES pelanggan (id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (${PelangganAktifSkema.idPaket}) REFERENCES paket (id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (${PelangganAktifSkema.idTransaksi}) REFERENCES transaksi (id) ON DELETE SET NULL
    )
  ''';

const String _tabelKritikSaran = '''
    CREATE TABLE kritik_saran(
      id TEXT PRIMARY KEY,
      isi TEXT NOT NULL,
      tanggal TEXT NOT NULL,
      userId TEXT NOT NULL,
      diperbarui TEXT,
      FOREIGN KEY (userId) REFERENCES pelanggan (id) ON DELETE CASCADE
    )
  ''';

const String _tabelPesanan = '''
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

Future<void> onCreateSqflite(Database db, int version) async {
  Log.info('========================================');
  Log.info('MEMULAI PEMBUATAN TABEL DATABASE (onCreate) UNTUK VERSI $version');
  Log.info('========================================');

  try {
    await db.execute(_tabelKategori);
    await db.execute(_tabelSubKategori);
    await db.execute(_tabelPaket);
    await db.execute(_tabelPelanggan);
    await db.execute(_tabelPelangganAktif);
    await db.execute(_tabelTransaksi);
    await db.execute(_tabelDompet);
    await db.execute(_tabelKritikSaran);
    await db.execute(_tabelPesanan);
    await db.execute(_tabelVersiApkUser);
    await db.execute(_tabelPengaturan);
    await db.execute(_tabelStatusUnggah);
    await db.execute(_tabelStatusAplikasi);
    await db.execute(_tabelPesan);
    Log.info('Semua 14 tabel utama berhasil dibuat.');

    Log.info('Memulai pembuatan index...');
    await db.execute(
      'CREATE INDEX idx_transaksi_dompet ON transaksi(id_dompet)',
    );
    await db.execute(
      'CREATE INDEX idx_transaksi_dompet_tujuan ON transaksi(id_dompet_tujuan)',
    );
    await db.execute(
      'CREATE INDEX idx_transaksi_isDeleted ON transaksi(isDeleted)',
    );
    Log.info('Semua 3 index berhasil dibuat.');

    Log.info('========================================');
    Log.info('PROSES PEMBUATAN TABEL & INDEX SELESAI');
    Log.info('========================================');
  } catch (e, st) {
    Log.error(
      'Gagal total saat membuat tabel atau index.',
      error: e,
      stackTrace: st,
    );
    rethrow;
  }
}
