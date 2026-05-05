// path: lib/halaman/lainnya/pelanggan.dart
// Halaman ini menampilkan daftar semua pelanggan yang terdaftar.

import 'package:admin_wifi/halaman/form/form_pelanggan.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_pelanggan.dart';

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
    _refreshPelangganList();
    _searchController.addListener(_filterPelanggan);
  }

  @override
  void dispose() {
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
                hintText: 'Cari pelanggan...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            )
          : const Text('Pelanggan'),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
        ),
      ],
    );
  }

  Future<void> _refreshPelangganList() async {
    setState(() => _isLoading = true);
    final list = await _pelangganOperasi.getPelanggan();
    list.sort((a, b) => a.nama.compareTo(b.nama));
    if (mounted) {
      setState(() {
        _allPelanggan = list;
        _filteredPelanggan = list;
        _isLoading = false;
      });
    }
  }

  void _filterPelanggan() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPelanggan = _allPelanggan
          .where((p) => p.nama.toLowerCase().contains(query))
          .toList();
    });
  }

  void _tambahPelanggan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPelanggan()),
    );
    if (result == true) {
      _refreshPelangganList();
    }
  }

  // ditambah: Fungsi untuk menampilkan dialog opsi saat item ditekan lama
  void _showDialogOpsi(PelangganModel pelanggan) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            pelanggan.nama,
          ), // Menampilkan nama pelanggan sebagai judul
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Pelanggan'),
                onTap: () {
                  Navigator.of(dialogContext).pop(); // Tutup dialog opsi
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
                  Navigator.of(dialogContext).pop(); // Tutup dialog opsi
                  _showDialogArsipkan(
                    pelanggan,
                  ); // Tampilkan dialog konfirmasi arsip
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialogArsipkan(PelangganModel pelanggan) {
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
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
    await _pelangganOperasi.arsipkanPelanggan(id);
    _refreshPelangganList();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pelanggan berhasil diarsipkan.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredPelanggan.isEmpty
          ? Center(
              child: Text(
                _allPelanggan.isEmpty
                    ? 'Tidak ada pelanggan terdaftar.'
                    : 'Pelanggan tidak ditemukan.',
              ),
            )
          : ListView.builder(
              itemCount: _filteredPelanggan.length,
              itemBuilder: (context, index) {
                final pelanggan = _filteredPelanggan[index];
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
                    // dihapus: PopupMenuButton telah diganti dengan onLongPress
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPelangganPage(pelanggan: pelanggan),
                        ),
                      );
                    },
                    onLongPress: () {
                      // ditambah: Memanggil dialog opsi saat ditekan lama
                      _showDialogOpsi(pelanggan);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPelanggan,
        child: const Icon(Icons.add),
      ),
    );
  }
}
