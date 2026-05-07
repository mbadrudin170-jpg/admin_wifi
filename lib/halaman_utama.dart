// path: lib/halaman_utama.dart
import 'package:admin_wifi/halaman/tes/halaman_tes.dart';
import 'package:admin_wifi/services/cek_langganan_kadaluarsa_service.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/halaman/tab/lainnya.dart';
import 'package:admin_wifi/halaman/tab/pelanggan_aktif.dart';
import 'package:admin_wifi/halaman/tab/dompet.dart';
import 'package:admin_wifi/halaman/tab/transaksi.dart';

class HalamanUtama extends StatefulWidget {
  // ditambah: untuk menerima status koneksi dari splash screen
  final bool isOffline;

  const HalamanUtama({
    super.key,
    this.isOffline = false, // Default value jika tidak dikirim
  });

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
    const HalamanTes(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // diubah: Menjalankan pengecekan status offline setelah frame pertama selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cekDanTampilkanPesanOffline();
      CekLanggananKadaluarsaService().prosesLanggananKadaluarsa();
    });
  }

  // ditambah: fungsi untuk menampilkan snackbar jika offline
  void _cekDanTampilkanPesanOffline() {
    if (widget.isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda dalam mode offline. Data mungkin tidak terbaru.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5), // Tampilkan lebih lama
        ),
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
          BottomNavigationBarItem(icon: Icon(Icons.label), label: 'test'),
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
