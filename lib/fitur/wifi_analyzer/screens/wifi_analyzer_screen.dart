// path: lib/fitur/wifi_analyzer/screens/wifi_analyzer_screen.dart

import 'dart:async';

import 'package:admin_wifi/fitur/wifi_analyzer/notifier/wifi_analyzer_notifier.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_analyzer_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiAnalyzerScreen extends ConsumerStatefulWidget {
  const WifiAnalyzerScreen({super.key});

  @override
  ConsumerState<WifiAnalyzerScreen> createState() => _WifiAnalyzerScreenState();
}

class _WifiAnalyzerScreenState extends ConsumerState<WifiAnalyzerScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          _muatData();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _muatData() async {
    await ref.read(wifiAnalyzerProvider.notifier).muatUlang();
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
    final asyncState = ref.watch(wifiAnalyzerProvider);

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
      body: () {
        if (asyncState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (asyncState.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat data: ${asyncState.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final state = asyncState.requireValue;
        final pesanError = state.errorMessage;
        if (pesanError != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(pesanError, textAlign: TextAlign.center),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _muatData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildKartuTerhubung(state),
              const SizedBox(height: 16),
              Text(
                'Jaringan di Sekitar (${state.accessPoints.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (state.accessPoints.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada jaringan terdeteksi.'),
                  ),
                )
              else
                ...state.accessPoints.map(_buildItemAp),
            ],
          ),
        );
      }(),
    );
  }

  Widget _buildKartuTerhubung(WifiAnalyzerState state) {
    final freq = state.frekuensiTerhubung;
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
            _buildInfoCustom('SSID', state.ssidTerhubung ?? '-'),
            _buildInfoCustom('BSSID', state.bssidTerhubung ?? '-'),
            _buildInfoCustom('IP', state.ipTerhubung ?? '-'),
            _buildInfoCustom('Band', band),
            _buildInfoCustom('Frekuensi', freq > 0 ? '$freq MHz' : '-'),
            _buildInfoCustom('Channel', channel),
            _buildInfoCustom('Sinyal', state.sinyalTerhubung),
          ],
        ),
      ),
    );
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
