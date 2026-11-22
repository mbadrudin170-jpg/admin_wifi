// path: lib/fitur/dompet/screens/form_dompet.dart
// Halaman ini menyediakan formulir untuk menambah atau mengedit dompet.
// diubah: Menghapus input saldo manual untuk konsistensi arsitektur baru.

import 'dart:async';

import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

class FormDompet extends ConsumerStatefulWidget {
  final DompetModel? dompet;

  const FormDompet({super.key, this.dompet});

  @override
  ConsumerState<FormDompet> createState() => _FormDompetState();
}

class _FormDompetState extends ConsumerState<FormDompet> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();

  final _namaFocusNode = FocusNode();

  bool get _isEditMode => widget.dompet != null;

  @override
  void initState() {
    super.initState();
    final isEditMode = widget.dompet != null;
    L.i(
      'Membuat state untuk FormDompet. '
      'Mode: ${isEditMode ? "EDIT (ID: ${widget.dompet!.id}, Nama: ${widget.dompet!.namaDompet}, Saldo: ${widget.dompet!.saldo})" : "TAMBAH BARU"}',
    );

    if (_isEditMode) {
      _namaController.text = widget.dompet!.namaDompet;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _namaFocusNode.dispose();
    super.dispose();
  }

  void _simpanForm() async {
    _namaFocusNode.unfocus();

    if (!_formKey.currentState!.validate()) {
      L.w('Validasi form GAGAL: Nama dompet kosong.');
      return;
    }

    final konfirmasi = await showOkCancelAlertDialog(
      context: context,
      title: _isEditMode ? 'Perbarui Dompet' : 'Tambah Dompet Baru',
      message: _isEditMode
          ? 'Apakah Anda yakin ingin memperbarui nama dompet ini?'
          : 'Apakah Anda yakin ingin menambah dompet baru?',
      okLabel: 'Simpan',
      cancelLabel: 'Batal',
    );

    if (konfirmasi != OkCancelResult.ok) return;

    L.i('Nama dompet yang akan disimpan: "${_namaController.text}"');

    unawaited(
      EasyLoading.show(
        status: 'Menyimpan...',
        maskType: EasyLoadingMaskType.black,
      ).catchError((Object e, StackTrace s) {
        L.e('Gagal menampilkan loading: $e $s');
      }),
    );

    try {
      if (_isEditMode) {
        final updatedDompet = DompetModel(
          id: widget.dompet!.id,
          namaDompet: _namaController.text,
          saldo: widget.dompet!.saldo,
          diperbarui: DateTime.now(),
        );

        await ref.read(dompetProvider.notifier).ubah(updatedDompet);

        if (!mounted) return;

        Nav.pop(context);
        AppToast.sukses(context, 'Nama dompet berhasil diperbarui!');
      } else {
        final newId = const Uuid().v4();

        final nuevoDompet = DompetModel(
          id: newId,
          namaDompet: _namaController.text,
          saldo: 0.0,
          diperbarui: DateTime.now(),
        );

        await ref.read(dompetProvider.notifier).tambah(nuevoDompet);

        if (!mounted) return;

        Nav.pop(context);
        AppToast.sukses(context, 'Dompet baru berhasil ditambahkan!');
      }
    } catch (e, s) {
      L.e('Gagal menyimpan dompet: $e $s');

      if (!mounted) return;

      AppToast.gagal(context, 'Gagal menyimpan dompet: $e');
    } finally {
      unawaited(
        EasyLoading.dismiss().catchError((Object e, StackTrace s) {
          L.e('Gagal menutup loading: $e $s');
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Nama Dompet' : 'Tambah Dompet Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Nav.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 24,
            children: [
              InputTeks(
                controller: _namaController,
                focusNode: _namaFocusNode,
                label: 'Nama Dompet',
                prefixIcon: Icons.account_balance_wallet,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _simpanForm(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama dompet tidak boleh kosong';
                  }
                  return null;
                },
              ),
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
