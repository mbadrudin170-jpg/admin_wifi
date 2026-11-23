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
  final _networkInfo = NetworkInfo();

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
      final gateway = await _networkInfo.getWifiGatewayIP();
      if (gateway == null || gateway.trim().isEmpty) {
        state = state.copyWith(isLoading: false, error: 'Gateway tidak ditemukan');
        return;
      }
      final host = gateway.trim();
      state = state.copyWith(host: host);

      var response;
      final stopwatch = Stopwatch()..start();
      while (response == null || response.time == null) {
        final r = ActiveHost.getPingData(host);
        if (r != null && r.time != null) {
          response = r;
          break;
        }
        if (stopwatch.elapsed >= const Duration(seconds: 3)) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (response != null && response.time != null) {
        state = state.copyWith(
          isLoading: false,
          latencyMs: response.time!.inMilliseconds,
          success: true,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Ping gagal');
      }
    } catch (e, s) {
      L.e('Gagal ping router: $e $s');
      state = state.copyWith(isLoading: false, error: 'Gagal ping: $e');
    }
  }
}