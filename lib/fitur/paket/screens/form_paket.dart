// path: lib/fitur/paket/screens/form_paket.dart

import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';
import 'package:share_global_saya/src/widget/toast_widget.dart';
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

  Future<void> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

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
      Nav.pop(context, true);
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
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Paket' : 'Tambah Paket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Nav.pop(context, false),
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
                  focusNode: _namaFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Nama Paket'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama paket tidak boleh kosong';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_hargaFocusNode),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hargaController,
                  focusNode: _hargaFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_durasiFocusNode),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durasiController,
                  focusNode: _durasiFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Durasi'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Durasi tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Durasi harus berupa angka';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_poinHadiahFocusNode),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _poinHadiahController,
                  focusNode: _poinHadiahFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Poin Hadiah'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        int.tryParse(value) == null) {
                      return 'Poin hadiah harus angka';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => FocusScope.of(
                    context,
                  ).requestFocus(_poinPenukaranFocusNode),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _poinPenukaranController,
                  focusNode: _poinPenukaranFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Poin Penukaran',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        int.tryParse(value) == null) {
                      return 'Poin penukaran harus angka';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _saveForm(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TipeDurasi>(
                  initialValue: _selectedTipe,
                  decoration: const InputDecoration(labelText: 'Tipe Durasi'),
                  items: TipeDurasi.values
                      .map(
                        (tipe) => DropdownMenuItem<TipeDurasi>(
                          value: tipe,
                          child: Text(tipe.label),
                        ),
                      )
                      .toList(),
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
                ElevatedButton(
                  onPressed: _saveForm,
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
}
