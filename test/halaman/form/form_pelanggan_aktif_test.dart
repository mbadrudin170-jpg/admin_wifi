// path: test/halaman/form/form_pelanggan_aktif_test.dart
// catatan: widget yang diuji kini berada di lib/fitur/pelanggan_aktif/screens/form_pelanggan_aktif.dart

import 'package:admin_wifi/enum/enum.dart';
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/dompet/state/dompet_state.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/kategori/state/kategori_state.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/paket/state/paket_state.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/state/pelanggan_state.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/screens/form_pelanggan_aktif.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/state/pelanggan_aktif_state.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/state/transaksi_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Pengganti PelangganNotifier agar widget test tidak menyentuh database.
class FakePelangganNotifier extends PelangganNotifier {
  FakePelangganNotifier(this._state);

  final PelangganState _state;

  @override
  Future<PelangganState> build() async => _state;
}

/// Pengganti PaketNotifier agar widget test tidak menyentuh database.
class FakePaketNotifier extends PaketNotifier {
  FakePaketNotifier(this._state);

  final PaketState _state;

  @override
  Future<PaketState> build() async => _state;
}

/// Pengganti DompetNotifier agar widget test tidak menyentuh database.
class FakeDompetNotifier extends DompetNotifier {
  FakeDompetNotifier(this._state);

  final DompetState _state;

  @override
  Future<DompetState> build() async => _state;
}

/// Pengganti KategoriNotifier agar widget test tidak menyentuh database.
class FakeKategoriNotifier extends KategoriNotifier {
  FakeKategoriNotifier(this._state);

  final KategoriState _state;

  @override
  Future<KategoriState> build() async => _state;
}

/// Pengganti TransaksiNotifier agar widget test tidak menyentuh database.
class FakeTransaksiNotifier extends TransaksiNotifier {
  int panggilanTambah = 0;
  int panggilanUbah = 0;
  int saldoPoin = 1000;

  @override
  Future<TransaksiState> build() async => const TransaksiState();

  @override
  Future<int> hitungTotalPoin(String idPelanggan) async => saldoPoin;

  @override
  Future<void> tambah(TransaksiModel model) async {
    panggilanTambah++;
  }

  @override
  Future<void> ubah(TransaksiModel model) async {
    panggilanUbah++;
  }
}

/// Pengganti PenggunaAktifNotifier agar widget test tidak menyentuh database.
class FakePenggunaAktifNotifier extends PenggunaAktifNotifier {
  int panggilanTambah = 0;
  int panggilanUbah = 0;

  @override
  Future<PelangganAktifState> build() async => const PelangganAktifState();

  @override
  Future<PelangganAktifModel> tambah(PelangganAktifModel model) async {
    panggilanTambah++;
    return PelangganAktifModel(
      id: model.id.isEmpty ? 'pa-baru' : model.id,
      idPelanggan: model.idPelanggan,
      idPaket: model.idPaket,
      tanggalMulai: model.tanggalMulai,
      tanggalBerakhir: model.tanggalBerakhir,
      status: model.status,
      idTransaksi: model.idTransaksi,
    );
  }

  @override
  Future<PelangganAktifModel> ubah(PelangganAktifModel model) async {
    panggilanUbah++;
    return model;
  }
}

void main() {
  initializeDateFormatting('id_ID', null);

  late FakeTransaksiNotifier fakeTransaksiNotifier;
  late FakePenggunaAktifNotifier fakePenggunaAktifNotifier;
  late FakePelangganNotifier fakePelangganNotifier;
  late FakePaketNotifier fakePaketNotifier;
  late FakeDompetNotifier fakeDompetNotifier;
  late FakeKategoriNotifier fakeKategoriNotifier;

  final pelangganDummy = <PelangganModel>[
    PelangganModel(
      id: 'p1',
      nama: 'Pelanggan A',
      telepon: '08123',
      alamat: 'Alamat A',
      password: 'pass',
      diperbarui: DateTime.now(),
    ),
  ];

  final paketDummy = <PaketModel>[
    PaketModel(
      id: 'pkt1',
      nama: 'Paket 1 Jam',
      harga: 5000,
      durasi: 1,
      tipe: TipeDurasi.jam,
      poinPenukaran: 0,
      poinHadiah: 10,
    ),
  ];

  final dompetDummy = <DompetModel>[
    DompetModel(
      id: 'd1',
      namaDompet: 'Dompet Utama',
      saldo: 100000,
      isDeleted: false,
    ),
  ];

  final kategoriDummy = <KategoriModel>[
    KategoriModel(
      id: 'k1',
      nama: 'Aktivasi Paket',
      tipe: TipeKategori.pemasukan,
      isDeleted: false,
    ),
  ];

  final pelangganAktifDummy = PelangganAktifModel(
    id: 'pa-dummy',
    idPelanggan: 'p1',
    idPaket: 'pkt1',
    tanggalMulai: DateTime.now(),
    tanggalBerakhir: DateTime.now().add(const Duration(hours: 1)),
    status: StatusPembayaranEnum.lunas,
  );

  Future<void> pumpForm(
    WidgetTester tester, {
    PelangganAktifModel? pelangganAktif,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transaksiProvider.overrideWith(() => fakeTransaksiNotifier),
          penggunaAktifProvider.overrideWith(() => fakePenggunaAktifNotifier),
          pelangganProvider.overrideWith(() => fakePelangganNotifier),
          paketProvider.overrideWith(() => fakePaketNotifier),
          dompetProvider.overrideWith(() => fakeDompetNotifier),
          kategoriProvider.overrideWith(() => fakeKategoriNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FormPelangganAktif(pelangganAktif: pelangganAktif),
          ),
        ),
      ),
    );
  }

  setUp(() {
    fakeTransaksiNotifier = FakeTransaksiNotifier();
    fakePenggunaAktifNotifier = FakePenggunaAktifNotifier();
    fakePelangganNotifier = FakePelangganNotifier(
      PelangganState(
        listPelanggan: pelangganDummy,
        jumlahPelanggan: pelangganDummy.length,
      ),
    );
    fakePaketNotifier = FakePaketNotifier(
      PaketState(listPaket: paketDummy, jumlahPaket: paketDummy.length),
    );
    fakeDompetNotifier = FakeDompetNotifier(
      DompetState(listDompet: dompetDummy, jumlahDompet: dompetDummy.length),
    );
    fakeKategoriNotifier = FakeKategoriNotifier(
      KategoriState(
        listKategori: kategoriDummy,
        jumlahKategori: kategoriDummy.length,
      ),
    );
  });

  testWidgets('simpan sukses (lunas)', (tester) async {
    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pelanggan_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pelanggan A').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('paket_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paket 1 Jam').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    // Beri waktu lebih dari durasi toast FToast (2 detik) agar timer-nya
    // tuntas sebelum widget tree dilepas.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(fakePenggunaAktifNotifier.panggilanTambah, 1);
    expect(fakeTransaksiNotifier.panggilanTambah, 1);
  });

  testWidgets('simpan gagal karena poin tidak cukup', (tester) async {
    fakeTransaksiNotifier.saldoPoin = 0;

    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pelanggan_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pelanggan A').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('paket_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paket 1 Jam').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(fakePenggunaAktifNotifier.panggilanTambah, 0);
    expect(fakeTransaksiNotifier.panggilanTambah, 0);
  });

  testWidgets('edit mode sukses', (tester) async {
    await pumpForm(tester, pelangganAktif: pelangganAktifDummy);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(fakePenggunaAktifNotifier.panggilanUbah, 1);
    expect(fakeTransaksiNotifier.panggilanUbah, 1);
  });
}
