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
    int migratedBuildCount = 0;
    int migratedTautanCount = 0;
    int migratedBuildDanTautanCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docRef = doc.reference;

      final dynamic nomorBuildLama = data['nomor_build_terbaru'];
      final dynamic tautanUnduhanLama = data['tautan_unduhan'];

      Map<String, dynamic> updateData = {};
      bool buildPerluMigrasi = false;
      bool tautanPerluMigrasi = false;

      // ✅ Migrasi nomor_build_terbaru
      if (nomorBuildLama != null && nomorBuildLama is! Map) {
        buildPerluMigrasi = true;

        if (nomorBuildLama is int) {
          // Data lama berupa int, konversi ke Map dengan key 'universal'
          updateData['nomor_build_terbaru'] = {
            'universal': nomorBuildLama,
            'bit_32': 0,
            'bit_64': 0,
          };
        } else if (nomorBuildLama is String &&
            int.tryParse(nomorBuildLama) != null) {
          // Data lama berupa String angka, konversi ke Map dengan key 'universal'
          updateData['nomor_build_terbaru'] = {
            'universal': int.parse(nomorBuildLama),
            'bit_32': 0,
            'bit_64': 0,
          };
        } else {
          // Data tidak valid, set default
          updateData['nomor_build_terbaru'] = {
            'universal': 0,
            'bit_32': 0,
            'bit_64': 0,
          };
        }
      }

      // ✅ Migrasi tautan_unduhan
      if (tautanUnduhanLama != null && tautanUnduhanLama is! Map) {
        tautanPerluMigrasi = true;

        if (tautanUnduhanLama is String && tautanUnduhanLama.isNotEmpty) {
          // Data lama berupa String, konversi ke Map dengan key 'universal'
          updateData['tautan_unduhan'] = {
            'universal': tautanUnduhanLama,
            'bit_32': '',
            'bit_64': '',
          };
        } else {
          // Data kosong atau tidak valid, set default
          updateData['tautan_unduhan'] = {
            'universal': '',
            'bit_32': '',
            'bit_64': '',
          };
        }
      }

      // ✅ Update jika ada yang perlu dimigrasi
      if (updateData.isNotEmpty) {
        batch.update(docRef, updateData);

        if (buildPerluMigrasi && tautanPerluMigrasi) {
          migratedBuildDanTautanCount++;
        } else if (buildPerluMigrasi) {
          migratedBuildCount++;
        } else if (tautanPerluMigrasi) {
          migratedTautanCount++;
        }
      }
    }

    // ✅ Log hasil migrasi
    if (migratedBuildCount > 0) {
      logs.add(
        '  - [nomor_build_terbaru] $migratedBuildCount dokumen akan dimigrasi.',
      );
    }
    if (migratedTautanCount > 0) {
      logs.add(
        '  - [tautan_unduhan] $migratedTautanCount dokumen akan dimigrasi.',
      );
    }
    if (migratedBuildDanTautanCount > 0) {
      logs.add(
        '  - [nomor_build + tautan] $migratedBuildDanTautanCount dokumen akan dimigrasi.',
      );
    }

    final totalMigrated =
        migratedBuildCount + migratedTautanCount + migratedBuildDanTautanCount;
    if (totalMigrated > 0) {
      logs.add(
        '  Total: $totalMigrated dokumen di `versi_apk_user` akan dimigrasi.',
      );
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
