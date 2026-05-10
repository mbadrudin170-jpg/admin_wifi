// path: lib/halaman/lainnya/versi_apk_user.dart

import 'package:admin_wifi/halaman/detail/detail_versi_apk_user.dart';
import 'package:admin_wifi/enum/arsitektur_apk_enum.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/halaman/form/form_versi_apk_user.dart';
import 'package:admin_wifi/debug/log.dart';

enum Urutan { buildZA, buildAZ, versiZA, versiAZ }

class VersiApkUserPage extends StatefulWidget {
  final VersiApkUserOperasi? operasi;

  const VersiApkUserPage({super.key, this.operasi});

  @override
  State<VersiApkUserPage> createState() => _VersiApkUserPageState();
}

class _VersiApkUserPageState extends State<VersiApkUserPage> {
  late final VersiApkUserOperasi _versiApkUserOperasi;
  List<VersiApkUserModel> _daftarVersiApk = [];
  bool _isLoading = true;
  String? _error;
  Urutan _urutanSaatIni = Urutan.buildZA;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Versi APK User');
    _versiApkUserOperasi = widget.operasi ?? VersiApkUserOperasi();
    _loadData();
  }

  void _urutkanList() {
    Log.info('Mengurutkan daftar berdasarkan $_urutanSaatIni');
    _daftarVersiApk.sort((a, b) {
      switch (_urutanSaatIni) {
        case Urutan.buildZA:
          return (b.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0)
              .compareTo(a.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0);
        case Urutan.buildAZ:
          return (a.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0)
              .compareTo(b.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0);
        case Urutan.versiZA:
          return b.versiTerbaru.compareTo(a.versiTerbaru);
        case Urutan.versiAZ:
          return a.versiTerbaru.compareTo(b.versiTerbaru);
      }
    });
    Log.info('Pengurutan selesai');
  }

  Future<void> _loadData() async {
    Log.info('Memulai pengambilan data versi APK aktif');
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final daftarVersi = await _versiApkUserOperasi.ambilSemuaVersiApkAktif();
      Log.info('Berhasil mengambil ${daftarVersi.length} data versi APK');
      if (!mounted) return;
      setState(() {
        _daftarVersiApk = daftarVersi;
        _urutkanList();
        _isLoading = false;
      });
    } catch (e, s) {
      Log.error(
        'Terjadi kesalahan saat memuat data versi APK',
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  void _perbaruiAtauTambahItem(VersiApkUserModel item) {
    Log.info('Memperbarui list lokal dengan item ID: ${item.id}');
    final index = _daftarVersiApk.indexWhere((v) => v.id == item.id);
    setState(() {
      if (index != -1) {
        Log.info('Mengganti data lama di index $index');
        _daftarVersiApk[index] = item;
      } else {
        Log.info('Menambahkan data baru ke dalam list');
        _daftarVersiApk.add(item);
      }
      _urutkanList();
    });
  }

  void _keDetail(VersiApkUserModel versiApk) {
    Log.info('Menuju halaman detail untuk Versi: ${versiApk.versiTerbaru}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailVersiApkUser(versiApk: versiApk),
      ),
    );
  }

  void _keFormEdit(VersiApkUserModel versiApk) async {
    Log.info('Menuju form edit untuk Versi: ${versiApk.versiTerbaru}');
    final hasil = await Navigator.push<VersiApkUserModel>(
      context,
      MaterialPageRoute(
        builder: (context) => FormVersiApkUser(
          versiApkUser: versiApk,
          operasi: _versiApkUserOperasi,
        ),
      ),
    );
    if (hasil != null && mounted) {
      Log.info('Mendapatkan hasil pembaharuan dari form');
      _perbaruiAtauTambahItem(hasil);
    }
  }

  void _keFormTambah() async {
    Log.info('Menuju form tambah versi APK baru');
    final hasil = await Navigator.push<VersiApkUserModel>(
      context,
      MaterialPageRoute(
        builder: (context) => FormVersiApkUser(operasi: _versiApkUserOperasi),
      ),
    );
    if (hasil != null && mounted) {
      Log.info('Mendapatkan data versi baru dari form');
      _perbaruiAtauTambahItem(hasil);
    }
  }

  Future<void> _tampilkanDialogUrutkan() async {
    Log.info('Menampilkan dialog pengurutan');
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
                  Log.info('Grup radio berubah ke $value');
                  if (value != null) {
                    setStateDialog(() {
                      selectedUrutan = value;
                    });
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: Urutan.values.map((urutan) {
                    return RadioListTile<Urutan>(
                      title: Text(_getNamaUrutan(urutan)),
                      value: urutan,
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Log.info('Dialog urutkan dibatalkan');
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Log.info('Konfirmasi urutan baru: $selectedUrutan');
                    Navigator.of(context).pop(selectedUrutan);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (urutanBaru != null && urutanBaru != _urutanSaatIni) {
      Log.info('Mengubah urutan dari $_urutanSaatIni ke $urutanBaru');
      setState(() {
        _urutanSaatIni = urutanBaru;
        _urutkanList();
      });
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
    Log.info('Menampilkan SimpleDialog opsi untuk Versi: ${versi.versiTerbaru}');
    showDialog(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text('Opsi Versi ${versi.versiTerbaru}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Log.info('Opsi Edit dipilih');
              Navigator.pop(c);
              _keFormEdit(versi);
            },
            child: const ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Log.info('Opsi Arsipkan dipilih');
              Navigator.pop(c);
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
    Log.info('Menampilkan konfirmasi arsip untuk ID: ${versi.id}');
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Arsipkan Versi APK?'),
        content: Text(
          'Anda yakin ingin mengarsipkan versi ${versi.versiTerbaru}?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Log.info('Pengarsipan dibatalkan user');
              Navigator.pop(c);
            },
          ),
          TextButton(
            child: const Text('Arsipkan'),
            onPressed: () {
              Log.info('User mengonfirmasi pengarsipan');
              Navigator.pop(c);
              _arsipkan(versi.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _arsipkan(String id) async {
    Log.info('Memulai proses pengarsipan untuk ID: $id');
    try {
      await _versiApkUserOperasi.arsipkanVersiApkUser(id);
      Log.info('Data berhasil diarsipkan dari database');
      if (!mounted) return;
      setState(() {
        _daftarVersiApk.removeWhere((v) => v.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil diarsipkan.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, s) {
      Log.error(
        'Gagal mengarsipkan data',
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengarsipkan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI VersiApkUserPage');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Versi APK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              Log.info('Icon sort ditekan');
              _tampilkanDialogUrutkan();
            },
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Log.info('Tombol tambah versi ditekan');
          _keFormTambah();
        },
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      Log.info('Menampilkan loading indicator');
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      Log.warning('Menampilkan pesan error UI: $_error');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_daftarVersiApk.isEmpty) {
      Log.info('Daftar kosong, menampilkan placeholder');
      return const Center(child: Text('Tidak ada data versi APK.'));
    }

    Log.info('Membangun ListView dengan ${_daftarVersiApk.length} item');
    return RefreshIndicator(
      onRefresh: () async {
        Log.info('User melakukan pull-to-refresh');
        await _loadData();
      },
      child: ListView.builder(
        itemCount: _daftarVersiApk.length,
        itemBuilder: (context, index) {
          final versiApk = _daftarVersiApk[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                'Versi: ${versiApk.versiTerbaru} (Build: ${versiApk.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0})',
              ),
              subtitle: Text(
                versiApk.catatanRilis,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Log.info('Item index $index diklik (Tap)');
                _keDetail(versiApk);
              },
              onLongPress: () {
                Log.info('Item index $index ditekan lama (LongPress)');
                _tampilkanDialogOpsi(versiApk);
              },
            ),
          );
        },
      ),
    );
  }
}
