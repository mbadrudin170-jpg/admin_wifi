// path: lib/fitur/wifi_analyzer/notifier/perangkat_wifi_notifier.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admin_wifi/fitur/wifi_analyzer/model/perangkat_wifi_model.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/perangkat_wifi_state.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:dart_ping/dart_ping.dart';
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
    final ssdpFuture = _jalankanSsdpDiscovery();

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

      String? submask;
      try {
        submask = await _infoJaringan.getWifiSubmask();
      } catch (e, s) {
        L.w('Gagal baca subnet mask: $e $s');
        submask = null;
      }

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
        try {
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
                  var latency = host.responseTime?.inMilliseconds;
                  // Fallback latensi per perangkat jika TCP sweep tidak menyediakan responseTime.
                  if (latency == null && !kIsWeb) {
                    latency = await _ukurLatensiIcmp(host.address);
                  }
                  final model = PerangkatWifiModel(
                    ip: host.address,
                    nama: (nama.isEmpty || nama == ActiveHost.generic)
                        ? null
                        : nama,
                    vendor: vendor,
                    macAddress: macAddress,
                    tipePerangkat: _klasifikasikanPerangkat(
                      nama: (nama.isEmpty || nama == ActiveHost.generic)
                          ? null
                          : nama,
                      vendor: vendor,
                      services: const <String>[],
                    ),
                    services: const <String>[],
                    terakhirDilihat: DateTime.now(),
                    latencyMs: latency,
                    latencyMethod: latency == null ? null : 'ICMP',
                    discoveryMethods: const <String>['icmp'],
                    isOnline: latency != null,
                    identificationStatus:
                        vendor == null &&
                            (nama.isEmpty || nama == ActiveHost.generic)
                        ? 'tidak tersedia'
                        : 'sebagian',
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

          await _subscription!.asFuture<void>().catchError((
            Object e,
            StackTrace s,
          ) {
            L.e('Stream scan perangkat error: $e $s');
          });
        } catch (e, s) {
          L.w('HostScannerService belum siap atau gagal: $e $s');
        }
      } else {
        L.w('Tidak ada host id valid untuk subnet $subnet; lewati ICMP scan.');
      }

      // Gabungkan hasil service discovery (mDNS/Bonsoir).
      final serviceData = await discoveryFuture;
      if (ref.mounted && serviceData.isNotEmpty) {
        _gabungkanServiceData(serviceData);
      }

      // SSDP/UPnP discovery (sudah berjalan paralel).
      if (ref.mounted) {
        final ssdpData = await ssdpFuture;
        if (ref.mounted && ssdpData.isNotEmpty) {
          _gabungkanServiceData(ssdpData);
        }
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

  Future<Map<String, ({String? nama, String? vendor, List<String> services})>>
  _jalankanServiceDiscovery() async {
    final hasil =
        <String, ({String? nama, String? vendor, List<String> services})>{};
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
                    final existing = hasil[addr];
                    final services = <String>[
                      ...?existing?.services,
                      if (!(existing?.services.contains(service.type) ?? false))
                        service.type,
                    ];
                    hasil[addr] = (
                      nama: existing?.nama ?? ((nama.isEmpty) ? null : nama),
                      vendor: existing?.vendor,
                      services: services,
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

  String _klasifikasikanPerangkat({
    String? nama,
    String? vendor,
    required List<String> services,
  }) {
    final teks = '${nama ?? ''} ${vendor ?? ''} ${services.join(' ')}'
        .toLowerCase();
    if (teks.contains('printer') ||
        teks.contains('ipp') ||
        teks.contains('_printer') ||
        vendor == 'hp' ||
        vendor == 'canon' ||
        vendor == 'epson' ||
        vendor == 'brother') {
      return 'Printer';
    }
    if (teks.contains('tv') ||
        teks.contains('chromecast') ||
        teks.contains('airplay') ||
        teks.contains('roku')) {
      return 'Smart TV';
    }
    if (services.any((s) => s.contains('matter')) ||
        teks.contains('iot') ||
        teks.contains('sensor')) {
      return 'IoT';
    }
    if (vendor == 'apple' &&
        (teks.contains('iphone') || teks.contains('ipad'))) {
      return teks.contains('ipad') ? 'Tablet' : 'Smartphone';
    }
    if (vendor == 'samsung' ||
        vendor == 'xiaomi' ||
        vendor == 'oppo' ||
        vendor == 'vivo' ||
        vendor == 'realme' ||
        vendor == 'huawei') {
      if (teks.contains('tablet')) return 'Tablet';
      return 'Smartphone';
    }
    if (teks.contains('router') ||
        teks.contains('gateway') ||
        teks.contains('access point') ||
        vendor == 'tplink' ||
        vendor == 'tp-link' ||
        vendor == 'netgear' ||
        vendor == 'linksys' ||
        vendor == 'dlink' ||
        vendor == 'd-link') {
      return 'Router / Access Point';
    }
    if (teks.contains('windows') ||
        teks.contains('macbook') ||
        teks.contains('linux') ||
        teks.contains('desktop')) {
      return 'Komputer / Laptop';
    }
    return 'Unknown';
  }

  Future<Map<String, ({String? nama, String? vendor, List<String> services})>>
  _jalankanSsdpDiscovery() async {
    final hasil =
        <String, ({String? nama, String? vendor, List<String> services})>{};
    if (kIsWeb) return hasil;
    if (Platform.environment['FLUTTER_TEST'] == 'true') return hasil;
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
        reuseAddress: true,
      );
      socket.broadcastEnabled = true;
      try {
        socket.joinMulticast(InternetAddress('239.255.255.250'));
      } catch (_) {
        // Beberapa perangkat tidak mengizinkan join multicast.
      }

      const permintaan =
          'M-SEARCH * HTTP/1.1\r\n'
          'HOST: 239.255.255.250:1900\r\n'
          'MAN: "ssdp:discover"\r\n'
          'MX: 2\r\n'
          'ST: ssdp:all\r\n'
          '\r\n';
      final data = utf8.encode(permintaan);
      socket.send(data, InternetAddress('239.255.255.250'), 1900);

      final batas = DateTime.now().add(const Duration(seconds: 3));
      while (DateTime.now().isBefore(batas)) {
        if (!ref.mounted) break;
        final event = socket.receive();
        if (event == null) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (!ref.mounted) break;
          continue;
        }
        try {
          final teks = utf8.decode(event.data);
          final locationMatch = RegExp(
            r'LOCATION:\s*(.+)',
            caseSensitive: false,
          ).firstMatch(teks);
          final location = locationMatch?.group(1)?.trim();
          if (location == null || location.isEmpty) continue;
          final uri = Uri.tryParse(location);
          if (uri == null || uri.host.isEmpty) continue;
          final ip = uri.host;

          // Ambil device description XML untuk manufacturer/model.
          String? nama;
          String? vendor;
          String? tipe;
          try {
            final client = HttpClient();
            client.connectionTimeout = const Duration(seconds: 2);
            final request = await client
                .getUrl(uri)
                .timeout(const Duration(seconds: 2));
            final response = await request.close().timeout(
              const Duration(seconds: 2),
            );
            final body = await response.transform(utf8.decoder).join();
            client.close();
            nama =
                _ambilTagXml(body, 'friendlyName') ??
                _ambilTagXml(body, 'modelName');
            vendor = _ambilTagXml(body, 'manufacturer');
            tipe = _ambilTagXml(body, 'deviceType');
          } catch (_) {
            // Abaikan; tetap simpan IP.
          }

          final existing = hasil[ip];
          final services = <String>[...?existing?.services];
          const layanan = 'SSDP';
          if (!services.contains(layanan)) services.add(layanan);
          hasil[ip] = (
            nama: existing?.nama ?? nama,
            vendor: existing?.vendor ?? vendor,
            services: services,
          );
          // Simpan tipe ke nama? Tipe perangkat akan diklasifikasikan nanti.
          if (tipe != null && tipe.isNotEmpty) {
            L.i('ssdp: ip=$ip type=$tipe');
          }
        } catch (_) {
          // Abaikan paket yang tidak valid.
        }
      }
    } catch (e, s) {
      L.w('SSDP discovery gagal: $e $s');
    } finally {
      socket?.close();
    }
    return hasil;
  }

  String? _ambilTagXml(String xml, String tag) {
    final match = RegExp(
      '<$tag[^>]*>([^<]+)</$tag>',
      caseSensitive: false,
    ).firstMatch(xml);
    return match?.group(1)?.trim();
  }

  Future<int?> _ukurLatensiIcmp(String ip) async {
    try {
      final ping = Ping(ip, count: 1, timeout: 1);
      await for (final event in ping.stream.timeout(
        const Duration(seconds: 2),
      )) {
        if (event is PingResponse && event.time != null) {
          return event.time!.inMilliseconds;
        }
      }
    } catch (_) {
      // Abaikan kegagalan ICMP.
    }
    return null;
  }

  void _gabungkanServiceData(
    Map<String, ({String? nama, String? vendor, List<String> services})>
    serviceData,
  ) {
    final updated = state.perangkat.map((p) {
      final info = serviceData[p.ip];
      if (info == null) return p;
      final methods = <String>[...p.discoveryMethods];
      // Tentukan sumber berdasarkan jenis layanan yang ditemukan.
      final sumber = info.services.any((s) => s.startsWith('_'))
          ? 'bonsoir'
          : 'ssdp';
      if (!methods.contains(sumber)) methods.add(sumber);
      final services = <String>[...p.services];
      for (final s in info.services) {
        if (!services.contains(s)) services.add(s);
      }
      return p.copyWith(
        nama: p.nama ?? info.nama,
        vendor: p.vendor ?? info.vendor,
        services: services,
        tipePerangkat: p.tipePerangkat == 'Unknown'
            ? _klasifikasikanPerangkat(
                nama: p.nama ?? info.nama,
                vendor: p.vendor ?? info.vendor,
                services: services,
              )
            : p.tipePerangkat,
        terakhirDilihat: DateTime.now(),
        discoveryMethods: methods,
        sumberDiscovery: p.sumberDiscovery == null
            ? sumber
            : '${p.sumberDiscovery}+$sumber',
      );
    }).toList();

    for (final entry in serviceData.entries) {
      if (updated.any((p) => p.ip == entry.key)) continue;
      final info = entry.value;
      final services = <String>[...info.services];
      final sumber = info.services.any((s) => s.startsWith('_'))
          ? 'bonsoir'
          : 'ssdp';
      updated.add(
        PerangkatWifiModel(
          ip: entry.key,
          nama: info.nama,
          vendor: info.vendor,
          services: services,
          tipePerangkat: _klasifikasikanPerangkat(
            nama: info.nama,
            vendor: info.vendor,
            services: services,
          ),
          terakhirDilihat: DateTime.now(),
          discoveryMethods: <String>[sumber],
          isOnline: true,
          identificationStatus: 'sebagian',
          sumberDiscovery: sumber,
        ),
      );
    }

    updated.sort((a, b) => a.ip.compareTo(b.ip));
    state = state.copyWith(perangkat: updated);
  }
}
