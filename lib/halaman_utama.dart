// path: lib/halaman_utama.dart
import 'dart:developer' as developer;
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
    developer.log(
      '👆 [HalamanUtama] -> [_onItemTapped] -> Berpindah ke tab indeks: $index',
      name: 'HalamanUtama.Navigation',
    );
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    developer.log(
      '🏠 [HalamanUtama] -> [initState] -> Inisialisasi Halaman Utama',
      name: 'HalamanUtama.Lifecycle',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cekDanTampilkanPesanOffline();

      developer.log(
        '⏳ [HalamanUtama] -> [PostFrameCallback] -> Menjalankan pengecekan langganan kadaluarsa',
        name: 'HalamanUtama.BackgroundJob',
      );
      CekLanggananKadaluarsaService().prosesLanggananKadaluarsa();
    });
  }

  void _cekDanTampilkanPesanOffline() {
    if (widget.isOffline) {
      developer.log(
        '⚠️ [HalamanUtama] -> [_cekDanTampilkanPesanOffline] -> Status: OFFLINE. Menampilkan SnackBar peringatan.',
        name: 'HalamanUtama.Network',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda dalam mode offline. Data mungkin tidak terbaru.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      developer.log(
        '🌐 [HalamanUtama] -> [_cekDanTampilkanPesanOffline] -> Status: ONLINE.',
        name: 'HalamanUtama.Network',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
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
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Lainnya'),
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
