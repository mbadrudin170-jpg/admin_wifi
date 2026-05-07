// test/data/sync/unggah_selektif_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/data/operasi/sub_kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/data/sync/unggah_selektif_service.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/enum/nama_tabel_enum.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'package:admin_wifi/model/status_unggah_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/riwayat_langganan_model.dart';
import 'package:admin_wifi/model/pesanan_model.dart';

import 'unggah_selektif_service_test.mocks.dart';

@GenerateMocks([
  StatusUnggahOperasi,
  DompetOperasi,
  KategoriOperasi,
  KritikSaranOperasi,
  PaketOperasi,
  PelangganAktifOperasi,
  PelangganOperasi,
  PengaturanOperasi,
  PesananOperasi,
  RiwayatLanggananOperasi,
  SubKategoriOperasi,
  TransaksiOperasi,
  VersiApkUserOperasi,
])
void main() {
  late UnggahSelektifService service;
  late FakeFirebaseFirestore fakeFirestore;
  late MockStatusUnggahOperasi mockStatusOperasi;
  late MockDompetOperasi mockDompetOperasi;
  late MockKategoriOperasi mockKategoriOperasi;
  late MockKritikSaranOperasi mockKritikSaranOperasi;
  late MockPaketOperasi mockPaketOperasi;
  late MockPelangganAktifOperasi mockPelangganAktifOperasi;
  late MockPelangganOperasi mockPelangganOperasi;
  late MockPengaturanOperasi mockPengaturanOperasi;
  late MockPesananOperasi mockPesananOperasi;
  late MockRiwayatLanggananOperasi mockRiwayatLanggananOperasi;
  late MockSubKategoriOperasi mockSubKategoriOperasi;
  late MockTransaksiOperasi mockTransaksiOperasi;
  late MockVersiApkUserOperasi mockVersiApkUserOperasi;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockStatusOperasi = MockStatusUnggahOperasi();
    mockDompetOperasi = MockDompetOperasi();
    mockKategoriOperasi = MockKategoriOperasi();
    mockKritikSaranOperasi = MockKritikSaranOperasi();
    mockPaketOperasi = MockPaketOperasi();
    mockPelangganAktifOperasi = MockPelangganAktifOperasi();
    mockPelangganOperasi = MockPelangganOperasi();
    mockPengaturanOperasi = MockPengaturanOperasi();
    mockPesananOperasi = MockPesananOperasi();
    mockRiwayatLanggananOperasi = MockRiwayatLanggananOperasi();
    mockSubKategoriOperasi = MockSubKategoriOperasi();
    mockTransaksiOperasi = MockTransaksiOperasi();
    mockVersiApkUserOperasi = MockVersiApkUserOperasi();

    service = UnggahSelektifService(
      firestore: fakeFirestore,
      statusOperasi: mockStatusOperasi,
      dompetOperasi: mockDompetOperasi,
      kategoriOperasi: mockKategoriOperasi,
      kritikSaranOperasi: mockKritikSaranOperasi,
      paketOperasi: mockPaketOperasi,
      pelangganAktifOperasi: mockPelangganAktifOperasi,
      pelangganOperasi: mockPelangganOperasi,
      pengaturanOperasi: mockPengaturanOperasi,
      pesananOperasi: mockPesananOperasi,
      riwayatLanggananOperasi: mockRiwayatLanggananOperasi,
      subKategoriOperasi: mockSubKategoriOperasi,
      transaksiOperasi: mockTransaksiOperasi,
      versiApkUserOperasi: mockVersiApkUserOperasi,
    );
  });

  group('unggahPerubahanTertunda', () {
    test('should do nothing if there are no pending changes', () async {
      when(mockStatusOperasi.ambilSemuaStatusUnggah()).thenAnswer((_) async => []);
      await service.unggahPerubahanTertunda();
      verify(mockStatusOperasi.ambilSemuaStatusUnggah()).called(1);
      verifyNoMoreInteractions(mockDompetOperasi);
    });

    test('should upload data for a single table and reset status', () async {
      final status = StatusUnggahModel(tabel: NamaTabel.dompet, ids: ['id1'], status: true);
      final dompet = DompetModel(id: 'id1', nama: 'Test', saldo: 100);

      when(mockStatusOperasi.ambilSemuaStatusUnggah()).thenAnswer((_) async => [status]);
      when(mockDompetOperasi.getDompetByIds(any)).thenAnswer((_) async => [dompet]);
      when(mockStatusOperasi.resetStatus(any)).thenAnswer((_) async {});

      await service.unggahPerubahanTertunda();

      final doc = await fakeFirestore.collection('dompet').doc('id1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['nama'], 'Test');

      verify(mockDompetOperasi.getDompetByIds(['id1'])).called(1);
      verify(mockStatusOperasi.resetStatus(NamaTabel.dompet)).called(1);
    });

    test('should handle settings upload correctly', () async {
      final status = StatusUnggahModel(tabel: NamaTabel.pengaturan, ids: ['ignored'], status: true);
      final pengaturan = PengaturanModel(intervalSinkronisasiOtomatis: 8);

      when(mockStatusOperasi.ambilSemuaStatusUnggah()).thenAnswer((_) async => [status]);
      when(mockPengaturanOperasi.getPengaturan()).thenAnswer((_) async => pengaturan);
      when(mockStatusOperasi.resetStatus(any)).thenAnswer((_) async {});

      await service.unggahPerubahanTertunda();

      final doc = await fakeFirestore.collection('pengaturan').doc('default').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['interval_sinkronisasi_otomatis'], 8);

      verify(mockPengaturanOperasi.getPengaturan()).called(1);
      verify(mockStatusOperasi.resetStatus(NamaTabel.pengaturan)).called(1);
    });

    test('should not reset status if upload fails', () async {
      final status = StatusUnggahModel(tabel: NamaTabel.dompet, ids: ['id1'], status: true);
      
      when(mockStatusOperasi.ambilSemuaStatusUnggah()).thenAnswer((_) async => [status]);
      when(mockDompetOperasi.getDompetByIds(any)).thenThrow(Exception('DB error'));

      await service.unggahPerubahanTertunda();

      verify(mockDompetOperasi.getDompetByIds(any)).called(1);
      verifyNever(mockStatusOperasi.resetStatus(any));
    });

    test('should continue with next table if one fails', async () {
      final status1 = StatusUnggahModel(tabel: NamaTabel.dompet, ids: ['id1'], status: true);
      final status2 = StatusUnggahModel(tabel: NamaTabel.transaksi, ids: ['id2'], status: true);
      final transaksi = TransaksiModel.create(idDompet: 'd1', jumlah: 50, tipe: TipeTransaksi.pemasukan);

      when(mockStatusOperasi.ambilSemuaStatusUnggah()).thenAnswer((_) async => [status1, status2]);
      when(mockDompetOperasi.getDompetByIds(any)).thenThrow(Exception('DB error'));
      when(mockTransaksiOperasi.getTransaksiByIds(any)).thenAnswer((_) async => [transaksi]);
      when(mockStatusOperasi.resetStatus(any)).thenAnswer((_) async {});
      
      await service.unggahPerubahanTertunda();

      // Verify first one failed
      verify(mockDompetOperasi.getDompetByIds(any)).called(1);
      verifyNever(mockStatusOperasi.resetStatus(NamaTabel.dompet));

      // Verify second one succeeded
      final doc = await fakeFirestore.collection('transaksi').doc(transaksi.id).get();
      expect(doc.exists, isTrue);
      verify(mockTransaksiOperasi.getTransaksiByIds(any)).called(1);
      verify(mockStatusOperasi.resetStatus(NamaTabel.transaksi)).called(1);
    });
  });
}
