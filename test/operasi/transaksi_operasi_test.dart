// path: test/operasi/transaksi_operasi_test.dart
// diubah: Menghapus anotasi @override yang salah.

import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

// Kelas palsu (mock) untuk DatabaseHelper yang menggunakan database di memori.
class MockDatabaseHelper extends DatabaseHelper {
  MockDatabaseHelper._() : super.internal();

  static final MockDatabaseHelper instance = MockDatabaseHelper._();

  static Database? _database;

  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // diubah: Menghapus @override karena tidak menimpa metode dari superclass.
  Future<Database> _initDB() async {
    // Menggunakan databaseFactoryFfi untuk membuat database di memori.
    return await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath, // Path khusus untuk database in-memory
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Membuat skema tabel yang sama persis dengan aplikasi utama.
          await _createDompetTable(db);
          await _createTransaksiTable(db);
        },
      ),
    );
  }

  // Definisi pembuatan tabel disalin dari DatabaseHelper asli.
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

  Future<void> _createTransaksiTable(Database db) async {
    await db.execute('''
      CREATE TABLE transaksi(
        id TEXT PRIMARY KEY,
        keterangan TEXT NOT NULL,
        jumlah REAL NOT NULL,
        tanggal TEXT NOT NULL,
        tipe TEXT NOT NULL,
        id_dompet TEXT NOT NULL,
        nama_dompet TEXT NOT NULL,
        id_dompet_tujuan TEXT, 
        nama_dompet_tujuan TEXT,
        id_kategori TEXT NOT NULL,
        nama_kategori TEXT NOT NULL,
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
}

void main() {
  // Inisialisasi FFI untuk sqflite sebelum semua tes berjalan.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TransaksiOperasi Tests', () {
    late TransaksiOperasi operasi;
    late Database db;
    late DompetModel dompetA;
    late DompetModel dompetB;
    const double saldoAwal = 1000.0;
    final uuid = const Uuid();

    // Fungsi helper untuk mendapatkan saldo dompet
    Future<double> getSaldo(String idDompet) async {
      final map = await db.query(
        'dompet',
        where: 'id = ?',
        whereArgs: [idDompet],
      );
      return map.first['saldo'] as double;
    }

    // `setUp` dijalankan sebelum SETIAP tes.
    setUp(() async {
      // Menggunakan instance dari MockDatabaseHelper
      final mockDbHelper = MockDatabaseHelper.instance;
      operasi = TransaksiOperasi.testing(mockDbHelper);
      db = await mockDbHelper.database;

      // Membuat data dompet awal untuk setiap tes
      dompetA = DompetModel(
        id: 'dompet-a',
        namaDompet: 'Dompet A',
        saldo: saldoAwal,
      );
      dompetB = DompetModel(
        id: 'dompet-b',
        namaDompet: 'Dompet B',
        saldo: saldoAwal,
      );

      await db.insert('dompet', dompetA.toMap());
      await db.insert('dompet', dompetB.toMap());
    });

    // `tearDown` dijalankan setelah SETIAP tes.
    tearDown(() async {
      // Menghapus semua data agar tidak mengganggu tes berikutnya
      await db.delete('transaksi');
      await db.delete('dompet');
    });

    // ===================================
    // Tes untuk `tambahTransaksi`
    // ===================================
    test('tambahTransaksi (Pemasukan) harus menambah saldo dompet', () async {
      final transaksi = TransaksiModel(
        id: uuid.v4(),
        keterangan: 'Gaji',
        jumlah: 500,
        tanggal: DateTime.now(),
        tipe: TipeTransaksi.pemasukan,
        idDompet: dompetA.id,
        namaDompet: dompetA.namaDompet,
        idKategori: '',
        namaKategori: '',
      );

      await operasi.tambahTransaksi(transaksi);

      final saldoAkhir = await getSaldo(dompetA.id);
      expect(saldoAkhir, saldoAwal + 500);
    });

    test(
      'tambahTransaksi (Pengeluaran) harus mengurangi saldo dompet',
      () async {
        final transaksi = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Beli Kopi',
          jumlah: 25,
          tanggal: DateTime.now(),
          tipe: TipeTransaksi.pengeluaran,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idKategori: '',
          namaKategori: '',
        );

        await operasi.tambahTransaksi(transaksi);

        final saldoAkhir = await getSaldo(dompetA.id);
        expect(saldoAkhir, saldoAwal - 25);
      },
    );

    test(
      'tambahTransaksi (Transfer) harus memindahkan saldo antar dompet',
      () async {
        final transaksi = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Bayar Utang',
          jumlah: 150,
          tanggal: DateTime.now(),
          tipe: TipeTransaksi.transfer,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idDompetTujuan: dompetB.id,
          namaDompetTujuan: dompetB.namaDompet,
          idKategori: '',
          namaKategori: '',
        );

        await operasi.tambahTransaksi(transaksi);

        final saldoAkhirA = await getSaldo(dompetA.id);
        final saldoAkhirB = await getSaldo(dompetB.id);

        expect(saldoAkhirA, saldoAwal - 150);
        expect(saldoAkhirB, saldoAwal + 150);
      },
    );

    // ===================================
    // Tes untuk `deleteTransaksi`
    // ===================================
    test('deleteTransaksi (Pemasukan) harus mengembalikan saldo', () async {
      final transaksi = TransaksiModel(
        id: uuid.v4(),
        keterangan: 'Bonus',
        jumlah: 200,
        tanggal: DateTime.now(),
        tipe: TipeTransaksi.pemasukan,
        idDompet: dompetA.id,
        namaDompet: dompetA.namaDompet,
        idKategori: '',
        namaKategori: '',
      );
      await operasi.tambahTransaksi(transaksi);

      // Saldo setelah ditambah
      expect(await getSaldo(dompetA.id), saldoAwal + 200);

      await operasi.deleteTransaksi(transaksi.id);

      // Saldo setelah dihapus
      expect(await getSaldo(dompetA.id), saldoAwal);
    });

    test('deleteTransaksi (Pengeluaran) harus mengembalikan saldo', () async {
      final transaksi = TransaksiModel(
        id: uuid.v4(),
        keterangan: 'Makan Siang',
        jumlah: 50,
        tanggal: DateTime.now(),
        tipe: TipeTransaksi.pengeluaran,
        idDompet: dompetA.id,
        namaDompet: dompetA.namaDompet,
        idKategori: '',
        namaKategori: '',
      );
      await operasi.tambahTransaksi(transaksi);

      expect(await getSaldo(dompetA.id), saldoAwal - 50);

      await operasi.deleteTransaksi(transaksi.id);

      expect(await getSaldo(dompetA.id), saldoAwal);
    });

    test(
      'deleteTransaksi (Transfer) harus mengembalikan saldo kedua dompet',
      () async {
        final transaksi = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Transfer',
          jumlah: 100,
          tanggal: DateTime.now(),
          tipe: TipeTransaksi.transfer,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idDompetTujuan: dompetB.id,
          namaDompetTujuan: dompetB.namaDompet,
          idKategori: '',
          namaKategori: '',
        );
        await operasi.tambahTransaksi(transaksi);

        expect(await getSaldo(dompetA.id), saldoAwal - 100);
        expect(await getSaldo(dompetB.id), saldoAwal + 100);

        await operasi.deleteTransaksi(transaksi.id);

        expect(await getSaldo(dompetA.id), saldoAwal);
        expect(await getSaldo(dompetB.id), saldoAwal);
      },
    );

    // ===================================
    // Tes untuk `updateTransaksi`
    // ===================================
    test(
      'updateTransaksi harus menyesuaikan saldo dengan benar (jumlah berubah)',
      () async {
        final transaksiAwal = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Pemasukan Awal',
          jumlah: 100,
          tanggal: DateTime.now(),
          tipe: TipeTransaksi.pemasukan,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idKategori: '',
          namaKategori: '',
        );
        await operasi.tambahTransaksi(transaksiAwal);

        expect(await getSaldo(dompetA.id), saldoAwal + 100);

        final transaksiUpdate = transaksiAwal.salinDengan(jumlah: 250);
        await operasi.updateTransaksi(transaksiUpdate);

        final saldoAkhir = await getSaldo(dompetA.id);
        expect(saldoAkhir, saldoAwal + 250);
      },
    );

    test(
      'updateTransaksi harus menyesuaikan saldo dengan benar (tipe berubah)',
      () async {
        final transaksiAwal = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Awalnya pemasukan',
          jumlah: 100,
          tanggal: DateTime.now(),
          tipe: TipeTransaksi.pemasukan,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idKategori: '',
          namaKategori: '',
        );
        await operasi.tambahTransaksi(transaksiAwal);

        expect(await getSaldo(dompetA.id), saldoAwal + 100);

        // Mengubah dari Pemasukan 100 menjadi Pengeluaran 50
        final transaksiUpdate = transaksiAwal.salinDengan(
          tipe: TipeTransaksi.pengeluaran,
          jumlah: 50,
        );
        await operasi.updateTransaksi(transaksiUpdate);

        // Saldo akhir harus: saldoAwal - 50
        final saldoAkhir = await getSaldo(dompetA.id);
        expect(saldoAkhir, saldoAwal - 50);
      },
    );

    test(
      'updateTransaksi harus menyesuaikan saldo dengan benar (transfer berubah)',
      () async {
        final transaksiAwal = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Transfer',
          jumlah: 100,
          tanggal: DateTime.now(),
          tipe: TipeTransaksi.transfer,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idDompetTujuan: dompetB.id,
          namaDompetTujuan: dompetB.namaDompet,
          idKategori: '',
          namaKategori: '',
        );
        await operasi.tambahTransaksi(transaksiAwal);

        expect(await getSaldo(dompetA.id), saldoAwal - 100);
        expect(await getSaldo(dompetB.id), saldoAwal + 100);

        // Ganti dompet tujuan dari B ke A (seharusnya menjadi pengeluaran biasa)
        final transaksiUpdate = transaksiAwal.salinDengan(
          tipe: TipeTransaksi.pengeluaran,
          idDompetTujuan: null,
          namaDompetTujuan: null,
        );
        await operasi.updateTransaksi(transaksiUpdate);

        final saldoAkhirA = await getSaldo(dompetA.id);
        final saldoAkhirB = await getSaldo(dompetB.id);

        // Saldo A harus kembali ke saldo awal dikurangi 100
        // Saldo B harus kembali ke saldo awal
        expect(saldoAkhirA, saldoAwal - 100);
        expect(saldoAkhirB, saldoAwal);
      },
    );

    // ===================================
    // Tes untuk Fungsi Agregat
    // ===================================
    group('Fungsi Agregat Tests', () {
      test(
        'getTotal... harus mengembalikan 0.0 jika tidak ada transaksi',
        () async {
          final pemasukan = await operasi.getTotalPemasukan();
          final pengeluaran = await operasi.getTotalPengeluaran();
          final net = await operasi.getNetTotal();

          expect(pemasukan, 0.0);
          expect(pengeluaran, 0.0);
          expect(net, 0.0);
        },
      );

      test('getTotal... harus menghitung total dengan benar', () async {
        await operasi.tambahTransaksi(
          TransaksiModel(
            id: uuid.v4(),
            keterangan: 'Pemasukan 1',
            jumlah: 200,
            tanggal: DateTime.now(),
            tipe: TipeTransaksi.pemasukan,
            idDompet: dompetA.id,
            namaDompet: dompetA.namaDompet,
            idKategori: '',
            namaKategori: '',
          ),
        );
        await operasi.tambahTransaksi(
          TransaksiModel(
            id: uuid.v4(),
            keterangan: 'Pemasukan 2',
            jumlah: 300,
            tanggal: DateTime.now(),
            tipe: TipeTransaksi.pemasukan,
            idDompet: dompetA.id,
            namaDompet: dompetA.namaDompet,
            idKategori: '',
            namaKategori: '',
          ),
        );
        await operasi.tambahTransaksi(
          TransaksiModel(
            id: uuid.v4(),
            keterangan: 'Pengeluaran 1',
            jumlah: 150,
            tanggal: DateTime.now(),
            tipe: TipeTransaksi.pengeluaran,
            idDompet: dompetA.id,
            namaDompet: dompetA.namaDompet,
            idKategori: '',
            namaKategori: '',
          ),
        );

        final pemasukan = await operasi.getTotalPemasukan();
        final pengeluaran = await operasi.getTotalPengeluaran();
        final net = await operasi.getNetTotal();

        expect(pemasukan, 500.0);
        expect(pengeluaran, 150.0);
        expect(net, 350.0); // 500 - 150
      });
    });

    // ===================================
    // Tes untuk `ambilSemuaTransaksi`
    // ===================================
    group('ambilSemuaTransaksi Tests', () {
      test('harus mengembalikan list kosong jika tidak ada data', () async {
        final hasil = await operasi.ambilSemuaTransaksi();
        expect(hasil.isEmpty, isTrue);
      });

      test('harus mengembalikan data terurut tanggal DESC', () async {
        final t1 = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Lama',
          jumlah: 1,
          tanggal: DateTime(2023, 1, 1),
          tipe: TipeTransaksi.pemasukan,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idKategori: '',
          namaKategori: '',
        );
        final t2 = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Baru',
          jumlah: 2,
          tanggal: DateTime(2023, 1, 2),
          tipe: TipeTransaksi.pemasukan,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idKategori: '',
          namaKategori: '',
        );

        // Tambahkan tidak berurutan
        await operasi.tambahTransaksi(t1);
        await operasi.tambahTransaksi(t2);

        final hasil = await operasi.ambilSemuaTransaksi();

        expect(hasil.length, 2);
        expect(hasil[0].keterangan, 'Baru'); // Transaksi terbaru harus di awal
        expect(hasil[1].keterangan, 'Lama'); // Transaksi terlama harus di akhir
      });
    });

    // ===================================
    // Tes untuk `sisipkanAtauPerbaruiBatch` (Setelah Perbaikan)
    // ===================================
    group('sisipkanAtauPerbaruiBatch (Setelah Perbaikan)', () {
      test(
        'harus menyisipkan data dan memperbarui saldo dengan benar (termasuk transfer)',
        () async {
          final batchTransaksi = [
            TransaksiModel(
              id: uuid.v4(),
              keterangan: 'Pemasukan Batch 1',
              jumlah: 100,
              tanggal: DateTime.now(),
              tipe: TipeTransaksi.pemasukan,
              idDompet: dompetA.id,
              namaDompet: dompetA.namaDompet,
              idKategori: '',
              namaKategori: '',
            ),
            TransaksiModel(
              id: uuid.v4(),
              keterangan: 'Pengeluaran Batch 1',
              jumlah: 25,
              tanggal: DateTime.now(),
              tipe: TipeTransaksi.pengeluaran,
              idDompet: dompetB.id,
              namaDompet: dompetB.namaDompet,
              idKategori: '',
              namaKategori: '',
            ),
            // ditambah: Skenario transfer untuk kelengkapan pengujian
            TransaksiModel(
              id: uuid.v4(),
              keterangan: 'Transfer Batch',
              jumlah: 50,
              tanggal: DateTime.now(),
              tipe: TipeTransaksi.transfer,
              idDompet: dompetB.id, // Dari Dompet B
              namaDompet: dompetB.namaDompet,
              idDompetTujuan: dompetA.id, // Ke Dompet A
              namaDompetTujuan: dompetA.namaDompet,
              idKategori: '',
              namaKategori: '',
            ),
          ];

          await operasi.sisipkanAtauPerbaruiBatch(batchTransaksi);

          final saldoAkhirA = await getSaldo(dompetA.id);
          final saldoAkhirB = await getSaldo(dompetB.id);

          // diubah: Ekspektasi saldo akhir dihitung ulang untuk mencakup transfer
          // Saldo A = 1000 (awal) + 100 (pemasukan) + 50 (transfer masuk) = 1150
          // Saldo B = 1000 (awal) - 25 (pengeluaran) - 50 (transfer keluar) = 925
          expect(
            saldoAkhirA,
            saldoAwal + 100 + 50,
            reason: 'Saldo Dompet A seharusnya bertambah 150 total',
          );
          expect(
            saldoAkhirB,
            saldoAwal - 25 - 50,
            reason: 'Saldo Dompet B seharusnya berkurang 75 total',
          );
        },
      );
    });
  });
}
