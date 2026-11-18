// path: lib/halaman/lainnya/paket.dart

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/fitur/paket/screens/detail_paket.dart';
import 'package:admin_wifi/fitur/paket/screens/form_paket.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:flutter/material.dart';
import 'package:share_global_saya/src/utils/l.dart';

class PaketPage extends StatefulWidget {
  const PaketPage({super.key});

  @override
  State<PaketPage> createState() => _PaketPageState();
}

class _PaketPageState extends State<PaketPage> {
  final PaketOperasi _paketOperasi = PaketOperasi();
  late Future<List<PaketModel>> _paketFuture;

  @override
  void initState() {
    super.initState();
    L.i('Menginisialisasi halaman Paket');
    _refreshPaketList();
  }

  void _refreshPaketList() {
    L.i('Memperbarui daftar paket dari database');
    setState(() {
      _paketFuture = _paketOperasi.getPaket();
    });
  }

  void _showEditDeleteDialog(PaketModel paket) {
    L.i('Menampilkan dialog opsi untuk paket: ${paket.nama}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(paket.nama),
          content: const Text('Pilih aksi yang ingin Anda lakukan.'),
          actions: [
            TextButton(
              onPressed: () {
                L.i('Memilih navigasi ke Form Edit untuk paket: ${paket.nama}');
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormPaket(paket: paket),
                  ),
                ).then((_) {
                  L.i('Kembali dari Form Edit, menyegarkan daftar paket');
                  _refreshPaketList();
                });
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                L.i('Memilih opsi Hapus untuk paket: ${paket.nama}');
                Navigator.pop(context);
                _showDeleteConfirmationDialog(paket);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(PaketModel paket) {
    L.i(
      'Menampilkan konfirmasi hapus untuk paket ID: ${paket.id}, nama: ${paket.nama}',
    );
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus paket ${paket.nama}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                L.i('Penghapusan paket ${paket.nama} dibatalkan oleh user');
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop();

                try {
                  L.i(
                    'Menjalankan operasi hapus paket ID: ${paket.id}, nama: ${paket.nama}',
                  );
                  await _paketOperasi.hapusPaket(paket.id);
                  L.i('Paket ID: ${paket.id} berhasil dihapus dari database');
                  _refreshPaketList();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Paket berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e, s) {
                  L.e(
                    'Gagal menghapus paket ID: ${paket.id}, nama: ${paket.nama} Error: $e $s',
                  );
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus paket: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _hapusSemuaPaket() {
    L.i('User menekan tombol hapus semua paket');
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Semua'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus SEMUA paket? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                L.i('Penghapusan massal semua paket dibatalkan oleh user');
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus Semua'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop();

                try {
                  L.i('Menjalankan operasi hapus semua paket dari database');
                  await _paketOperasi.hapusSemuaPaket();
                  L.i('Semua paket berhasil dihapus dari database');
                  _refreshPaketList();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Semua paket berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e, s) {
                  L.e('Gagal menghapus semua paket dari database Error: $e $s');
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus semua paket: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI halaman Daftar Paket');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Paket'),
        actions: [
          IconButton(
            onPressed: _hapusSemuaPaket,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: FutureBuilder<List<PaketModel>>(
        future: _paketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            L.e(
              'Terjadi error saat memuat data paket Error: $snapshot.error $snapshot.stackTrace',
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            L.i('Data paket kosong, tidak ada paket yang tersedia');
            return const Center(child: Text('Tidak ada paket yang tersedia.'));
          }
          final paketList = snapshot.data!;
          L.i('Menampilkan ${paketList.length} paket dalam daftar');

          return ListView.builder(
            itemCount: paketList.length,
            itemBuilder: (context, index) {
              final paket = paketList[index];
              return InkWell(
                onTap: () {
                  L.i(
                    'Navigasi ke halaman Detail Paket: ${paket.nama} (ID: ${paket.id})',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPaketPage(paket: paket),
                    ),
                  ).then((_) {
                    L.i(
                      'Kembali dari halaman Detail Paket, menyegarkan daftar',
                    );
                    _refreshPaketList();
                  });
                },
                onLongPress: () {
                  L.i(
                    'Long press pada paket: ${paket.nama} (ID: ${paket.id}), menampilkan menu edit/hapus',
                  );
                  _showEditDeleteDialog(paket);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      paket.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Rp ${paket.harga} / ${paket.durasi} ${paket.tipe.name}',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          L.i('Navigasi ke Form Tambah Paket');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPaket()),
          ).then((_) {
            L.i('Kembali dari Form Tambah Paket, menyegarkan daftar');
            _refreshPaketList();
          });
        },
        tooltip: 'Tambah Paket',
        child: const Icon(Icons.add),
      ),
    );
  }
}
