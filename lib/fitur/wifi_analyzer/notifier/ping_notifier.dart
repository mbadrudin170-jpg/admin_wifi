// path: lib/fitur/wifi_analyzer/notifier/ping_notifier.dart

import 'dart:async';
import 'dart:io';

import 'package:admin_wifi/fitur/wifi_analyzer/state/ping_state.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/core_shared.dart';

part 'ping_notifier.g.dart';

@riverpod
class PingNotifier extends _$PingNotifier {
  final _infoJaringan = NetworkInfo();

  @override
  PingState build() => const PingState();

  Future<void> pingRouter() async {
    if (kIsWeb) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ping tidak didukung di Web',
      );
      return;
    }

    try {
      final gateway = await _infoJaringan.getWifiGatewayIP();
      if (!ref.mounted) return;
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
      final validIp =
          bagianIp.length == 4 &&
          bagianIp.every((oktet) {
            final nilai = int.tryParse(oktet);
            return nilai != null && nilai >= 0 && nilai <= 255;
          });
      if (!validIp) {
        L.w('host=$host');
        state = state.copyWith(
          isLoading: false,
          error: 'Format IP gateway tidak valid',
        );
        return;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        success: false,
        latencyMs: null,
        host: host,
      );

      // Jalur 1: ICMP ping langsung ke host.
      int? latensiMs;
      bool suksesIcmp = false;
      try {
        final ping = Ping(host, count: 1, timeout: 2);
        await for (final event in ping.stream.timeout(
          const Duration(seconds: 3),
        )) {
          if (!ref.mounted) return;
          if (event is PingResponse && event.time != null) {
            suksesIcmp = true;
            latensiMs = event.time?.inMilliseconds;
          }
        }
      } catch (e, s) {
        L.w('ICMP gagal: $e $s');
      }
      if (!ref.mounted) return;

      if (suksesIcmp) {
        L.s('host=$host, latensiMs=$latensiMs, jalur=icmp');
        state = state.copyWith(
          isLoading: false,
          latencyMs: latensiMs,
          success: true,
          jenisPengukuran: 'icmp',
        );
        return;
      }

      // Jalur 2: fallback TCP connect ke port umum router.
      final hasilTcp = await _cekPortFallback(host);
      if (!ref.mounted) return;
      if (hasilTcp != null) {
        L.s(
          'host=$host, portTerbuka=${hasilTcp.$1}, '
          'latensiMs=${hasilTcp.$2}, jalur=tcp_fallback',
        );
        state = state.copyWith(
          isLoading: false,
          latencyMs: hasilTcp.$2,
          success: true,
          jenisPengukuran: 'tcp probe',
        );
        return;
      }

      L.w('host=$host, suksesIcmp=false, hasilTcp=null');
      state = state.copyWith(
        isLoading: false,
        success: false,
        error: 'Router tidak merespons ping maupun port',
      );
    } on TimeoutException catch (e, s) {
      if (!ref.mounted) return;
      L.e('Timeout ping router: $e $s');
      state = state.copyWith(isLoading: false, error: 'Ping timeout');
    } catch (e, s) {
      if (!ref.mounted) return;
      L.e('Gagal ping router: $e $s');
      state = state.copyWith(isLoading: false, error: 'Gagal ping router');
    }
  }

  Future<(int, int)?> _cekPortFallback(String host) async {
    const daftarPort = [80, 443, 8080, 8443, 22];
    final completer = Completer<(int, int)?>();
    var sisa = daftarPort.length;

    for (final port in daftarPort) {
      _cekSatuPort(host, port).then((hasil) {
        if (hasil != null && !completer.isCompleted) {
          completer.complete(hasil);
        }
        sisa--;
        if (sisa == 0 && !completer.isCompleted) {
          completer.complete(null);
        }
      });
    }

    return completer.future;
  }

  Future<(int, int)?> _cekSatuPort(String host, int port) async {
    final sw = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        host,
        port,
      ).timeout(const Duration(seconds: 2));
      sw.stop();
      await socket.close();
      return (port, sw.elapsedMilliseconds);
    } on SocketException catch (e) {
      sw.stop();
      final code = e.osError?.errorCode;
      if (code == 111 || code == 10061 || code == 61) {
        return (port, sw.elapsedMilliseconds);
      }
      return null;
    } on TimeoutException {
      return null;
    } catch (e, s) {
      L.w('Port $port gagal: $e $s');
      return null;
    }
  }
}
