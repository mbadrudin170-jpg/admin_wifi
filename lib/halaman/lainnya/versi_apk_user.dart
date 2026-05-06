// path: lib/halaman/lainnya/versi_apk_user.dart

import 'package:admin_wifi/halaman/detail/detail_versi_apk_user.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/halaman/form/form_versi_apk_user.dart';
import 'dart:developer' as developer;

// untuk menampilkan daftar versi APK
class VersiApkUserPage extends StatefulWidget {
  const VersiApkUserPage({super.key});

  @override
  State<VersiApkUserPage> createState() => _VersiApkUserPageState();
}

class _VersiApkUserPageState extends State<VersiApkUserPage> {
  final VersiApkUserOperasi _versiApkUserOperasi = VersiApkUserOperasi();
  List<VersiApkUserModel> _daftarVersiApk = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // untuk memuat daftar data
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _versiApkUserOperasi.ambilSemuaVersiApkAktif();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e, s) {
      developer.log('Gagal memuat daftar versi APK', error: e, stackTrace: s);
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  // untuk navigasi ke halaman detail
  void _keDetail(VersiApkUserModel versiApk) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailVersiApkUser(versiApk: versiApk),
      ),
    );
  }

  // ditambah: fungsi untuk menampilkan dialog konfirmasi pengarsipan
  Future<void> _tampilkanDialogArsip(VersiApkUserModel versi) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Arsipkan Versi APK?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Anda yakin ingin mengarsipkan versi ${versi.versiTerbaru}?',
                ),
                const Text(
                  'Tindakan ini akan menandai data sebagai terhapus dan tidak akan tampil lagi di daftar ini.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Arsipkan'),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await _arsipkanDanMuatUlang(versi.id);
              },
            ),
          ],
        );
      },
    );
  }

  // ditambah: fungsi untuk mengeksekusi pengarsipan dan memuat ulang data
  Future<void> _arsipkanDanMuatUlang(String id) async {
    if (!mounted) return;
    try {
      await _versiApkUserOperasi.arsipkanVersiApkUser(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Versi APK berhasil diarsipkan.'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadData(); // Muat ulang data untuk memperbarui UI
    } catch (e, s) {
      developer.log(
        'Gagal mengarsipkan',
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

  // untuk membangun konten utama
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_daftarVersiApk.isEmpty) {
      return const Center(child: Text('Tidak ada data versi APK.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _daftarVersiApk.length,
        itemBuilder: (context, index) {
          final versiApk = _daftarVersiApk[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Versi: ${versiApk.versiTerbaru}'),
              subtitle: Text(
                versiApk.catatanRilis,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _keDetail(versiApk),
              // ditambah: onLongPress untuk memanggil dialog arsip
              onLongPress: () {
                _tampilkanDialogArsip(versiApk);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Versi APK')),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const FormVersiApkUser()),
          );
          if (result == true) {
            _loadData();
          }
        },
        tooltip: 'Tambah Versi APK',
        child: const Icon(Icons.add),
      ),
    );
  }
}
