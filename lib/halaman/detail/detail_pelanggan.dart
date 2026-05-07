// lib/halaman/detail/detail_pelanggan.dart
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/halaman/form/form_pelanggan.dart';
import 'package:admin_wifi/halaman/pembantu/halaman_poin.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPelangganPage extends StatefulWidget {
  final PelangganModel pelanggan;
  const DetailPelangganPage({super.key, required this.pelanggan});

  @override
  DetailPelangganPageState createState() => DetailPelangganPageState();
}

class DetailPelangganPageState extends State<DetailPelangganPage> {
  bool _isPasswordVisible = false;
  int _totalPoin = 0;
  bool _isLoadingPoin = true;
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  @override
  void initState() {
    super.initState();
    _loadTotalPoin();
  }

  Future<void> _loadTotalPoin() async {
    try {
      final poin = await _pelangganOperasi.getTotalPoin(widget.pelanggan.id);
      if (mounted) {
        setState(() {
          _totalPoin = poin;
          _isLoadingPoin = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPoin = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat poin: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    String formattedNumber =
        '62${phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')}';
    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedNumber');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak dapat membuka WhatsApp. Pastikan sudah terinstal.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pelanggan.nama),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FormPelanggan(pelanggan: widget.pelanggan),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoinCard(),
            const SizedBox(height: 20),
            Text(
              'Nama: ${widget.pelanggan.nama}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                InkWell(
                  onTap: () => _launchWhatsApp(widget.pelanggan.telepon),
                  child: Row(
                    children: [
                      Text(
                        'Telepon: ${widget.pelanggan.telepon}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 20.0),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.pelanggan.telepon),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor telepon berhasil disalin!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Salin nomor telepon',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Alamat: ${widget.pelanggan.alamat}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'MAC Address: ${widget.pelanggan.macAddress}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 20.0),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.pelanggan.macAddress),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('MAC Address berhasil disalin!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Salin MAC Address',
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Password: ${_isPasswordVisible ? widget.pelanggan.password : '********'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final allInfo =
                    '''
Nama: ${widget.pelanggan.nama}
Telepon: ${widget.pelanggan.telepon}
Alamat: ${widget.pelanggan.alamat}
MAC Address: ${widget.pelanggan.macAddress}
Password: ${widget.pelanggan.password}
''';
                Clipboard.setData(ClipboardData(text: allInfo));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Semua informasi pelanggan berhasil disalin!',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Salin Semua Info'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoinCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HalamanPoin()),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.purple.shade700, Colors.deepPurple.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.yellow, size: 40),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Poin', 
                    style: TextStyle(color: Colors.white70, fontSize: 16)
                  ),
                  if (_isLoadingPoin)
                    const SizedBox(
                      height: 20, 
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  else
                    Text(
                      '$_totalPoin',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 28, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}
