// path: lib/dummy/dummy_screen.dart

import 'package:admin_wifi/dummy/dummy_helper.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/widget/toast_widget.dart';

class DummyScreen extends ConsumerStatefulWidget {
  const DummyScreen({super.key});

  @override
  ConsumerState<DummyScreen> createState() => _DummyScreenState();
}

class _DummyScreenState extends ConsumerState<DummyScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    L.i('Halaman Data Dummy diinisialisasi.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Dummy')),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: _isProcessing ? null : _tambahSemuaDummy,
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Tambah Semua Dummy'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _risetSemuaDummy,
                      icon: const Icon(Icons.restore),
                      label: const Text('Riset Semua Dummy'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isProcessing ? null : _hapusSemuaDummy,
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Hapus Semua Dummy'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _tambahSemuaDummy() async {
    if (_isProcessing) return;
    L.i('Meminta penambahan semua data dummy.');
    setState(() {
      _isProcessing = true;
    });

    try {
      await DummyHelper.tambahSemuaDummy();
      _invalidateProvider();
      if (!mounted) return;
      AppToast.sukses(context, 'Semua data dummy berhasil ditambahkan.');
    } catch (e, s) {
      L.e('Gagal menambahkan semua data dummy. Error: $e $s');
      if (!mounted) return;
      AppToast.gagal(context, 'Gagal menambahkan data dummy: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _risetSemuaDummy() async {
    if (_isProcessing) return;

    final konfirmasi = await _tampilkanKonfirmasi(
      judul: 'Konfirmasi Riset Semua Dummy',
      pesan:
          'Hapus lalu tambahkan kembali semua data dummy? Data pengguna biasa tidak terpengaruh.',
      labelAksi: 'Riset',
    );
    if (konfirmasi != true || !mounted) return;

    L.i('Meminta riset semua data dummy.');
    setState(() {
      _isProcessing = true;
    });

    try {
      await DummyHelper.risetSemuaDummy();
      _invalidateProvider();
      if (!mounted) return;
      AppToast.sukses(context, 'Semua data dummy berhasil direset.');
    } catch (e, s) {
      L.e('Gagal mereset semua data dummy. Error: $e $s');
      if (!mounted) return;
      AppToast.gagal(context, 'Gagal mereset data dummy: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _hapusSemuaDummy() async {
    if (_isProcessing) return;

    final konfirmasi = await _tampilkanKonfirmasi(
      judul: 'Konfirmasi Hapus Semua Dummy',
      pesan:
          'Hapus permanen semua data dummy? Data pengguna biasa tidak terpengaruh.',
      labelAksi: 'Hapus',
      hapus: true,
    );
    if (konfirmasi != true || !mounted) return;

    L.i('Meminta penghapusan semua data dummy.');
    setState(() {
      _isProcessing = true;
    });

    try {
      await DummyHelper.hapusSemuaDummy();
      _invalidateProvider();
      if (!mounted) return;
      AppToast.sukses(context, 'Semua data dummy berhasil dihapus.');
    } catch (e, s) {
      L.e('Gagal menghapus semua data dummy. Error: $e $s');
      if (!mounted) return;
      AppToast.gagal(context, 'Gagal menghapus data dummy: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _invalidateProvider() {
    ref.invalidate(penggunaAktifProvider);
    ref.invalidate(pelangganProvider);
    ref.invalidate(paketProvider);
    ref.invalidate(dompetProvider);
  }

  Future<bool?> _tampilkanKonfirmasi({
    required String judul,
    required String pesan,
    required String labelAksi,
    bool hapus = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(judul),
          content: Text(pesan),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                labelAksi,
                style: TextStyle(
                  color: hapus ? Theme.of(context).colorScheme.error : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
