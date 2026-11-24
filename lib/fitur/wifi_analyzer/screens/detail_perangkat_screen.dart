// path: lib/fitur/wifi_analyzer/screens/detail_perangkat_screen.dart

import 'dart:async';
import 'dart:io';

import 'package:admin_wifi/fitur/wifi_analyzer/model/perangkat_wifi_model.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';

class DetailPerangkatScreen extends StatefulWidget {
  const DetailPerangkatScreen({super.key, required this.perangkat});

  final PerangkatWifiModel perangkat;

  @override
  State<DetailPerangkatScreen> createState() => _DetailPerangkatScreenState();
}

class _DetailPerangkatScreenState extends State<DetailPerangkatScreen> {
  bool _sedangPing = false;
  int? _latencyMs;
  bool? _pingBerhasil;
  int _packetLossPersen = 100;
  String? _errorPing;

  Timer? _timerMonitor;
  bool _sedangMonitor = false;
  int? _latencyMin;
  int? _latencyMax;

  bool _sedangPortScan = false;
  bool _batalkanPortScan = false;
  final List<int> _portTerbuka = <int>[];
  String? _errorPort;

  static const Map<int, String> _namaLayananPort = <int, String>{
    21: 'FTP',
    22: 'SSH',
    23: 'Telnet',
    25: 'SMTP',
    53: 'DNS',
    80: 'HTTP',
    110: 'POP3',
    139: 'NetBIOS',
    143: 'IMAP',
    443: 'HTTPS',
    445: 'SMB',
    554: 'RTSP',
    631: 'IPP',
    1883: 'MQTT',
    3306: 'MySQL',
    3389: 'RDP',
    5555: 'ADB',
    5900: 'VNC',
    8000: 'HTTP-Alt',
    8080: 'HTTP-Proxy',
    8443: 'HTTPS-Alt',
    9100: 'Printer',
  };

  Future<void> _pingPerangkat() async {
    if (kIsWeb) {
      setState(() => _errorPing = 'Ping tidak didukung di Web');
      return;
    }
    if (_sedangPing) return;
    setState(() {
      _sedangPing = true;
      _errorPing = null;
      _pingBerhasil = null;
      _latencyMs = null;
      _packetLossPersen = 100;
    });

    const jumlahProbe = 4;
    int diterima = 0;
    final latensi = <int>[];

    try {
      final ping = Ping(widget.perangkat.ip, count: jumlahProbe, timeout: 2);
      await for (final event in ping.stream.timeout(
        const Duration(seconds: 12),
      )) {
        if (!mounted) return;
        if (event is PingResponse && event.time != null) {
          diterima++;
          latensi.add(event.time!.inMilliseconds);
        }
      }
      if (!mounted) return;

      final kehilangan = ((jumlahProbe - diterima) / jumlahProbe * 100).round();
      int? rataRata;
      int? minLat;
      int? maxLat;
      if (latensi.isNotEmpty) {
        rataRata = (latensi.reduce((a, b) => a + b) / latensi.length).round();
        minLat = latensi.reduce((a, b) => a < b ? a : b);
        maxLat = latensi.reduce((a, b) => a > b ? a : b);
      }

      setState(() {
        _sedangPing = false;
        _pingBerhasil = diterima > 0;
        _latencyMs = rataRata;
        _packetLossPersen = kehilangan;
        if (minLat != null && maxLat != null) {
          _latencyMin = _latencyMin == null
              ? minLat
              : (_latencyMin! < minLat ? _latencyMin! : minLat);
          _latencyMax = _latencyMax == null
              ? maxLat
              : (_latencyMax! > maxLat ? _latencyMax! : maxLat);
        }
        if (diterima == 0) {
          _errorPing = 'Perangkat tidak merespons';
        }
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _sedangPing = false;
        _pingBerhasil = false;
        _packetLossPersen = 100;
        _errorPing = 'Ping timeout';
      });
    } catch (e, s) {
      L.e('Gagal ping perangkat: $e $s');
      if (!mounted) return;
      setState(() {
        _sedangPing = false;
        _pingBerhasil = false;
        _packetLossPersen = 100;
        _errorPing = 'Gagal ping perangkat';
      });
    }
  }

  void _mulaiMonitor() {
    if (_sedangMonitor) return;
    setState(() {
      _sedangMonitor = true;
      _latencyMin = null;
      _latencyMax = null;
    });
    _pingPerangkat();
    _timerMonitor = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _pingPerangkat();
    });
  }

  void _hentikanMonitor() {
    _timerMonitor?.cancel();
    _timerMonitor = null;
    setState(() => _sedangMonitor = false);
  }

  @override
  void dispose() {
    _timerMonitor?.cancel();
    super.dispose();
  }

  Future<void> _pindaiPort() async {
    if (_sedangPortScan) return;
    setState(() {
      _sedangPortScan = true;
      _batalkanPortScan = false;
      _errorPort = null;
      _portTerbuka.clear();
    });

    const batasKonkurensi = 8;
    final ports = _namaLayananPort.keys.toList();
    try {
      for (var i = 0; i < ports.length; i += batasKonkurensi) {
        if (_batalkanPortScan) break;
        final chunk = ports.sublist(
          i,
          (i + batasKonkurensi).clamp(0, ports.length),
        );
        final hasil = await Future.wait<bool>(
          chunk.map((port) => _cekPort(widget.perangkat.ip, port)),
        );
        if (!mounted) return;
        if (_batalkanPortScan) break;
        for (var j = 0; j < chunk.length; j++) {
          if (hasil[j]) _portTerbuka.add(chunk[j]);
        }
        _portTerbuka.sort();
        setState(() {});
      }
      if (!mounted) return;
      setState(() => _sedangPortScan = false);
    } catch (e, s) {
      L.e('Gagal pindai port: $e $s');
      if (!mounted) return;
      setState(() {
        _sedangPortScan = false;
        _errorPort = 'Gagal pindai port';
      });
    }
  }

  void _hentikanPortScan() {
    _batalkanPortScan = true;
    setState(() => _sedangPortScan = false);
  }

  Future<bool> _cekPort(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 2),
      );
      await socket.close();
      return true;
    } on SocketException catch (e) {
      final code = e.osError?.errorCode;
      // Connection refused berarti host aktif tetapi port tertutup.
      if (code == 111 || code == 10061 || code == 61) return false;
      return false;
    } on TimeoutException {
      return false;
    } catch (e, s) {
      L.w('Port $port gagal: $e $s');
      return false;
    }
  }

  String _formatTanggal(DateTime? tanggal) {
    if (tanggal == null) return 'Tidak tersedia';
    return tanggal.toLocal().toString();
  }

  Widget _barisInfo(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(nilai, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.perangkat;
    return Scaffold(
      appBar: AppBar(title: Text(p.nama ?? p.ip)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Identitas Perangkat',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _barisInfo('Nama Perangkat', p.nama ?? 'Tidak tersedia'),
          _barisInfo('Tipe Perangkat', p.tipePerangkat ?? 'Unknown'),
          _barisInfo('Manufaktur', p.vendor ?? 'Tidak tersedia'),
          _barisInfo('MAC Address', p.macAddress ?? 'Tidak tersedia'),
          _barisInfo('Sumber', p.sumberDiscovery ?? 'Tidak tersedia'),
          _barisInfo(
            'Metode Discovery',
            p.discoveryMethods.isEmpty
                ? 'Tidak tersedia'
                : p.discoveryMethods.join(', '),
          ),
          _barisInfo(
            'Layanan',
            p.services.isEmpty ? 'Tidak tersedia' : p.services.join(', '),
          ),
          _barisInfo(
            'Status Identifikasi',
            p.identificationStatus ?? 'Tidak tersedia',
          ),
          const SizedBox(height: 16),
          Text(
            'Informasi Jaringan',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _barisInfo('IP Address', p.ip),
          _barisInfo(
            'Status',
            _pingBerhasil == null
                ? 'Belum diperiksa'
                : (_pingBerhasil! ? 'Online' : 'Offline'),
          ),
          _barisInfo(
            'Ping',
            _latencyMs == null ? 'Tidak tersedia' : '$_latencyMs ms',
          ),
          _barisInfo('Metode Latensi', p.latencyMethod ?? 'Tidak tersedia'),
          _barisInfo('Packet Loss', '$_packetLossPersen%'),
          _barisInfo(
            'Ping Min',
            _latencyMin == null ? 'Tidak tersedia' : '$_latencyMin ms',
          ),
          _barisInfo(
            'Ping Max',
            _latencyMax == null ? 'Tidak tersedia' : '$_latencyMax ms',
          ),
          _barisInfo('Terakhir Terlihat', _formatTanggal(p.terakhirDilihat)),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _sedangPing ? null : _pingPerangkat,
            icon: _sedangPing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.network_check),
            label: Text(_sedangPing ? 'Memeriksa...' : 'Ping Perangkat'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _sedangMonitor ? _hentikanMonitor : _mulaiMonitor,
            icon: Icon(_sedangMonitor ? Icons.stop : Icons.play_arrow),
            label: Text(_sedangMonitor ? 'Hentikan Pantau' : 'Mulai Pantau'),
          ),
          if (_errorPing != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorPing!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Port Terbuka',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _sedangPortScan ? _hentikanPortScan : _pindaiPort,
            icon: _sedangPortScan
                ? const Icon(Icons.stop)
                : const Icon(Icons.search),
            label: Text(_sedangPortScan ? 'Hentikan' : 'Pindai Port'),
          ),
          if (_errorPort != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorPort!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 8),
          if (_portTerbuka.isEmpty && !_sedangPortScan)
            const Text('Belum ada hasil pemindaian port.')
          else
            ..._portTerbuka.map(
              (port) => ListTile(
                dense: true,
                title: Text('Port $port'),
                subtitle: Text(_namaLayananPort[port] ?? 'Unknown'),
              ),
            ),
        ],
      ),
    );
  }
}
