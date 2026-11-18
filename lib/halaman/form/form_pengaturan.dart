// path: lib/halaman/form/form_pengaturan.dart

import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/fitur/pengaturan/model/pengaturan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_global_saya/src/utils/l.dart';

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
    L.i('Menginisialisasi Form Edit Pengaturan');
    L.i(
      'Data awal - Interval: ${widget.pengaturan.intervalSinkronisasiOtomatis} jam, Hapus arsip: ${widget.pengaturan.hapusOtomatisDataArsip} hari, Mode pemeliharaan: ${widget.pengaturan.modePemeliharaan ? "Aktif" : "Nonaktif"}, Info: ${widget.pengaturan.infoPemeliharaan.isNotEmpty ? widget.pengaturan.infoPemeliharaan : "(kosong)"}',
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

    L.i('Controller berhasil diinisialisasi dengan data awal');
  }

  @override
  void dispose() {
    L.i('Membersihkan controller Form Edit Pengaturan');
    _intervalController.dispose();
    _hapusArsipController.dispose();
    _infoController.dispose();
    super.dispose();
    L.i('Controller berhasil dibersihkan, Form Edit Pengaturan di-dispose');
  }

  void _simpanForm() async {
    L.i('Memvalidasi dan menyimpan data pengaturan');

    if (_formKey.currentState!.validate()) {
      L.i('Validasi form berhasil');
      setState(() => _isLoading = true);
      L.i('Loading state diaktifkan');

      final interval = int.tryParse(_intervalController.text) ?? 0;
      final hapusArsip = int.tryParse(_hapusArsipController.text) ?? 0;

      L.i(
        'Nilai dari form - Interval: $interval jam, Hapus arsip: $hapusArsip hari, Mode pemeliharaan: ${_modePemeliharaan ? "Aktif" : "Nonaktif"}, Info: ${_infoController.text.isNotEmpty ? _infoController.text : "(kosong)"}',
      );

      final pengaturanBaru = PengaturanModel(
        intervalSinkronisasiOtomatis: interval,
        hapusOtomatisDataArsip: hapusArsip,
        modePemeliharaan: _modePemeliharaan,
        infoPemeliharaan: _infoController.text,
      );

      try {
        L.i(
          'Menyimpan pengaturan baru ke database - Interval: $interval, Hapus Arsip: $hapusArsip, Mode: $_modePemeliharaan',
        );
        await _pengaturanOperasi.simpanAtauPerbaruiPengaturan(pengaturanBaru);
        L.i('Pengaturan berhasil disimpan ke database');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengaturan berhasil disimpan.'),
              backgroundColor: Colors.green,
            ),
          );
          L.i(
            'SnackBar sukses ditampilkan, navigasi kembali dengan result true',
          );
          Navigator.pop(context, true);
        } else {
          L.i(
            'Widget tidak mounted setelah simpan berhasil, tidak dapat navigasi',
          );
        }
      } catch (e, stackTrace) {
        L.e('Gagal menyimpan pengaturan ke database Error: $e $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan pengaturan: $e'),
              backgroundColor: Colors.red,
            ),
          );
          L.i('SnackBar error ditampilkan');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
          L.i('Loading state dinonaktifkan');
        }
      }
    } else {
      L.i('Validasi form gagal, periksa inputan user');
      // Log detail error validasi
      final intervalValue = _intervalController.text;
      final hapusArsipValue = _hapusArsipController.text;
      L.i(
        'Input tidak valid - Interval: "$intervalValue", Hapus Arsip: "$hapusArsipValue"',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI Form Edit Pengaturan');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            L.i('Kembali ke halaman Pengaturan tanpa menyimpan');
            Navigator.of(context).pop();
          },
        ),
      ),
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
                    subtitle: Text(
                      _modePemeliharaan
                          ? 'Aplikasi dalam mode pemeliharaan'
                          : 'Aplikasi berjalan normal',
                    ),
                    value: _modePemeliharaan,
                    onChanged: (bool value) {
                      L.i(
                        'Mode pemeliharaan diubah dari ${_modePemeliharaan ? "Aktif" : "Nonaktif"} menjadi ${value ? "Aktif" : "Nonaktif"}',
                      );
                      setState(() {
                        _modePemeliharaan = value;
                      });
                    },
                    secondary: Icon(
                      _modePemeliharaan
                          ? Icons.construction
                          : Icons.check_circle_outline,
                      color: _modePemeliharaan ? Colors.orange : Colors.green,
                    ),
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
                        onChanged: (value) {
                          L.i(
                            'Info pemeliharaan diubah: ${value.length > 50 ? value.substring(0, 50) : value}',
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _simpanForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
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
    L.i('Membangun TextFormField untuk: $label');
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        L.i('Input $label berubah: $value');
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          L.i('Validasi $label gagal: field kosong');
          return 'Field ini tidak boleh kosong.';
        }
        if (int.tryParse(value) == null) {
          L.i('Validasi $label gagal: bukan angka valid ("$value")');
          return 'Harap masukkan angka yang valid.';
        }
        if (int.parse(value) <= 0) {
          L.i('Validasi $label gagal: nilai <= 0 ($value)');
          return 'Nilai harus lebih besar dari 0';
        }
        L.i('Validasi $label berhasil: $value');
        return null;
      },
    );
  }
}
