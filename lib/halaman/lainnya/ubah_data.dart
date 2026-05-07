// path: lib/halaman/lainnya/ubah_data.dart
import 'package:admin_wifi/services/firebase_migration/firebase_migration_service.dart';
import 'package:flutter/material.dart';

class UbahDataPage extends StatefulWidget {
  const UbahDataPage({super.key});

  @override
  State<UbahDataPage> createState() => _UbahDataPageState();
}

class _UbahDataPageState extends State<UbahDataPage> {
  final FirebaseMigrationService _migrationService = FirebaseMigrationService();
  bool _isLoading = false;
  final List<String> _progressLogs = [];

  void _runMigration() async {
    setState(() {
      _isLoading = true;
      _progressLogs.clear();
    });

    try {
      final logs = await _migrationService.runAllMigrations((message) {
        setState(() {
          _progressLogs.add(message);
        });
      });
      setState(() {
        _progressLogs.addAll(logs);
      });
    } catch (e) {
      setState(() {
        _progressLogs.add('❌ Terjadi kesalahan: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Migrasi Data Firebase')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Klik tombol di bawah untuk memulai proses migrasi data di Firebase. Proses ini akan mengubah tipe data kolom `isDeleted` dari Angka (0 atau 1) menjadi Boolean (true atau false), dan memperbarui struktur data koleksi `versi_apk_user`. Pastikan Anda memiliki koneksi internet yang stabil.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_sync),
              label: Text(
                _isLoading ? 'Memigrasi...' : 'Mulai Migrasi Data Firebase',
              ),
              onPressed: _isLoading ? null : _runMigration,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Log Progres:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.builder(
                  itemCount: _progressLogs.length,
                  itemBuilder: (context, index) {
                    final log = _progressLogs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        log,
                        style: TextStyle(
                          color: log.startsWith('✅')
                              ? Colors.green
                              : log.startsWith('❌')
                              ? Colors.red
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
