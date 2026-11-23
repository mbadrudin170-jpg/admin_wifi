// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perangkat_wifi_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PerangkatWifiNotifier)
final perangkatWifiProvider = PerangkatWifiNotifierProvider._();

final class PerangkatWifiNotifierProvider
    extends $NotifierProvider<PerangkatWifiNotifier, PerangkatWifiState> {
  PerangkatWifiNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'perangkatWifiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$perangkatWifiNotifierHash();

  @$internal
  @override
  PerangkatWifiNotifier create() => PerangkatWifiNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PerangkatWifiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PerangkatWifiState>(value),
    );
  }
}

String _$perangkatWifiNotifierHash() =>
    r'7a208d5c140262e63cd34a420176dad286501402';

abstract class _$PerangkatWifiNotifier extends $Notifier<PerangkatWifiState> {
  PerangkatWifiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PerangkatWifiState, PerangkatWifiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PerangkatWifiState, PerangkatWifiState>,
              PerangkatWifiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
