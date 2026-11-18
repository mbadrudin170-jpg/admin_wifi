// path: lib/fitur/pelanggan/screens/pelanggan.dart

import 'dart:async';

import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/screens/detail_pelanggan.dart';
import 'package:admin_wifi/fitur/pelanggan/screens/form_pelanggan.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';
import 'package:share_global_saya/src/widget/toast_widget.dart';

class PelangganPage extends ConsumerStatefulWidget {
  const PelangganPage({super.key});

  @override
  ConsumerState<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends ConsumerState<PelangganPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    L.i(
      'Menginisialisasi state untuk PelangganPage. Memanggil _muatUlang untuk pertama kali.',
    );
    _muatUlang();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    L.i(
      'Membersihkan resource di PelangganPage. _searchController di-dispose.',
    );
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _muatUlang() async {
    L.i('Memulai proses muat ulang daftar pelanggan via notifier.');
    try {
      await ref.read(pelangganProvider.notifier).muatUlang();
      L.i('Berhasil memuat ulang daftar pelanggan.');
    } catch (e, s) {
      L.e('Gagal memuat daftar pelanggan. Error: $e $s');
      if (mounted) {
        AppToast.gagal(
          context,
          'Gagal memuat data pelanggan. Silakan coba lagi.',
        );
      }
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari nama pelanggan...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            )
          : const Text('Daftar Pelanggan'),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            L.i('Tombol search/close ditekan. Mengubah state _isSearching.');
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                L.i(
                  'Mode pencarian dinonaktifkan. Membersihkan search controller.',
                );
                _searchController.clear();
              } else {
                L.i('Mode pencarian diaktifkan.');
              }
            });
          },
        ),
      ],
    );
  }

  void _tambahPelanggan() async {
    L.i(
      'Tombol FAB (+) ditekan. Menavigasi ke FormPelanggan untuk menambah data baru.',
    );
    final result = await Nav.to(context, const FormPelanggan());
    if (result == true) {
      L.i(
        'Kembali dari FormPelanggan dengan hasil sukses (true). Memanggil _muatUlang untuk memuat ulang data.',
      );
      await _muatUlang();
    } else {
      L.i(
        'Kembali dari FormPelanggan tanpa hasil (false atau null). Tidak ada aksi yang diambil.',
      );
    }
  }

  void _showDialogOpsi(PelangganModel pelanggan) {
    L.i(
      'Menampilkan dialog opsi (Edit/Arsipkan) untuk pelanggan: ${pelanggan.nama} (ID: ${pelanggan.id}).',
    );
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(pelanggan.nama),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Pelanggan'),
                onTap: () {
                  L.i(
                    'Opsi "Edit Pelanggan" dipilih. Menutup dialog dan menavigasi ke FormPelanggan dengan data yang ada.',
                  );
                  Nav.pop(dialogContext);
                  unawaited(
                    Nav.to(context, FormPelanggan(pelanggan: pelanggan))
                        .then((_) => _muatUlang())
                        .catchError((Object e, StackTrace s) {
                          L.e('Navigasi gagal: $e $s');
                        }),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Arsipkan Pelanggan'),
                onTap: () {
                  L.i(
                    'Opsi "Arsipkan Pelanggan" dipilih. Menutup dialog dan memanggil _showDialogArsipkan.',
                  );
                  Nav.pop(dialogContext);
                  _showDialogArsipkan(pelanggan);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialogArsipkan(PelangganModel pelanggan) {
    L.i(
      'Menampilkan dialog konfirmasi pengarsipan untuk pelanggan "${pelanggan.nama}".',
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsip'),
          content: Text(
            'Apakah Anda yakin ingin mengarsipkan pelanggan "${pelanggan.nama}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                L.i('Pengguna membatalkan proses pengarsipan.');
                Nav.pop(context);
              },
            ),
            TextButton(
              child: const Text(
                'Arsipkan',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                L.i(
                  'Pengguna mengonfirmasi pengarsipan. Memanggil _arsipkanPelanggan dengan ID: ${pelanggan.id}.',
                );
                Nav.pop(context);
                _arsipkanPelanggan(pelanggan.id);
              },
            ),
          ],
        );
      },
    );
  }

  void _arsipkanPelanggan(String id) async {
    L.i('Memulai proses pengarsipan untuk ID pelanggan: $id.');
    try {
      await ref.read(pelangganProvider.notifier).hapus(id);
      L.i('Berhasil mengarsipkan pelanggan dengan ID: $id.');
      if (mounted) {
        AppToast.sukses(context, 'Pelanggan berhasil diarsipkan.');
      }
      await _muatUlang();
    } catch (e, s) {
      L.e('Gagal mengarsipkan pelanggan dengan ID: $id. Error: $e $s');
      if (mounted) {
        AppToast.gagal(context, 'Gagal mengarsipkan pelanggan.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI PelangganPage.');
    final asyncPelanggan = ref.watch(pelangganProvider);

    if (asyncPelanggan.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (asyncPelanggan.hasError) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                const Icon(Icons.error_outline, size: 48),
                Text(
                  'Gagal memuat data pelanggan: ${asyncPelanggan.error}',
                  textAlign: TextAlign.center,
                ),
                FilledButton(
                  onPressed: () => ref.refresh(pelangganProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final semua = List<PelangganModel>.from(
      asyncPelanggan.requireValue.listPelanggan,
    )..sort((a, b) => a.nama.compareTo(b.nama));

    final query = _searchController.text.toLowerCase();
    final filtered = query.isEmpty
        ? semua
        : semua.where((p) => p.nama.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _muatUlang,
        child: filtered.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Text(
                      _isSearching
                          ? 'Pelanggan tidak ditemukan untuk pencarian ini.'
                          : 'Belum ada pelanggan. Tekan tombol + untuk menambah.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final pelanggan = filtered[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(
                        pelanggan.nama,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(pelanggan.macAddress),
                      onTap: () {
                        L.i(
                          'ListTile untuk pelanggan "${pelanggan.nama}" ditekan. Menavigasi ke DetailPelangganPage.',
                        );
                        unawaited(
                          Nav.to(
                            context,
                            DetailPelangganPage(idPelanggan: pelanggan.id),
                          ).catchError((Object e, StackTrace s) {
                            L.e('Navigasi gagal: $e $s');
                            return null;
                          }),
                        );
                      },
                      onLongPress: () {
                        L.i(
                          'ListTile untuk pelanggan "${pelanggan.nama}" ditekan lama (long press). Memanggil _showDialogOpsi.',
                        );
                        _showDialogOpsi(pelanggan);
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPelanggan,
        tooltip: 'Tambah Pelanggan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
