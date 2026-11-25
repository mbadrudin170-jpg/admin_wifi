// path: lib/fitur/kritik_saran/screens/detail_kritik_saran.dart

import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:admin_wifi/fitur/kritik_saran/notifier/kritik_saran_notifier.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';

class DetailKritikSaranPage extends ConsumerStatefulWidget {
  final String id;

  const DetailKritikSaranPage({super.key, required this.id});

  @override
  ConsumerState<DetailKritikSaranPage> createState() =>
      _DetailKritikSaranPageState();
}

class _DetailKritikSaranPageState extends ConsumerState<DetailKritikSaranPage> {
  @override
  void initState() {
    super.initState();

    L.i('Membuka halaman detail kritik dan saran dengan ID: ${widget.id}.');
  }

  /// Fungsi untuk menghapus kritik saran
  Future<void> _hapusKritikSaran() async {
    L.i('Menampilkan dialog konfirmasi penghapusan kritik dan saran.');

    final konfirmasi = await showOkCancelAlertDialog(
      context: context,
      title: 'Konfirmasi Hapus',
      message: 'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
      okLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructiveAction: true,
    );

    if (konfirmasi != OkCancelResult.ok) {
      L.w('Pengguna membatalkan proses penghapusan kritik dan saran.');
      return;
    }

    L.i('Pengguna mengonfirmasi penghapusan kritik dan saran.');

    if (!mounted) return;

    try {
      unawaited(
        EasyLoading.show(
          status: 'Menghapus...',
          maskType: EasyLoadingMaskType.black,
        ).catchError((Object e, StackTrace s) {
          L.e('Gagal menampilkan loading: $e $s');
        }),
      );

      L.i('Memanggil operasi hapus kritik dan saran ke database.');

      await ref.read(kritikSaranProvider.notifier).hapusKritikSaran(widget.id);

      L.i('Data kritik dan saran berhasil dihapus dari database.');

      if (mounted) {
        AppToast.sukses(context, 'Kritik dan saran berhasil dihapus');
      }

      if (mounted) {
        L.i('Kembali ke halaman sebelumnya dengan status sukses.');
        Nav.pop(context, true);
      }
    } catch (e, stackTrace) {
      L.e(
        'Terjadi kesalahan saat menghapus kritik dan saran. Error: $e $stackTrace',
      );

      if (mounted) {
        AppToast.gagal(context, 'Gagal menghapus: $e');
      }
    } finally {
      unawaited(
        EasyLoading.dismiss().catchError((Object e, StackTrace s) {
          L.e('Gagal menutup loading: $e $s');
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI halaman detail kritik dan saran.');

    final asyncKritikSaran = ref.watch(kritikSaranProvider);

    if (asyncKritikSaran.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (asyncKritikSaran.hasError) {
      return Scaffold(
        body: Center(child: Text('Error: ${asyncKritikSaran.error}')),
      );
    }

    final kritikSaran = asyncKritikSaran.requireValue.getKritikSaranById(
      widget.id,
    );
    if (kritikSaran == null) {
      return const Scaffold(
        body: Center(child: Text('Data tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kritik & Saran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _hapusKritikSaran,
            tooltip: 'Hapus Kritik & Saran',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_pin,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NamaPelangganWidget(
                        idPelanggan: kritikSaran.userId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pesan:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kritikSaran.isi,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const Divider(height: 40),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    FormatTanggal.formatDasar(kritikSaran.tanggal),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
