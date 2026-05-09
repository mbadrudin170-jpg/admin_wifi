// path: lib/halaman/form/form_pengaturan.dart

import 'dart:developer' as developer; // Tambahkan import log
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';

// Halaman formulir untuk mengedit dan menyimpan pengaturan aplikasi.
class FormPengaturan extends StatefulWidget {
  final PengaturanModel pengaturan;

  const FormPengaturan({super.key, required this.pengaturan});

  @override
  State<FormPengaturan> createState() => _FormPengaturanState();
}

class _FormPengaturanState extends State<FormPengaturan> {
  final _formKey = GlobalKey<FormState>();
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();

  late TextEditingController _intervalController;
  late TextEditingController _hapusArsipController;
  late TextEditingController _infoController;
  late bool _modePemeliharaan;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    developer.log(
      '📝 [FormPengaturan] -> [initState] -> Inisialisasi formulir dengan data awal',
      name: 'FormPengaturan.Lifecycle',
    );
    _intervalController = TextEditingController(
      text: widget.pengaturan.intervalSinkronisasiOtomatis.toString(),
    );
    _hapusArsipController = TextEditingController(
      text: widget.pengaturan.hapusOtomatisDataArsip.toString(),
    );
    _infoController = TextEditingController(
      text: widget.pengaturan.infoPemeliharaan,
    );
    _modePemeliharaan = widget.pengaturan.modePemeliharaan;
  }

  @override
  void dispose() {
    developer.log(
      '🗑️ [FormPengaturan] -> [dispose] -> Membersihkan controller formulir',
      name: 'FormPengaturan.Lifecycle',
    );
    _intervalController.dispose();
    _hapusArsipController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  void _simpanForm() async {
    developer.log(
      '🔘 [FormPengaturan] -> [_simpanForm] -> Mencoba memvalidasi dan menyimpan data',
      name: 'FormPengaturan.Action',
    );

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final interval = int.tryParse(_intervalController.text) ?? 0;
      final hapusArsip = int.tryParse(_hapusArsipController.text) ?? 0;

      final pengaturanBaru = PengaturanModel(
        intervalSinkronisasiOtomatis: interval,
        hapusOtomatisDataArsip: hapusArsip,
        modePemeliharaan: _modePemeliharaan,
        infoPemeliharaan: _infoController.text,
      );

      try {
        developer.log(
          '💾 [FormPengaturan] -> [_simpanForm] -> Mengirim data baru ke database',
          name: 'FormPengaturan.Database',
        );
        await _pengaturanOperasi.simpanAtauPerbaruiPengaturan(pengaturanBaru);
        
        if (mounted) {
          developer.log(
            '✅ [FormPengaturan] -> [_simpanForm] -> Pengaturan berhasil diperbarui',
            name: 'FormPengaturan.Success',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengaturan berhasil disimpan.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Kembali dengan sinyal sukses
        }
      } catch (e) {
        developer.log(
          '❌ [FormPengaturan] -> [_simpanForm] -> Error saat menyimpan: $e',
          name: 'FormPengaturan.Error',
          error: e,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan pengaturan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      developer.log(
        '⚠️ [FormPengaturan] -> [_simpanForm] -> Validasi gagal, periksa inputan user',
        name: 'FormPengaturan.Validation',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengaturan')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextFormField(
                    controller: _intervalController,
                    label: 'Interval Sinkronisasi (Jam)',
                    icon: Icons.sync_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _hapusArsipController,
                    label: 'Hapus Arsip Setelah (Hari)',
                    icon: Icons.auto_delete_outlined,
                  ),
                  const Divider(height: 32, thickness: 1),
                  SwitchListTile(
                    title: const Text(
                      'Mode Pemeliharaan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: _modePemeliharaan,
                    onChanged: (bool value) {
                      developer.log(
                        '🔄 [FormPengaturan] -> [onChanged Mode] -> Mengubah status pemeliharaan ke: $value',
                        name: 'FormPengaturan.UI',
                      );
                      setState(() {
                        _modePemeliharaan = value;
                      });
                    },
                    secondary: const Icon(Icons.construction_outlined),
                  ),
                  if (_modePemeliharaan)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextFormField(
                        controller: _infoController,
                        decoration: const InputDecoration(
                          labelText: 'Informasi Pemeliharaan',
                          hintText:
                              'Contoh: Aplikasi sedang dalam perbaikan hingga jam 3 sore.',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        maxLines: 3,
                      ),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _simpanForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
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
              color: const Color.fromRGBO(0, 0, 0, 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field ini tidak boleh kosong.';
        }
        if (int.tryParse(value) == null) {
          return 'Harap masukkan angka yang valid.';
        }
        if (int.parse(value) <= 0) {
          return 'Nilai harus lebih besar dari 0';
        }
        return null;
      },
    );
  }
}