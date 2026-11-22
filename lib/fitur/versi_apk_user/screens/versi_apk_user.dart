// path: lib/halaman/lainnya/versi_apk_user.dart

import 'dart:async';

import 'package:admin_wifi/fitur/versi_apk_user/notifier/versi_apk_user_notifier.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:admin_wifi/fitur/versi_apk_user/enum/arsitektur_apk_enum.dart';
import 'package:admin_wifi/fitur/versi_apk_user/screens/detail_versi_apk_user.dart';
import 'package:admin_wifi/fitur/versi_apk_user/screens/form_versi_apk_user.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';

enum Urutan { buildZA, buildAZ, versiZA, versiAZ }

class VersiApkUserPage extends ConsumerStatefulWidget {
  final dynamic operasi;

  const VersiApkUserPage({super.key, this.operasi});

  @override
  ConsumerState<VersiApkUserPage> createState() => _VersiApkUserPageState();
}

class _VersiApkUserPageState extends ConsumerState<VersiApkUserPage> {
  Urutan _urutanSaatIni = Urutan.buildZA;

  @override
  void initState() {
    super.initState();
  }

  void _keDetail(VersiApkUserModel versiApk) {
    L.i(
      'Navigasi ke halaman Detail Versi APK - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}',
    );
    unawaited(
      Nav.to(context, DetailVersiApkUser(versiApk: versiApk))
          .then((_) {
            L.i('Kembali dari halaman Detail Versi APK ID: ${versiApk.id}');
          })
          .catchError((Object e, StackTrace s) {
            L.e('Navigasi gagal: $e $s');
          }),
    );
  }

  void _keFormEdit(VersiApkUserModel versiApk) {
    L.i(
      'Navigasi ke Form Edit Versi APK - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}',
    );
    unawaited(
      Nav.to<VersiApkUserModel>(
        context,
        FormVersiApkUser(
          versiApkUser: versiApk,
          operasi: ref.read(versiApkUserProvider.notifier),
        ),
      ).catchError((Object e, StackTrace s) {
        L.e('Navigasi gagal: $e $s');
        return null;
      }),
    );
  }

  void _keFormTambah() {
    L.i('Navigasi ke Form Tambah Versi APK');
    unawaited(
      Nav.to<VersiApkUserModel>(
        context,
        FormVersiApkUser(operasi: ref.read(versiApkUserProvider.notifier)),
      ).catchError((Object e, StackTrace s) {
        L.e('Navigasi gagal: $e $s');
        return null;
      }),
    );
  }

  Future<void> _tampilkanDialogUrutkan() async {
    L.i(
      'Menampilkan dialog pengurutan, urutan saat ini: ${_getNamaUrutan(_urutanSaatIni)}',
    );
    final urutanBaru = await showDialog<Urutan>(
      context: context,
      builder: (BuildContext context) {
        Urutan? selectedUrutan = _urutanSaatIni;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Urutkan Berdasarkan'),
              content: RadioGroup<Urutan>(
                groupValue: selectedUrutan,
                onChanged: (Urutan? value) {
                  if (value != null) {
                    L.i('User memilih opsi: ${_getNamaUrutan(value)}');
                    setStateDialog(() {
                      selectedUrutan = value;
                    });
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: Urutan.values.map((urutan) {
                    final isSelected = urutan == _urutanSaatIni;
                    final nama = _getNamaUrutan(urutan);
                    return RadioListTile<Urutan>(
                      title: Text('$nama${isSelected ? " (saat ini)" : ""}'),
                      value: urutan,
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    L.i('Dialog urutkan dibatalkan oleh user');
                    Nav.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    L.i(
                      'User mengonfirmasi urutan: ${selectedUrutan != null ? _getNamaUrutan(selectedUrutan!) : "null"}',
                    );
                    Nav.pop(context, selectedUrutan);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (urutanBaru != null && urutanBaru != _urutanSaatIni) {
      L.i(
        'Mengubah urutan dari ${_getNamaUrutan(_urutanSaatIni)} ke ${_getNamaUrutan(urutanBaru)}',
      );
      setState(() {
        _urutanSaatIni = urutanBaru;
      });
    } else if (urutanBaru == _urutanSaatIni) {
      L.i(
        'User memilih urutan yang sama (${_getNamaUrutan(_urutanSaatIni)}), tidak ada perubahan',
      );
    } else {
      L.i('Dialog ditutup tanpa memilih urutan');
    }
  }

  Future<void> _tampilkanDialogOpsi(VersiApkUserModel versi) async {
    L.i(
      'Menampilkan dialog opsi untuk Versi: ${versi.versiTerbaru} (ID: ${versi.id})',
    );
    showDialog(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text('Opsi Versi ${versi.versiTerbaru}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              L.i('Opsi Edit dipilih untuk Versi: ${versi.versiTerbaru}');
              Nav.pop(c);
              _keFormEdit(versi);
            },
            child: const ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              L.i('Opsi Arsipkan dipilih untuk Versi: ${versi.versiTerbaru}');
              Nav.pop(c);
              _tampilkanDialogArsip(versi);
            },
            child: const ListTile(
              leading: Icon(Icons.archive),
              title: Text('Arsipkan'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _tampilkanDialogArsip(VersiApkUserModel versi) async {
    L.i(
      'Menampilkan dialog konfirmasi arsip untuk ID: ${versi.id}, Versi: ${versi.versiTerbaru}',
    );
    final konfirmasi = await showOkCancelAlertDialog(
      context: context,
      title: 'Arsipkan Versi APK?',
      message:
          'Anda yakin ingin mengarsipkan versi ${versi.versiTerbaru}? Data yang diarsipkan tidak akan ditampilkan di daftar aktif.',
      okLabel: 'Arsipkan',
      cancelLabel: 'Batal',
      isDestructiveAction: true,
    );
    if (konfirmasi != OkCancelResult.ok) {
      L.i('Pengarsipan versi ${versi.versiTerbaru} dibatalkan oleh user');
      return;
    }
    L.i('User mengonfirmasi pengarsipan versi ${versi.versiTerbaru}');
    _arsipkan(versi.id);
  }

  Future<void> _arsipkan(String id) async {
    L.i('Memulai proses pengarsipan untuk ID: $id');

    // Cari data sebelum dihapus untuk logging
    final state = ref.read(versiApkUserProvider).value;
    final dataSebelumArsip = state?.listVersiApkUser.firstWhereOrNull(
      (v) => v.id == id,
    );
    if (dataSebelumArsip != null) {
      L.i(
        'Data yang akan diarsipkan - Versi: ${dataSebelumArsip.versiTerbaru}, Build: ${dataSebelumArsip.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
      );
    }

    try {
      await ref.read(versiApkUserProvider.notifier).arsipkanVersiApkUser(id);
      L.i('Data ID: $id berhasil diarsipkan di database');

      if (!mounted) {
        L.w(
          'Widget tidak mounted setelah arsip berhasil, membatalkan update UI',
        );
        return;
      }

      if (mounted) {
        AppToast.sukses(
          context,
          'Versi ${dataSebelumArsip?.versiTerbaru ?? id} berhasil diarsipkan.',
        );
        L.i('Toast sukses ditampilkan');
      }
    } catch (e, s) {
      L.e('Gagal mengarsipkan data ID: $id Error: $e $s');
      if (!mounted) {
        L.w('Widget tidak mounted setelah error arsip');
        return;
      }
      AppToast.gagal(context, 'Gagal mengarsipkan: $e');
      L.i('Toast error ditampilkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(versiApkUserProvider);

    if (asyncState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (asyncState.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Versi APK')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Gagal memuat data: ${asyncState.error}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final state = asyncState.requireValue;
    final daftarVersi = state.listVersiApkUser;
    final daftarUrut = daftarVersi.sorted((a, b) {
      final buildA = a.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
      final buildB = b.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
      switch (_urutanSaatIni) {
        case Urutan.buildZA:
          return buildB.compareTo(buildA);
        case Urutan.buildAZ:
          return buildA.compareTo(buildB);
        case Urutan.versiZA:
          return b.versiTerbaru.compareTo(a.versiTerbaru);
        case Urutan.versiAZ:
          return a.versiTerbaru.compareTo(b.versiTerbaru);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Versi APK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _tampilkanDialogUrutkan,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: daftarUrut.isEmpty
          ? const Center(child: Text('Tidak ada data versi APK.'))
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(versiApkUserProvider.notifier).muatUlang(),
              child: ListView.builder(
                itemCount: daftarUrut.length,
                itemBuilder: (context, index) {
                  final versiApk = daftarUrut[index];
                  final buildUniversal =
                      versiApk.nomorBuildTerbaru[ArsitekturApkEnum.universal] ??
                      0;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        'Versi: ${versiApk.versiTerbaru} (Build: $buildUniversal)',
                      ),
                      subtitle: Text(
                        versiApk.catatanRilis,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _keDetail(versiApk),
                      onLongPress: () => _tampilkanDialogOpsi(versiApk),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _keFormTambah,
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getNamaUrutan(Urutan urutan) {
    switch (urutan) {
      case Urutan.buildZA:
        return 'Build (Terbaru ke Terlama)';
      case Urutan.buildAZ:
        return 'Build (Terlama ke Terbaru)';
      case Urutan.versiZA:
        return 'Versi (Z-A)';
      case Urutan.versiAZ:
        return 'Versi (A-Z)';
    }
  }
}
