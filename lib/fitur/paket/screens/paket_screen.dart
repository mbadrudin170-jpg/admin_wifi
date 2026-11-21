// path: lib/fitur/paket/screens/paket.dart

import 'dart:async';

import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/paket/screens/detail_paket.dart';
import 'package:admin_wifi/fitur/paket/screens/form_paket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';
import 'package:share_global_saya/src/widget/toast_widget.dart';

class PaketScreen extends ConsumerStatefulWidget {
  const PaketScreen({super.key});

  @override
  ConsumerState<PaketScreen> createState() => _PaketScreenState();
}

class _PaketScreenState extends ConsumerState<PaketScreen> {
  Future<void> _muatUlang() async {
    try {
      await ref.read(paketProvider.notifier).muatUlang();
    } catch (e, s) {
      L.e('Gagal memperbarui daftar paket. Error: $e $s');
      if (mounted) {
        AppToast.gagal(context, 'Gagal memuat data paket. Silakan coba lagi.');
      }
    }
  }

  void _showEditDeleteDialog(PaketModel paket) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(paket.nama),
          content: const Text('Pilih aksi yang ingin Anda lakukan.'),
          actions: [
            TextButton(
              onPressed: () {
                Nav.pop(context);
                unawaited(
                  Nav.to(context, FormPaket(paket: paket))
                      .then((_) {
                        _muatUlang();
                      })
                      .catchError((Object e, StackTrace s) {
                        L.e('Navigasi gagal: $e $s');
                      }),
                );
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Nav.pop(context);
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
                Nav.pop(dialogContext);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                Nav.pop(dialogContext);

                try {
                  await ref.read(paketProvider.notifier).hapus(paket.id);
                  if (mounted) {
                    AppToast.sukses(context, 'Paket berhasil dihapus.');
                  }
                } catch (e, s) {
                  L.e(
                    'Gagal menghapus paket ID: ${paket.id}, nama: ${paket.nama} Error: $e $s',
                  );
                  if (mounted) {
                    AppToast.gagal(context, 'Gagal menghapus paket: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _hapusSemuaPaket() {
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
                Nav.pop(dialogContext);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus Semua'),
              onPressed: () async {
                Nav.pop(dialogContext);

                try {
                  await ref.read(paketProvider.notifier).hapusSemuaPaket();
                  if (mounted) {
                    AppToast.sukses(context, 'Semua paket berhasil dihapus.');
                  }
                  await _muatUlang();
                } catch (e, s) {
                  L.e('Gagal menghapus semua paket dari database Error: $e $s');
                  if (mounted) {
                    AppToast.gagal(context, 'Gagal menghapus semua paket: $e');
                  }
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
    final asyncPaket = ref.watch(paketProvider);

    if (asyncPaket.isLoading) {
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (asyncPaket.hasError) {
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                const Icon(Icons.error_outline, size: 48),
                Text(
                  'Gagal memuat data paket: ${asyncPaket.error}',
                  textAlign: TextAlign.center,
                ),
                FilledButton(
                  onPressed: () => ref.refresh(paketProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final paketList = asyncPaket.requireValue.listPaket;

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
      body: paketList.isEmpty
          ? const Center(child: Text('Tidak ada paket yang tersedia.'))
          : ListView.builder(
              itemCount: paketList.length,
              itemBuilder: (context, index) {
                final paket = paketList[index];
                return InkWell(
                  onTap: () {
                    unawaited(
                      Nav.to(context, DetailPaketPage(paket: paket))
                          .then((_) {
                            _muatUlang();
                          })
                          .catchError((Object e, StackTrace s) {
                            L.e('Navigasi gagal: $e $s');
                          }),
                    );
                  },
                  onLongPress: () {
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          unawaited(
            Nav.to(context, const FormPaket())
                .then((_) {
                  _muatUlang();
                })
                .catchError((Object e, StackTrace s) {
                  L.e('Navigasi gagal: $e $s');
                }),
          );
        },
        tooltip: 'Tambah Paket',
        child: const Icon(Icons.add),
      ),
    );
  }
}
