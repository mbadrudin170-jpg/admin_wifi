// path: lib/halaman/lainnya/pelanggan.dart

import 'package:admin_wifi/halaman/form/form_pelanggan.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_pelanggan.dart';
import 'package:admin_wifi/debug/log.dart'; // diubah: Menggunakan Log kustom

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
    Log.info('Menginisialisasi state untuk PelangganPage. Memanggil _refreshPelangganList untuk pertama kali.');
    _refreshPelangganList();
    _searchController.addListener(_filterPelanggan);
  }

  @override
  void dispose() {
    Log.info('Membersihkan resource di PelangganPage. _searchController di-dispose.');
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
            Log.info('Tombol search/close ditekan. Mengubah state _isSearching.');
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                Log.info('Mode pencarian dinonaktifkan. Membersihkan search controller.');
                _searchController.clear();
              } else {
                Log.info('Mode pencarian diaktifkan.');
              }
            });
          },
        ),
      ],
    );
  }

  Future<void> _refreshPelangganList() async {
    Log.info('Memulai proses refresh daftar pelanggan. Mengatur _isLoading ke true.');
    if (mounted) setState(() => _isLoading = true);

    try {
      final list = await _pelangganOperasi.getPelanggan();
      list.sort((a, b) => a.nama.compareTo(b.nama));

      Log.info('Berhasil mengambil dan menyortir ${list.length} data pelanggan.');

      if (mounted) {
        setState(() {
          _allPelanggan = list;
          _filteredPelanggan = list;
          _isLoading = false;
          Log.info('State diperbarui dengan daftar pelanggan yang baru. _isLoading diatur ke false.');
        });
      }
    } catch (e, s) {
      Log.error('Gagal total saat memuat daftar pelanggan.', error: e, stackTrace: s);
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
    Log.info('Listener _searchController aktif. Memfilter daftar dengan query: "$query".');

    setState(() {
      _filteredPelanggan = _allPelanggan
          .where((p) => p.nama.toLowerCase().contains(query))
          .toList();
      Log.info('Filter selesai. Ditemukan ${_filteredPelanggan.length} pelanggan yang cocok.');
    });
  }

  void _tambahPelanggan() async {
    Log.info('Tombol FAB (+) ditekan. Menavigasi ke FormPelanggan untuk menambah data baru.');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPelanggan()),
    );
    if (result == true) {
      Log.info('Kembali dari FormPelanggan dengan hasil sukses (true). Memanggil _refreshPelangganList untuk memuat ulang data.');
      _refreshPelangganList();
    } else {
      Log.info('Kembali dari FormPelanggan tanpa hasil (false atau null). Tidak ada aksi yang diambil.');
    }
  }

  void _showDialogOpsi(PelangganModel pelanggan) {
    Log.info('Menampilkan dialog opsi (Edit/Arsipkan) untuk pelanggan: ${pelanggan.nama} (ID: ${pelanggan.id}).');
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
                  Log.info('Opsi "Edit Pelanggan" dipilih. Menutup dialog dan menavigasi ke FormPelanggan dengan data yang ada.');
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
                  Log.info('Opsi "Arsipkan Pelanggan" dipilih. Menutup dialog dan memanggil _showDialogArsipkan.');
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
    Log.info('Menampilkan dialog konfirmasi pengarsipan untuk pelanggan "${pelanggan.nama}".');
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
                Log.info('Pengguna membatalkan proses pengarsipan.');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Arsipkan', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Log.info('Pengguna mengonfirmasi pengarsipan. Memanggil _arsipkanPelanggan dengan ID: ${pelanggan.id}.');
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
    Log.info('Memulai proses pengarsipan untuk ID pelanggan: $id.');
    try {
      await _pelangganOperasi.arsipkanPelanggan(id);
      Log.info('Berhasil mengarsipkan pelanggan dengan ID: $id. Memuat ulang daftar dan menampilkan SnackBar.');
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
      Log.error('Gagal mengarsipkan pelanggan dengan ID: $id.', error: e, stackTrace: s);
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
    Log.info('Membangun UI PelangganPage. Status loading: $_isLoading.');
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
      Log.info('Membangun UI content: Daftar pelanggan kosong.');
      return Center(
        child: Text(
          _isSearching
              ? 'Pelanggan tidak ditemukan untuk pencarian ini.'
              : 'Belum ada pelanggan. Tekan tombol + untuk menambah.',
          textAlign: TextAlign.center,
        ),
      );
    }

    Log.info('Membangun UI content: Menampilkan ListView dengan ${_filteredPelanggan.length} pelanggan.');
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
              Log.info('ListTile untuk pelanggan "${pelanggan.nama}" ditekan. Menavigasi ke DetailPelangganPage.');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailPelangganPage(idPelanggan: pelanggan.id),
                ),
              );
            },
            onLongPress: () {
              Log.info('ListTile untuk pelanggan "${pelanggan.nama}" ditekan lama (long press). Memanggil _showDialogOpsi.');
              _showDialogOpsi(pelanggan);
            },
          ),
        );
      },
    );
  }
}
