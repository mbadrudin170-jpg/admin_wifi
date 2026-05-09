// path: lib/halaman/lainnya/paket.dart

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_paket.dart';
import 'package:admin_wifi/halaman/form/form_paket.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

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
    developer.log('[PaketPage]-[initState] 🏁 : Menginisialisasi halaman Paket', name: 'Paket');
    _refreshPaketList();
  }

  void _refreshPaketList() {
    developer.log('[PaketPage]-[_refreshPaketList] 🔄 : Memperbarui daftar paket dari database', name: 'Paket');
    setState(() {
      _paketFuture = _paketOperasi.getPaket();
    });
  }

  void _showEditDeleteDialog(PaketModel paket) {
    developer.log('[PaketPage]-[_showEditDeleteDialog] 📂 : Menampilkan dialog opsi untuk paket: ${paket.nama}', name: 'Paket');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(paket.nama),
          content: const Text('Pilih aksi yang ingin Anda lakukan.'),
          actions: [
            TextButton(
              onPressed: () {
                developer.log('[PaketPage]-[_showEditDeleteDialog] ✏️ : Memilih navigasi ke Form Edit', name: 'Paket');
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormPaket(paket: paket),
                  ),
                ).then((_) {
                  developer.log('[PaketPage]-[_showEditDeleteDialog] ✅ : Kembali dari Form Edit, menyegarkan list', name: 'Paket');
                  _refreshPaketList();
                });
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                developer.log('[PaketPage]-[_showEditDeleteDialog] 🗑️ : Memilih opsi Hapus', name: 'Paket');
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
    developer.log('[PaketPage]-[_showDeleteConfirmationDialog] ❓ : Konfirmasi hapus untuk ID: ${paket.id}', name: 'Paket');
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
                developer.log('[PaketPage]-[_showDeleteConfirmationDialog] 🔙 : Penghapusan dibatalkan user', name: 'Paket');
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
                  developer.log('[PaketPage]-[_showDeleteConfirmationDialog] 🔨 : Menjalankan operasi hapus di database', name: 'Paket');
                  await _paketOperasi.hapusPaket(paket.id);
                  developer.log('[PaketPage]-[_showDeleteConfirmationDialog] ✅ : Paket ${paket.id} berhasil dihapus', name: 'Paket');
                  _refreshPaketList();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Paket berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e, s) {
                  developer.log(
                    '[PaketPage]-[_showDeleteConfirmationDialog] ❌ : Gagal menghapus paket',
                    error: e,
                    stackTrace: s,
                    name: 'Paket',
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
    developer.log('[PaketPage]-[_hapusSemuaPaket] ⚠️ : User menekan tombol hapus semua paket', name: 'Paket');
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua paket? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                developer.log('[PaketPage]-[_hapusSemuaPaket] 🔙 : Penghapusan massal dibatalkan', name: 'Paket');
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
                  developer.log('[PaketPage]-[_hapusSemuaPaket] 💣 : Menjalankan operasi hapus semua paket', name: 'Paket');
                  await _paketOperasi.hapusSemuaPaket();
                  developer.log('[PaketPage]-[_hapusSemuaPaket] ✅ : Semua paket berhasil dibersihkan', name: 'Paket');
                  _refreshPaketList();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Semua paket berhasil dihapus.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e, s) {
                  developer.log(
                    '[PaketPage]-[_hapusSemuaPaket] ❌ : Gagal menghapus semua paket',
                    error: e,
                    stackTrace: s,
                    name: 'Paket',
                  );
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
    developer.log('[PaketPage]-[build] 🏗️ : Membangun UI PaketPage', name: 'Paket');
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
            developer.log('[PaketPage]-[FutureBuilder] ⚠️ : Snapshot memiliki error', error: snapshot.error, name: 'Paket');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            developer.log('[PaketPage]-[FutureBuilder] 📭 : Data paket kosong', name: 'Paket');
            return const Center(child: Text('Tidak ada paket yang tersedia.'));
          }
          final paketList = snapshot.data!;
          developer.log('[PaketPage]-[FutureBuilder] 📜 : Menampilkan ${paketList.length} paket', name: 'Paket');
          
          return ListView.builder(
            itemCount: paketList.length,
            itemBuilder: (context, index) {
              final paket = paketList[index];
              return InkWell(
                onTap: () {
                  developer.log('[PaketPage]-[ListView] 👆 : Navigasi ke Detail Paket: ${paket.nama}', name: 'Paket');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPaketPage(paket: paket),
                    ),
                  ).then((_) {
                    developer.log('[PaketPage]-[ListView] ✅ : Kembali dari Detail, menyegarkan list', name: 'Paket');
                    _refreshPaketList();
                  });
                },
                onLongPress: () {
                  developer.log('[PaketPage]-[ListView] 🖐️ : Long press pada paket: ${paket.nama}', name: 'Paket');
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
          developer.log('[PaketPage]-[FAB] ➕ : Navigasi ke Form Tambah Paket', name: 'Paket');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPaket()),
          ).then((_) {
            developer.log('[PaketPage]-[FAB] ✅ : Kembali dari Form Tambah, menyegarkan list', name: 'Paket');
            _refreshPaketList();
          });
        },
        tooltip: 'Tambah Paket',
        child: const Icon(Icons.add),
      ),
    );
  }
}