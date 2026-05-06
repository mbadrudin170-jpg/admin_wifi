// path: lib/halaman/lainnya/versi_apk_user.dart

import 'package:admin_wifi/halaman/detail/detail_versi_apk_user.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/halaman/form/form_versi_apk_user.dart';
import 'dart:developer' as developer;

enum Urutan {
  buildZA,
  buildAZ,
  versiZA,
  versiAZ,
}

class VersiApkUserPage extends StatefulWidget {
  final VersiApkUserOperasi? operasi;

  const VersiApkUserPage({
    super.key,
    this.operasi,
  });

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
    _versiApkUserOperasi = widget.operasi ?? VersiApkUserOperasi();
    _loadData();
  }

  void _urutkanList() {
    _daftarVersiApk.sort((a, b) {
      switch (_urutanSaatIni) {
        case Urutan.buildZA:
          return (b.nomorBuildTerbaru['universal'] ?? 0).compareTo(a.nomorBuildTerbaru['universal'] ?? 0);
        case Urutan.buildAZ:
          return (a.nomorBuildTerbaru['universal'] ?? 0).compareTo(b.nomorBuildTerbaru['universal'] ?? 0);
        case Urutan.versiZA:
          return b.versiTerbaru.compareTo(a.versiTerbaru);
        case Urutan.versiAZ:
          return a.versiTerbaru.compareTo(b.versiTerbaru);
      }
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final daftarVersi = await _versiApkUserOperasi.ambilSemuaVersiApkAktif();
      if (!mounted) return;
      setState(() {
        _daftarVersiApk = daftarVersi;
        _urutkanList();
        _isLoading = false;
      });
    } catch (e, s) {
      developer.log('Gagal memuat data', error: e, stackTrace: s, name: 'VersiApkUserPage');
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  // ditambah: Fungsi cerdas untuk memperbarui atau menambahkan item di list
  void _perbaruiAtauTambahItem(VersiApkUserModel item) {
    final index = _daftarVersiApk.indexWhere((v) => v.id == item.id);
    setState(() {
      if (index != -1) {
        // Mode Edit: Ganti item yang ada
        _daftarVersiApk[index] = item;
      } else {
        // Mode Tambah: Tambahkan item baru
        _daftarVersiApk.add(item);
      }
      _urutkanList(); // Selalu urutkan kembali setelah perubahan
    });
  }

  void _keDetail(VersiApkUserModel versiApk) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailVersiApkUser(versiApk: versiApk)));
  }

  // diubah: Sekarang menunggu kembalian objek VersiApkUserModel
  void _keFormEdit(VersiApkUserModel versiApk) async {
    final hasil = await Navigator.push<VersiApkUserModel>(
      context,
      MaterialPageRoute(builder: (context) => FormVersiApkUser(versiApkUser: versiApk, operasi: _versiApkUserOperasi)),
    );
    if (hasil != null && mounted) {
      _perbaruiAtauTambahItem(hasil);
    }
  }

  // ditambah: Fungsi terpisah untuk navigasi ke form tambah
  void _keFormTambah() async {
    final hasil = await Navigator.push<VersiApkUserModel>(
      context,
      MaterialPageRoute(builder: (context) => FormVersiApkUser(operasi: _versiApkUserOperasi)),
    );
    if (hasil != null && mounted) {
      _perbaruiAtauTambahItem(hasil);
    }
  }

  Future<void> _tampilkanDialogUrutkan() async {
    final urutanBaru = await showDialog<Urutan>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: Urutan.values.map((urutan) {
          return RadioListTile<Urutan>(
            title: Text(_getNamaUrutan(urutan)),
            value: urutan,
            groupValue: _urutanSaatIni,
            onChanged: (Urutan? value) => Navigator.pop(context, value),
          );
        }).toList(),
      ),
    );
    if (urutanBaru != null && urutanBaru != _urutanSaatIni) {
      setState(() {
        _urutanSaatIni = urutanBaru;
        _urutkanList();
      });
    }
  }

  String _getNamaUrutan(Urutan urutan) {
    switch (urutan) {
      case Urutan.buildZA: return 'Build (Terbaru ke Terlama)';
      case Urutan.buildAZ: return 'Build (Terlama ke Terbaru)';
      case Urutan.versiZA: return 'Versi (Z-A)';
      case Urutan.versiAZ: return 'Versi (A-Z)';
    }
  }

  Future<void> _tampilkanDialogOpsi(VersiApkUserModel versi) async {
    showDialog(context: context, builder: (c) => SimpleDialog(
      title: Text('Opsi Versi ${versi.versiTerbaru}'),
      children: [
        SimpleDialogOption(onPressed: () { Navigator.pop(c); _keFormEdit(versi); }, child: const ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
        SimpleDialogOption(onPressed: () { Navigator.pop(c); _tampilkanDialogArsip(versi); }, child: const ListTile(leading: Icon(Icons.archive), title: Text('Arsipkan'))),
      ],
    ));
  }

  Future<void> _tampilkanDialogArsip(VersiApkUserModel versi) async {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text('Arsipkan Versi APK?'),
      content: Text('Anda yakin ingin mengarsipkan versi ${versi.versiTerbaru}?'),
      actions: [
        TextButton(child: const Text('Batal'), onPressed: () => Navigator.pop(c)),
        TextButton(child: const Text('Arsipkan'), onPressed: () { Navigator.pop(c); _arsipkan(versi.id); }),
      ],
    ));
  }

  // diubah: Fungsi ini sekarang hanya menghapus item dari list, tidak memuat ulang semua data
  Future<void> _arsipkan(String id) async {
    try {
      await _versiApkUserOperasi.arsipkanVersiApkUser(id);
      if (!mounted) return;
      setState(() {
        _daftarVersiApk.removeWhere((v) => v.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil diarsipkan.'), backgroundColor: Colors.green),
      );
    } catch (e, s) {
      developer.log('Gagal mengarsipkan', name: 'VersiApkUserPage', error: e, stackTrace: s);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengarsipkan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Versi APK'),
        actions: [
          IconButton(icon: const Icon(Icons.sort), onPressed: _tampilkanDialogUrutkan, tooltip: 'Urutkan'),
        ],
      ),
      // diubah: Body sekarang menggunakan fungsi _buildContent
      body: _buildContent(),
      // diubah: FAB sekarang memanggil _keFormTambah
      floatingActionButton: FloatingActionButton(
        onPressed: _keFormTambah,
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!, textAlign: TextAlign.center)));
    if (_daftarVersiApk.isEmpty) return const Center(child: Text('Tidak ada data versi APK.'));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _daftarVersiApk.length,
        itemBuilder: (context, index) {
          final versiApk = _daftarVersiApk[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Versi: ${versiApk.versiTerbaru} (Build: ${versiApk.nomorBuildTerbaru['universal'] ?? 0})'),
              subtitle: Text(versiApk.catatanRilis, maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () => _keDetail(versiApk),
              onLongPress: () => _tampilkanDialogOpsi(versiApk),
            ),
          );
        },
      ),
    );
  }
}
