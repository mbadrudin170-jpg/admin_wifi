// path: test/data/operasi/transaksi_operasi_test.dart
// diubah: Menyesuaikan semua pemanggilan toMapForSqlite menjadi toSqlite

import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  late Database db;
  late TransaksiOperasi operasi;
  late DompetModel dompetA;
  late DompetModel dompetB;
  const double saldoAwal = 1000.0;
  final uuid = const Uuid();

  // `setUp` dijalankan sebelum SETIAP tes untuk memastikan isolasi.
  setUp(() async {
    // Inisialisasi FFI untuk sqflite dan gunakan factory-nya
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Buka database in-memory yang baru untuk setiap tes
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Inisialisasi skema database dari DatabaseHelper
    await DatabaseHelper.instance.createTables(db);

    // Suntikkan database in-memory ini ke dalam instance singleton DatabaseHelper
    DatabaseHelper.instance.stubDb(db);

    // Buat instance operasi dengan database yang sudah di-stub
    operasi = TransaksiOperasi();

    // Buat data dompet awal yang bersih untuk setiap tes
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

    await db.insert('dompet', dompetA.toSqlite());
    await db.insert('dompet', dompetB.toSqlite());
  });

  // `tearDown` dijalankan setelah SETIAP tes untuk membersihkan.
  tearDown(() async {
    await db.close();
  });

  // Fungsi helper untuk mendapatkan saldo dompet
  Future<double> getSaldo(String idDompet) async {
    final map = await db.query(
      'dompet',
      where: 'id = ?',
      whereArgs: [idDompet],
    );
    if (map.isNotEmpty) {
      return (map.first['saldo'] as num).toDouble();
    }
    return 0.0;
  }

  group('TransaksiOperasi Tests', () {
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

    test(
      'arsipkanTransaksi (Pemasukan) harus mengembalikan saldo, data transaksi harus ubah isDeleted : true, diarspikan :DateTime.now, diperbarui : DateTime.now',
      () async {
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

        expect(await getSaldo(dompetA.id), saldoAwal + 200);

        await operasi.arsipkanTransaksi(transaksi.id);

        expect(await getSaldo(dompetA.id), saldoAwal);
      },
    );

    test(
      'arsipkanTransaksi (Pengeluaran) harus mengembalikan saldo, data transaksi harus ubah isDeleted : true, diarspikan :DateTime.now, diperbarui : DateTime.now',
      () async {
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

        await operasi.arsipkanTransaksi(transaksi.id);

        expect(await getSaldo(dompetA.id), saldoAwal);
      },
    );

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

        await operasi.arsipkanTransaksi(transaksi.id);

        expect(await getSaldo(dompetA.id), saldoAwal);
        expect(await getSaldo(dompetB.id), saldoAwal);
      },
    );

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

        final transaksiUpdate = transaksiAwal.copyWith(jumlah: 250);
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

        final transaksiUpdate = transaksiAwal.copyWith(
          tipe: TipeTransaksi.pengeluaran,
          jumlah: 50,
        );
        await operasi.updateTransaksi(transaksiUpdate);

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

        final transaksiUpdate = transaksiAwal.copyWith(
          tipe: TipeTransaksi.pengeluaran,
          idDompetTujuan: null,
          namaDompetTujuan: null,
        );
        await operasi.updateTransaksi(transaksiUpdate);

        final saldoAkhirA = await getSaldo(dompetA.id);
        final saldoAkhirB = await getSaldo(dompetB.id);

        expect(saldoAkhirA, saldoAwal - 100);
        expect(saldoAkhirB, saldoAwal);
      },
    );

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

    test(
      'ambilTransaksiByDompetId harus mengambil data berdasarkan id_dompet dan isDeletednya 0 atau false, lalu urutkan berdasarkan tanggal terbaru',
      () async {
        final tDompetA1 = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Pemasukan Dompet A (Baru)',
          jumlah: 100,
          tanggal: DateTime(2023, 10, 2), // Terbaru
          tipe: TipeTransaksi.pemasukan,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idKategori: '',
          namaKategori: '',
        );
        final tDompetA2 = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Pemasukan Dompet A (Lama)',
          jumlah: 50,
          tanggal: DateTime(2023, 10, 1), // Lama
          tipe: TipeTransaksi.pemasukan,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idKategori: '',
          namaKategori: '',
        );
        final tDompetADihapus = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Pemasukan Dompet A (Dihapus)',
          jumlah: 200,
          tanggal: DateTime(2023, 10, 3),
          tipe: TipeTransaksi.pemasukan,
          idDompet: dompetA.id,
          namaDompet: dompetA.namaDompet,
          idKategori: '',
          namaKategori: '',
          isDeleted: true, // Dihapus
        );
        final tDompetB = TransaksiModel(
          id: uuid.v4(),
          keterangan: 'Pemasukan Dompet B',
          jumlah: 1000,
          tanggal: DateTime(2023, 10, 4),
          tipe: TipeTransaksi.pemasukan,
          idDompet: dompetB.id, // Beda Dompet
          namaDompet: dompetB.namaDompet,
          idKategori: '',
          namaKategori: '',
        );

        await db.insert('transaksi', tDompetA1.toSqlite());
        await db.insert('transaksi', tDompetA2.toSqlite());
        await db.insert('transaksi', tDompetADihapus.toSqlite());
        await db.insert('transaksi', tDompetB.toSqlite());

        final hasil = await operasi.ambilTransaksiByDompetId(dompetA.id);

        expect(
          hasil.length,
          2,
          reason:
              'Seharusnya hanya mengembalikan 2 transaksi aktif untuk dompet A',
        );
        expect(
          hasil[0].keterangan,
          'Pemasukan Dompet A (Baru)',
          reason: 'Urutan harus yang paling baru',
        );
        expect(
          hasil[1].keterangan,
          'Pemasukan Dompet A (Lama)',
          reason: 'Urutan kedua adalah data setelahnya',
        );
      },
    );

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

        await operasi.tambahTransaksi(t1);
        await operasi.tambahTransaksi(t2);

        final hasil = await operasi.ambilSemuaTransaksi();

        expect(hasil.length, 2);
        expect(hasil[0].keterangan, 'Baru');
        expect(hasil[1].keterangan, 'Lama');
      });
    });

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
            TransaksiModel(
              id: uuid.v4(),
              keterangan: 'Transfer Batch',
              jumlah: 50,
              tanggal: DateTime.now(),
              tipe: TipeTransaksi.transfer,
              idDompet: dompetB.id,
              namaDompet: dompetB.namaDompet,
              idDompetTujuan: dompetA.id,
              namaDompetTujuan: dompetA.namaDompet,
              idKategori: '',
              namaKategori: '',
            ),
          ];

          await operasi.sisipkanAtauPerbaruiBatch(batchTransaksi);

          final saldoAkhirA = await getSaldo(dompetA.id);
          final saldoAkhirB = await getSaldo(dompetB.id);

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

    group('ambilSemuaTransaksi (filter isDeleted)', () {
      test(
        'ambilTransaksiAktif harus mengambil data transaksi yang isDeleted-nya false dan urutkan berdasarkan tanggal terbaru',
        () async {
          final tAktifKemarin = TransaksiModel(
            id: uuid.v4(),
            keterangan: 'Aktif Kemarin',
            jumlah: 10,
            tanggal: DateTime.now().subtract(const Duration(days: 1)),
            tipe: TipeTransaksi.pemasukan,
            idDompet: dompetA.id,
            namaDompet: dompetA.namaDompet,
            idKategori: '',
            namaKategori: '',
            isDeleted: false,
          );
          final tAktifSekarang = TransaksiModel(
            id: uuid.v4(),
            keterangan: 'Aktif Sekarang',
            jumlah: 20,
            tanggal: DateTime.now(),
            tipe: TipeTransaksi.pemasukan,
            idDompet: dompetA.id,
            namaDompet: dompetA.namaDompet,
            idKategori: '',
            namaKategori: '',
            isDeleted: false,
          );
          final tDihapusLampau = TransaksiModel(
            id: uuid.v4(),
            keterangan: 'Sudah Dihapus',
            jumlah: 30,
            tanggal: DateTime.now().subtract(const Duration(days: 2)),
            tipe: TipeTransaksi.pemasukan,
            idDompet: dompetA.id,
            namaDompet: dompetA.namaDompet,
            idKategori: '',
            namaKategori: '',
            isDeleted: true,
          );

          await db.insert('transaksi', tAktifKemarin.toSqlite());
          await db.insert('transaksi', tAktifSekarang.toSqlite());
          await db.insert('transaksi', tDihapusLampau.toSqlite());

          final hasil = await operasi.ambilSemuaTransaksi();

          expect(
            hasil.length,
            2,
            reason:
                "Seharusnya hanya mengembalikan transaksi yang tidak dihapus",
          );

          expect(
            hasil.every((t) => !t.isDeleted),
            isTrue,
            reason:
                "Semua transaksi yang dikembalikan harus memiliki isDeleted == false",
          );

          expect(
            hasil[0].keterangan,
            'Aktif Sekarang',
            reason: "Urutan pertama harus data terbaru",
          );
          expect(
            hasil[1].keterangan,
            'Aktif Kemarin',
            reason: "Urutan kedua harus data setelahnya",
          );
        },
      );
    });
  });
}
