// path: lib/fitur/wifi_analyzer/screens/wifi_analyzer_screen.dart

import 'dart:async';

import 'package:admin_wifi/fitur/wifi_analyzer/notifier/ping_notifier.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/notifier/wifi_analyzer_notifier.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/ping_state.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_analyzer_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiAnalyzerScreen extends ConsumerStatefulWidget {
  const WifiAnalyzerScreen({super.key});

  @override
  ConsumerState<WifiAnalyzerScreen> createState() => _WifiAnalyzerScreenState();
}

class _WifiAnalyzerScreenState extends ConsumerState<WifiAnalyzerScreen> {
  @override
  void initState() {
    super.initState();
    _pingRouter();
  }

  Future<void> _muatData() async {
    ref.invalidate(wifiAnalyzerProvider);
    await ref.read(wifiAnalyzerProvider.future);
    unawaited(_pingRouter());
  }

  Future<void> _pingRouter() async {
    await ref.read(pingProvider.notifier).pingRouter();
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

  Color _warnaSinyal(int level) {
    if (level >= -50) return const Color(0xFF4CAF50);
    if (level >= -60) return const Color(0xFF8BC34A);
    if (level >= -70) return const Color(0xFFFF9800);
    if (level >= -80) return const Color(0xFFFF5722);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(wifiAnalyzerProvider);
    final pingState = ref.watch(pingProvider);

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
        final errors = <String>[
          if (state.connectionError != null) state.connectionError!,
          if (state.scanError != null) state.scanError!,
        ];
        if (errors.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: errors
                    .map((e) => Text(e, textAlign: TextAlign.center))
                    .toList(),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _muatData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildKartuTerhubung(state, pingState),
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

  Widget _buildKartuTerhubung(WifiAnalyzerState state, PingState pingState) {
    final levelTerhubung = state.levelTerhubung;
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
            _buildInfoCustom(
              'Sinyal',
              state.sinyalTerhubung,
              valueColor: levelTerhubung != null
                  ? _warnaSinyal(levelTerhubung)
                  : null,
            ),
            _buildInfoCustom(
              'Ping Router',
              pingState.isLoading
                  ? 'Menguji...'
                  : pingState.success
                  ? '${pingState.latencyMs} ms'
                  : (pingState.error ?? '-'),
            ),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text('BSSID: ${ap.bssid}'),
            Text('Band: ${_bandDariFrekuensi(ap.frequency)}'),
            Text('Frekuensi: ${ap.frequency} MHz'),
            Text('Channel: ${channel ?? '-'}'),
            Text(
              'Sinyal: ${ap.level} dBm (${_kualitasSinyal(ap.level)})',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: _warnaSinyal(ap.level)),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildInfoCustom(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
