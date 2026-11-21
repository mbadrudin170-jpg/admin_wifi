// path: lib/fitur/kritik_saran/screens/kritik_saran.dart

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/fitur/kritik_saran/notifier/kritik_saran_notifier.dart';
import 'package:admin_wifi/fitur/kritik_saran/screens/detail_kritik_saran.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/widget/toast_widget.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

class KritikSaranPage extends ConsumerStatefulWidget {
  const KritikSaranPage({super.key});

  @override
  ConsumerState<KritikSaranPage> createState() => _KritikSaranPageState();
}

class _KritikSaranPageState extends ConsumerState<KritikSaranPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _hapusKritikSaran(KritikSaranModel item) async {
    L.i(
      'Menampilkan konfirmasi hapus untuk kritik/saran ID: ${item.id}, User ID: ${item.userId}',
    );

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
        L.i(
          'Menjalankan operasi hapus kritik/saran ID: ${item.id} dari database',
        );
        await ref.read(kritikSaranProvider.notifier).hapusKritikSaran(item.id);

        L.i('Kritik/saran ID: ${item.id} berhasil dihapus dari database');

        if (mounted) {
          AppToast.sukses(context, 'Kritik dan saran berhasil dihapus');
        }
      } catch (e, stackTrace) {
        L.e(
          'Gagal menghapus kritik/saran ID: ${item.id} dari database Error: $e $stackTrace',
        );
        if (mounted) {
          AppToast.gagal(context, 'Gagal menghapus: $e');
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI halaman Kritik & Saran');
    final asyncKritikSaran = ref.watch(kritikSaranProvider);

    if (asyncKritikSaran.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (asyncKritikSaran.hasError) {
      L.e(
        'Terjadi error saat memuat data kritik dan saran Error: ${asyncKritikSaran.error}',
      );
      return Scaffold(
        body: Center(child: Text('Error: ${asyncKritikSaran.error}')),
      );
    }

    final listKritikSaran = asyncKritikSaran.requireValue.listKritikSaran;
    if (listKritikSaran.isEmpty) {
      L.i('Data kritik dan saran kosong, belum ada kritik dan saran');
      return Scaffold(
        appBar: AppBar(title: const Text('Kritik & Saran')),
        body: const Center(child: Text('Belum ada kritik dan saran.')),
      );
    }

    L.i(
      'Menampilkan ${listKritikSaran.length} item kritik dan saran dalam daftar',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Kritik & Saran')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: listKritikSaran.length,
        itemBuilder: (context, index) {
          final item = listKritikSaran[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                L.i(
                  'Navigasi ke halaman Detail Kritik/Saran ID: ${item.id}',
                );
                await Nav.to(
                  context,
                  DetailKritikSaranPage(id: item.id),
                );
              },
              onLongPress: () {
                L.i(
                  'Long press pada kritik/saran ID: ${item.id}, menampilkan menu hapus',
                );
                _hapusKritikSaran(item);
              },
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
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        NamaPelangganWidget(
                          idPelanggan: item.userId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.isi,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const Divider(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        FormatTanggal.formatTanggalDanJam(item.tanggal),
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
          );
        },
      ),
    );
  }
}
