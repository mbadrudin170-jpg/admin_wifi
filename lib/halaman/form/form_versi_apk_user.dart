 // path: lib/halaman/form/form_versi_apk_user.dart

// Halaman ini menyediakan formulir untuk menambah atau mengedit data VersiApkUser.

import 'package:flutter/material.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';

// TODO: Buat dan import file operasi untuk menyimpan data ke Firestore
// import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';

// untuk menampilkan form untuk mengedit konfigurasi versi aplikasi.
class FormVersiApkUser extends StatefulWidget {
  final VersiApkUserModel? versiApkUser;

  const FormVersiApkUser({super.key, this.versiApkUser});

  @override
  State<FormVersiApkUser> createState() => _FormVersiApkUserState();
}

class _FormVersiApkUserState extends State<FormVersiApkUser> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk field String
  late TextEditingController _catatanRilisController;
  late TextEditingController _versiTerbaruController;
  late TextEditingController _youtubeTutorialController;

  // Controllers untuk map 'nomorBuildTerbaru'
  late TextEditingController _buildBit32Controller;
  late TextEditingController _buildBit64Controller;
  late TextEditingController _buildUniversalController;

  // Controllers untuk map 'tautanUnduhan'
  late TextEditingController _tautanArm64Controller;
  late TextEditingController _tautanArmeabiController;
  late TextEditingController _tautanUniversalController;

  // State untuk field boolean 'wajibUpdate'
  late bool _wajibUpdate;

  @override
  // untuk menginisialisasi state dan controller dengan data yang ada.
  void initState() {
    super.initState();
    final data = widget.versiApkUser;

    _catatanRilisController = TextEditingController(text: data?.catatanRilis ?? '');
    _versiTerbaruController = TextEditingController(text: data?.versiTerbaru ?? '');
    _youtubeTutorialController =
        TextEditingController(text: data?.youtubeTutorial ?? '');

    _buildBit32Controller = TextEditingController(
        text: data?.nomorBuildTerbaru['bit_32']?.toString() ?? '');
    _buildBit64Controller = TextEditingController(
        text: data?.nomorBuildTerbaru['bit_64']?.toString() ?? '');
    _buildUniversalController = TextEditingController(
        text: data?.nomorBuildTerbaru['universal']?.toString() ?? '');

    _tautanArm64Controller =
        TextEditingController(text: data?.tautanUnduhan['arm64-v8a'] ?? '');
    _tautanArmeabiController =
        TextEditingController(text: data?.tautanUnduhan['armeabi-v7a'] ?? '');
    _tautanUniversalController =
        TextEditingController(text: data?.tautanUnduhan['universal'] ?? '');

    _wajibUpdate = data?.wajibUpdate ?? false;
  }

  @override
  // untuk membersihkan controller saat widget tidak lagi digunakan.
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

  // untuk memvalidasi dan menyimpan data dari form.
  void _simpanForm() {
    if (_formKey.currentState!.validate()) {
      // Mengumpulkan data dari controllers menjadi Map
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

      // Membuat objek model baru dari data form
      VersiApkUserModel(
        catatanRilis: _catatanRilisController.text,
        versiTerbaru: _versiTerbaruController.text,
        youtubeTutorial: _youtubeTutorialController.text,
        wajibUpdate: _wajibUpdate,
        nomorBuildTerbaru: nomorBuildTerbaru,
        tautanUnduhan: tautanUnduhan,
      );

      // TODO: Panggil operasi untuk menyimpan dataBaru ke Firestore
      // final operasi = VersiApkUserOperasi();
      // await operasi.updateVersiApkUser(dataBaru);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan!')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  // untuk membangun UI dari halaman form.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.versiApkUser == null
            ? 'Tambah Versi APK'
            : 'Edit Versi APK'),
        actions: [
          IconButton(
            tooltip: 'Simpan',
            icon: const Icon(Icons.save),
            onPressed: _simpanForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  controller: _tautanArm64Controller, labelText: 'arm64-v8a'),
              const SizedBox(height: 8),
              _buildTextFormField(
                  controller: _tautanArmeabiController, labelText: 'armeabi-v7a'),
              const SizedBox(height: 8),
              _buildTextFormField(
                  controller: _tautanUniversalController, labelText: 'universal'),
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
    );
  }

  // untuk membuat judul bagian form.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // untuk membuat TextFormField dengan gaya yang konsisten.
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
