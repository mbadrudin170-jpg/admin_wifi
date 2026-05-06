// path: lib/halaman/form/form_versi_apk_user.dart

import 'dart:developer' as developer;
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
    setState(() => _isLoading = true);
    try {
      final versiTerakhir = await widget.operasi.ambilVersiApkTerbaru();
      if (versiTerakhir != null && mounted) {
        _versiTerbaruController.text = versiTerakhir.versiTerbaru;
        final buildBerikutnya =
            (versiTerakhir.nomorBuildTerbaru['universal'] ?? 0) + 1;
        _buildUniversalController.text = buildBerikutnya.toString();
      }
    } catch (e, s) {
      developer.log('Gagal memuat data versi terakhir',
          name: 'FormVersiApkUser', error: e, stackTrace: s);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _populateControllers(VersiApkUserModel data) {
    _catatanRilisController.text = data.catatanRilis;
    _versiTerbaruController.text = data.versiTerbaru;
    _youtubeTutorialController.text = data.youtubeTutorial;
    _wajibUpdate = data.wajibUpdate;

    _buildUniversalController.text =
        data.nomorBuildTerbaru['universal']?.toString() ?? '';
    _build32Controller.text = data.nomorBuildTerbaru['bit_32']?.toString() ?? '';
    _build64Controller.text = data.nomorBuildTerbaru['bit_64']?.toString() ?? '';

    _tautanUniversalController.text = data.tautanUnduhan['universal'] ?? '';
    _tautan32Controller.text = data.tautanUnduhan['bit_32'] ?? '';
    _tautan64Controller.text = data.tautanUnduhan['bit_64'] ?? '';
  }

  @override
  void dispose() {
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

  // diubah: Fungsi simpan sekarang menampilkan dialog konfirmasi
  void _simpanForm() async {
    if (_formKey.currentState!.validate()) {
      final konfirmasi = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah semua data yang Anda masukkan sudah benar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya'),
            ),
          ],
        ),
      );

      if (konfirmasi != true) return; // Jika pengguna menekan 'Tidak' atau menutup dialog

      setState(() => _isLoading = true);

      final nomorBuild = <String, int>{};
      if (_buildUniversalController.text.isNotEmpty) {
        nomorBuild['universal'] = int.parse(_buildUniversalController.text);
      }
      if (_build32Controller.text.isNotEmpty) {
        nomorBuild['bit_32'] = int.parse(_build32Controller.text);
      }
      if (_build64Controller.text.isNotEmpty) {
        nomorBuild['bit_64'] = int.parse(_build64Controller.text);
      }

      final tautanUnduhan = <String, String>{};
      if (_tautanUniversalController.text.isNotEmpty) {
        tautanUnduhan['universal'] = _tautanUniversalController.text;
      }
      if (_tautan32Controller.text.isNotEmpty) {
        tautanUnduhan['bit_32'] = _tautan32Controller.text;
      }
      if (_tautan64Controller.text.isNotEmpty) {
        tautanUnduhan['bit_64'] = _tautan64Controller.text;
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
          await widget.operasi.perbaruiVersiApkUser(dataToSave);
        } else {
          await widget.operasi.tambahVersiApkUser(dataToSave);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Data berhasil disimpan!'),
            backgroundColor: Colors.green));
        Navigator.of(context).pop(dataToSave);
      } catch (e, s) {
        developer.log('Gagal menyimpan versi APK',
            name: 'FormVersiApkUser', error: e, stackTrace: s);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text('Gagal menyimpan data: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    decoration: const InputDecoration(labelText: 'Versi Terbaru'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  Text('Nomor Build', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _buildUniversalController,
                    decoration:
                        const InputDecoration(labelText: 'Build Universal'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _build32Controller,
                    decoration: const InputDecoration(labelText: 'Build 32-bit'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _build64Controller,
                    decoration: const InputDecoration(labelText: 'Build 64-bit'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  Text('Tautan Unduhan',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tautanUniversalController,
                    decoration:
                        const InputDecoration(labelText: 'Tautan Universal'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tautan32Controller,
                    decoration: const InputDecoration(labelText: 'Tautan 32-bit'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tautan64Controller,
                    decoration: const InputDecoration(labelText: 'Tautan 64-bit'),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _catatanRilisController,
                    decoration: const InputDecoration(labelText: 'Catatan Rilis'),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _youtubeTutorialController,
                    decoration:
                        const InputDecoration(labelText: 'URL Tutorial YouTube'),
                  ),
                  SwitchListTile(
                    title: const Text('Wajib Update'),
                    value: _wajibUpdate,
                    onChanged: (bool value) =>
                        setState(() => _wajibUpdate = value),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _simpanForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Simpan'),

                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              // diubah: Menggunakan withAlpha untuk mengatur opacity
              color: Colors.black.withAlpha(128),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
