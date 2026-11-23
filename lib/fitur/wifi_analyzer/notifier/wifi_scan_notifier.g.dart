// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wifi_scan_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WifiScanNotifier)
final wifiScanProvider = WifiScanNotifierProvider._();

final class WifiScanNotifierProvider
    extends $StreamNotifierProvider<WifiScanNotifier, WifiScanState> {
  WifiScanNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wifiScanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wifiScanNotifierHash();

  @$internal
  @override
  WifiScanNotifier create() => WifiScanNotifier();
}

String _$wifiScanNotifierHash() => r'd9fb04dc070d695999bc6dae409d735799ff6111';

abstract class _$WifiScanNotifier extends $StreamNotifier<WifiScanState> {
  Stream<WifiScanState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WifiScanState>, WifiScanState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WifiScanState>, WifiScanState>,
              AsyncValue<WifiScanState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
