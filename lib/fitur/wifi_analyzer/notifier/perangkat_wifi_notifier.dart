// path: lib/fitur/wifi_analyzer/notifier/perangkat_wifi_notifier.dart

import 'dart:async';

import 'package:admin_wifi/fitur/wifi_analyzer/model/perangkat_wifi_model.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/perangkat_wifi_state.dart';
import 'package:bonsoir/bonsoir.dart';
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
  Timer? _timerPemindaian;
  bool _sedangScan = false;
  String? _ipTerakhir;

  @override
  PerangkatWifiState build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _timerPemindaian?.cancel();
    });

    if (kIsWeb) {
      return const PerangkatWifiState(
        isLoading: false,
        error: 'Pemindaian perangkat tidak didukung di Web. Gunakan perangkat Android.',
      );
    }

    // Pemindaian berjalan otomatis saat provider mulai di-watch oleh widget.
    unawaited(_pindai());

    // Auto-refresh tiap 30 detik.
    _timerPemindaian = Timer.periodic(const Duration(seconds: 30), (_) {
      if (ref.mounted) {
        unawaited(
          _pindai().catchError((Object e, StackTrace s) {
            L.e('Gagal auto-refresh perangkat: $e $s');
            return null;
          }),
        );
      }
    });

    return const PerangkatWifiState(isLoading: true, progress: 0);
  }

  Future<void> _pindai() async {
    if (kIsWeb) {
      state = state.copyWith(
        isLoading: false,
        error: 'Pemindaian perangkat tidak didukung di Web. Gunakan perangkat Android.',
      );
      return;
    }

    if (_sedangScan) return;
    _sedangScan = true;

    await _subscription?.cancel();
    _subscription = null;

    state = state.copyWith(error: null, progress: 0);

    final discoveryFuture = _jalankanServiceDiscovery();

    try {
      final ip = await _infoJaringan.getWifiIP();
      if (ip == null || ip.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'IP perangkat tidak ditemukan. Pastikan terhubung ke WiFi.',
        );
        return;
      }
      final ipBersih = ip.trim();

      final submask = await _infoJaringan.getWifiSubmask();

      final subnet = _deriveSubnet(ipBersih, submask);
      if (subnet == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Format IP/subnet tidak valid: $ipBersih / ${submask ?? '-'}',
        );
        return;
      }

      if (_ipTerakhir != null && _ipTerakhir != ipBersih) {
        state = state.copyWith(perangkat: const <PerangkatWifiModel>[]);
      }
      _ipTerakhir = ipBersih;

      final hostIds = _hostIdsUntukSubnet(ipBersih, submask);
      L.i('pindai: ip=$ipBersih subnet=$subnet hostIds=${hostIds.length}');

      final ditemukan = <String, PerangkatWifiModel>{};

      if (hostIds.isNotEmpty) {
        _subscription = HostScannerService.instance
            .getAllPingableDevicesAsync(
              subnet,
              hostIds: hostIds,
              progressCallback: (progress) {
                if (!ref.mounted) return;
                state = state.copyWith(progress: progress.round());
              },
            )
            .listen(
              (host) async {
                if (!ref.mounted) return;
                final nama = await host.deviceName;
                final vendorMac = (await host.vendor)?.vendorName;
                final vendor = (vendorMac == null || vendorMac.isEmpty)
                    ? null
                    : vendorMac;
                final macAddress = await host.getMacAddress();
                final latency = host.responseTime?.inMilliseconds;
                final model = PerangkatWifiModel(
                  ip: host.address,
                  nama: (nama.isEmpty || nama == ActiveHost.generic)
                      ? null
                      : nama,
                  vendor: vendor,
                  macAddress: macAddress,
                  tipePerangkat: 'Unknown',
                  terakhirDilihat: DateTime.now(),
                  latencyMs: latency,
                  sumberDiscovery: 'icmp',
                );
                ditemukan[host.address] = model;
                L.i(
                  'host ditemukan: ${host.address} nama=$nama vendor=$vendor latency=$latency',
                );
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
                state = state.copyWith(progress: 100);
              },
            );

        // Tunggu hingga stream selesai.
        await _subscription!.asFuture<void>().catchError((
          Object e,
          StackTrace s,
        ) {
          L.e('Stream scan perangkat error: $e $s');
        });
      } else {
        L.w('Tidak ada host id valid untuk subnet $subnet; lewati ICMP scan.');
      }

      // Gabungkan hasil service discovery (nama/vendor/mac) berdasarkan IP.
      final serviceData = await discoveryFuture;
      if (ref.mounted && serviceData.isNotEmpty) {
        _gabungkanServiceData(serviceData);
      }
    } catch (e, s) {
      L.e('Gagal memindai perangkat: $e $s');
      if (ref.mounted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Gagal memindai perangkat: $e',
        );
      }
    } finally {
      _sedangScan = false;
      if (ref.mounted) {
        state = state.copyWith(isLoading: false, progress: 100);
      }
    }
  }

  Future<void> batalkan() async {
    await _subscription?.cancel();
    _subscription = null;
    _sedangScan = false;
    state = state.copyWith(isLoading: false);
  }

  ({
    List<int> ipOktet,
    List<int> maskOktet,
    int prefix,
    List<int> networkOktet,
  })?
  _parseSubnet(String ip, String? submask) {
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

    return (
      ipOktet: ipOktet.cast<int>(),
      maskOktet: maskOktet.cast<int>(),
      prefix: prefix,
      networkOktet: networkOktet,
    );
  }

  String? _deriveSubnet(String ip, String? submask) {
    final info = _parseSubnet(ip, submask);
    if (info == null) return null;
    L.i(
      'deriveSubnet: ip=$ip mask=${submask ?? '255.255.255.0'} '
      'prefix=${info.prefix} network=${info.networkOktet.join('.')} '
      'hostIds=${_hostIdsUntukSubnet(ip, submask).length}',
    );
    // network_tools hanya mendukung pemindaian /24; gunakan /24 yang memuat IP.
    return '${info.networkOktet[0]}.${info.networkOktet[1]}.${info.networkOktet[2]}';
  }

  List<int> _hostIdsUntukSubnet(String ip, String? submask) {
    final info = _parseSubnet(ip, submask);
    if (info == null) {
      return List<int>.generate(254, (i) => i + 1);
    }
    final prefix = info.prefix;
    if (prefix < 24) {
      // Subnet lebih besar: pindai seluruh /24 yang memuat IP (subset subnet).
      return List<int>.generate(254, (i) => i + 1);
    }
    if (prefix >= 31) {
      final hostId = info.ipOktet[3];
      if (hostId > 0 && hostId < 255) return <int>[hostId];
      return const <int>[];
    }
    final blockSize = 1 << (32 - prefix);
    final networkInt =
        (info.networkOktet[0] << 24) |
        (info.networkOktet[1] << 16) |
        (info.networkOktet[2] << 8) |
        info.networkOktet[3];
    final firstHost = networkInt + 1;
    final lastHost = networkInt + blockSize - 2;
    final start = firstHost & 0xFF;
    final end = lastHost & 0xFF;
    final ids = <int>[];
    for (var i = start; i <= end; i++) {
      if (i > 0 && i < 255) ids.add(i);
    }
    if (ids.isEmpty) {
      return List<int>.generate(254, (i) => i + 1);
    }
    return ids;
  }

  Future<Map<String, ({String? nama, String? vendor, String? layanan})>>
  _jalankanServiceDiscovery() async {
    final hasil = <String, ({String? nama, String? vendor, String? layanan})>{};
    if (kIsWeb) return hasil;
    const serviceTypes = <String>[
      '_http._tcp',
      '_https._tcp',
      '_workstation._tcp',
      '_ipp._tcp',
      '_printer._tcp',
      '_smb._tcp',
      '_ssh._tcp',
      '_googlecast._tcp',
      '_airplay._tcp',
      '_hap._tcp',
      '_matter._tcp',
    ];
    const batchSize = 5;
    for (var i = 0; i < serviceTypes.length; i += batchSize) {
      final chunk = serviceTypes.sublist(
        i,
        (i + batchSize).clamp(0, serviceTypes.length),
      );
      await Future.wait(
        chunk.map((type) async {
          BonsoirDiscovery? discovery;
          try {
            discovery = BonsoirDiscovery(type: type);
            await discovery.initialize();
            discovery.eventStream?.listen((event) {
              switch (event) {
                case BonsoirDiscoveryServiceFoundEvent():
                  event.service.resolve(discovery!.serviceResolver);
                  break;
                case BonsoirDiscoveryServiceResolvedEvent():
                  final service = event.service;
                  final nama = service.name;
                  final addresses = service.hostAddresses;
                  L.i('bonsoir resolved: ${service.name} addresses=$addresses');
                  for (final addr in addresses) {
                    if (addr.isEmpty) continue;
                    hasil[addr] = (
                      nama: (nama.isEmpty) ? null : nama,
                      vendor: null,
                       layanan: service.type,
                     );
                   }
                   break;
                default:
                  break;
              }
            });
            await discovery.start();
            await Future<void>.delayed(const Duration(seconds: 3));
          } catch (e, s) {
            L.e('Gagal bonsoir discovery $type: $e $s');
          } finally {
            if (discovery != null) {
              try {
                await discovery.stop();
              } catch (e, s) {
                L.e('Gagal stop bonsoir discovery $type: $e $s');
              }
            }
          }
        }),
      );
    }
    return hasil;
  }

  void _gabungkanServiceData(
    Map<String, ({String? nama, String? vendor, String? layanan})> serviceData,
  ) {
    final updated = state.perangkat.map((p) {
      final info = serviceData[p.ip];
      if (info == null) return p;
      return p.copyWith(
        nama: p.nama ?? info.nama,
        vendor: p.vendor ?? info.vendor,
        layanan: p.layanan ?? info.layanan,
        terakhirDilihat: DateTime.now(),
        sumberDiscovery: p.sumberDiscovery == null
            ? 'gabungan'
            : '${p.sumberDiscovery}+bonsoir',
      );
    }).toList();

    for (final entry in serviceData.entries) {
      if (updated.any((p) => p.ip == entry.key)) continue;
      final info = entry.value;
      updated.add(
        PerangkatWifiModel(
          ip: entry.key,
          nama: info.nama,
          vendor: info.vendor,
          layanan: info.layanan,
          tipePerangkat: 'Unknown',
          terakhirDilihat: DateTime.now(),
          sumberDiscovery: 'bonsoir',
        ),
      );
    }

    updated.sort((a, b) => a.ip.compareTo(b.ip));
    state = state.copyWith(perangkat: updated);
  }

}
