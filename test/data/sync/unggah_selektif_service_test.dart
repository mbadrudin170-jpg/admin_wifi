import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/data/sync/unggah_selektif_service.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/enum/nama_tabel_enum.dart';
import 'package:admin_wifi/model/status_unggah_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'unggah_selektif_service_test.mocks.dart';

// Anotasi untuk menghasilkan file mock
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  WriteBatch,
  StatusUnggahOperasi,
  DompetOperasi,
], customMocks: [
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(as: #MockQuerySnapshot),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(as: #MockDocumentSnapshot),
])
void main() {
  // Deklarasi variabel mock
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockWriteBatch mockWriteBatch;
  late MockStatusUnggahOperasi mockStatusUnggahOperasi;
  late MockDompetOperasi mockDompetOperasi;
  
  // Instance dari kelas yang akan diuji
  late UnggahSelektifService unggahSelektifService;

  // Data palsu untuk pengujian
  final idDompet1 = 'dompet-id-1';
  final idDompet2 = 'dompet-id-2';
  final dompet1 = DompetModel(id: idDompet1, namaDompet: 'Dompet A', saldo: 1000, diperbarui: DateTime.now());
  final dompet2 = DompetModel(id: idDompet2, namaDompet: 'Dompet B', saldo: 2000, diperbarui: DateTime.now());

  setUp(() {
    // Inisialisasi Mocks
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockWriteBatch = MockWriteBatch();
    mockStatusUnggahOperasi = MockStatusUnggahOperasi();
    mockDompetOperasi = MockDompetOperasi();

    // diubah: Menyuntikkan mock langsung ke konstruktor
    unggahSelektifService = UnggahSelektifService(
      firestore: mockFirestore,
      statusOperasi: mockStatusUnggahOperasi,
      dompetOperasi: mockDompetOperasi,
    );

    // Stubbing default untuk Firestore
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocRef);
    when(mockFirestore.batch()).thenReturn(mockWriteBatch);
  });

  group('UnggahSelektifService', () {

    test('tidak melakukan apa-apa jika tidak ada data untuk diunggah', () async {
      // ARRANGE
      when(mockStatusUnggahOperasi.ambilSemuaStatusUnggah()).thenAnswer((_) async => []);

      // ACT
      await unggahSelektifService.unggahPerubahanTertunda();

      // ASSERT
      verify(mockStatusUnggahOperasi.ambilSemuaStatusUnggah()).called(1);
      verifyNever(mockDompetOperasi.getDompetByIds(any));
      verifyNever(mockFirestore.batch());
    });

    test('mengunggah data dompet dan mereset status saat berhasil', () async {
      // ARRANGE
      final statusList = [
        StatusUnggahModel(tabel: NamaTabel.dompet, status: true, ids: [idDompet1, idDompet2]),
      ];
      final List<DompetModel> dompetList = [dompet1, dompet2];

      when(mockStatusUnggahOperasi.ambilSemuaStatusUnggah()).thenAnswer((_) async => statusList);
      when(mockDompetOperasi.getDompetByIds(any)).thenAnswer((_) async => dompetList);
      when(mockStatusUnggahOperasi.resetStatus(any)).thenAnswer((_) async => Future.value());
      
      // ACT
      await unggahSelektifService.unggahPerubahanTertunda();

      // ASSERT
      verify(mockStatusUnggahOperasi.ambilSemuaStatusUnggah()).called(1);
      verify(mockDompetOperasi.getDompetByIds([idDompet1, idDompet2])).called(1);
      verify(mockFirestore.batch()).called(1);
      verify(mockCollection.doc(idDompet1)).called(1);
      verify(mockWriteBatch.set(any, dompet1.toMapForFirebase(), any)).called(1);
      verify(mockCollection.doc(idDompet2)).called(1);
      verify(mockWriteBatch.set(any, dompet2.toMapForFirebase(), any)).called(1);
      verify(mockWriteBatch.commit()).called(1);
      verify(mockStatusUnggahOperasi.resetStatus(NamaTabel.dompet)).called(1);
    });

    test('tidak mereset status jika unggah ke Firestore gagal', () async {
      // ARRANGE
      final statusList = [
        StatusUnggahModel(tabel: NamaTabel.dompet, status: true, ids: [idDompet1]),
      ];
      final List<DompetModel> dompetList = [dompet1];

      when(mockStatusUnggahOperasi.ambilSemuaStatusUnggah()).thenAnswer((_) async => statusList);
      when(mockDompetOperasi.getDompetByIds(any)).thenAnswer((_) async => dompetList);
      when(mockWriteBatch.commit()).thenThrow(Exception('Firestore error'));

      // ACT
      await unggahSelektifService.unggahPerubahanTertunda();
      
      // ASSERT
      verify(mockStatusUnggahOperasi.ambilSemuaStatusUnggah()).called(1);
      verify(mockDompetOperasi.getDompetByIds(any)).called(1);
      verify(mockWriteBatch.commit()).called(1);
      verifyNever(mockStatusUnggahOperasi.resetStatus(any));
    });

     test('mereset status meskipun tidak ada data dompet yang ditemukan', () async {
      // ARRANGE
      final statusList = [
        StatusUnggahModel(tabel: NamaTabel.dompet, status: true, ids: ['id-hilang']),
      ];

      when(mockStatusUnggahOperasi.ambilSemuaStatusUnggah()).thenAnswer((_) async => statusList);
      when(mockDompetOperasi.getDompetByIds(any)).thenAnswer((_) async => []);

      // ACT
      await unggahSelektifService.unggahPerubahanTertunda();

      // ASSERT
      verify(mockStatusUnggahOperasi.ambilSemuaStatusUnggah()).called(1);
      verify(mockDompetOperasi.getDompetByIds(['id-hilang'])).called(1);
      verifyNever(mockFirestore.batch());
      verifyNever(mockWriteBatch.commit());
      verify(mockStatusUnggahOperasi.resetStatus(NamaTabel.dompet)).called(1);
    });

  });
}
