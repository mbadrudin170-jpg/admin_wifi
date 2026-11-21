// path: lib/halaman/lainnya/versi_apk_user.dart

import 'dart:async';

import 'package:admin_wifi/fitur/versi_apk_user/notifier/versi_apk_user_notifier.dart';
import 'package:admin_wifi/enum/arsitektur_apk_enum.dart';
import 'package:admin_wifi/fitur/versi_apk_user/screens/detail_versi_apk_user.dart';
import 'package:admin_wifi/fitur/versi_apk_user/screens/form_versi_apk_user.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

enum Urutan { buildZA, buildAZ, versiZA, versiAZ }

class VersiApkUserPage extends StatefulWidget {
  final dynamic operasi;

  const VersiApkUserPage({super.key, this.operasi});

  @override
  State<VersiApkUserPage> createState() => _VersiApkUserPageState();
}

class _VersiApkUserPageState extends State<VersiApkUserPage> {
  late final dynamic _versiApkUserOperasi;
  List<VersiApkUserModel> _daftarVersiApk = [];
  bool _isLoading = true;
  String? _error;
  Urutan _urutanSaatIni = Urutan.buildZA;

  @override
  void initState() {
    super.initState();
    L.i('Menginisialisasi halaman Versi APK User');
    _versiApkUserOperasi = versiApkUserNotifierGlobal;
    L.i(
      'Menggunakan operasi: ${widget.operasi != null ? "dari parameter" : "instance baru"}',
    );
    _loadData();
  }

  void _urutkanList() {
    L.i(
      'Mengurutkan ${_daftarVersiApk.length} data berdasarkan: ${_getNamaUrutan(_urutanSaatIni)}',
    );

    _daftarVersiApk.sort((a, b) {
      final buildA = a.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
      final buildB = b.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;

      switch (_urutanSaatIni) {
        case Urutan.buildZA:
          L.i('Pengurutan Build Z-A: membandingkan build $buildB vs $buildA');
          return buildB.compareTo(buildA);
        case Urutan.buildAZ:
          L.i('Pengurutan Build A-Z: membandingkan build $buildA vs $buildB');
          return buildA.compareTo(buildB);
        case Urutan.versiZA:
          L.i(
            'Pengurutan Versi Z-A: membandingkan ${b.versiTerbaru} vs ${a.versiTerbaru}',
          );
          return b.versiTerbaru.compareTo(a.versiTerbaru);
        case Urutan.versiAZ:
          L.i(
            'Pengurutan Versi A-Z: membandingkan ${a.versiTerbaru} vs ${b.versiTerbaru}',
          );
          return a.versiTerbaru.compareTo(b.versiTerbaru);
      }
    });

    // Log 5 data teratas setelah pengurutan
    L.i('5 data teratas setelah pengurutan:');
    for (
      int i = 0;
      i < (_daftarVersiApk.length < 5 ? _daftarVersiApk.length : 5);
      i++
    ) {
      final v = _daftarVersiApk[i];
      L.i(
        '  ${i + 1}. ID: ${v.id}, Versi: ${v.versiTerbaru}, Build Universal: ${v.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
      );
    }

    L.i('Pengurutan selesai');
  }

  Future<void> _loadData() async {
    L.i('Memuat data versi APK aktif dari database');
    if (!mounted) {
      L.w('Widget tidak mounted, membatalkan load data');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      L.i('Set state: isLoading=true, error=null');
    });

    try {
      final daftarVersi = await _versiApkUserOperasi.ambilSemuaVersiApkAktif();
      L.i('Berhasil memuat ${daftarVersi.length} data versi APK aktif');

      // Log detail setiap versi APK
      for (var versi in daftarVersi) {
        final buildUniversal =
            versi.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
        final bit_32 = versi.nomorBuildTerbaru[ArsitekturApkEnum.bit_32] ?? 0;
        final bit_64 = versi.nomorBuildTerbaru[ArsitekturApkEnum.bit_64] ?? 0;
        L.i(
          'Versi APK ID: ${versi.id}, Versi: ${versi.versiTerbaru}, Build Universal: $buildUniversal, Build ARM64: $bit_32, Build X86_64: $bit_64, Catatan: ${versi.catatanRilis.length > 50 ? "${versi.catatanRilis.substring(0, 50)}..." : versi.catatanRilis}',
        );
      }

      if (!mounted) {
        L.w('Widget tidak mounted setelah fetch, membatalkan setState');
        return;
      }

      setState(() {
        _daftarVersiApk = daftarVersi;
        _urutkanList();
        _isLoading = false;
        L.i(
          'Set state: daftarVersiApk=${_daftarVersiApk.length} data, isLoading=false',
        );
      });
    } catch (e, s) {
      L.e('Gagal memuat data versi APK dari database Error: $e $s');
      if (!mounted) {
        L.w('Widget tidak mounted setelah error, membatalkan setState');
        return;
      }
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
        L.i('Set state: error="$_error", isLoading=false');
      });
    }
  }

  void _perbaruiAtauTambahItem(VersiApkUserModel item) {
    L.i(
      'Memperbarui/menambah item lokal - ID: ${item.id}, Versi: ${item.versiTerbaru}',
    );
    final index = _daftarVersiApk.indexWhere((v) => v.id == item.id);
    setState(() {
      if (index != -1) {
        L.i(
          'Item ditemukan di index $index, mengganti data lama dengan data baru',
        );
        L.i(
          'Data lama - Versi: ${_daftarVersiApk[index].versiTerbaru}, Build: ${_daftarVersiApk[index].nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
        );
        L.i(
          'Data baru - Versi: ${item.versiTerbaru}, Build: ${item.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
        );
        _daftarVersiApk[index] = item;
      } else {
        L.i(
          'Item baru, menambahkan ke dalam daftar (sebelumnya ${_daftarVersiApk.length} data)',
        );
        _daftarVersiApk.add(item);
        L.i('Daftar sekarang berisi ${_daftarVersiApk.length} data');
      }
      _urutkanList();
    });
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

  void _keFormEdit(VersiApkUserModel versiApk) async {
    L.i(
      'Navigasi ke Form Edit Versi APK - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}',
    );
    final hasil = await Nav.to<VersiApkUserModel>(
      context,
      FormVersiApkUser(versiApkUser: versiApk, operasi: _versiApkUserOperasi),
    );

    if (hasil != null && mounted) {
      L.i(
        'Menerima hasil edit dari Form - ID: ${hasil.id}, Versi: ${hasil.versiTerbaru}',
      );
      _perbaruiAtauTambahItem(hasil);
    } else if (hasil == null) {
      L.i('Kembali dari Form Edit tanpa perubahan data');
    } else {
      L.i('Widget tidak mounted, mengabaikan hasil edit');
    }
  }

  void _keFormTambah() async {
    L.i('Navigasi ke Form Tambah Versi APK');
    final hasil = await Nav.to<VersiApkUserModel>(
      context,
      FormVersiApkUser(operasi: _versiApkUserOperasi),
    );

    if (hasil != null && mounted) {
      L.i(
        'Menerima data versi baru dari Form - ID: ${hasil.id}, Versi: ${hasil.versiTerbaru}',
      );
      _perbaruiAtauTambahItem(hasil);
    } else if (hasil == null) {
      L.i('Kembali dari Form Tambah tanpa membuat data baru');
    } else {
      L.i('Widget tidak mounted, mengabaikan data baru');
    }
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
        _urutkanList();
      });
    } else if (urutanBaru == _urutanSaatIni) {
      L.i(
        'User memilih urutan yang sama (${_getNamaUrutan(_urutanSaatIni)}), tidak ada perubahan',
      );
    } else {
      L.i('Dialog ditutup tanpa memilih urutan');
    }
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
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Arsipkan Versi APK?'),
        content: Text(
          'Anda yakin ingin mengarsipkan versi ${versi.versiTerbaru}? Data yang diarsipkan tidak akan ditampilkan di daftar aktif.',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              L.i(
                'Pengarsipan versi ${versi.versiTerbaru} dibatalkan oleh user',
              );
              Nav.pop(c);
            },
          ),
          TextButton(
            child: const Text('Arsipkan'),
            onPressed: () {
              L.i('User mengonfirmasi pengarsipan versi ${versi.versiTerbaru}');
              Nav.pop(c);
              _arsipkan(versi.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _arsipkan(String id) async {
    L.i('Memulai proses pengarsipan untuk ID: $id');

    // Cari data sebelum dihapus untuk logging
    final dataSebelumArsip = _daftarVersiApk
        .where((v) => v.id == id)
        .firstOrNull;
    if (dataSebelumArsip != null) {
      L.i(
        'Data yang akan diarsipkan - Versi: ${dataSebelumArsip.versiTerbaru}, Build: ${dataSebelumArsip.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
      );
    }

    try {
      await _versiApkUserOperasi.arsipkanVersiApkUser(id);
      L.i('Data ID: $id berhasil diarsipkan di database');

      if (!mounted) {
        L.w(
          'Widget tidak mounted setelah arsip berhasil, membatalkan update UI',
        );
        return;
      }

      setState(() {
        final jumlahSebelum = _daftarVersiApk.length;
        _daftarVersiApk.removeWhere((v) => v.id == id);
        L.i(
          'Data dihapus dari daftar lokal: $jumlahSebelum -> ${_daftarVersiApk.length} data',
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Versi ${dataSebelumArsip?.versiTerbaru ?? id} berhasil diarsipkan.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        L.i('SnackBar sukses ditampilkan');
      }
    } catch (e, s) {
      L.e('Gagal mengarsipkan data ID: $id Error: $e $s');
      if (!mounted) {
        L.w('Widget tidak mounted setelah error arsip');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengarsipkan: $e'),
          backgroundColor: Colors.red,
        ),
      );
      L.i('SnackBar error ditampilkan');
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i(
      'Membangun UI VersiApkUserPage - Data: ${_daftarVersiApk.length}, Loading: $_isLoading, Error: ${_error != null ? "Ya" : "Tidak"}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Versi APK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            L.i('Kembali ke halaman sebelumnya dari Versi APK User');
            Nav.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              L.i('Icon sort pada AppBar ditekan');
              _tampilkanDialogUrutkan();
            },
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          L.i('FAB Tambah Versi APK ditekan');
          _keFormTambah();
        },
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    L.i(
      'Membangun konten body - isLoading: $_isLoading, error: ${_error != null}, dataCount: ${_daftarVersiApk.length}',
    );

    if (_isLoading) {
      L.i('Menampilkan CircularProgressIndicator (loading)');
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      L.i('Menampilkan pesan error: $_error');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_daftarVersiApk.isEmpty) {
      L.i('Daftar versi APK kosong, menampilkan placeholder');
      return const Center(child: Text('Tidak ada data versi APK.'));
    }

    L.i('Menampilkan ListView dengan ${_daftarVersiApk.length} item');
    return RefreshIndicator(
      onRefresh: () async {
        L.i('User melakukan pull-to-refresh pada daftar versi APK');
        await _loadData();
        L.i('Pull-to-refresh selesai, data berhasil dimuat ulang');
      },
      child: ListView.builder(
        itemCount: _daftarVersiApk.length,
        itemBuilder: (context, index) {
          final versiApk = _daftarVersiApk[index];
          final buildUniversal =
              versiApk.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;

          L.i(
            'Membangun item ke-${index + 1} dari ${_daftarVersiApk.length} - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}, Build: $buildUniversal',
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                'Versi: ${versiApk.versiTerbaru} (Build: $buildUniversal)',
              ),
              subtitle: Text(
                versiApk.catatanRilis,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                L.i(
                  'Tap pada item index $index - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}',
                );
                _keDetail(versiApk);
              },
              onLongPress: () {
                L.i(
                  'LongPress pada item index $index - ID: ${versiApk.id}, Versi: ${versiApk.versiTerbaru}',
                );
                _tampilkanDialogOpsi(versiApk);
              },
            ),
          );
        },
      ),
    );
  }
}
