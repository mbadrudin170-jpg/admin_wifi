// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wifi_analyzer_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WifiAnalyzerNotifier)
final wifiAnalyzerProvider = WifiAnalyzerNotifierProvider._();

final class WifiAnalyzerNotifierProvider
    extends $AsyncNotifierProvider<WifiAnalyzerNotifier, WifiAnalyzerState> {
  WifiAnalyzerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wifiAnalyzerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wifiAnalyzerNotifierHash();

  @$internal
  @override
  WifiAnalyzerNotifier create() => WifiAnalyzerNotifier();
}

String _$wifiAnalyzerNotifierHash() =>
    r'92a7b18099c9addf449444c3c3f19d6650388673';

abstract class _$WifiAnalyzerNotifier
    extends $AsyncNotifier<WifiAnalyzerState> {
  FutureOr<WifiAnalyzerState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<WifiAnalyzerState>, WifiAnalyzerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WifiAnalyzerState>, WifiAnalyzerState>,
              AsyncValue<WifiAnalyzerState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
