// path: test/fitur/wifi_analyzer/screens/wifi_analyzer_screen_test.dart

import 'package:admin_wifi/fitur/wifi_analyzer/screens/wifi_analyzer_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:network_info_plus_platform_interface/network_info_plus_platform_interface.dart';

const String _kWifiName = '1337wifi';
const String _kBssid = 'c0:ff:33:c0:d3:55';
const String _kIp = '127.0.0.1';

class _MockNetworkInfoPlatform extends NetworkInfoPlatform {
  @override
  Future<String?> getWifiName() async => _kWifiName;

  @override
  Future<String?> getWifiBSSID() async => _kBssid;

  @override
  Future<String?> getWifiIP() async => _kIp;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('wifi_scan');
  final handlers = <String, Function(dynamic arguments)>{};

  setUp(() {
    NetworkInfoPlatform.instance = _MockNetworkInfoPlatform();
    handlers['canStartScan'] = (_) => 1; // CanStartScan.yes
    handlers['startScan'] = (_) => true;
    handlers['canGetScannedResults'] = (_) => 1; // CanGetScannedResults.yes
    handlers['getScannedResults'] = (_) => <Map<String, dynamic>>[
      <String, dynamic>{
        'ssid': 'TestSSID',
        'bssid': '00:11:22:33:44:55',
        'capabilities': 'Unknown',
        'frequency': 2412,
        'level': -40,
        'timestamp': null,
        'standard': null,
        'centerFrequency0': null,
        'centerFrequency1': null,
        'channelWidth': null,
        'isPasspoint': null,
        'operatorFriendlyName': null,
        'venueName': null,
        'is80211mcResponder': null,
      },
    ];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          final result = handlers[call.method]?.call(call.arguments);
          if (result is Future) return result;
          return Future.value(result);
        });
  });

  tearDown(() {
    handlers.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('menampilkan SSID terhubung dan AP terdeteksi', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WifiAnalyzerScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(_kWifiName), findsOneWidget);
    expect(find.textContaining('TestSSID'), findsOneWidget);
    expect(find.textContaining('Jaringan di Sekitar (1)'), findsOneWidget);
  });
}
