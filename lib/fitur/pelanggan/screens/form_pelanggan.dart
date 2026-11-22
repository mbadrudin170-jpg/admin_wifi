// path: lib/halaman/form/form_pelanggan.dart

import 'dart:async';

import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart' hide FormatTanggal;
import 'package:uuid/uuid.dart';

class FormPelanggan extends StatefulWidget {
  final PelangganModel? pelanggan;
  const FormPelanggan({super.key, this.pelanggan});

  @override
  State<FormPelanggan> createState() => _FormPelangganState();
}

class _FormPelangganState extends State<FormPelanggan> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _macAddressController = TextEditingController();
  final _poinAwalController = TextEditingController();

  final _namaFocusNode = FocusNode();
  final _teleponFocusNode = FocusNode();
  final _alamatFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _macAddressFocusNode = FocusNode();
  final _poinAwalFocusNode = FocusNode();

  bool get _isEditMode => widget.pelanggan != null;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    L.i(
      'Membuka FormPelanggan dalam mode: ${_isEditMode ? "Edit" : "Tambah"}.',
    );
    if (_isEditMode) {
      final pelanggan = widget.pelanggan;
      if (pelanggan == null) return;
      L.i(
        'Mode Edit: Mempopulasikan form dengan data pelanggan ID: ${pelanggan.id}',
      );
      _namaController.text = pelanggan.nama;
      _teleponController.text = pelanggan.telepon;
      _alamatController.text = pelanggan.alamat;
      _passwordController.text = pelanggan.password;
      _macAddressController.text = pelanggan.macAddress;
      _poinAwalController.text = pelanggan.poinAwal.toString();
    }
  }

  @override
  void dispose() {
    L.i(
      'Menjalankan dispose di FormPelanggan. Membersihkan semua controllers dan focus nodes.',
    );
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _macAddressController.dispose();
    _poinAwalController.dispose();
    _namaFocusNode.dispose();
    _teleponFocusNode.dispose();
    _alamatFocusNode.dispose();
    _passwordFocusNode.dispose();
    _macAddressFocusNode.dispose();
    _poinAwalFocusNode.dispose();
    super.dispose();
  }

  void _simpanForm() async {
    L.i('Tombol "Simpan" ditekan.');
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      L.i('Form valid. Memulai proses penyimpanan.');

      unawaited(
        EasyLoading.show(
          status: 'Menyimpan...',
          maskType: EasyLoadingMaskType.black,
        ).catchError((Object e, StackTrace s) {
          L.e('Gagal menampilkan loading: $e $s');
        }),
      );

      final pelangganEdit = widget.pelanggan;
      final newPelanggan = PelangganModel(
        id: _isEditMode && pelangganEdit != null
            ? pelangganEdit.id
            : const Uuid().v4(),
        nama: _namaController.text.trim(),
        telepon: _teleponController.text.trim(),
        alamat: _alamatController.text.trim(),
        password: _passwordController.text, // No trim for password
        macAddress: _macAddressController.text.trim().toUpperCase(),
        poinAwal: double.tryParse(_poinAwalController.text.trim()) ?? 0,
        diperbarui: DateTime.now(),
      );

      L.i(
        'Model Pelanggan yang akan disimpan — id: ${newPelanggan.id}, nama: ${newPelanggan.nama}',
      );

      try {
        if (!_isEditMode) {
          L.i(
            'Menjalankan operasi CREATE untuk pelanggan baru: ${newPelanggan.nama}',
          );
          await pelangganNotifierGlobal.tambah(newPelanggan);
        } else {
          L.i(
            'Menjalankan operasi UPDATE untuk pelanggan ID: ${newPelanggan.id}',
          );
          await pelangganNotifierGlobal.ubah(newPelanggan);
        }

        if (mounted) {
          L.i(
            'Penyimpanan berhasil. Menutup form dan kembali dengan hasil true.',
          );
          Nav.pop(context);
          AppToast.sukses(context, 'Data pelanggan berhasil disimpan.');
        }
      } catch (e, s) {
        L.e('Gagal menyimpan data pelanggan ke database. Error: $e $s');
        if (mounted) {
          AppToast.gagal(context, 'Gagal menyimpan data: $e');
        }
      } finally {
        unawaited(
          EasyLoading.dismiss().catchError((Object e, StackTrace s) {
            L.e('Gagal menutup loading: $e $s');
          }),
        );
      }
    } else {
      L.w('Form tidak valid. Proses penyimpanan dibatalkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI FormPelanggan.');
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  label: 'Nama Pelanggan',
                  icon: Icons.person_outline,
                  nextFocus: _teleponFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                _buildTextField(
                  controller: _teleponController,
                  focusNode: _teleponFocusNode,
                  label: 'Nomor Telepon (WhatsApp)',
                  icon: Icons.phone_android_outlined,
                  keyboard: TextInputType.phone,
                  nextFocus: _alamatFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Telepon tidak boleh kosong'
                      : null,
                ),
                _buildTextField(
                  controller: _alamatController,
                  focusNode: _alamatFocusNode,
                  label: 'Alamat Lengkap',
                  icon: Icons.home_outlined,
                  nextFocus: _passwordFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Alamat tidak boleh kosong'
                      : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        L.i('Visibilitas password diubah.');
                        setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_macAddressFocusNode),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Password tidak boleh kosong'
                      : null,
                ),
                _buildTextField(
                  controller: _macAddressController,
                  focusNode: _macAddressFocusNode,
                  label: 'MAC Address',
                  icon: Icons.router_outlined,
                  hint: 'XX:XX:XX:XX:XX:XX',
                  action: TextInputAction.done,
                  onSubmitted: (_) => _macAddressFocusNode.unfocus(),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'MAC Address tidak boleh kosong'
                      : null,
                ),
                _buildTextField(
                  controller: _poinAwalController,
                  focusNode: _poinAwalFocusNode,
                  label: 'Poin Awal',
                  icon: Icons.stars_outlined,
                  keyboard: TextInputType.number,
                  action: TextInputAction.done,
                  onSubmitted: (_) => _poinAwalFocusNode.unfocus(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (double.tryParse(v) == null) {
                      return 'Poin harus berupa angka';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: _simpanForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboard = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    FocusNode? nextFocus,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboard,
      textInputAction: action,
      onFieldSubmitted: (v) {
        if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
        if (onSubmitted != null) onSubmitted(v);
      },
      validator: validator,
    );
  }
}
