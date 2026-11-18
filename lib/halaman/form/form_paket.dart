// lib/halaman/form/form_paket.dart
// Halaman ini menyediakan formulir untuk menambah atau mengedit paket internet.
// diperbaiki: Menambahkan SingleChildScrollView untuk mengatasi RenderFlex overflow.
// diubah: Menerapkan Dependency Injection untuk PaketOperasi agar mudah diuji.
// ditambah: Implementasi FocusNode untuk perpindahan input dengan tombol Enter.

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:flutter/material.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class FormPaket extends StatefulWidget {
  final PaketModel? paket;
  final PaketOperasi? paketOperasi;

  const FormPaket({super.key, this.paket, this.paketOperasi});

  @override
  State<FormPaket> createState() => _FormPaketState();
}

class _FormPaketState extends State<FormPaket> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _durasiController = TextEditingController();
  final _poinHadiahController = TextEditingController();
  final _poinPenukaranController = TextEditingController();
  late final PaketOperasi _paketOperasi;

  // ditambah: FocusNode untuk setiap input field
  final _namaFocusNode = FocusNode();
  final _hargaFocusNode = FocusNode();
  final _durasiFocusNode = FocusNode();
  final _poinHadiahFocusNode = FocusNode();
  final _poinPenukaranFocusNode = FocusNode();

  TipeDurasi _selectedTipe = TipeDurasi.hari;

  bool get _isEditMode => widget.paket != null;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    L.i('========================================');
    L.i('LIFECYCLE: initState() - Halaman FormPaket');
    L.i('========================================');

    // dihapus: Variabel lokal isEditMode tidak digunakan
    L.i(
      'Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}, '
      '${_isEditMode ? "ID: ${widget.paket!.id}, Nama: ${widget.paket!.nama}, Harga: ${widget.paket!.harga}, Durasi: ${widget.paket!.durasi} ${widget.paket!.tipe.label}" : ""}',
    );

    L.i(
      'Menginisialisasi PaketOperasi. '
      'Menggunakan instance dari widget jika tersedia, jika tidak membuat instance baru.',
    );
    _paketOperasi = widget.paketOperasi ?? PaketOperasi();
    L.i(
      'PaketOperasi berhasil diinisialisasi. '
      'Instance: ${_paketOperasi.hashCode}, '
      'Sumber: ${widget.paketOperasi != null ? "Dependency Injection" : "Instance Baru"}',
    );

    if (_isEditMode) {
      L.i('MODE EDIT terdeteksi. Data paket yang akan diedit:');
      L.i('  - ID: ${widget.paket!.id}');
      L.i('  - Nama: ${widget.paket!.nama}');
      L.i('  - Harga: ${widget.paket!.harga}');
      L.i('  - Durasi: ${widget.paket!.durasi}');
      L.i('  - Tipe Durasi: ${widget.paket!.tipe.label}');
      L.i('  - Poin Hadiah: ${widget.paket!.poinHadiah}');
      L.i('  - Poin Penukaran: ${widget.paket!.poinPenukaran}');
      L.i('  - isPublic: ${widget.paket!.isPublic}');
      L.i('  - isDeleted: ${widget.paket!.isDeleted}');
      L.i('  - Diperbarui: ${widget.paket!.diperbarui}');
      L.i('  - Diarsipkan: ${widget.paket!.diarsipkan ?? "NULL"}');

      L.i('Mengisi TextEditingController dengan data dari paket yang diedit.');
      _namaController.text = widget.paket!.nama;
      L.i('  - _namaController.text = "${widget.paket!.nama}"');

      _hargaController.text = widget.paket!.harga.toString();
      L.i('  - _hargaController.text = "${widget.paket!.harga}"');

      _durasiController.text = widget.paket!.durasi.toString();
      L.i('  - _durasiController.text = "${widget.paket!.durasi}"');

      _poinHadiahController.text = widget.paket!.poinHadiah.toString();
      L.i('  - _poinHadiahController.text = "${widget.paket!.poinHadiah}"');

      _poinPenukaranController.text = widget.paket!.poinPenukaran.toString();
      L.i(
        '  - _poinPenukaranController.text = "${widget.paket!.poinPenukaran}"',
      );

      _selectedTipe = widget.paket!.tipe;
      L.i('  - _selectedTipe = ${widget.paket!.tipe.label}');

      _isPublic = widget.paket!.isPublic;
      L.i('  - _isPublic = ${widget.paket!.isPublic}');
    } else {
      L.i('MODE TAMBAH BARU terdeteksi.');
      L.i('Form akan membuat paket baru dengan:');
      L.i('  - ID: Akan digenerate otomatis oleh database');
      L.i('  - isPublic default: true (paket aktif)');
      L.i('  - Tipe Durasi default: hari');
      L.i('  - isDeleted default: 0');
      L.i('  - Diarsipkan default: NULL');
      L.i('  - Diperbarui: Akan diisi otomatis');
    }

    L.i(
      'Inisialisasi FormPaket selesai. Semua controller siap menerima input.',
    );
  }

  void _saveForm() async {
    L.i('========================================');
    L.i('AKSI: Tombol Simpan Ditekan');
    L.i('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    L.i('========================================');

    L.i('Memvalidasi form...');
    if (_formKey.currentState!.validate()) {
      L.i('Validasi form BERHASIL. Semua input valid.');

      L.i('Data yang akan disimpan:');
      L.i('  - Nama: "${_namaController.text}"');
      L.i('  - Harga: ${_hargaController.text}');
      L.i('  - Durasi: ${_durasiController.text}');
      L.i('  - Tipe Durasi: ${_selectedTipe.label}');
      L.i(
        '  - Poin Hadiah: ${_poinHadiahController.text.isNotEmpty ? _poinHadiahController.text : "0 (default)"}',
      );
      L.i(
        '  - Poin Penukaran: ${_poinPenukaranController.text.isNotEmpty ? _poinPenukaranController.text : "0 (default)"}',
      );
      L.i('  - isPublic: $_isPublic');
      L.i(
        '  - ID: ${_isEditMode ? widget.paket!.id : "Akan digenerate otomatis"}',
      );

      L.i('Membuat objek PaketModel baru dari data form.');
      final newPaket = PaketModel(
        id: _isEditMode ? widget.paket!.id : const Uuid().v4(),
        nama: _namaController.text,
        harga: int.parse(_hargaController.text),
        durasi: int.parse(_durasiController.text),
        tipe: _selectedTipe,
        poinHadiah: int.tryParse(_poinHadiahController.text) ?? 0,
        poinPenukaran: int.tryParse(_poinPenukaranController.text) ?? 0,
        isPublic: _isPublic,
      );

      L.i('Objek PaketModel berhasil dibuat:');
      L.i('  - ID: ${newPaket.id}');
      L.i('  - Nama: ${newPaket.nama}');
      L.i('  - Harga: ${newPaket.harga}');
      L.i('  - Durasi: ${newPaket.durasi}');
      L.i('  - Tipe: ${newPaket.tipe.label}');
      L.i('  - Poin Hadiah: ${newPaket.poinHadiah}');
      L.i('  - Poin Penukaran: ${newPaket.poinPenukaran}');
      L.i('  - isPublic: ${newPaket.isPublic}');

      try {
        if (_isEditMode) {
          L.i('========================================');
          L.i('PROSES UPDATE PAKET (MODE EDIT)');
          L.i('========================================');
          L.i('Data sebelum update:');
          L.i('  - Nama: ${widget.paket!.nama} -> ${newPaket.nama}');
          L.i('  - Harga: ${widget.paket!.harga} -> ${newPaket.harga}');
          L.i('  - Durasi: ${widget.paket!.durasi} -> ${newPaket.durasi}');
          L.i(
            '  - Tipe: ${widget.paket!.tipe.label} -> ${newPaket.tipe.label}',
          );
          L.i(
            '  - Poin Hadiah: ${widget.paket!.poinHadiah} -> ${newPaket.poinHadiah}',
          );
          L.i(
            '  - Poin Penukaran: ${widget.paket!.poinPenukaran} -> ${newPaket.poinPenukaran}',
          );
          L.i(
            '  - isPublic: ${widget.paket!.isPublic} -> ${newPaket.isPublic}',
          );

          L.i(
            'Memanggil _paketOperasi.updatePaket() untuk menyimpan perubahan ke database.',
          );
          await _paketOperasi.updatePaket(newPaket);
          L.i(
            'Update paket BERHASIL. Data paket telah diperbarui di database.',
          );
        } else {
          L.i('========================================');
          L.i('PROSES TAMBAH PAKET BARU (MODE TAMBAH)');
          L.i('========================================');

          L.i(
            'Memanggil _paketOperasi.createPaket() untuk menyimpan paket baru ke database.',
          );
          await _paketOperasi.createPaket(newPaket);
          L.i('Paket baru BERHASIL disimpan ke database.');
        }

        if (!mounted) {
          L.w(
            'Widget sudah tidak mounted setelah operasi database berhasil. '
            'Tidak dapat menampilkan SnackBar atau melakukan Navigator.pop.',
          );
          return;
        }

        L.i('========================================');
        L.i('PENYIMPANAN DATA PAKET BERHASIL');
        L.i('========================================');

        L.i('Menampilkan SnackBar sukses ke pengguna.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // diperbaiki: Menghapus backslash yang salah
              'Data paket berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}!',
            ),
          ),
        );
        L.i('SnackBar sukses telah ditampilkan.');

        L.i(
          'Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.',
        );
        L.i(
          'Nilai result true dikirim untuk memberitahu halaman sebelumnya bahwa ada perubahan data.',
        );
        Navigator.pop(context, true);
        L.i('Navigator.pop berhasil dijalankan.');
      } on DatabaseException catch (e, s) {
        L.i('========================================');
        L.i('ERROR DATABASE TERDETEKSI');
        L.i('========================================');

        String errorMessage =
            'Gagal menyimpan paket. Terjadi kesalahan database.';
        L.w('Terjadi DatabaseException saat menyimpan paket.');
        L.w('Detail exception: ${e.toString()}');

        if (e.isUniqueConstraintError()) {
          errorMessage = 'Nama paket sudah ada. Harap gunakan nama lain.';
          L.w(
            'Penyebab: UNIQUE CONSTRAINT VIOLATION. '
            'Nama paket "${_namaController.text}" sudah ada di database. '
            'Pengguna harus menggunakan nama yang berbeda.',
          );
        } else {
          L.e(
            'DatabaseException tidak dikenal saat menyimpan paket. '
            'Kemungkinan penyebab: constraint violation lain, database corrupt, '
            'atau kesalahan struktur tabel. Error: $e $s',
          );
        }

        if (!mounted) {
          L.w(
            'Widget sudah tidak mounted setelah DatabaseException. '
            'Tidak dapat menampilkan SnackBar error.',
          );
          return;
        }

        L.i(
          'Menampilkan SnackBar error ke pengguna dengan pesan: "$errorMessage"',
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        L.i('SnackBar error telah ditampilkan.');
      } catch (e, s) {
        L.e(
          'Gagal menyimpan paket karena error tidak dikenal (Unknown Error). '
          'Terjadi kesalahan yang tidak terduga saat operasi ${_isEditMode ? "update" : "create"} paket. '
          'Kemungkinan penyebab: koneksi database gagal, memory overflow, '
          'atau exception dari sistem yang tidak tertangani. Error: $e $s',
        );

        if (!mounted) {
          L.w(
            'Widget sudah tidak mounted setelah Unknown Error. '
            'Tidak dapat menampilkan SnackBar error.',
          );
          return;
        }

        L.i('Menampilkan SnackBar error umum ke pengguna.');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
        L.i('SnackBar error telah ditampilkan.');
      }
    } else {
      L.w('Validasi form GAGAL. Terdapat input yang tidak valid.');
      L.w('Kemungkinan penyebab:');
      L.w('  - Nama paket kosong');
      L.w('  - Harga kosong atau bukan angka');
      L.w('  - Durasi kosong atau bukan angka');
      L.w('  - Poin hadiah bukan angka');
      L.w('  - Poin penukaran bukan angka');
      L.i('Form tidak akan disimpan sampai semua input valid.');
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('========================================');
    L.i('LIFECYCLE: build() - Membangun UI FormPaket');
    L.i('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    L.i('Data form saat ini:');
    L.i('  - Nama: "${_namaController.text}"');
    L.i('  - Harga: "${_hargaController.text}"');
    L.i('  - Durasi: "${_durasiController.text}"');
    L.i('  - Tipe Durasi: ${_selectedTipe.label}');
    L.i('  - Poin Hadiah: "${_poinHadiahController.text}"');
    L.i('  - Poin Penukaran: "${_poinPenukaranController.text}"');
    L.i('  - isPublic: $_isPublic');
    L.i('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Paket' : 'Tambah Paket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            L.i(
              'NAVIGASI: Tombol Kembali ditekan. '
              'Kembali ke halaman sebelumnya dengan result false (tidak ada perubahan).',
            );
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _namaController,
                  focusNode: _namaFocusNode, // ditambah: focusNode
                  textInputAction:
                      TextInputAction.next, // ditambah: textInputAction
                  decoration: const InputDecoration(labelText: 'Nama Paket'),
                  onChanged: (value) {
                    L.i(
                      'INPUT: Nama paket berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    L.i(
                      'VALIDASI: Memvalidasi input nama paket. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      L.w('VALIDASI GAGAL: Nama paket kosong.');
                      return 'Nama paket tidak boleh kosong';
                    }
                    L.i('VALIDASI BERHASIL: Nama paket valid.');
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    FocusScope.of(context).requestFocus(_hargaFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hargaController,
                  focusNode: _hargaFocusNode, // ditambah: focusNode
                  textInputAction:
                      TextInputAction.next, // ditambah: textInputAction
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    L.i(
                      'INPUT: Harga berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    L.i(
                      'VALIDASI: Memvalidasi input harga. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      L.w('VALIDASI GAGAL: Harga kosong.');
                      return 'Harga tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      L.w(
                        'VALIDASI GAGAL: Harga bukan angka yang valid. Nilai: "$value"',
                      );
                      return 'Harga harus berupa angka';
                    }
                    L.i('VALIDASI BERHASIL: Harga valid = ${int.parse(value)}');
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    FocusScope.of(context).requestFocus(_durasiFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durasiController,
                  focusNode: _durasiFocusNode, // ditambah: focusNode
                  textInputAction:
                      TextInputAction.next, // ditambah: textInputAction
                  decoration: const InputDecoration(labelText: 'Durasi'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    L.i(
                      'INPUT: Durasi berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    L.i(
                      'VALIDASI: Memvalidasi input durasi. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      L.w('VALIDASI GAGAL: Durasi kosong.');
                      return 'Durasi tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      L.w(
                        'VALIDASI GAGAL: Durasi bukan angka yang valid. Nilai: "$value"',
                      );
                      return 'Durasi harus berupa angka';
                    }
                    L.i(
                      'VALIDASI BERHASIL: Durasi valid = ${int.parse(value)}',
                    );
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    FocusScope.of(context).requestFocus(_poinHadiahFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _poinHadiahController,
                  focusNode: _poinHadiahFocusNode, // ditambah: focusNode
                  textInputAction:
                      TextInputAction.next, // ditambah: textInputAction
                  decoration: const InputDecoration(labelText: 'Poin Hadiah'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    L.i(
                      'INPUT: Poin hadiah berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    L.i(
                      'VALIDASI: Memvalidasi input poin hadiah. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      L.i(
                        'VALIDASI: Poin hadiah kosong, dianggap valid (opsional). Default akan digunakan (0).',
                      );
                      return null;
                    }
                    if (int.tryParse(value) == null) {
                      L.w(
                        'VALIDASI GAGAL: Poin hadiah bukan angka yang valid. Nilai: "$value"',
                      );
                      return 'Poin hadiah harus angka';
                    }
                    L.i(
                      'VALIDASI BERHASIL: Poin hadiah valid = ${int.parse(value)}',
                    );
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    FocusScope.of(
                      context,
                    ).requestFocus(_poinPenukaranFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _poinPenukaranController,
                  focusNode: _poinPenukaranFocusNode, // ditambah: focusNode
                  textInputAction: TextInputAction
                      .done, // diubah: textInputAction menjadi done
                  decoration: const InputDecoration(
                    labelText: 'Poin Penukaran',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    L.i(
                      'INPUT: Poin penukaran berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    L.i(
                      'VALIDASI: Memvalidasi input poin penukaran. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      L.i(
                        'VALIDASI: Poin penukaran kosong, dianggap valid (opsional). Default akan digunakan (0).',
                      );
                      return null;
                    }
                    if (int.tryParse(value) == null) {
                      L.w(
                        'VALIDASI GAGAL: Poin penukaran bukan angka yang valid. Nilai: "$value"',
                      );
                      return 'Poin penukaran harus angka';
                    }
                    L.i(
                      'VALIDASI BERHASIL: Poin penukaran valid = ${int.parse(value)}',
                    );
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    _saveForm(); // diubah: panggil _saveForm saat selesai
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TipeDurasi>(
                  initialValue: _selectedTipe,
                  decoration: const InputDecoration(labelText: 'Tipe Durasi'),
                  items: TipeDurasi.values.map((TipeDurasi tipe) {
                    return DropdownMenuItem<TipeDurasi>(
                      value: tipe,
                      child: Text(tipe.label),
                    );
                  }).toList(),
                  onChanged: (TipeDurasi? newValue) {
                    if (newValue != null) {
                      L.i('DROPDOWN: Tipe durasi diubah.');
                      L.i('  - Tipe Lama: ${_selectedTipe.label}');
                      L.i('  - Tipe Baru: ${newValue.label}');
                      setState(() {
                        _selectedTipe = newValue;
                      });
                      L.i(
                        'State _selectedTipe berhasil diperbarui ke: ${_selectedTipe.label}',
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Paket Aktif (Public)'),
                  subtitle: const Text('Jika OFF, paket tidak tampil ke user'),
                  value: _isPublic,
                  onChanged: (value) {
                    L.i('SWITCH: Status public diubah.');
                    L.i('  - Status Lama: $_isPublic');
                    L.i('  - Status Baru: $value');
                    L.i(
                      '  - Efek: Paket akan ${value ? "TAMPIL" : "TIDAK TAMPIL"} ke pengguna.',
                    );
                    setState(() {
                      _isPublic = value;
                    });
                    L.i('State _isPublic berhasil diperbarui ke: $_isPublic');
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    L.i('AKSI: Tombol Simpan ditekan oleh pengguna.');
                    _saveForm();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    L.i('========================================');
    L.i('LIFECYCLE: dispose() - Halaman FormPaket');
    L.i('Membersihkan resource:');
    L.i('  - Mendispose TextEditingController (_namaController)');
    L.i('  - Mendispose TextEditingController (_hargaController)');
    L.i('  - Mendispose TextEditingController (_durasiController)');
    L.i('  - Mendispose TextEditingController (_poinHadiahController)');
    L.i('  - Mendispose TextEditingController (_poinPenukaranController)');
    L.i('  - Mendispose FocusNode (_namaFocusNode)');
    L.i('  - Mendispose FocusNode (_hargaFocusNode)');
    L.i('  - Mendispose FocusNode (_durasiFocusNode)');
    L.i('  - Mendispose FocusNode (_poinHadiahFocusNode)');
    L.i('  - Mendispose FocusNode (_poinPenukaranFocusNode)');
    L.i('========================================');

    _namaController.dispose();
    _hargaController.dispose();
    _durasiController.dispose();
    _poinHadiahController.dispose();
    _poinPenukaranController.dispose();

    // ditambah: dispose FocusNode
    _namaFocusNode.dispose();
    _hargaFocusNode.dispose();
    _durasiFocusNode.dispose();
    _poinHadiahFocusNode.dispose();
    _poinPenukaranFocusNode.dispose();

    L.i('Semua resource berhasil dibersihkan.');
    super.dispose();
  }
}
