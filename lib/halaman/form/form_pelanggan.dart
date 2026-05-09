// path: lib/halaman/form/form_pelanggan.dart

import 'dart:developer' as developer; // Import logging
import 'package:flutter/material.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
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

  final _namaFocusNode = FocusNode();
  final _teleponFocusNode = FocusNode();
  final _alamatFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _macAddressFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isSaving = false; // Status loading saat simpan

  @override
  void initState() {
    super.initState();
    developer.log(
      '🎬 [FormPelanggan] -> [initState] -> Membuka formulir (${widget.pelanggan != null ? 'Mode Edit' : 'Mode Tambah'})',
      name: 'FormPelanggan.Lifecycle',
    );
    if (widget.pelanggan != null) {
      _namaController.text = widget.pelanggan!.nama;
      _teleponController.text = widget.pelanggan!.telepon;
      _alamatController.text = widget.pelanggan!.alamat;
      _passwordController.text = widget.pelanggan!.password;
      _macAddressController.text = widget.pelanggan!.macAddress;
    }
  }

  @override
  void dispose() {
    developer.log('🗑️ [FormPelanggan] -> [dispose] -> Menutup halaman', name: 'FormPelanggan.Lifecycle');
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _macAddressController.dispose();
    _namaFocusNode.dispose();
    _teleponFocusNode.dispose();
    _alamatFocusNode.dispose();
    _passwordFocusNode.dispose();
    _macAddressFocusNode.dispose();
    super.dispose();
  }

  void _simpanForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final newPelanggan = PelangganModel(
        id: widget.pelanggan?.id ?? const Uuid().v4(),
        nama: _namaController.text.trim(),
        telepon: _teleponController.text.trim(),
        alamat: _alamatController.text.trim(),
        password: _passwordController.text,
        macAddress: _macAddressController.text.trim().toUpperCase(),
        diperbarui: DateTime.now(),
      );

      try {
        if (widget.pelanggan == null) {
          developer.log('💾 [FormPelanggan] -> [_simpanForm] -> Membuat pelanggan baru: ${newPelanggan.nama}', name: 'FormPelanggan.Database');
          await PelangganOperasi().createPelanggan(newPelanggan);
        } else {
          developer.log('💾 [FormPelanggan] -> [_simpanForm] -> Memperbarui data ID: ${newPelanggan.id}', name: 'FormPelanggan.Database');
          await PelangganOperasi().updatePelanggan(newPelanggan);
        }

        if (mounted) {
          developer.log('✅ [FormPelanggan] -> [_simpanForm] -> Berhasil disimpan', name: 'FormPelanggan.Success');
          Navigator.pop(context, true);
        }
      } catch (e) {
        developer.log('❌ [FormPelanggan] -> [_simpanForm] -> Gagal menyimpan: $e', name: 'FormPelanggan.Error', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else {
      developer.log('⚠️ [FormPelanggan] -> [_simpanForm] -> Validasi form gagal', name: 'FormPelanggan.Validation');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pelanggan == null ? 'Tambah Pelanggan' : 'Edit Pelanggan',
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        leading: BackButton(
          onPressed: () {
            developer.log('⬅️ [FormPelanggan] -> [BackButton] -> Kembali tanpa menyimpan', name: 'FormPelanggan.UI');
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  label: 'Nama',
                  icon: Icons.person,
                  nextFocus: _teleponFocusNode,
                  validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
                ),
                _buildTextField(
                  controller: _teleponController,
                  focusNode: _teleponFocusNode,
                  label: 'Telepon',
                  icon: Icons.phone,
                  keyboard: TextInputType.phone,
                  nextFocus: _alamatFocusNode,
                  validator: (v) => (v == null || v.isEmpty) ? 'Telepon tidak boleh kosong' : null,
                ),
                _buildTextField(
                  controller: _alamatController,
                  focusNode: _alamatFocusNode,
                  label: 'Alamat',
                  icon: Icons.home,
                  nextFocus: _passwordFocusNode,
                  validator: (v) => (v == null || v.isEmpty) ? 'Alamat tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_macAddressFocusNode),
                  validator: (v) => (v == null || v.isEmpty) ? 'Password tidak boleh kosong' : null,
                ),
                _buildTextField(
                  controller: _macAddressController,
                  focusNode: _macAddressFocusNode,
                  label: 'MAC Address',
                  icon: Icons.router,
                  hint: 'XX:XX:XX:XX:XX:XX',
                  action: TextInputAction.done,
                  onSubmitted: (_) => _macAddressFocusNode.unfocus(),
                  validator: (v) => (v == null || v.isEmpty) ? 'MAC Address tidak boleh kosong' : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _simpanForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SIMPAN DATA', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget untuk merapikan kode TextFormField
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