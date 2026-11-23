// path: lib/fitur/wifi_analyzer/screens/wifi_analyzer_screen.dart

import 'dart:async';

import 'package:admin_wifi/fitur/wifi_analyzer/notifier/ping_notifier.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/notifier/wifi_analyzer_notifier.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/notifier/wifi_scan_notifier.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/ping_state.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_analyzer_state.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_scan_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiAnalyzerScreen extends ConsumerStatefulWidget {
  const WifiAnalyzerScreen({super.key});

  @override
  ConsumerState<WifiAnalyzerScreen> createState() => _WifiAnalyzerScreenState();
}

class _WifiAnalyzerScreenState extends ConsumerState<WifiAnalyzerScreen> {
  Timer? _pingTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(_pingRouter);
    _pingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _pingRouter();
    });
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    super.dispose();
  }

  Future<void> _muatData() async {
    final scanFuture = ref.read(wifiScanProvider.notifier).pindaiUlang();

    ref.invalidate(wifiAnalyzerProvider);
    try {
      await ref.read(wifiAnalyzerProvider.future);
    } catch (_) {
      // Abaikan error analyzer; UI menampilkan pesan error melalui state.
    }

    await scanFuture;

    _pingRouter();
  }

  void _pingRouter() {
    ref.read(pingProvider.notifier).pingRouter();
  }

  String _bandDariFrekuensi(int frekuensi) {
    if (frekuensi < 3000) return '2.4 GHz';
    if (frekuensi < 5925) return '5 GHz';
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
    if (frekuensi >= 5955 && frekuensi <= 7125) {
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
    final asyncAnalyzer = ref.watch(wifiAnalyzerProvider);
    final asyncScan = ref.watch(wifiScanProvider);
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
        if (asyncAnalyzer.isLoading && asyncAnalyzer.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (asyncScan.isLoading && asyncScan.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (asyncAnalyzer.hasError && asyncAnalyzer.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat data: ${asyncAnalyzer.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (asyncScan.hasError && asyncScan.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat data: ${asyncScan.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final state = asyncAnalyzer.value ?? const WifiAnalyzerState();
        final scanState = asyncScan.value ?? const WifiScanState();
        final errors = <String>[
          if (state.connectionError != null) state.connectionError!,
          if (scanState.scanError != null) scanState.scanError!,
        ];
        return RefreshIndicator(
          onRefresh: _muatData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (errors.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: errors
                        .map((e) => Text(e, textAlign: TextAlign.center))
                        .toList(),
                  ),
                ),
              _buildKartuTerhubung(state, pingState, scanState),
              const SizedBox(height: 16),
              Text(
                'Jaringan di Sekitar (${scanState.accessPoints.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (scanState.accessPoints.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada jaringan terdeteksi.'),
                  ),
                )
              else
                ...scanState.accessPoints.map(_buildItemAp),
            ],
          ),
        );
      }(),
    );
  }

  Widget _buildKartuTerhubung(
    WifiAnalyzerState state,
    PingState pingState,
    WifiScanState scanState,
  ) {
    final bssid = state.bssidTerhubung;
    final apTerhubung = bssid == null
        ? null
        : scanState.accessPoints.firstWhereOrNull(
            (a) => a.bssid.toLowerCase() == bssid.toLowerCase(),
          );
    final levelTerhubung = apTerhubung?.level;
    final freq = apTerhubung?.frequency ?? 0;
    final band = freq > 0 ? _bandDariFrekuensi(freq) : '-';
    final channel = freq > 0
        ? (_channelDariFrekuensi(freq)?.toString() ?? '-')
        : '-';
    final sinyal = apTerhubung != null ? '${apTerhubung.level} dBm' : '-';
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
              sinyal,
              valueColor: levelTerhubung != null
                  ? _warnaSinyal(levelTerhubung)
                  : null,
            ),
            _buildInfoCustom(
              'Ping Router',
              pingState.isLoading
                  ? 'Menguji...'
                  : pingState.success
                  ? '${pingState.latencyMs ?? '-'} ms (${pingState.jenisPengukuran ?? 'icmp'})'
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
