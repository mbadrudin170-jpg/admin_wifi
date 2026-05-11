// path: lib/halaman_utama.dart

import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/services/cek_langganan_kadaluarsa_service.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/halaman/tab/lainnya.dart';
import 'package:admin_wifi/halaman/tab/pelanggan_aktif.dart';
import 'package:admin_wifi/halaman/tab/dompet.dart';
import 'package:admin_wifi/halaman/tab/transaksi.dart';

class HalamanUtama extends StatefulWidget {
  final bool isOffline;

  const HalamanUtama({super.key, this.isOffline = false});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const PelangganAktifPage(),
    const DompetPage(),
    const TransaksiPage(),
    const LainnyaPage(),
  ];

  void _onItemTapped(int index) {
    Log.info(
      'Pengguna menekan bottom navigation index: $index.',
    );

    if (_selectedIndex == index) {
      Log.info( // diubah: dari warning ke info karena ini bukan kondisi error
        'Index yang ditekan sama dengan halaman aktif saat ini. Tidak ada perubahan state.',
      );

      return;
    }

    setState(() {
      Log.info(
        'Mengubah selected index dari $_selectedIndex menjadi $index.',
      );

      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    Log.info(
      'Memulai inisialisasi halaman utama. Status offline: ${widget.isOffline}.',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Log.info(
        'Frame pertama selesai dirender.',
      );

      _cekDanTampilkanPesanOffline();

      Log.info(
        'Menjalankan proses pengecekan langganan kadaluarsa.',
      );

      CekLanggananKadaluarsaService().prosesLanggananKadaluarsa();
    });
  }

  void _cekDanTampilkanPesanOffline() {
    Log.info(
      'Memeriksa status koneksi aplikasi.',
    );

    if (widget.isOffline) {
      Log.warning(
        'Aplikasi berjalan dalam mode offline. Menampilkan snackbar peringatan.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda dalam mode offline. Data mungkin tidak terbaru.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );

      Log.info(
        'Snackbar offline berhasil ditampilkan.',
      );
    } else {
      Log.info(
        'Aplikasi berjalan dalam mode online.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun UI halaman utama dengan selected index: $_selectedIndex.',
    );

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_circle),
            label: 'Aktif',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Dompet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Lainnya',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withAlpha(179),
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}