// path: lib/fitur/kritik_saran/screens/detail_kritik_saran.dart

import 'package:admin_wifi/fitur/kritik_saran/notifier/kritik_saran_notifier.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

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

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        L.i('Dialog konfirmasi penghapusan berhasil ditampilkan.');

        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                L.w(
                  'Pengguna membatalkan proses penghapusan kritik dan saran.',
                );

                Nav.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                L.i('Pengguna mengonfirmasi penghapusan kritik dan saran.');

                Nav.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    L.i('Dialog konfirmasi selesai diproses dengan hasil: $konfirmasi.');

    if (konfirmasi == true && mounted) {
      L.i('Memulai proses penghapusan data kritik dan saran.');

      try {
        L.i('Menampilkan loading dialog selama proses penghapusan.');

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            L.i('Loading dialog berhasil ditampilkan.');

            return const Center(child: CircularProgressIndicator());
          },
        );

        L.i('Memanggil operasi hapus kritik dan saran ke database.');

        await ref.read(kritikSaranProvider.notifier).hapusKritikSaran(widget.id);

        L.i('Data kritik dan saran berhasil dihapus dari database.');

        if (mounted) {
          L.i('Menutup loading dialog.');

          Nav.pop(context);
        }

        if (mounted) {
          L.i('Menampilkan snackbar sukses penghapusan.');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kritik dan saran berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
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
          L.w('Menutup loading dialog karena terjadi error.');

          Nav.pop(context);
        }

        if (mounted) {
          L.w('Menampilkan snackbar error penghapusan.');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      L.w('Proses penghapusan dibatalkan atau widget sudah tidak mounted.');
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
                    FormatTanggal.formatTanggalDanJam(kritikSaran.tanggal),
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
