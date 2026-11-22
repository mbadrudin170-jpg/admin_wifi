// path: lib/fitur/paket/screens/form_paket.dart

import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class FormPaket extends ConsumerStatefulWidget {
  final PaketModel? paket;

  const FormPaket({super.key, this.paket});

  @override
  ConsumerState<FormPaket> createState() => _FormPaketState();
}

class _FormPaketState extends ConsumerState<FormPaket> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _durasiController = TextEditingController();
  final _poinHadiahController = TextEditingController();
  final _poinPenukaranController = TextEditingController();

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

    if (_isEditMode) {
      final p = widget.paket!;
      _namaController.text = p.nama;
      _hargaController.text = p.harga.toString();
      _durasiController.text = p.durasi.toString();
      _poinHadiahController.text = p.poinHadiah.toString();
      _poinPenukaranController.text = p.poinPenukaran.toString();
      _selectedTipe = p.tipe;
      _isPublic = p.isPublic;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _durasiController.dispose();
    _poinHadiahController.dispose();
    _poinPenukaranController.dispose();

    _namaFocusNode.dispose();
    _hargaFocusNode.dispose();
    _durasiFocusNode.dispose();
    _poinHadiahFocusNode.dispose();
    _poinPenukaranFocusNode.dispose();

    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final newPaket = PaketModel(
      id: _isEditMode ? widget.paket!.id : const Uuid().v4(),
      nama: _namaController.text,
      harga: InputAngka.parseAngkaRibuan(_hargaController.text).toInt(),
      durasi: InputAngka.parseAngkaRibuan(_durasiController.text).toInt(),
      tipe: _selectedTipe,
      poinHadiah: InputAngka.parseAngkaRibuan(
        _poinHadiahController.text,
      ).toInt(),
      poinPenukaran: InputAngka.parseAngkaRibuan(
        _poinPenukaranController.text,
      ).toInt(),
      isPublic: _isPublic,
    );

    try {
      final notifier = ref.read(paketProvider.notifier);
      if (_isEditMode) {
        await notifier.ubah(newPaket);
      } else {
        await notifier.tambah(newPaket);
      }

      if (!mounted) return;
      AppToast.sukses(
        context,
        'Data paket berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}!',
      );
      Nav.pop(context);
    } on DatabaseException catch (e, s) {
      L.e('Gagal menyimpan paket: $e $s');
      if (!mounted) return;
      final errorMessage = e.isUniqueConstraintError()
          ? 'Nama paket sudah ada. Harap gunakan nama lain.'
          : 'Gagal menyimpan paket. Terjadi kesalahan database.';
      AppToast.gagal(context, errorMessage);
    } catch (e, s) {
      L.e('Gagal menyimpan paket: $e $s');
      if (!mounted) return;
      AppToast.gagal(context, 'Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Paket' : 'Tambah Paket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                InputTeks(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  label: 'Nama Paket',
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_hargaFocusNode),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama paket tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InputAngka(
                  controller: _hargaController,
                  focusNode: _hargaFocusNode,
                  label: 'Harga',
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_durasiFocusNode),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    if (InputAngka.parseAngkaRibuan(value).toInt() == 0 &&
                        value.replaceAll(RegExp(r'[^0-9]'), '') == '') {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InputAngka(
                  controller: _durasiController,
                  focusNode: _durasiFocusNode,
                  label: 'Durasi',
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_poinHadiahFocusNode),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Durasi tidak boleh kosong';
                    }
                    if (InputAngka.parseAngkaRibuan(value) == 0 &&
                        value.replaceAll(RegExp(r'[^0-9]'), '') == '') {
                      return 'Durasi harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InputAngka(
                  controller: _poinHadiahController,
                  focusNode: _poinHadiahFocusNode,
                  label: 'Poin Hadiah',
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(
                    context,
                  ).requestFocus(_poinPenukaranFocusNode),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        InputAngka.parseAngkaRibuan(value) == 0 &&
                        value.replaceAll(RegExp(r'[^0-9]'), '') != '') {
                      return 'Poin hadiah harus angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InputAngka(
                  controller: _poinPenukaranController,
                  focusNode: _poinPenukaranFocusNode,
                  label: 'Poin Penukaran',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveForm(),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        InputAngka.parseAngkaRibuan(value) == 0 &&
                        value.replaceAll(RegExp(r'[^0-9]'), '') != '') {
                      return 'Poin penukaran harus angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputDropdown<TipeDurasi>(
                  value: _selectedTipe,
                  label: 'Tipe Durasi',
                  items: TipeDurasi.values,
                  displayString: (tipe) => tipe.label,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedTipe = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Paket Aktif (Public)'),
                  subtitle: const Text('Jika OFF, paket tidak tampil ke user'),
                  value: _isPublic,
                  onChanged: (value) => setState(() => _isPublic = value),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          await _saveForm();
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Simpan'),
      ),
    );
  }
}
