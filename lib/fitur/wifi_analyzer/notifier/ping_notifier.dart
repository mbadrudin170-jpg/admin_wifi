// path: lib/fitur/wifi_analyzer/notifier/ping_notifier.dart

import 'dart:async';
import 'dart:collection';
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

  final Queue<int> _riwayatLatensi = Queue<int>();
  String? _hostRiwayat;
  JenisPengukuranPing? _jenisRiwayat;

  bool _sedangPing = false;

  @override
  PingState build() => const PingState();

  Future<void> pingRouter() async {
    if (_sedangPing) return;
    _sedangPing = true;
    try {
      await _jalankanPing();
    } finally {
      _sedangPing = false;
    }
  }

  Future<void> _jalankanPing() async {
    if (kIsWeb) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ping tidak didukung di Web',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      success: false,
      latencyMs: null,
      error: null,
      jenisPengukuran: null,
    );

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

      if (suksesIcmp && latensiMs != null) {
        final latensiStabil = _stabilkanLatensi(
          host: host,
          jenis: JenisPengukuranPing.icmp,
          latensi: latensiMs,
        );

        L.s('host=$host, raw=$latensiMs, median=$latensiStabil, jalur=icmp');

        state = state.copyWith(
          isLoading: false,
          latencyMs: latensiStabil,
          success: true,
          jenisPengukuran: JenisPengukuranPing.icmp,
        );
        return;
      }

      // Jalur 2: fallback TCP connect ke port umum router.
      final hasilTcp = await _cekPortFallback(host);
      if (!ref.mounted) return;
      if (hasilTcp != null) {
        final latensiStabil = _stabilkanLatensi(
          host: host,
          jenis: JenisPengukuranPing.tcpProbe,
          latensi: hasilTcp.$2,
        );

        L.s(
          'host=$host, port=${hasilTcp.$1}, '
          'raw=${hasilTcp.$2}, median=$latensiStabil, jalur=tcp',
        );

        state = state.copyWith(
          isLoading: false,
          latencyMs: latensiStabil,
          success: true,
          jenisPengukuran: JenisPengukuranPing.tcpProbe,
        );
        return;
      }

      L.w('host=$host, suksesIcmp=false, hasilTcp=null');
      state = state.copyWith(
        isLoading: false,
        success: false,
        error: 'Router tidak merespons',
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

  int _stabilkanLatensi({
    required String host,
    required JenisPengukuranPing jenis,
    required int latensi,
  }) {
    if (_hostRiwayat != host || _jenisRiwayat != jenis) {
      _riwayatLatensi.clear();
      _hostRiwayat = host;
      _jenisRiwayat = jenis;
    }

    _riwayatLatensi.addLast(latensi);

    if (_riwayatLatensi.length > 5) {
      _riwayatLatensi.removeFirst();
    }

    final hasil = _riwayatLatensi.toList()..sort();
    final tengah = hasil.length ~/ 2;

    if (hasil.length.isOdd) {
      return hasil[tengah];
    }

    return ((hasil[tengah - 1] + hasil[tengah]) / 2).round();
  }

  Future<(int, int)?> _cekPortFallback(String host) async {
    const daftarPort = [80, 443, 8080, 8443, 22];

    final hasil = await Future.wait<(int, int)?>([
      for (final port in daftarPort) _cekSatuPort(host, port),
    ]);

    final berhasil = hasil.whereType<(int, int)>().toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));

    if (berhasil.isEmpty) {
      return null;
    }

    return berhasil.first;
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
