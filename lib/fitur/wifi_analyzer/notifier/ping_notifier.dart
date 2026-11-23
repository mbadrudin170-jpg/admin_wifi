// path: lib/fitur/wifi_analyzer/notifier/ping_notifier.dart

import 'dart:async';

import 'package:admin_wifi/fitur/wifi_analyzer/state/ping_state.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/core_shared.dart';

part 'ping_notifier.g.dart';

@riverpod
class PingNotifier extends _$PingNotifier {
  final _infoJaringan = NetworkInfo();

  @override
  PingState build() => const PingState();

  Future<void> pingRouter() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      success: false,
      latencyMs: null,
    );

    try {
      final gateway = await _infoJaringan.getWifiGatewayIP();
      if (gateway == null || gateway.trim().isEmpty) {
        L.w('gateway=$gateway');
        state = state.copyWith(
          isLoading: false,
          error: 'Gateway tidak ditemukan',
        );
        return;
      }

      final host = gateway.trim();
      final bagianIp = host.split('.');
      final oktetTerakhir = int.tryParse(bagianIp.last);
      if (bagianIp.length != 4 || oktetTerakhir == null) {
        L.w('host=$host, oktetTerakhir=$oktetTerakhir');
        state = state.copyWith(
          isLoading: false,
          error: 'Format IP gateway tidak valid',
        );
        return;
      }

      final subnet = bagianIp.take(3).join('.');
      state = state.copyWith(host: host);

      ActiveHost? hostDitemukan;
      final stream = HostScannerService.instance
          .getAllPingableDevices(
            subnet,
            firstHostId: oktetTerakhir,
            lastHostId: oktetTerakhir,
          )
          .timeout(const Duration(seconds: 4));

      await for (final aktifHost in stream) {
        if (aktifHost.address == host) {
          hostDitemukan = aktifHost;
        }
      }

      if (hostDitemukan != null) {
        final latensiMs = hostDitemukan.pingData?.time?.inMilliseconds;
        L.s('host=$host, latensiMs=$latensiMs, jalur=icmp');
        state = state.copyWith(
          isLoading: false,
          latencyMs: latensiMs,
          success: true,
        );
        return;
      }

      final portTerbuka = await _cekPortFallback(host);
      if (portTerbuka != null) {
        L.s('host=$host, portTerbuka=$portTerbuka, jalur=tcp_fallback');
        state = state.copyWith(
          isLoading: false,
          latencyMs: null,
          success: true,
        );
        return;
      }

      L.w('host=$host, hostDitemukan=null, portTerbuka=null');
      state = state.copyWith(
        isLoading: false,
        error: 'Router tidak merespons ping maupun port',
      );
    } on TimeoutException catch (e, s) {
      L.e('Timeout ping router: $e $s');
      state = state.copyWith(
        isLoading: false,
        error: 'Ping timeout',
      );
    } catch (e, s) {
      L.e('Gagal ping router: $e $s');
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal ping: $e',
      );
    }
  }

  Future<int?> _cekPortFallback(String host) async {
    const daftarPort = [80, 443];
    for (final port in daftarPort) {
      final terbuka = await PortScannerService.instance.isOpen(host, port);
      if (terbuka != null) {
        return port;
      }
    }
    return null;
  }
}