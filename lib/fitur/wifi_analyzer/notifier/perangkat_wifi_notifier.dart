// path: lib/fitur/wifi_analyzer/notifier/perangkat_wifi_notifier.dart

import 'dart:async';

import 'package:admin_wifi/fitur/wifi_analyzer/state/perangkat_wifi_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/core_shared.dart';

part 'perangkat_wifi_notifier.g.dart';

@riverpod
class PerangkatWifiNotifier extends _$PerangkatWifiNotifier {
  final _infoJaringan = NetworkInfo();

  StreamSubscription<ActiveHost>? _subscription;

  @override
  PerangkatWifiState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return const PerangkatWifiState();
  }

  Future<void> pindai() async {
    if (kIsWeb) {
      state = state.copyWith(
        isLoading: false,
        error: 'Pemindaian perangkat tidak didukung di Web. Gunakan perangkat Android.',
      );
      return;
    }

    await _subscription?.cancel();
    _subscription = null;

    state = state.copyWith(
      isLoading: true,
      error: null,
      perangkat: <ActiveHost>[],
      progress: 0,
    );

    try {
      final ip = await _infoJaringan.getWifiIP();
      if (ip == null || ip.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'IP perangkat tidak ditemukan. Pastikan terhubung ke WiFi.',
        );
        return;
      }

      final bagianIp = ip.trim().split('.');
      if (bagianIp.length != 4) {
        state = state.copyWith(
          isLoading: false,
          error: 'Format IP tidak valid: $ip',
        );
        return;
      }

      final subnet = '${bagianIp[0]}.${bagianIp[1]}.${bagianIp[2]}';

      final ditemukan = <ActiveHost>{};

      _subscription = HostScannerService.instance
          .getAllPingableDevicesAsync(
            subnet,
            progressCallback: (progress) {
              if (!ref.mounted) return;
              state = state.copyWith(progress: progress.round());
            },
          )
          .listen(
            (host) {
              if (!ref.mounted) return;
              ditemukan.add(host);
              state = state.copyWith(
                perangkat: ditemukan.toList()
                  ..sort((a, b) => a.address.compareTo(b.address)),
              );
            },
            onError: (Object e, StackTrace s) {
              L.e('Gagal memindai perangkat: $e $s');
              if (!ref.mounted) return;
              state = state.copyWith(error: 'Gagal memindai: $e');
            },
            onDone: () {
              if (!ref.mounted) return;
              state = state.copyWith(isLoading: false, progress: 100);
            },
          );

      // Tunggu hingga stream selesai.
      await _subscription!.asFuture<void>().catchError((
        Object e,
        StackTrace s,
      ) {
        L.e('Stream scan perangkat error: $e $s');
      });
    } catch (e, s) {
      L.e('Gagal memindai perangkat: $e $s');
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memindai perangkat: $e',
      );
    }
  }

  Future<void> batalkan() async {
    await _subscription?.cancel();
    _subscription = null;
    state = state.copyWith(isLoading: false);
  }
}
