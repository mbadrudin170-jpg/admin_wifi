// path: lib/halaman/lainnya/kategori.dart

import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/halaman/form/form_kategori.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:flutter/material.dart';
import 'package:share_global_saya/src/utils/l.dart';

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
    L.i('Menginisialisasi halaman Kategori');
    _loadKategori();
  }

  void _loadKategori() {
    L.i('Memuat data kategori dari database');
    setState(() {
      _listaKategoriFuture = _kategoriOperasi
          .getKategori()
          .then((data) {
            int totalSubKategori = data.fold(
              0,
              (sum, kat) => sum + kat.subKategori.length,
            );
            L.i(
              'Berhasil memuat ${data.length} kategori utama dengan total $totalSubKategori sub-kategori',
            );
            for (var kat in data) {
              L.i(
                'Kategori: ${kat.nama} (ID: ${kat.id}, Tipe: ${kat.tipe.name}, Sub: ${kat.subKategori.length}, Diarsipkan: ${kat.diarsipkan != null ? "Ya" : "Tidak"})',
              );
            }
            return data;
          })
          .catchError((error, stackTrace) {
            L.e(
              'Gagal memuat data kategori dari database Error: $error $stackTrace',
            );
            throw error;
          });
    });
  }

  void _tambahKategori() async {
    L.i('Navigasi ke Form Tambah Kategori');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormKategoriPage()),
    );
    if (result == true) {
      L.i('Kategori baru berhasil ditambahkan, menyegarkan daftar kategori');
      _loadKategori();
    } else {
      L.i('Kembali dari Form Tambah Kategori tanpa menambah data');
    }
  }

  Future<bool> _tampilkanDialogKonfirmasi(String judul, String konten) async {
    L.i('Menampilkan dialog konfirmasi: "$judul"');
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(judul),
          content: Text(konten),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                L.i('Dialog "$judul" - User memilih Batal');
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                L.i('Dialog "$judul" - User memilih Ya');
                Navigator.of(context).pop(true);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
    L.i(
      'Hasil konfirmasi dialog "$judul": ${konfirmasi == true ? "Ya" : "Batal"}',
    );
    return konfirmasi ?? false;
  }

  Future<void> _arsipkanKategoriUtama(KategoriModel kategori) async {
    L.i(
      'Memproses pengarsipan kategori utama: ${kategori.nama} (ID: ${kategori.id})',
    );
    final bool konfirmasi = await _tampilkanDialogKonfirmasi(
      'Arsipkan Kategori',
      'Anda yakin ingin mengarsipkan "${kategori.nama}"? Kategori ini tidak akan bisa digunakan lagi.',
    );
    if (!mounted || !konfirmasi) {
      L.i(
        'Pengarsipan kategori ${kategori.nama} dibatalkan (konfirmasi: $konfirmasi, mounted: $mounted)',
      );
      return;
    }

    try {
      L.i(
        'Mengarsipkan kategori utama ID: ${kategori.id}, nama: ${kategori.nama}',
      );
      final kategoriDiperbarui = kategori.copyWith(diarsipkan: DateTime.now());
      await _kategoriOperasi.update(kategoriDiperbarui);
      L.i(
        'Kategori ${kategori.nama} (ID: ${kategori.id}) berhasil diarsipkan pada ${kategoriDiperbarui.diarsipkan}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori berhasil diarsipkan.')),
      );
      _loadKategori();
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengarsipkan kategori ID: ${kategori.id}, nama: ${kategori.nama} Error: $e $stackTrace',
      );
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
    L.i(
      'Memproses pengarsipan sub-kategori: ${subKategori.nama} (ID: ${subKategori.id}) dari kategori induk: ${kategoriInduk.nama}',
    );
    final bool konfirmasi = await _tampilkanDialogKonfirmasi(
      'Arsipkan Sub-Kategori',
      'Anda yakin ingin mengarsipkan sub-kategori "${subKategori.nama}"?',
    );
    if (!mounted || !konfirmasi) {
      L.i(
        'Pengarsipan sub-kategori ${subKategori.nama} dibatalkan (konfirmasi: $konfirmasi, mounted: $mounted)',
      );
      return;
    }

    try {
      L.i(
        'Mengarsipkan sub-kategori ID: ${subKategori.id}, nama: ${subKategori.nama}',
      );
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
      L.i(
        'Sub-kategori ${subKategori.nama} (ID: ${subKategori.id}) berhasil diarsipkan, kategori induk ${kategoriInduk.nama} diperbarui',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sub-kategori berhasil diarsipkan.')),
      );
      _loadKategori();
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengarsipkan sub-kategori ID: ${subKategori.id}, nama: ${subKategori.nama} Error: $e $stackTrace',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengarsipkan sub-kategori: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i(
      'Membangun UI halaman Kategori (Mode Edit: $_isEdit, Mode Arsip: $_isArsipMode, Filter Tipe: ${_selectedTipe.name})',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            tooltip: _isArsipMode ? 'Selesai' : 'Arsipkan',
            onPressed: () {
              setState(() {
                _isArsipMode = !_isArsipMode;
                if (_isArsipMode) {
                  _isEdit = false;
                  L.i('Mode ARSIP diaktifkan, Mode EDIT dinonaktifkan');
                } else {
                  L.i('Mode ARSIP dinonaktifkan');
                }
              });
            },
            icon: Icon(_isArsipMode ? Icons.check : Icons.archive_outlined),
          ),
          IconButton(
            tooltip: _isEdit ? 'Selesai' : 'Edit',
            onPressed: () {
              setState(() {
                _isEdit = !_isEdit;
                if (_isEdit) {
                  _isArsipMode = false;
                  L.i('Mode EDIT diaktifkan, Mode ARSIP dinonaktifkan');
                } else {
                  L.i('Mode EDIT dinonaktifkan');
                }
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
                  L.i('Filter tipe diubah ke PEMASUKAN');
                  setState(() => _selectedTipe = TipeKategori.pemasukan);
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
                  L.i('Filter tipe diubah ke PENGELUARAN');
                  setState(() => _selectedTipe = TipeKategori.pengeluaran);
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
                  L.e(
                    'Terjadi error saat memuat data kategori di FutureBuilder Error: $snapshot.error $snapshot.stackTrace',
                  );
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  L.i('Data kategori kosong, tidak ada kategori ditemukan');
                  return const Center(
                    child: Text('Tidak ada kategori ditemukan.'),
                  );
                } else {
                  final filteredKategori = snapshot.data!
                      .where(
                        (k) => k.tipe == _selectedTipe && k.diarsipkan == null,
                      )
                      .toList();

                  L.i(
                    'Menampilkan ${filteredKategori.length} kategori dengan tipe ${_selectedTipe.name} (total data: ${snapshot.data!.length}, difilter: ${snapshot.data!.length - filteredKategori.length} diarsipkan/beda tipe)',
                  );

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
                                    L.i(
                                      'Navigasi ke Form Edit Kategori Utama: ${kategori.nama} (ID: ${kategori.id})',
                                    );
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FormKategoriPage(
                                          kategori: kategori,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      L.i(
                                        'Kategori ${kategori.nama} berhasil diedit, menyegarkan daftar',
                                      );
                                      _loadKategori();
                                    } else {
                                      L.i(
                                        'Kembali dari Form Edit Kategori tanpa perubahan',
                                      );
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
                                            L.i(
                                              'Navigasi ke Form Edit Sub-Kategori: ${sub.nama} (ID: ${sub.id})',
                                            );
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
                                              L.i(
                                                'Sub-kategori ${sub.nama} berhasil diedit, menyegarkan daftar',
                                              );
                                              _loadKategori();
                                            } else {
                                              L.i(
                                                'Kembali dari Form Edit Sub-Kategori tanpa perubahan',
                                              );
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
