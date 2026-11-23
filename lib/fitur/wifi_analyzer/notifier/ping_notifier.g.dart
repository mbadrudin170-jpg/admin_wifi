// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PingNotifier)
final pingProvider = PingNotifierProvider._();

final class PingNotifierProvider
    extends $NotifierProvider<PingNotifier, PingState> {
  PingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pingNotifierHash();

  @$internal
  @override
  PingNotifier create() => PingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PingState>(value),
    );
  }
}

String _$pingNotifierHash() => r'a9a1eee2027d0b2e1e2dcad01c808bd06ce10b1c';

abstract class _$PingNotifier extends $Notifier<PingState> {
  PingState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PingState, PingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PingState, PingState>,
              PingState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
