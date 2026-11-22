// path: lib/fitur/wifi_analyzer/screens/wifi_analyzer_screen.dart

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiAnalyzerScreen extends ConsumerStatefulWidget {
  const WifiAnalyzerScreen({super.key});

  @override
  ConsumerState<WifiAnalyzerScreen> createState() => _WifiAnalyzerScreenState();
}

class _WifiAnalyzerScreenState extends ConsumerState<WifiAnalyzerScreen> {
  final _networkInfo = NetworkInfo();

  bool _isLoading = false;
  String? _errorMessage;
  List<WiFiAccessPoint> _accessPoints = <WiFiAccessPoint>[];

  String? _ssidTerhubung;
  String? _bssidTerhubung;
  String? _ipTerhubung;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Informasi jaringan yang sedang terhubung.
      _ssidTerhubung = await _networkInfo.getWifiName();
      _bssidTerhubung = await _networkInfo.getWifiBSSID();
      _ipTerhubung = await _networkInfo.getWifiIP();

      // Pindai jaringan di sekitar (Android).
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
      }
      final canGet = await WiFiScan.instance.canGetScannedResults();
      if (canGet == CanGetScannedResults.yes) {
        _accessPoints = await WiFiScan.instance.getScannedResults();
      } else {
        _errorMessage = 'Tidak dapat membaca hasil pemindaian: $canGet';
      }
    } catch (e, s) {
      L.e('Gagal memuat data WiFi analyzer: $e $s');
      _errorMessage = 'Gagal memuat data: $e';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _bandDariFrekuensi(int frekuensi) {
    if (frekuensi < 3000) return '2.4 GHz';
    if (frekuensi < 6000) return '5 GHz';
    return '6 GHz';
  }

  int? _channelDariFrekuensi(int frekuensi) {
    if (frekuensi >= 2412 && frekuensi <= 2484) {
      if (frekuensi == 2484) return 14;
      return (frekuensi - 2407) ~/ 5;
    }
    if (frekuensi >= 5170 && frekuensi <= 5825) {
      return (frekuensi - 5000) ~/ 5;
    }
    if (frekuensi >= 5925 && frekuensi <= 7125) {
      return (frekuensi - 5950) ~/ 5;
    }
    return null;
  }

  String _kualitasSinyal(int level) {
    if (level >= -50) return 'Sangat Baik';
    if (level >= -60) return 'Baik';
    if (level >= -70) return 'Cukup';
    if (level >= -80) return 'Lemah';
    return 'Sangat Lemah';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Analyzer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatData,
            tooltip: 'Pindai Ulang',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: _muatData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildKartuTerhubung(),
                  const SizedBox(height: 16),
                  Text(
                    'Jaringan di Sekitar (${_accessPoints.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_accessPoints.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Tidak ada jaringan terdeteksi.'),
                      ),
                    )
                  else
                    ..._accessPoints.map(_buildItemAp),
                ],
              ),
            ),
    );
  }

  Widget _buildKartuTerhubung() {
    final freq = _frekuensiTerhubung();
    final band = freq > 0 ? _bandDariFrekuensi(freq) : '-';
    final channel = freq > 0
        ? (_channelDariFrekuensi(freq)?.toString() ?? '-')
        : '-';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              'JARINGAN TERHUBUNG',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            _buildInfoCustom('SSID', _ssidTerhubung ?? '-'),
            _buildInfoCustom('BSSID', _bssidTerhubung ?? '-'),
            _buildInfoCustom('IP', _ipTerhubung ?? '-'),
            _buildInfoCustom('Band', band),
            _buildInfoCustom('Frekuensi', freq > 0 ? '$freq MHz' : '-'),
            _buildInfoCustom('Channel', channel),
          ],
        ),
      ),
    );
  }

  int _frekuensiTerhubung() {
    // Cari AP yang BSSID-nya sama dengan jaringan terhubung.
    final bssid = _bssidTerhubung;
    if (bssid == null) return 0;
    final ap = _accessPoints.firstWhereOrNull(
      (a) => a.bssid.toLowerCase() == bssid.toLowerCase(),
    );
    return ap?.frequency ?? 0;
  }

  Widget _buildItemAp(WiFiAccessPoint ap) {
    final channel = _channelDariFrekuensi(ap.frequency);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(ap.ssid.isEmpty ? '(Tersembunyi)' : ap.ssid),
        subtitle: Text(
          'BSSID: ${ap.bssid}\n'
          'Band: ${_bandDariFrekuensi(ap.frequency)} | '
          'Frekuensi: ${ap.frequency} MHz | '
          'Channel: ${channel ?? '-'} | '
          'Sinyal: ${ap.level} dBm (${_kualitasSinyal(ap.level)})',
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildInfoCustom(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
