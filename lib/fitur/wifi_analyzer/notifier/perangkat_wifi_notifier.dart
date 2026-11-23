// path: lib/fitur/wifi_analyzer/notifier/perangkat_wifi_notifier.dart

import 'dart:async';

import 'package:admin_wifi/fitur/wifi_analyzer/model/perangkat_wifi_model.dart';
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
      perangkat: <PerangkatWifiModel>[],
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

      final submask = await _infoJaringan.getWifiSubmask();

      final subnet = _deriveSubnet(ip.trim(), submask);
      if (subnet == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Format IP/subnet tidak valid: $ip / ${submask ?? '-'}',
        );
        return;
      }

      final ditemukan = <String, PerangkatWifiModel>{};

      _subscription = HostScannerService.instance
          .getAllPingableDevicesAsync(
            subnet,
            progressCallback: (progress) {
              if (!ref.mounted) return;
              state = state.copyWith(progress: progress.round());
            },
          )
          .listen(
            (host) async {
              if (!ref.mounted) return;
              final nama = await host.deviceName;
              final mac = await host.getMacAddress();
              final vendor = (await host.vendor)?.vendorName;
              final latency = host.responseTime?.inMilliseconds;
              final model = PerangkatWifiModel(
                ip: host.address,
                nama: (nama.isEmpty || nama == ActiveHost.generic)
                    ? null
                    : nama,
                mac: (mac == null || mac.isEmpty) ? null : mac,
                vendor: (vendor == null || vendor.isEmpty) ? null : vendor,
                latencyMs: latency,
              );
              ditemukan[host.address] = model;
              if (!ref.mounted) return;
              final list = ditemukan.values.toList()
                ..sort((a, b) => a.ip.compareTo(b.ip));
              state = state.copyWith(perangkat: list);
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

  String? _deriveSubnet(String ip, String? submask) {
    final bagianIp = ip.split('.');
    if (bagianIp.length != 4) return null;
    final ipOktet = bagianIp.map(int.tryParse).toList();
    if (ipOktet.any((v) => v == null || v < 0 || v > 255)) return null;

    final maskStr = (submask == null || submask.trim().isEmpty)
        ? '255.255.255.0'
        : submask.trim();
    final bagianMask = maskStr.split('.');
    if (bagianMask.length != 4) return null;
    final maskOktet = bagianMask.map(int.tryParse).toList();
    if (maskOktet.any((v) => v == null || v < 0 || v > 255)) return null;

    var prefix = 0;
    for (final m in maskOktet) {
      var bits = m!;
      for (var i = 7; i >= 0; i--) {
        if ((bits >> i) & 1 == 1) {
          prefix++;
        } else {
          break;
        }
      }
      if (bits != 255) break;
    }

    final networkOktet = List<int>.generate(
      4,
      (i) => ipOktet[i]! & maskOktet[i]!,
    );

    if (prefix >= 24) {
      return '${networkOktet[0]}.${networkOktet[1]}.${networkOktet[2]}';
    }
    if (prefix >= 16) {
      return '${networkOktet[0]}.${networkOktet[1]}';
    }
    if (prefix >= 8) {
      return '${networkOktet[0]}';
    }
    return null;
  }
}
