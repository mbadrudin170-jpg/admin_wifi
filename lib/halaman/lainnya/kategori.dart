// path: lib/halaman/lainnya/kategori.dart
// File ini menampilkan halaman untuk mengelola kategori pemasukan dan pengeluaran.
// Pengguna dapat melihat, menambah, mengedit, atau menghapus kategori.
// Terdapat tombol untuk beralih antara tipe kategori (Pemasukan/Pengeluaran).

import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/halaman/form/form_kategori.dart';
import 'package:admin_wifi/model/kategori_model.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  late Future<List<KategoriModel>> _listaKategoriFuture;
  TipeKategori _selectedTipe = TipeKategori.pemasukan;
  // ditambahkan: Variabel untuk mengontrol mode edit
  bool _isEdit = false;
  // ditambahkan: Variabel untuk mengontrol mode hapus
  bool _isHapus = false;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  // Fungsi untuk memuat ulang daftar kategori
  void _loadKategori() {
    setState(() {
      _listaKategoriFuture = _kategoriOperasi.getKategori();
    });
  }

  // Fungsi untuk navigasi ke halaman tambah kategori
  void _tambahKategori() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormKategoriPage()),
    );
    if (result == true) {
      _loadKategori();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          // ditambahkan: Tombol untuk mengaktifkan/menonaktifkan mode hapus
          IconButton(
            onPressed: () {
              setState(() {
                _isHapus = !_isHapus;
                // dinonaktifkan: Mode edit akan dinonaktifkan jika mode hapus aktif
                if (_isHapus) _isEdit = false;
              });
            },
            icon: Icon(_isHapus ? Icons.check : Icons.delete),
          ),
          // diubah: Tombol untuk mengaktifkan/menonaktifkan mode edit
          IconButton(
            onPressed: () {
              setState(() {
                _isEdit = !_isEdit;
                // dinonaktifkan: Mode hapus akan dinonaktifkan jika mode edit aktif
                if (_isEdit) _isHapus = false;
              });
            },
            icon: Icon(_isEdit ? Icons.check : Icons.edit),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tombol untuk filter tipe kategori
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTipe = TipeKategori.pemasukan;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTipe == TipeKategori.pemasukan
                      ? Colors.green
                      : Colors.grey,
                ),
                child: const Text('Pemasukan'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTipe = TipeKategori.pengeluaran;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTipe == TipeKategori.pengeluaran
                      ? Colors.red
                      : Colors.grey,
                ),
                child: const Text('Pengeluaran'),
              ),
            ],
          ),
          // Daftar kategori
          Expanded(
            child: FutureBuilder<List<KategoriModel>>(
              future: _listaKategoriFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada kategori ditemukan.'),
                  );
                } else {
                  final filteredKategori = snapshot.data!
                      .where((k) => k.tipe == _selectedTipe)
                      .toList();
                  return ListView.builder(
                    itemCount: filteredKategori.length,
                    itemBuilder: (context, index) {
                      final kategori = filteredKategori[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          title: Text(kategori.nama),
                          // diubah: Menampilkan tombol edit atau hapus
                          trailing: _isEdit
                              ? IconButton(
                                  onPressed: () {
                                    // TODO: Tambahkan logika untuk mengedit kategori utama
                                  },
                                  icon: const Icon(Icons.edit),
                                )
                              : _isHapus
                                  ? IconButton(
                                      onPressed: () {
                                        // TODO: Tambahkan logika untuk menghapus kategori utama
                                      },
                                      icon: const Icon(Icons.delete),
                                    )
                                  : null,
                          children: kategori.subKategori.map((sub) {
                            return ListTile(
                              title: Text(sub.nama),
                              // diubah: Menampilkan tombol edit atau hapus
                              trailing: _isEdit
                                  ? IconButton(
                                      onPressed: () {
                                        // TODO: Tambahkan logika untuk mengedit sub-kategori
                                      },
                                      icon: const Icon(Icons.edit),
                                    )
                                  : _isHapus
                                      ? IconButton(
                                          onPressed: () {
                                            // TODO: Tambahkan logika untuk menghapus sub-kategori
                                          },
                                          icon: const Icon(Icons.delete),
                                        )
                                      : null,
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahKategori,
        child: const Icon(Icons.add),
      ),
    );
  }
}
