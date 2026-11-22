// path: lib/halaman/form/form_versi_apk_user.dart

import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:admin_wifi/fitur/versi_apk_user/enum/arsitektur_apk_enum.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:admin_wifi/fitur/versi_apk_user/notifier/versi_apk_user_notifier.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:uuid/uuid.dart';

class FormVersiApkUser extends ConsumerStatefulWidget {
  final VersiApkUserModel? versiApkUser;

  const FormVersiApkUser({super.key, this.versiApkUser});

  @override
  ConsumerState<FormVersiApkUser> createState() => _FormVersiApkUserState();
}

class _FormVersiApkUserState extends ConsumerState<FormVersiApkUser> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEdit => widget.versiApkUser != null;

  final TextEditingController _catatanRilisController = TextEditingController();
  final TextEditingController _versiTerbaruController = TextEditingController();
  final TextEditingController _youtubeTutorialController =
      TextEditingController();
  bool _wajibUpdate = false;

  final TextEditingController _buildUniversalController =
      TextEditingController();
  final TextEditingController _build32Controller = TextEditingController();
  final TextEditingController _build64Controller = TextEditingController();
  final TextEditingController _tautanUniversalController =
      TextEditingController();
  final TextEditingController _tautan32Controller = TextEditingController();
  final TextEditingController _tautan64Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    L.i(
      'Menginisialisasi FormVersiApkUser (Mode: ${_isEdit ? 'Edit' : 'Tambah'})',
    );

    if (_isEdit) {
      _populateControllers(widget.versiApkUser!);
    } else {
      _muatDataVersiTerakhir();
    }
  }

  void _muatDataVersiTerakhir() async {
    L.i('Memuat data rilis terakhir untuk otomatisasi input.');
    try {
      final versiTerakhir = await ref
          .read(versiApkUserProvider.notifier)
          .ambilVersiApkTerbaru();
      if (versiTerakhir != null && mounted) {
        _versiTerbaruController.text = versiTerakhir.versiTerbaru;
        final buildBerikutnya =
            (versiTerakhir.nomorBuildTerbaru[ArsitekturApkEnum.universal] ??
                0) +
            1;
        _buildUniversalController.text = buildBerikutnya.toString();

        L.i(
          'Data rilis sebelumnya ditemukan. Menyarankan build: $buildBerikutnya',
        );
      }
    } catch (e, s) {
      L.e('Gagal memuat data versi terakhir Error: $e $s');
    }
  }

  void _populateControllers(VersiApkUserModel data) {
    L.i('Memasukkan data model ke dalam form controller (ID: ${data.id})');
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
    L.i('Menghapus semua controller (dispose)');
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
    if (_formKey.currentState?.validate() ?? false) {
      L.i('Menampilkan dialog konfirmasi kepada pengguna');

      final konfirmasi = await showOkCancelAlertDialog(
        context: context,
        title: 'Konfirmasi Simpan',
        message: 'Apakah data versi aplikasi yang Anda masukkan sudah benar?',
        okLabel: 'Ya, Simpan',
        cancelLabel: 'Periksa Kembali',
      );

      if (konfirmasi != OkCancelResult.ok) {
        L.i('Pengguna membatalkan proses penyimpanan');
        return;
      }

      unawaited(
        EasyLoading.show(
          status: 'Menyimpan...',
          maskType: EasyLoadingMaskType.black,
        ).catchError((Object e, StackTrace s) {
          L.e('Gagal menampilkan loading: $e $s');
        }),
      );
      L.i('Sedang memproses penyimpanan ke database...');

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

      L.i(
        'Model Versi APK yang akan disimpan: versi=${dataToSave.versiTerbaru}, wajibUpdate=${dataToSave.wajibUpdate}',
      );

      try {
        if (_isEdit) {
          L.i('Menjalankan perintah update data...');
          await ref
              .read(versiApkUserProvider.notifier)
              .perbaruiVersiApkUser(dataToSave);
        } else {
          L.i('Menjalankan perintah tambah data baru...');
          await ref
              .read(versiApkUserProvider.notifier)
              .tambahVersiApkUser(dataToSave);
        }

        L.i('Proses penyimpanan berhasil diselesaikan');

        if (!mounted) return;
        AppToast.sukses(context, 'Data berhasil disimpan!');
        Nav.pop(context);
      } catch (e, s) {
        L.e('Terjadi kesalahan saat menyimpan data Error: $e $s');
        if (!mounted) return;
        AppToast.gagal(context, 'Gagal menyimpan data: $e');
      } finally {
        unawaited(
          EasyLoading.dismiss().catchError((Object e, StackTrace s) {
            L.e('Gagal menutup loading: $e $s');
          }),
        );
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
                  InputTeks(
                    controller: _versiTerbaruController,
                    label: 'Versi Terbaru (Contoh: 1.0.0)',
                    prefixIcon: Icons.info_outline,
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
                  InputTeks(
                    controller: _catatanRilisController,
                    label: 'Catatan Rilis',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  InputTeks(
                    controller: _youtubeTutorialController,
                    label: 'URL Tutorial YouTube',
                    prefixIcon: Icons.play_circle_fill,
                  ),
                  SwitchListTile(
                    title: const Text('Wajib Update'),
                    value: _wajibUpdate,
                    onChanged: (bool value) {
                      L.i('Switch Wajib Update diubah ke: $value');
                      setState(() => _wajibUpdate = value);
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _simpanForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('SIMPAN DATA RILIS'),
                  ),
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
      child: InputAngka(controller: controller, label: label),
    );
  }

  Widget _buildUrlField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InputTeks(
        controller: controller,
        label: label,
        prefixIcon: Icons.link,
      ),
    );
  }
}
