// path: lib/halaman/lainnya/pelanggan.dart

import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_pelanggan.dart';
import 'package:admin_wifi/halaman/form/form_pelanggan.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:flutter/material.dart';
import 'package:share_global_saya/src/utils/l.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<PelangganModel> _allPelanggan = [];
  List<PelangganModel> _filteredPelanggan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    L.i(
      'Menginisialisasi state untuk PelangganPage. Memanggil _refreshPelangganList untuk pertama kali.',
    );
    _refreshPelangganList();
    _searchController.addListener(_filterPelanggan);
  }

  @override
  void dispose() {
    L.i(
      'Membersihkan resource di PelangganPage. _searchController di-dispose.',
    );
    _searchController.dispose();
    super.dispose();
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

  Future<void> _refreshPelangganList() async {
    L.i(
      'Memulai proses refresh daftar pelanggan. Mengatur _isLoading ke true.',
    );
    if (mounted) setState(() => _isLoading = true);

    try {
      final list = await _pelangganOperasi.getPelanggan();
      list.sort((a, b) => a.nama.compareTo(b.nama));

      L.i('Berhasil mengambil dan menyortir ${list.length} data pelanggan.');

      if (mounted) {
        setState(() {
          _allPelanggan = list;
          _filteredPelanggan = list;
          _isLoading = false;
          L.i(
            'State diperbarui dengan daftar pelanggan yang baru. _isLoading diatur ke false.',
          );
        });
      }
    } catch (e, s) {
      L.e('Gagal total saat memuat daftar pelanggan. Error: $e $s');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data pelanggan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterPelanggan() {
    final query = _searchController.text.toLowerCase();
    L.i(
      'Listener _searchController aktif. Memfilter daftar dengan query: "$query".',
    );

    setState(() {
      _filteredPelanggan = _allPelanggan
          .where((p) => p.nama.toLowerCase().contains(query))
          .toList();
      L.i(
        'Filter selesai. Ditemukan ${_filteredPelanggan.length} pelanggan yang cocok.',
      );
    });
  }

  void _tambahPelanggan() async {
    L.i(
      'Tombol FAB (+) ditekan. Menavigasi ke FormPelanggan untuk menambah data baru.',
    );
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPelanggan()),
    );
    if (result == true) {
      L.i(
        'Kembali dari FormPelanggan dengan hasil sukses (true). Memanggil _refreshPelangganList untuk memuat ulang data.',
      );
      _refreshPelangganList();
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
                  Navigator.of(dialogContext).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormPelanggan(pelanggan: pelanggan),
                    ),
                  ).then((_) => _refreshPelangganList());
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Arsipkan Pelanggan'),
                onTap: () {
                  L.i(
                    'Opsi "Arsipkan Pelanggan" dipilih. Menutup dialog dan memanggil _showDialogArsipkan.',
                  );
                  Navigator.of(dialogContext).pop();
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
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
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
      await _pelangganOperasi.arsipkanPelanggan(id);
      L.i(
        'Berhasil mengarsipkan pelanggan dengan ID: $id. Memuat ulang daftar dan menampilkan SnackBar.',
      );
      _refreshPelangganList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pelanggan berhasil diarsipkan.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, s) {
      L.e('Gagal mengarsipkan pelanggan dengan ID: $id. Error: $e $s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengarsipkan pelanggan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI PelangganPage. Status loading: $_isLoading.');
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshPelangganList,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPelanggan,
        tooltip: 'Tambah Pelanggan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredPelanggan.isEmpty) {
      L.i('Membangun UI content: Daftar pelanggan kosong.');
      return Center(
        child: Text(
          _isSearching
              ? 'Pelanggan tidak ditemukan untuk pencarian ini.'
              : 'Belum ada pelanggan. Tekan tombol + untuk menambah.',
          textAlign: TextAlign.center,
        ),
      );
    }

    L.i(
      'Membangun UI content: Menampilkan ListView dengan ${_filteredPelanggan.length} pelanggan.',
    );
    return ListView.builder(
      itemCount: _filteredPelanggan.length,
      itemBuilder: (context, index) {
        final pelanggan = _filteredPelanggan[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailPelangganPage(idPelanggan: pelanggan.id),
                ),
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
    );
  }
}
