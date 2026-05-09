// path: lib/halaman/form/form_versi_apk_user.dart

import 'dart:developer' as developer;
import 'package:admin_wifi/enum/arsitektur_apk_enum.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:uuid/uuid.dart';

class FormVersiApkUser extends StatefulWidget {
  final VersiApkUserModel? versiApkUser;
  final VersiApkUserOperasi operasi;

  FormVersiApkUser({super.key, this.versiApkUser, VersiApkUserOperasi? operasi})
    : operasi = operasi ?? VersiApkUserOperasi();

  @override
  State<FormVersiApkUser> createState() => _FormVersiApkUserState();
}

class _FormVersiApkUserState extends State<FormVersiApkUser> {
  final String fileName = 'form_versi_apk_user.dart';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool get _isEdit => widget.versiApkUser != null;

  late TextEditingController _catatanRilisController;
  late TextEditingController _versiTerbaruController;
  late TextEditingController _youtubeTutorialController;
  late bool _wajibUpdate;

  late TextEditingController _buildUniversalController;
  late TextEditingController _build32Controller;
  late TextEditingController _build64Controller;
  late TextEditingController _tautanUniversalController;
  late TextEditingController _tautan32Controller;
  late TextEditingController _tautan64Controller;

  @override
  void initState() {
    super.initState();
    developer.log(
      '🚀 Inisialisasi FormVersiApkUser (Mode: ${_isEdit ? 'Edit' : 'Tambah'})',
      name: fileName,
    );

    _catatanRilisController = TextEditingController();
    _versiTerbaruController = TextEditingController();
    _youtubeTutorialController = TextEditingController();
    _wajibUpdate = false;

    _buildUniversalController = TextEditingController();
    _build32Controller = TextEditingController();
    _build64Controller = TextEditingController();
    _tautanUniversalController = TextEditingController();
    _tautan32Controller = TextEditingController();
    _tautan64Controller = TextEditingController();

    if (_isEdit) {
      _populateControllers(widget.versiApkUser!);
    } else {
      _muatDataVersiTerakhir();
    }
  }

  void _muatDataVersiTerakhir() async {
    developer.log(
      '📡 Memuat data rilis terakhir untuk otomatisasi input...',
      name: fileName,
    );
    setState(() => _isLoading = true);
    try {
      final versiTerakhir = await widget.operasi.ambilVersiApkTerbaru();
      if (versiTerakhir != null && mounted) {
        _versiTerbaruController.text = versiTerakhir.versiTerbaru;
        final buildBerikutnya =
            (versiTerakhir.nomorBuildTerbaru[ArsitekturApkEnum.universal] ??
                0) +
            1;
        _buildUniversalController.text = buildBerikutnya.toString();

        developer.log(
          '✨ Data rilis sebelumnya ditemukan. Menyarankan build: $buildBerikutnya',
          name: fileName,
        );
      }
    } catch (e, s) {
      developer.log(
        '❌ Gagal memuat data versi terakhir',
        name: fileName,
        error: e,
        stackTrace: s,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _populateControllers(VersiApkUserModel data) {
    developer.log(
      '📝 Memasukkan data model ke dalam form controller (ID: ${data.id})',
      name: fileName,
    );
    _catatanRilisController.text = data.catatanRilis;
    _versiTerbaruController.text = data.versiTerbaru;
    _youtubeTutorialController.text = data.youtubeTutorial;
    _wajibUpdate = data.wajibUpdate;

    _buildUniversalController.text =
        data.nomorBuildTerbaru[ArsitekturApkEnum.universal]?.toString() ?? '';
    _build32Controller.text =
        data.nomorBuildTerbaru[ArsitekturApkEnum.bit_32]?.toString() ?? '';
    _build64Controller.text =
        data.nomorBuildTerbaru[ArsitekturApkEnum.bit_64]?.toString() ?? '';

    _tautanUniversalController.text =
        data.tautanUnduhan[ArsitekturApkEnum.universal] ?? '';
    _tautan32Controller.text =
        data.tautanUnduhan[ArsitekturApkEnum.bit_32] ?? '';
    _tautan64Controller.text =
        data.tautanUnduhan[ArsitekturApkEnum.bit_64] ?? '';
  }

  @override
  void dispose() {
    developer.log('🔌 Menghapus semua controller (dispose)', name: fileName);
    _catatanRilisController.dispose();
    _versiTerbaruController.dispose();
    _youtubeTutorialController.dispose();
    _buildUniversalController.dispose();
    _build32Controller.dispose();
    _build64Controller.dispose();
    _tautanUniversalController.dispose();
    _tautan32Controller.dispose();
    _tautan64Controller.dispose();
    super.dispose();
  }

  void _simpanForm() async {
    if (_formKey.currentState!.validate()) {
      developer.log(
        '❓ Menampilkan dialog konfirmasi kepada pengguna',
        name: fileName,
      );

      final konfirmasi = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 10),
              Text('Konfirmasi Simpan'),
            ],
          ),
          content: const Text(
            'Apakah data versi aplikasi yang Anda masukkan sudah benar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Periksa Kembali'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya, Simpan'),
            ),
          ],
        ),
      );

      if (konfirmasi != true) {
        developer.log(
          '🚫 Pengguna membatalkan proses penyimpanan',
          name: fileName,
        );
        return;
      }

      setState(() => _isLoading = true);
      developer.log(
        '💾 Sedang memproses penyimpanan ke database...',
        name: fileName,
      );

      final nomorBuild = <ArsitekturApkEnum, int>{};
      if (_buildUniversalController.text.isNotEmpty) {
        nomorBuild[ArsitekturApkEnum.universal] = int.parse(
          _buildUniversalController.text,
        );
      }
      if (_build32Controller.text.isNotEmpty) {
        nomorBuild[ArsitekturApkEnum.bit_32] = int.parse(
          _build32Controller.text,
        );
      }
      if (_build64Controller.text.isNotEmpty) {
        nomorBuild[ArsitekturApkEnum.bit_64] = int.parse(
          _build64Controller.text,
        );
      }

      final tautanUnduhan = <ArsitekturApkEnum, String>{};
      if (_tautanUniversalController.text.isNotEmpty) {
        tautanUnduhan[ArsitekturApkEnum.universal] =
            _tautanUniversalController.text;
      }
      if (_tautan32Controller.text.isNotEmpty) {
        tautanUnduhan[ArsitekturApkEnum.bit_32] = _tautan32Controller.text;
      }
      if (_tautan64Controller.text.isNotEmpty) {
        tautanUnduhan[ArsitekturApkEnum.bit_64] = _tautan64Controller.text;
      }

      final dataToSave = VersiApkUserModel(
        id: widget.versiApkUser?.id ?? const Uuid().v4(),
        catatanRilis: _catatanRilisController.text,
        versiTerbaru: _versiTerbaruController.text,
        youtubeTutorial: _youtubeTutorialController.text,
        wajibUpdate: _wajibUpdate,
        nomorBuildTerbaru: nomorBuild,
        tautanUnduhan: tautanUnduhan,
      );

      try {
        if (_isEdit) {
          developer.log(
            '🆙 Menjalankan perintah update data...',
            name: fileName,
          );
          await widget.operasi.perbaruiVersiApkUser(dataToSave);
        } else {
          developer.log(
            '🆕 Menjalankan perintah tambah data baru...',
            name: fileName,
          );
          await widget.operasi.tambahVersiApkUser(dataToSave);
        }

        developer.log(
          '✅ Proses penyimpanan berhasil diselesaikan',
          name: fileName,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(dataToSave);
      } catch (e, s) {
        developer.log(
          '❌ Terjadi kesalahan saat menyimpan data',
          name: fileName,
          error: e,
          stackTrace: s,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Gagal menyimpan data: $e'),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ Diperbaiki: dari app_bar ke appBar
        title: Text(_isEdit ? 'Edit Versi APK' : 'Tambah Versi APK'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _versiTerbaruController,
                    decoration: const InputDecoration(
                      labelText: 'Versi Terbaru (Contoh: 1.0.0)',
                      prefixIcon: Icon(
                        Icons.info_outline,
                      ), // ✅ Diperbaiki: Ikon yang valid
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Nomor Build'),
                  _buildNumberField(
                    _buildUniversalController,
                    'Build Universal',
                  ),
                  _buildNumberField(_build32Controller, 'Build 32-bit'),
                  _buildNumberField(_build64Controller, 'Build 64-bit'),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tautan Unduhan'),
                  _buildUrlField(
                    _tautanUniversalController,
                    'Tautan Universal',
                  ),
                  _buildUrlField(_tautan32Controller, 'Tautan 32-bit'),
                  _buildUrlField(_tautan64Controller, 'Tautan 64-bit'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _catatanRilisController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Rilis',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _youtubeTutorialController,
                    decoration: const InputDecoration(
                      labelText: 'URL Tutorial YouTube',
                      prefixIcon: Icon(
                        Icons.play_circle_fill,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Wajib Update'),
                    value: _wajibUpdate,
                    onChanged: (bool value) {
                      developer.log(
                        '🔔 Switch Wajib Update diubah ke: $value',
                        name: fileName,
                      );
                      setState(() => _wajibUpdate = value);
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _simpanForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('SIMPAN DATA RILIS'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(
                128,
              ), // ✅ Diperbaiki: withAlpha menggantikan opacity manual
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Menyimpan...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildUrlField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.link),
        ),
        keyboardType: TextInputType.url,
      ),
    );
  }
}
