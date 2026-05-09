// path: lib/halaman/form/form_dompet.dart
// Halaman ini menyediakan formulir untuk menambah atau mengedit dompet.
// diubah: Menghapus input saldo manual untuk konsistensi arsitektur baru.

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class FormDompet extends StatefulWidget {
  final DompetModel? dompet;

  const FormDompet({super.key, this.dompet});

  @override
  State<FormDompet> createState() => _FormDompetState();
}

class _FormDompetState extends State<FormDompet> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final DompetOperasi _dompetOperasi = DompetOperasi();

  late FocusNode _namaFocusNode;

  bool get _isEditMode => widget.dompet != null;

  @override
  void initState() {
    super.initState();
    developer.log('[FormDompet] 🚀 : Inisialisasi FormDompet');
    _namaFocusNode = FocusNode();

    if (_isEditMode) {
      developer.log(
        '[FormDompet] 📝 : Mode Edit Dompet: ${widget.dompet!.namaDompet}',
      );
      _namaController.text = widget.dompet!.namaDompet;
    } else {
      developer.log('[FormDompet] ✨ : Mode Tambah Dompet Baru');
    }
  }

  @override
  void dispose() {
    developer.log(
      '[FormDompet] 🧹 : Melakukan dispose pada controller dan focusNode',
    );
    _namaController.dispose();
    _namaFocusNode.dispose();
    super.dispose();
  }

  void _simpanForm() async {
    developer.log('[FormDompet] 💾 : Proses simpan dimulai');
    _namaFocusNode.unfocus();

    if (_formKey.currentState!.validate()) {
      try {
        if (_isEditMode) {
          developer.log(
            '[FormDompet] 🔄 : Memperbarui nama dompet ID: ${widget.dompet!.id}',
          );
          final updatedDompet = DompetModel(
            id: widget.dompet!.id,
            namaDompet: _namaController.text,
            saldo: widget.dompet!.saldo, // Saldo tetap mengikuti data lama
            diperbarui: DateTime.now(),
          );
          await _dompetOperasi.updateDompet(updatedDompet);

          developer.log('[FormDompet] ✅ : Nama dompet berhasil diperbarui');

          if (!mounted) return;
          Navigator.pop(context, true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nama dompet berhasil diperbarui!'),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          developer.log(
            '[FormDompet] 🆕 : Membuat dompet baru dengan saldo awal 0',
          );
          final nuevoDompet = DompetModel(
            id: const Uuid().v4(),
            namaDompet: _namaController.text,
            saldo: 0.0, // Arsitektur baru: saldo awal selalu 0
            diperbarui: DateTime.now(),
          );
          await _dompetOperasi.createDompet(nuevoDompet);

          developer.log('[FormDompet] ✅ : Dompet baru berhasil disimpan');

          if (!mounted) return;
          Navigator.pop(context, true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dompet baru berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e, s) {
        developer.log(
          '[FormDompet] ❌ : Gagal menyimpan dompet',
          name: 'form_dompet.save',
          error: e,
          stackTrace: s,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan dompet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      developer.log('[FormDompet] ⚠️ : Validasi form gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Nama Dompet' : 'Tambah Dompet Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                focusNode: _namaFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Nama Dompet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _simpanForm(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama dompet tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpanForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
