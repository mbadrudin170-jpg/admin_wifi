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
                InputTeks(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  label: 'Nama Pelanggan',
                  prefixIcon: Icons.person_outline,
                  nextFocusNode: _teleponFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                InputTeks(
                  controller: _teleponController,
                  focusNode: _teleponFocusNode,
                  label: 'Nomor Telepon (WhatsApp)',
                  prefixIcon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  nextFocusNode: _alamatFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Telepon tidak boleh kosong'
                      : null,
                ),
                InputTeks(
                  controller: _alamatController,
                  focusNode: _alamatFocusNode,
                  label: 'Alamat Lengkap',
                  prefixIcon: Icons.home_outlined,
                  nextFocusNode: _passwordFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Alamat tidak boleh kosong'
                      : null,
                ),
                InputTeks(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  obscureText: !_isPasswordVisible,
                  nextFocusNode: _macAddressFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Password tidak boleh kosong'
                      : null,
                ),
                InputTeks(
                  controller: _macAddressController,
                  focusNode: _macAddressFocusNode,
                  label: 'MAC Address',
                  prefixIcon: Icons.router_outlined,
                  hintText: 'XX:XX:XX:XX:XX:XX',
                  nextFocusNode: _poinAwalFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'MAC Address tidak boleh kosong'
                      : null,
                ),
                InputAngka(
                  controller: _poinAwalController,
                  focusNode: _poinAwalFocusNode,
                  label: 'Poin Awal',
                  prefixIcon: Icons.stars_outlined,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _poinAwalFocusNode.unfocus(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (InputAngka.parseAngkaRibuan(v) == 0 &&
                        v.replaceAll(RegExp(r'[^0-9]'), '') != '') {
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
}
