// path: lib/halaman/lainnya/kategori.dart
// diperbaiki: Menambahkan pemeriksaan 'mounted' untuk mengatasi peringatan build context.
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/halaman/form/form_kategori.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  late Future<List<KategoriModel>> _listaKategoriFuture;
  TipeKategori _selectedTipe = TipeKategori.pemasukan;
  bool _isEdit = false;
  bool _isArsipMode = false;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  void _loadKategori() {
    setState(() {
      _listaKategoriFuture = _kategoriOperasi.getKategori();
    });
  }

  void _tambahKategori() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormKategoriPage()),
    );
    if (result == true) {
      _loadKategori();
    }
  }

  Future<bool> _tampilkanDialogKonfirmasi(String judul, String konten) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(judul),
          content: Text(konten),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
    return konfirmasi ?? false;
  }

  Future<void> _arsipkanKategoriUtama(KategoriModel kategori) async {
    final bool konfirmasi = await _tampilkanDialogKonfirmasi(
      'Arsipkan Kategori',
      'Anda yakin ingin mengarsipkan "${kategori.nama}"? Kategori ini tidak akan bisa digunakan lagi.',
    );
    if (!mounted || !konfirmasi) return;

    try {
      final kategoriDiperbarui = kategori.copyWith(diarsipkan: DateTime.now());
      await _kategoriOperasi.update(kategoriDiperbarui);

      // diperbaiki: Pemeriksaan 'mounted' sebelum menggunakan BuildContext.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori berhasil diarsipkan.')),
      );
      _loadKategori();
    } catch (e) {
      // diperbaiki: Pemeriksaan 'mounted' sebelum menggunakan BuildContext.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengarsipkan kategori: $e')),
      );
    }
  }

  Future<void> _arsipkanSubKategori(
    KategoriModel kategoriInduk,
    SubKategoriModel subKategori,
  ) async {
    final bool konfirmasi = await _tampilkanDialogKonfirmasi(
      'Arsipkan Sub-Kategori',
      'Anda yakin ingin mengarsipkan sub-kategori "${subKategori.nama}"?',
    );
    if (!mounted || !konfirmasi) return;

    try {
      final subKategoriDiperbarui = subKategori.copyWith(
        diarsipkan: DateTime.now(),
      );
      final daftarSubKategoriBaru = kategoriInduk.subKategori.map((sub) {
        return sub.id == subKategori.id ? subKategoriDiperbarui : sub;
      }).toList();
      final kategoriIndukDiperbarui = kategoriInduk.copyWith(
        subKategori: daftarSubKategoriBaru,
        diperbarui: DateTime.now(),
      );

      await _kategoriOperasi.update(kategoriIndukDiperbarui);

      // diperbaiki: Pemeriksaan 'mounted' sebelum menggunakan BuildContext.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sub-kategori berhasil diarsipkan.')),
      );
      _loadKategori();
    } catch (e) {
      // diperbaiki: Pemeriksaan 'mounted' sebelum menggunakan BuildContext.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengarsipkan sub-kategori: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            tooltip: _isArsipMode ? 'Selesai' : 'Arsipkan',
            onPressed: () {
              setState(() {
                _isArsipMode = !_isArsipMode;
                if (_isArsipMode) _isEdit = false;
              });
            },
            icon: Icon(_isArsipMode ? Icons.check : Icons.archive_outlined),
          ),
          IconButton(
            tooltip: _isEdit ? 'Selesai' : 'Edit',
            onPressed: () {
              setState(() {
                _isEdit = !_isEdit;
                if (_isEdit) _isArsipMode = false;
              });
            },
            icon: Icon(_isEdit ? Icons.check : Icons.edit_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
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
                          trailing: _isEdit
                              ? IconButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FormKategoriPage(
                                          kategori: kategori,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadKategori();
                                    }
                                  },
                                  icon: const Icon(Icons.edit),
                                )
                              : _isArsipMode
                              ? IconButton(
                                  onPressed: () =>
                                      _arsipkanKategoriUtama(kategori),
                                  icon: const Icon(Icons.archive),
                                )
                              : null,
                          children: kategori.subKategori
                              .where((sub) => sub.diarsipkan == null)
                              .map((sub) {
                                return ListTile(
                                  title: Text(sub.nama),
                                  trailing: _isEdit
                                      ? IconButton(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FormKategoriPage(
                                                      subKategori: sub,
                                                      idKategoriInduk:
                                                          kategori.id,
                                                    ),
                                              ),
                                            );
                                            if (result == true) {
                                              _loadKategori();
                                            }
                                          },
                                          icon: const Icon(Icons.edit),
                                        )
                                      : _isArsipMode
                                      ? IconButton(
                                          onPressed: () => _arsipkanSubKategori(
                                            kategori,
                                            sub,
                                          ),
                                          icon: const Icon(Icons.archive),
                                        )
                                      : null,
                                );
                              })
                              .toList(),
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
