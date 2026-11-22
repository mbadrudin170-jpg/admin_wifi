// path: test/halaman/tab/transaksi_test.dart
// diubah: Menghapus parameter namaDompet dan namaKategori yang sudah usang dari fungsi helper.

import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/dompet/state/dompet_state.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/kategori/state/kategori_state.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/paket/state/paket_state.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/state/pelanggan_state.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/screens/transaksi_screen.dart';
import 'package:admin_wifi/fitur/transaksi/state/transaksi_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';

import '../../mocks.dart';

class FakeTransaksiNotifier extends TransaksiNotifier {
  FakeTransaksiNotifier({
    this.delay = Duration.zero,
    this.initialState = const TransaksiState(),
    this.error,
  });

  final Duration delay;
  final TransaksiState initialState;
  final Object? error;

  @override
  Future<TransaksiState> build() async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (error != null) {
      throw error!;
    }
    return initialState;
  }
}

class FakeDompetNotifier extends DompetNotifier {
  @override
  Future<DompetState> build() async => const DompetState();
}

class FakeKategoriNotifier extends KategoriNotifier {
  @override
  Future<KategoriState> build() async => const KategoriState();
}

class FakePelangganNotifier extends PelangganNotifier {
  @override
  Future<PelangganState> build() async => const PelangganState();
}

class FakePaketNotifier extends PaketNotifier {
  @override
  Future<PaketState> build() async => const PaketState();
}

TransaksiModel buatTransaksi({
  required String id,
  required String keterangan,
  required double jumlah,
  required TipeTransaksi tipe,
  required DateTime tanggal,
}) {
  return TransaksiModel(
    id: id,
    keterangan: keterangan,
    jumlah: jumlah,
    tipe: tipe,
    idDompet: 'dompet-1',
    idKategori: 'kat-1',
    tanggal: tanggal,
  );
}

void main() {
  late MockNavigatorObserver mockNavigatorObserver;

  final pemasukan1 = buatTransaksi(
    id: '1',
    keterangan: 'Gaji Mei',
    jumlah: 100000,
    tipe: TipeTransaksi.pemasukan,
    tanggal: DateTime(2026, 5, 5, 9, 0),
  );
  final pengeluaran1 = buatTransaksi(
    id: '2',
    keterangan: 'Beli Kopi',
    jumlah: 25000,
    tipe: TipeTransaksi.pengeluaran,
    tanggal: DateTime(2026, 5, 5, 15, 30),
  );
  final pemasukan2 = buatTransaksi(
    id: '3',
    keterangan: 'Bonus Proyek',
    jumlah: 75000,
    tipe: TipeTransaksi.pemasukan,
    tanggal: DateTime(2026, 5, 6, 11, 0),
  );

  final semuaTransaksi = [pemasukan1, pengeluaran1, pemasukan2];

  setUpAll(() {
    initializeDateFormatting('id_ID');
  });

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(
      MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink()),
    );
  });

  Future<void> pumpTransaksiPage(
    WidgetTester tester, {
    Duration delay = Duration.zero,
    TransaksiState state = const TransaksiState(),
    Object? error,
  }) async {
    final fake = FakeTransaksiNotifier(
      delay: delay,
      initialState: state,
      error: error,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transaksiProvider.overrideWith(() => fake),
          dompetProvider.overrideWith(() => FakeDompetNotifier()),
          kategoriProvider.overrideWith(() => FakeKategoriNotifier()),
          pelangganProvider.overrideWith(() => FakePelangganNotifier()),
          paketProvider.overrideWith(() => FakePaketNotifier()),
        ],
        child: MaterialApp(
          home: TransaksiPage(),
          navigatorObservers: [mockNavigatorObserver],
        ),
      ),
    );
  }

  group('TransaksiPage Widget Tests', () {
    testWidgets('menampilkan CircularProgressIndicator saat loading', (
      tester,
    ) async {
      await pumpTransaksiPage(tester, delay: const Duration(seconds: 2));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('menampilkan pesan error saat terjadi kegagalan', (
      tester,
    ) async {
      await pumpTransaksiPage(tester, error: Exception('Database Error'));
      await tester.pumpAndSettle();
      expect(
        find.text('Gagal memuat data transaksi: Exception: Database Error'),
        findsOneWidget,
      );
    });

    testWidgets('menampilkan pesan saat tidak ada transaksi', (tester) async {
      await pumpTransaksiPage(tester);
      await tester.pumpAndSettle();
      expect(find.text('Tidak ada transaksi ditemukan.'), findsOneWidget);
    });

    testWidgets(
      'menampilkan data ringkasan dan daftar transaksi dengan benar saat sukses',
      (tester) async {
        await pumpTransaksiPage(
          tester,
          state: TransaksiState(listTransaksi: semuaTransaksi),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('Pemasukan')), findsOneWidget);
        expect(find.byKey(const ValueKey('Pengeluaran')), findsOneWidget);
        expect(find.byKey(const ValueKey('Total')), findsOneWidget);

        final item1Finder = find.byKey(const ValueKey('3'));
        expect(item1Finder, findsOneWidget);
        expect(
          find.descendant(of: item1Finder, matching: find.text('Bonus Proyek')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: item1Finder, matching: find.text('Rp 75.000')),
          findsOneWidget,
        );

        final item2Finder = find.byKey(const ValueKey('1'));
        expect(item2Finder, findsOneWidget);
        expect(
          find.descendant(of: item2Finder, matching: find.text('Gaji Mei')),
          findsOneWidget,
        );

        final item3Finder = find.byKey(const ValueKey('2'));
        expect(item3Finder, findsOneWidget);
        expect(
          find.descendant(of: item3Finder, matching: find.text('Beli Kopi')),
          findsOneWidget,
        );
      },
    );

    testWidgets('menavigasi ke DetailTransaksiPage saat item di-tap', (
      tester,
    ) async {
      await pumpTransaksiPage(
        tester,
        state: TransaksiState(listTransaksi: semuaTransaksi),
      );
      await tester.pumpAndSettle();

      clearInteractions(mockNavigatorObserver);

      final itemToTap = find.byKey(const ValueKey('2'));
      expect(itemToTap, findsOneWidget);
      await tester.tap(itemToTap);
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
    });
  });
}
