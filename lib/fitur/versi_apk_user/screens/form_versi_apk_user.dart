// path: lib/halaman/form/form_versi_apk_user.dart

import 'package:admin_wifi/fitur/versi_apk_user/notifier/versi_apk_user_notifier.dart';
import 'package:admin_wifi/enum/arsitektur_apk_enum.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:uuid/uuid.dart';

class FormVersiApkUser extends StatefulWidget {
  final VersiApkUserModel? versiApkUser;
  final dynamic operasi;

  FormVersiApkUser({super.key, this.versiApkUser, dynamic operasi})
    : operasi = operasi ?? versiApkUserNotifierGlobal;

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
    L.i(
      'Menginisialisasi FormVersiApkUser (Mode: ${_isEdit ? 'Edit' : 'Tambah'})',
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
    L.i('Memuat data rilis terakhir untuk otomatisasi input.');
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

        L.i(
          'Data rilis sebelumnya ditemukan. Menyarankan build: $buildBerikutnya',
        );
      }
    } catch (e, s) {
      L.e('Gagal memuat data versi terakhir Error: $e $s');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    if (_formKey.currentState!.validate()) {
      L.i('Menampilkan dialog konfirmasi kepada pengguna');

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
              onPressed: () => Nav.pop(context, false),
              child: const Text('Periksa Kembali'),
            ),
            ElevatedButton(
              onPressed: () => Nav.pop(context, true),
              child: const Text('Ya, Simpan'),
            ),
          ],
        ),
      );

      if (konfirmasi != true) {
        L.i('Pengguna membatalkan proses penyimpanan');
        return;
      }

      setState(() => _isLoading = true);
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
          await widget.operasi.perbaruiVersiApkUser(dataToSave);
        } else {
          L.i('Menjalankan perintah tambah data baru...');
          await widget.operasi.tambahVersiApkUser(dataToSave);
        }

        L.i('Proses penyimpanan berhasil diselesaikan');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Nav.pop(context, dataToSave);
      } catch (e, s) {
        L.e('Terjadi kesalahan saat menyimpan data Error: $e $s');
        if (!mounted) return;
        AppToast.gagal(context, 'Gagal menyimpan data: $e');
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
              color: Colors.black.withAlpha(128),
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
