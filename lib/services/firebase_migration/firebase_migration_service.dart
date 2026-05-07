// path: lib/services/firebase_migration/firebase_migration_service.dart
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Daftar koleksi untuk migrasi `isDeleted`
  final List<String> _isDeletedCollections = [
    'dompet',
    'kategori',
    'paket',
    'pelanggan_aktif',
    'pelanggan',
    'pesanan',
    'riwayat_langganan',
    'sub_kategori',
    'transaksi',
    'versi_apk_user',
  ];

  // Migrasi untuk field `isDeleted` dari int ke bool
  Future<void> _migrateIsDeleted(
    String collectionName,
    WriteBatch batch,
    List<String> logs,
  ) async {
    final QuerySnapshot snapshot = await _firestore
        .collection(collectionName)
        .get();
    int migratedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('isDeleted')) {
        final currentValue = data['isDeleted'];
        if (currentValue is int) {
          final bool newValue = currentValue == 1;
          batch.update(doc.reference, {'isDeleted': newValue});
          migratedCount++;
        }
      }
    }

    if (migratedCount > 0) {
      logs.add(
        '  - [isDeleted] $migratedCount dokumen akan dimigrasi di `$collectionName`.',
      );
    }
  }

  // Migrasi untuk field di koleksi `versi_apk_user`
  Future<void> _migrateVersiApkUser(WriteBatch batch, List<String> logs) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('versi_apk_user')
        .get();
    int migratedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docRef = doc.reference;

      final nomorBuild = data['nomor_build_terbaru'];
      final tautanUnduhan = data['tautan_unduhan'];

      bool needsMigration = false;
      Map<String, dynamic> updateData = {};

      if (nomorBuild is int) {
        needsMigration = true;
        updateData['nomor_build_terbaru'] = {'universal': nomorBuild};
      } else if (nomorBuild is String && int.tryParse(nomorBuild) != null) {
        needsMigration = true;
        updateData['nomor_build_terbaru'] = {
          'universal': int.parse(nomorBuild),
        };
      }

      if (tautanUnduhan is String && tautanUnduhan.isNotEmpty) {
        // Hanya migrasi jika bukan Map
        if (data['tautan_unduhan'] is! Map) {
          needsMigration = true;
          updateData['tautan_unduhan'] = {'universal': tautanUnduhan};
        }
      }

      if (needsMigration) {
        batch.update(docRef, updateData);
        migratedCount++;
      }
    }
    if (migratedCount > 0) {
      logs.add('  - [VersiApkUser] $migratedCount dokumen akan dimigrasi.');
    }
  }

  Future<List<String>> runAllMigrations(
    Function(String message) onProgress,
  ) async {
    onProgress('Memulai semua migrasi...');
    final WriteBatch batch = _firestore.batch();
    final List<String> logs = [];
    int totalMigrations = 0;

    // 1. Jalankan migrasi 'isDeleted' untuk semua koleksi terkait
    onProgress('Menganalisis migrasi `isDeleted`...');
    for (final collectionName in _isDeletedCollections) {
      try {
        List<String> collectionLogs = [];
        await _migrateIsDeleted(collectionName, batch, collectionLogs);
        if (collectionLogs.isNotEmpty) {
          logs.addAll(collectionLogs);
          totalMigrations++;
        }
      } catch (e, s) {
        final message =
            '❌ Error saat menganalisis migrasi isDeleted untuk $collectionName: $e';
        developer.log(message, name: 'Migration', error: e, stackTrace: s);
        onProgress(message);
        throw Exception(
          'Migrasi dihentikan karena error pada koleksi $collectionName.',
        );
      }
    }
    if (totalMigrations == 0) {
      logs.add('Tidak ada migrasi `isDeleted` yang perlu dilakukan.');
    }

    int versiApkMigrations = 0;
    // 2. Jalankan migrasi `versi_apk_user`
    onProgress('Menganalisis migrasi `versi_apk_user`...');
    try {
      List<String> versiApkLogs = [];
      await _migrateVersiApkUser(batch, versiApkLogs);
      if (versiApkLogs.isNotEmpty) {
        logs.addAll(versiApkLogs);
        versiApkMigrations++;
      }
    } catch (e, s) {
      final message = '❌ Error saat menganalisis migrasi versi_apk_user: $e';
      developer.log(message, name: 'Migration', error: e, stackTrace: s);
      onProgress(message);
      throw Exception(
        'Migrasi dihentikan karena error pada koleksi versi_apk_user.',
      );
    }
    if (versiApkMigrations == 0) {
      logs.add('Tidak ada migrasi `versi_apk_user` yang perlu dilakukan.');
    }

    if (totalMigrations > 0 || versiApkMigrations > 0) {
      // 3. Commit semua perubahan
      onProgress('Menjalankan semua perubahan...');
      try {
        await batch.commit();
        onProgress('🎉 Semua migrasi telah selesai dengan sukses!');
      } catch (e, s) {
        final message = '❌ Gagal melakukan commit perubahan: $e';
        developer.log(
          message,
          name: 'Migration.Commit',
          error: e,
          stackTrace: s,
        );
        onProgress(message);
        throw Exception('Gagal menyimpan perubahan ke Firestore.');
      }
    } else {
      onProgress('ℹ️ Tidak ada data yang perlu dimigrasi.');
    }

    return logs;
  }
}
