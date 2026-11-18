// path: lib/halaman_utama.dart

import 'package:admin_wifi/fitur/pelanggan_aktif/screens/pelanggan_aktif_screen.dart';
import 'package:admin_wifi/fitur/dompet/screens/dompet.dart';
import 'package:admin_wifi/halaman/tab/lainnya.dart';
import 'package:admin_wifi/halaman/tab/transaksi.dart';
import 'package:admin_wifi/services/cek_langganan_kadaluarsa_service.dart';
import 'package:flutter/material.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/widget/toast_widget.dart';

class Home extends StatefulWidget {
  final bool isOffline;

  const Home({super.key, this.isOffline = false});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  // Penanda tab yang sudah pernah dibuka; tab yang belum pernah dibuka
  // belum dibangun (lazy loading), tetapi setelah dibuka state-nya tetap
  // terjaga di dalam IndexedStack.
  final Set<int> _tabDibangun = <int>{0};

  final List<Widget> _widgetOptions = <Widget>[
    const PelangganAktifScreen(),
    const DompetPage(),
    const TransaksiPage(),
    const LainnyaPage(),
  ];

  void _onItemTapped(int index) {
    L.i('Pengguna menekan bottom navigation index: $index.');

    if (_selectedIndex == index) {
      L.i(
        // diubah: dari warning ke info karena ini bukan kondisi error
        'Index yang ditekan sama dengan halaman aktif saat ini. Tidak ada perubahan state.',
      );

      return;
    }

    setState(() {
      L.i('Mengubah selected index dari $_selectedIndex menjadi $index.');

      _tabDibangun.add(index);
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    L.i(
      'Memulai inisialisasi halaman utama. Status offline: ${widget.isOffline}.',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      L.i('Frame pertama selesai dirender.');

      _cekDanTampilkanPesanOffline();

      L.i('Menjalankan proses pengecekan langganan kadaluarsa.');

      CekLanggananKadaluarsaService().prosesLanggananKadaluarsa();
    });
  }

  void _cekDanTampilkanPesanOffline() {
    L.i('Memeriksa status koneksi aplikasi.');

    if (widget.isOffline) {
      L.w(
        'Aplikasi berjalan dalam mode offline. Menampilkan toast peringatan.',
      );

      AppToast.warning(
        context,
        'Anda dalam mode offline. Data mungkin tidak terbaru.',
      );

      L.i('Toast offline berhasil ditampilkan.');
    } else {
      L.i('Aplikasi berjalan dalam mode online.');
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI halaman utama dengan selected index: $_selectedIndex.');

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          for (var i = 0; i < _widgetOptions.length; i++)
            _tabDibangun.contains(i)
                ? SizedBox.expand(child: _widgetOptions[i])
                : const SizedBox.shrink(),
        ],
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
