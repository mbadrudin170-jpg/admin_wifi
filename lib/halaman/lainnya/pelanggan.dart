// path: lib/halaman/lainnya/pelanggan.dart

import 'package:admin_wifi/halaman/form/form_pelanggan.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_pelanggan.dart';
import 'dart:developer' as developer;

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
    developer.log('[PelangganPage]-[initState] 🏁 : Menginisialisasi halaman Pelanggan', name: 'Pelanggan');
    _refreshPelangganList();
    _searchController.addListener(_filterPelanggan);
  }

  @override
  void dispose() {
    developer.log('[PelangganPage]-[dispose] 🚮 : Menghapus controller dan membersihkan resource', name: 'Pelanggan');
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
            developer.log('[PelangganPage]-[AppBar] 🔍 : Toggle search mode -> ${_isSearching ? 'Nonaktif' : 'Aktif'}', name: 'Pelanggan');
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
    developer.log('[PelangganPage]-[_refreshPelangganList] 🔄 : Memuat ulang daftar pelanggan', name: 'Pelanggan');
    setState(() => _isLoading = true);
    
    try {
      final list = await _pelangganOperasi.getPelanggan();
      list.sort((a, b) => a.nama.compareTo(b.nama));
      
      developer.log('[PelangganPage]-[_refreshPelangganList] 📥 : Berhasil mengambil ${list.length} pelanggan', name: 'Pelanggan');
      
      if (mounted) {
        setState(() {
          _allPelanggan = list;
          _filteredPelanggan = list;
          _isLoading = false;
        });
      }
    } catch (e, s) {
      developer.log('[PelangganPage]-[_refreshPelangganList] ❌ : Error saat memuat data', error: e, stackTrace: s, name: 'Pelanggan');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterPelanggan() {
    final query = _searchController.text.toLowerCase();
    developer.log('[PelangganPage]-[_filterPelanggan] ⌨️ : Mencari dengan keyword: "$query"', name: 'Pelanggan');
    
    setState(() {
      _filteredPelanggan = _allPelanggan
          .where((p) => p.nama.toLowerCase().contains(query))
          .toList();
      developer.log('[PelangganPage]-[_filterPelanggan] 🎯 : Hasil filter -> ${_filteredPelanggan.length} item', name: 'Pelanggan');
    });
  }

  void _tambahPelanggan() async {
    developer.log('[PelangganPage]-[_tambahPelanggan] ➕ : Menuju form tambah pelanggan', name: 'Pelanggan');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPelanggan()),
    );
    if (result == true) {
      developer.log('[PelangganPage]-[_tambahPelanggan] ✅ : Pelanggan baru ditambahkan, menyegarkan list', name: 'Pelanggan');
      _refreshPelangganList();
    }
  }

  void _showDialogOpsi(PelangganModel pelanggan) {
    developer.log('[PelangganPage]-[_showDialogOpsi] 📂 : Menampilkan opsi untuk pelanggan: ${pelanggan.nama}', name: 'Pelanggan');
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
                  developer.log('[PelangganPage]-[_showDialogOpsi] ✏️ : Memilih edit pelanggan', name: 'Pelanggan');
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
                  developer.log('[PelangganPage]-[_showDialogOpsi] 📦 : Memilih arsipkan pelanggan', name: 'Pelanggan');
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
    developer.log('[PelangganPage]-[_showDialogArsipkan] ❓ : Menampilkan konfirmasi arsip untuk ${pelanggan.id}', name: 'Pelanggan');
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
                developer.log('[PelangganPage]-[_showDialogArsipkan] 🔙 : Pengarsipan dibatalkan', name: 'Pelanggan');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () {
                developer.log('[PelangganPage]-[_showDialogArsipkan] 🆗 : Konfirmasi arsip diterima', name: 'Pelanggan');
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
    developer.log('[PelangganPage]-[_arsipkanPelanggan] 🔨 : Memulai proses pengarsipan di database', name: 'Pelanggan');
    try {
      await _pelangganOperasi.arsipkanPelanggan(id);
      developer.log('[PelangganPage]-[_arsipkanPelanggan] ✅ : Berhasil mengarsipkan ID: $id', name: 'Pelanggan');
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
      developer.log('[PelangganPage]-[_arsipkanPelanggan] ❌ : Gagal mengarsipkan', error: e, stackTrace: s, name: 'Pelanggan');
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('[PelangganPage]-[build] 🏗️ : Membangun UI PelangganPage', name: 'Pelanggan');
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
                    onTap: () {
                      developer.log('[PelangganPage]-[ListView] 👆 : Menuju detail pelanggan: ${pelanggan.nama}', name: 'Pelanggan');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPelangganPage(idPelanggan: pelanggan.id),
                        ),
                      );
                    },
                    onLongPress: () {
                      developer.log('[PelangganPage]-[ListView] 🖐️ : Long press pada pelanggan: ${pelanggan.nama}', name: 'Pelanggan');
                      _showDialogOpsi(pelanggan);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPelanggan,
        tooltip: 'Tambah Pelanggan',
        child: const Icon(Icons.add),
      ),
    );
  }
}