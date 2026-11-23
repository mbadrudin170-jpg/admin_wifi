// path: lib/fitur/wifi_analyzer/dummy/wifi_analyzer_dummy.dart

import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_analyzer_state.dart';

/// Data dummy `WifiAnalyzerState` untuk kebutuhan pratinjau UI.
abstract final class WifiAnalyzerDummy {
  static final WifiAnalyzerState dummyState = WifiAnalyzerState(
    ssidTerhubung: 'WiFi-Rumah',
    bssidTerhubung: 'aa:bb:cc:dd:ee:ff',
    ipTerhubung: '192.168.1.10',
  );
}
