// path: lib/fitur/kritik_saran/screens/detail_kritik_saran.dart

import 'package:admin_wifi/fitur/kritik_saran/notifier/kritik_saran_notifier.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

class DetailKritikSaranPage extends StatefulWidget {
  final String id;

  const DetailKritikSaranPage({super.key, required this.id});

  @override
  State<DetailKritikSaranPage> createState() => _DetailKritikSaranPageState();
}

class _DetailKritikSaranPageState extends State<DetailKritikSaranPage> {
  late Future<KritikSaranModel> _kritikSaranFuture;

  @override
  void initState() {
    super.initState();

    L.i('Membuka halaman detail kritik dan saran dengan ID: ${widget.id}.');

    _loadData();
  }

  void _loadData() {
    L.i('Memulai proses pengambilan data kritik dan saran dari database.');

    _kritikSaranFuture = kritikSaranNotifierGlobal
        .getKritikSaranById(widget.id)
        .then((value) {
          L.i('Data kritik dan saran berhasil dimuat dari database.');

          return value;
        })
        .catchError((error, stackTrace) {
          L.e(
            'Terjadi kesalahan saat mengambil data kritik dan saran. Error: $error $stackTrace',
          );

          throw error;
        });
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

        await kritikSaranNotifierGlobal.hapusKritikSaran(widget.id);

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
      body: FutureBuilder<KritikSaranModel>(
        future: _kritikSaranFuture,
        builder: (context, snapshot) {
          L.i(
            'FutureBuilder dijalankan dengan connection state: ${snapshot.connectionState}.',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            L.i('Data masih dalam proses loading.');

            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            L.e(
              'FutureBuilder menerima error saat memuat data. Error: $snapshot.error',
            );

            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            L.i('FutureBuilder berhasil menerima data kritik dan saran.');

            final kritikSaran = snapshot.data!;

            L.i(
              'Menampilkan detail kritik dan saran dengan ID: ${kritikSaran.id}.',
            );

            return SingleChildScrollView(
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
                          FormatTanggal.formatTanggalDanJam(
                            kritikSaran.tanggal,
                          ),
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
          } else {
            L.w('FutureBuilder tidak menerima data kritik dan saran.');

            return const Center(child: Text('Data tidak ditemukan'));
          }
        },
      ),
    );
  }
}
