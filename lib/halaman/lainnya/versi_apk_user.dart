// path: lib/halaman/lainnya/versi_apk_user.dart

import 'package:admin_wifi/halaman/detail/detail_versi_apk_user.dart';
import 'package:admin_wifi/enum/arsitektur_apk_enum.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/halaman/form/form_versi_apk_user.dart';
import 'dart:developer' as developer;

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
    developer.log('[VersiApkUserPage]-[initState] 🏁 : Menginisialisasi halaman Versi APK User', name: 'VersiApkUserPage');
    _versiApkUserOperasi = widget.operasi ?? VersiApkUserOperasi();
    _loadData();
  }

  void _urutkanList() {
    developer.log('[VersiApkUserPage]-[_urutkanList] ⚖️ : Mengurutkan daftar berdasarkan $_urutanSaatIni', name: 'VersiApkUserPage');
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
    developer.log('[VersiApkUserPage]-[_urutkanList] ✅ : Pengurutan selesai', name: 'VersiApkUserPage');
  }

  Future<void> _loadData() async {
    developer.log('[VersiApkUserPage]-[_loadData] 🔄 : Memulai pengambilan data versi APK aktif dari database/cloud', name: 'VersiApkUserPage');
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final daftarVersi = await _versiApkUserOperasi.ambilSemuaVersiApkAktif();
      developer.log('[VersiApkUserPage]-[_loadData] 📥 : Berhasil mengambil ${daftarVersi.length} data versi APK', name: 'VersiApkUserPage');
      if (!mounted) return;
      setState(() {
        _daftarVersiApk = daftarVersi;
        _urutkanList();
        _isLoading = false;
      });
    } catch (e, s) {
      developer.log(
        '[VersiApkUserPage]-[_loadData] ❌ : Terjadi kesalahan saat memuat data',
        error: e,
        stackTrace: s,
        name: 'VersiApkUserPage',
      );
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  void _perbaruiAtauTambahItem(VersiApkUserModel item) {
    developer.log('[VersiApkUserPage]-[_perbaruiAtauTambahItem] 🛠️ : Memperbarui list lokal dengan item ID: ${item.id}', name: 'VersiApkUserPage');
    final index = _daftarVersiApk.indexWhere((v) => v.id == item.id);
    setState(() {
      if (index != -1) {
        developer.log('[VersiApkUserPage]-[_perbaruiAtauTambahItem] 📝 : Mengganti data lama di index $index', name: 'VersiApkUserPage');
        _daftarVersiApk[index] = item;
      } else {
        developer.log('[VersiApkUserPage]-[_perbaruiAtauTambahItem] ✨ : Menambahkan data baru ke dalam list', name: 'VersiApkUserPage');
        _daftarVersiApk.add(item);
      }
      _urutkanList();
    });
  }

  void _keDetail(VersiApkUserModel versiApk) {
    developer.log('[VersiApkUserPage]-[_keDetail] 🔍 : Menuju halaman detail untuk Versi: ${versiApk.versiTerbaru}', name: 'VersiApkUserPage');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailVersiApkUser(versiApk: versiApk),
      ),
    );
  }

  void _keFormEdit(VersiApkUserModel versiApk) async {
    developer.log('[VersiApkUserPage]-[_keFormEdit] ✏️ : Menuju form edit untuk Versi: ${versiApk.versiTerbaru}', name: 'VersiApkUserPage');
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
      developer.log('[VersiApkUserPage]-[_keFormEdit] ✅ : Mendapatkan hasil pembaharuan dari form', name: 'VersiApkUserPage');
      _perbaruiAtauTambahItem(hasil);
    }
  }

  void _keFormTambah() async {
    developer.log('[VersiApkUserPage]-[_keFormTambah] ➕ : Menuju form tambah versi APK baru', name: 'VersiApkUserPage');
    final hasil = await Navigator.push<VersiApkUserModel>(
      context,
      MaterialPageRoute(
        builder: (context) => FormVersiApkUser(operasi: _versiApkUserOperasi),
      ),
    );
    if (hasil != null && mounted) {
      developer.log('[VersiApkUserPage]-[_keFormTambah] ✅ : Mendapatkan data versi baru dari form', name: 'VersiApkUserPage');
      _perbaruiAtauTambahItem(hasil);
    }
  }

  Future<void> _tampilkanDialogUrutkan() async {
    developer.log('[VersiApkUserPage]-[_tampilkanDialogUrutkan] 🗣️ : Menampilkan dialog pengurutan', name: 'VersiApkUserPage');
    final urutanBaru = await showDialog<Urutan>(
      context: context,
      builder: (BuildContext context) {
        Urutan? selectedUrutan = _urutanSaatIni;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Urutkan Berdasarkan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioGroup<Urutan>(
                    groupValue: selectedUrutan,
                    onChanged: (Urutan? value) {
                      developer.log('[VersiApkUserPage]-[_tampilkanDialogUrutkan] 🔘 : Radio button berubah ke $value', name: 'VersiApkUserPage');
                      setStateDialog(() {
                        selectedUrutan = value;
                      });
                    },
                    child: Column(
                      children: Urutan.values.map((urutan) {
                        return ListTile(
                          title: Text(_getNamaUrutan(urutan)),
                          leading: Radio<Urutan>(value: urutan),
                          onTap: () {
                            developer.log('[VersiApkUserPage]-[_tampilkanDialogUrutkan] 👆 : ListTile urutan $urutan diklik', name: 'VersiApkUserPage');
                            setStateDialog(() {
                              selectedUrutan = urutan;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    developer.log('[VersiApkUserPage]-[_tampilkanDialogUrutkan] 🔙 : Dialog dibatalkan', name: 'VersiApkUserPage');
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    developer.log('[VersiApkUserPage]-[_tampilkanDialogUrutkan] 👌 : Konfirmasi urutan baru: $selectedUrutan', name: 'VersiApkUserPage');
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
      developer.log('[VersiApkUserPage]-[_tampilkanDialogUrutkan] 🔃 : Mengubah urutan dari $_urutanSaatIni ke $urutanBaru', name: 'VersiApkUserPage');
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
    developer.log('[VersiApkUserPage]-[_tampilkanDialogOpsi] 📂 : Menampilkan SimpleDialog opsi untuk Versi: ${versi.versiTerbaru}', name: 'VersiApkUserPage');
    showDialog(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text('Opsi Versi ${versi.versiTerbaru}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              developer.log('[VersiApkUserPage]-[_tampilkanDialogOpsi] 👆 : Opsi Edit dipilih', name: 'VersiApkUserPage');
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
              developer.log('[VersiApkUserPage]-[_tampilkanDialogOpsi] 👆 : Opsi Arsipkan dipilih', name: 'VersiApkUserPage');
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
    developer.log('[VersiApkUserPage]-[_tampilkanDialogArsip] ❓ : Menampilkan konfirmasi arsip untuk ID: ${versi.id}', name: 'VersiApkUserPage');
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
              developer.log('[VersiApkUserPage]-[_tampilkanDialogArsip] 🔙 : Pengarsipan dibatalkan user', name: 'VersiApkUserPage');
              Navigator.pop(c);
            },
          ),
          TextButton(
            child: const Text('Arsipkan'),
            onPressed: () {
              developer.log('[VersiApkUserPage]-[_tampilkanDialogArsip] 🆗 : User mengonfirmasi pengarsipan', name: 'VersiApkUserPage');
              Navigator.pop(c);
              _arsipkan(versi.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _arsipkan(String id) async {
    developer.log('[VersiApkUserPage]-[_arsipkan] 📦 : Memulai proses pengarsipan di layer Operasi untuk ID: $id', name: 'VersiApkUserPage');
    try {
      await _versiApkUserOperasi.arsipkanVersiApkUser(id);
      developer.log('[VersiApkUserPage]-[_arsipkan] ✅ : Data berhasil diarsipkan dari database', name: 'VersiApkUserPage');
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
      developer.log(
        '[VersiApkUserPage]-[_arsipkan] ❌ : Gagal mengarsipkan data',
        name: 'VersiApkUserPage',
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
    developer.log('[VersiApkUserPage]-[build] 🏗️ : Membangun UI VersiApkUserPage', name: 'VersiApkUserPage');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Versi APK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              developer.log('[VersiApkUserPage]-[AppBar] 👆 : Icon sort ditekan', name: 'VersiApkUserPage');
              _tampilkanDialogUrutkan();
            },
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          developer.log('[VersiApkUserPage]-[FAB] 👆 : Tombol tambah versi ditekan', name: 'VersiApkUserPage');
          _keFormTambah();
        },
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      developer.log('[VersiApkUserPage]-[_buildContent] ⏳ : Menampilkan loading indicator', name: 'VersiApkUserPage');
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      developer.log('[VersiApkUserPage]-[_buildContent] ⚠️ : Menampilkan pesan error UI', name: 'VersiApkUserPage');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_daftarVersiApk.isEmpty) {
      developer.log('[VersiApkUserPage]-[_buildContent] 📭 : Daftar kosong, menampilkan placeholder', name: 'VersiApkUserPage');
      return const Center(child: Text('Tidak ada data versi APK.'));
    }

    developer.log('[VersiApkUserPage]-[_buildContent] 📜 : Membangun ListView dengan ${_daftarVersiApk.length} item', name: 'VersiApkUserPage');
    return RefreshIndicator(
      onRefresh: () async {
        developer.log('[VersiApkUserPage]-[RefreshIndicator] 🔃 : User melakukan pull-to-refresh', name: 'VersiApkUserPage');
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
                developer.log('[VersiApkUserPage]-[ListView] 👆 : Item index $index diklik (Tap)', name: 'VersiApkUserPage');
                _keDetail(versiApk);
              },
              onLongPress: () {
                developer.log('[VersiApkUserPage]-[ListView] 🖐️ : Item index $index ditekan lama (LongPress)', name: 'VersiApkUserPage');
                _tampilkanDialogOpsi(versiApk);
              },
            ),
          );
        },
      ),
    );
  }
}