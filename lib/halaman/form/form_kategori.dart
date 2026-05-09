// path: lib/halaman/form/form_kategori.dart
// Halaman ini menyediakan formulir untuk menambah atau mengedit kategori dan sub-kategori.

import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer; // Tambahkan import developer

class FormKategoriPage extends StatefulWidget {
  final KategoriModel? kategori;
  final SubKategoriModel? subKategori;
  final String? idKategoriInduk;

  const FormKategoriPage({
    super.key,
    this.kategori,
    this.subKategori,
    this.idKategoriInduk,
  });

  @override
  State<FormKategoriPage> createState() => _FormKategoriPageState();
}

class _FormKategoriPageState extends State<FormKategoriPage> {
  final _formKey = GlobalKey<FormState>();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final LayananUnggahData _layananUnggahData = LayananUnggahData();

  late TipeKategori _tipe;
  late TextEditingController _namaController;
  final _namaFocusNode = FocusNode();

  final List<TextEditingController> _subKategoriControllers = [];

  bool get _isEditMode => widget.kategori != null || widget.subKategori != null;
  bool get _isSubKategoriMode =>
      widget.subKategori != null || widget.idKategoriInduk != null;

  final _cekKoneksi = KoneksiInternetService();

  @override
  void initState() {
    super.initState();
    developer.log('[FormKategori] 🚀 : Inisialisasi FormKategoriPage');
    _namaController = TextEditingController();

    if (widget.kategori != null) {
      developer.log('[FormKategori] 📝 : Mode Edit Kategori detected: ${widget.kategori!.nama}');
      _namaController.text = widget.kategori!.nama;
      _tipe = widget.kategori!.tipe;
    } else if (widget.subKategori != null) {
      developer.log('[FormKategori] 📝 : Mode Edit Sub-Kategori detected: ${widget.subKategori!.nama}');
      _namaController.text = widget.subKategori!.nama;
    } else {
      developer.log('[FormKategori] ✨ : Mode Tambah Baru');
      _tipe = TipeKategori.pemasukan;
      _tambahInputSubKategori();
    }
  }

  @override
  void dispose() {
    developer.log('[FormKategori] 🧹 : Melakukan dispose pada controller dan focusNode');
    _namaController.dispose();
    _namaFocusNode.dispose();
    for (var controller in _subKategoriControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _tambahInputSubKategori() {
    developer.log('[FormKategori] ➕ : Menambahkan field input sub-kategori baru');
    setState(() {
      _subKategoriControllers.add(TextEditingController());
    });
  }

  void _hapusInputSubKategori(int index) {
    developer.log('[FormKategori] 🗑️ : Menghapus field input sub-kategori pada index: $index');
    setState(() {
      _subKategoriControllers[index].dispose();
      _subKategoriControllers.removeAt(index);
    });
  }

  void _simpanForm() async {
    developer.log('[FormKategori] 💾 : Tombol Simpan ditekan');
    if (_formKey.currentState!.validate()) {
      try {
        if (_isEditMode && widget.subKategori != null) {
          developer.log('[FormKategori] 🔄 : Memproses pembaruan Sub-Kategori');
          if (widget.idKategoriInduk == null) {
            throw Exception('ID kategori induk tidak ditemukan saat mengedit sub-kategori.');
          }
          final kategoriInduk = await _kategoriOperasi.getKategoriById(widget.idKategoriInduk!);
          final subKategoriIndex = kategoriInduk.subKategori.indexWhere((s) => s.id == widget.subKategori!.id);

          if (subKategoriIndex != -1) {
            final subKategoriDiperbarui = kategoriInduk.subKategori[subKategoriIndex].copyWith(
              nama: _namaController.text,
              diperbarui: DateTime.now(),
            );
            kategoriInduk.subKategori[subKategoriIndex] = subKategoriDiperbarui;
            await _kategoriOperasi.update(kategoriInduk);
          } else {
            throw Exception('Sub-kategori tidak ditemukan untuk diedit.');
          }
        } else if (_isEditMode && widget.kategori != null) {
          developer.log('[FormKategori] 🔄 : Memproses pembaruan Kategori Induk');
          final kategoriDiperbarui = widget.kategori!.copyWith(
            nama: _namaController.text,
            tipe: _tipe,
            diperbarui: DateTime.now(),
          );
          await _kategoriOperasi.update(kategoriDiperbarui);
        } else {
          developer.log('[FormKategori] 📤 : Membuat data Kategori dan Sub-Kategori baru');
          final String kategoriId = const Uuid().v4();

          final List<SubKategoriModel> subKategoriList = _subKategoriControllers
              .where((controller) => controller.text.isNotEmpty)
              .map((controller) => SubKategoriModel(
                    nama: controller.text,
                    idKategori: kategoriId,
                    diperbarui: DateTime.now(),
                  ))
              .toList();

          final kategoriBaru = KategoriModel(
            id: kategoriId,
            nama: _namaController.text,
            tipe: _tipe,
            subKategori: subKategoriList,
            diperbarui: DateTime.now(),
          );
          await _kategoriOperasi.createKategori(kategoriBaru);
        }

        // Sinkronisasi ke Cloud jika online
        if (await _cekKoneksi.cekKoneksi()) {
          developer.log('[FormKategori] ☁️ : Koneksi tersedia, mencoba unggah data ke server');
          await _layananUnggahData.unggahDataKategori();
        }

        developer.log('[FormKategori] ✅ : Data berhasil disimpan ke lokal');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_isSubKategoriMode ? 'Sub-Kategori' : 'Kategori'} berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        developer.log('[FormKategori] ❌ : Error saat menyimpan data: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      developer.log('[FormKategori] ⚠️ : Validasi form gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    String judul = 'Form Kategori';
    if (_isEditMode && widget.kategori != null) judul = 'Edit Kategori';
    if (_isEditMode && widget.subKategori != null) judul = 'Edit Sub-Kategori';
    if (!_isEditMode && widget.idKategoriInduk != null) judul = 'Tambah Sub-Kategori';
    if (!_isEditMode && widget.kategori == null && widget.subKategori == null) judul = 'Tambah Kategori Baru';

    return Scaffold(
      appBar: AppBar(title: Text(judul), leading: const BackButton()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  decoration: InputDecoration(
                    labelText: _isSubKategoriMode ? 'Nama Sub-Kategori' : 'Nama Kategori',
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  validator: (value) => (value == null || value.isEmpty) ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                if (!_isEditMode && !_isSubKategoriMode) ...[
                  DropdownButtonFormField<TipeKategori>(
                    initialValue: _tipe,
                    decoration: const InputDecoration(
                      labelText: 'Tipe',
                      border: OutlineInputBorder(),
                    ),
                    items: TipeKategori.values
                        .where((tipe) => tipe != TipeKategori.transfer)
                        .map((TipeKategori tipe) {
                      return DropdownMenuItem<TipeKategori>(
                        value: tipe,
                        child: Text(
                          tipe.name.substring(0, 1).toUpperCase() + tipe.name.substring(1),
                        ),
                      );
                    }).toList(),
                    onChanged: (TipeKategori? newValue) {
                      if (newValue != null) {
                        developer.log('[FormKategori] 🔘 : Tipe kategori diubah menjadi: $newValue');
                        setState(() {
                          _tipe = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tambah Sub-Kategori (Opsional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subKategoriControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _subKategoriControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Nama Sub-Kategori ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _hapusInputSubKategori(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _tambahInputSubKategori,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Input'),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _simpanForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
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
}