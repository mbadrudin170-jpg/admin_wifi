// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kritik_saran_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KritikSaranNotifier)
final kritikSaranProvider = KritikSaranNotifierProvider._();

final class KritikSaranNotifierProvider
    extends $AsyncNotifierProvider<KritikSaranNotifier, KritikSaranState> {
  KritikSaranNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kritikSaranProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kritikSaranNotifierHash();

  @$internal
  @override
  KritikSaranNotifier create() => KritikSaranNotifier();
}

String _$kritikSaranNotifierHash() =>
    r'607361f9055b39cb860d99759bfb743d872d335c';

abstract class _$KritikSaranNotifier extends $AsyncNotifier<KritikSaranState> {
  FutureOr<KritikSaranState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<KritikSaranState>, KritikSaranState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<KritikSaranState>, KritikSaranState>,
              AsyncValue<KritikSaranState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
