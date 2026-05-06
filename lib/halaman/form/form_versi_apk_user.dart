// path: lib/halaman/form/form_versi_apk_user.dart

// Halaman ini menyediakan formulir untuk menambah atau mengedit data VersiApkUser.

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';

// untuk menampilkan form untuk menambah atau mengedit konfigurasi versi aplikasi.
class FormVersiApkUser extends StatefulWidget {
  final VersiApkUserModel? versiApkUser;

  const FormVersiApkUser({super.key, this.versiApkUser});

  @override
  State<FormVersiApkUser> createState() => _FormVersiApkUserState();
}

class _FormVersiApkUserState extends State<FormVersiApkUser> {
  final _formKey = GlobalKey<FormState>();
  final _operasi = VersiApkUserOperasi();
  bool _isLoading = false;

  // ditambah: Getter untuk memeriksa mode edit dengan mudah.
  bool get _isEdit => widget.versiApkUser != null;

  late TextEditingController _catatanRilisController;
  late TextEditingController _versiTerbaruController;
  late TextEditingController _youtubeTutorialController;
  late TextEditingController _buildBit32Controller;
  late TextEditingController _buildBit64Controller;
  late TextEditingController _buildUniversalController;
  late TextEditingController _tautanArm64Controller;
  late TextEditingController _tautanArmeabiController;
  late TextEditingController _tautanUniversalController;
  late bool _wajibUpdate;

  @override
  void initState() {
    super.initState();
    _catatanRilisController = TextEditingController();
    _versiTerbaruController = TextEditingController();
    _youtubeTutorialController = TextEditingController();
    _buildBit32Controller = TextEditingController();
    _buildBit64Controller = TextEditingController();
    _buildUniversalController = TextEditingController();
    _tautanArm64Controller = TextEditingController();
    _tautanArmeabiController = TextEditingController();
    _tautanUniversalController = TextEditingController();
    _wajibUpdate = false;

    // diubah: Logika pemuatan data disederhanakan.
    if (_isEdit) {
      _populateControllers(widget.versiApkUser!);
    }
  }

  // diubah: Fungsi ini sekarang hanya untuk mengisi data saat mode edit.
  void _populateControllers(VersiApkUserModel data) {
    _catatanRilisController.text = data.catatanRilis;
    _versiTerbaruController.text = data.versiTerbaru;
    _youtubeTutorialController.text = data.youtubeTutorial;
    _buildBit32Controller.text = data.nomorBuildTerbaru['bit_32']?.toString() ?? '';
    _buildBit64Controller.text = data.nomorBuildTerbaru['bit_64']?.toString() ?? '';
    _buildUniversalController.text = data.nomorBuildTerbaru['universal']?.toString() ?? '';
    _tautanArm64Controller.text = data.tautanUnduhan['arm64-v8a'] ?? '';
    _tautanArmeabiController.text = data.tautanUnduhan['armeabi-v7a'] ?? '';
    _tautanUniversalController.text = data.tautanUnduhan['universal'] ?? '';
    _wajibUpdate = data.wajibUpdate;
  }

  @override
  void dispose() {
    _catatanRilisController.dispose();
    _versiTerbaruController.dispose();
    _youtubeTutorialController.dispose();
    _buildBit32Controller.dispose();
    _buildBit64Controller.dispose();
    _buildUniversalController.dispose();
    _tautanArm64Controller.dispose();
    _tautanArmeabiController.dispose();
    _tautanUniversalController.dispose();
    super.dispose();
  }

  void _simpanForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final nomorBuildTerbaru = {
        'bit_32': int.tryParse(_buildBit32Controller.text) ?? 0,
        'bit_64': int.tryParse(_buildBit64Controller.text) ?? 0,
        'universal': int.tryParse(_buildUniversalController.text) ?? 0,
      };

      final tautanUnduhan = {
        'arm64-v8a': _tautanArm64Controller.text,
        'armeabi-v7a': _tautanArmeabiController.text,
        'universal': _tautanUniversalController.text,
      };

      // diubah: Biarkan model yang menangani pembuatan ID jika null.
      final dataToSave = VersiApkUserModel(
        id: widget.versiApkUser?.id,
        catatanRilis: _catatanRilisController.text,
        versiTerbaru: _versiTerbaruController.text,
        youtubeTutorial: _youtubeTutorialController.text,
        wajibUpdate: _wajibUpdate,
        nomorBuildTerbaru: nomorBuildTerbaru,
        tautanUnduhan: tautanUnduhan,
      );

      try {
        // diubah: Logika untuk memanggil tambah atau perbarui.
        if (_isEdit) {
          await _operasi.perbaruiVersiApkUser(dataToSave);
        } else {
          await _operasi.tambahVersiApkUser(dataToSave);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Data berhasil disimpan!')),
        );

        Navigator.of(context).pop(true);
      } catch (e, s) {
        developer.log('Gagal menyimpan versi APK',
            name: 'FormVersiApkUser', error: e, stackTrace: s);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text('Gagal menyimpan data: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // diubah: Judul dinamis berdasarkan mode edit atau tambah.
        title: Text(_isEdit ? 'Edit Versi APK' : 'Tambah Versi APK'),
        actions: [
          IconButton(
            tooltip: 'Simpan',
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _simpanForm, // Nonaktifkan saat loading
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFormField(
                    controller: _catatanRilisController,
                    labelText: 'Catatan Rilis',
                    validator: (value) =>
                        value!.isEmpty ? 'Catatan rilis tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _versiTerbaruController,
                    labelText: 'Versi Terbaru (Contoh: 1.0.12+21)',
                    validator: (value) =>
                        value!.isEmpty ? 'Versi terbaru tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Nomor Build Terbaru'),
                  _buildTextFormField(
                    controller: _buildBit32Controller,
                    labelText: 'bit_32',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _buildBit64Controller,
                    labelText: 'bit_64',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _buildUniversalController,
                    labelText: 'universal',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tautan Unduhan'),
                  _buildTextFormField(
                    controller: _tautanArm64Controller,
                    labelText: 'arm64-v8a',
                  ),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _tautanArmeabiController,
                    labelText: 'armeabi-v7a',
                  ),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _tautanUniversalController,
                    labelText: 'universal',
                  ),
                  const SizedBox(height: 24),
                  _buildTextFormField(
                    controller: _youtubeTutorialController,
                    labelText: 'URL Tutorial YouTube',
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Wajib Update'),
                    value: _wajibUpdate,
                    onChanged: (bool value) {
                      setState(() {
                        _wajibUpdate = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}
