// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pesanan_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PesananNotifier)
final pesananProvider = PesananNotifierProvider._();

final class PesananNotifierProvider
    extends $AsyncNotifierProvider<PesananNotifier, PesananState> {
  PesananNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pesananProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pesananNotifierHash();

  @$internal
  @override
  PesananNotifier create() => PesananNotifier();
}

String _$pesananNotifierHash() => r'75b4760726b4b55441b75a683b8b9b6a60834e44';

abstract class _$PesananNotifier extends $AsyncNotifier<PesananState> {
  FutureOr<PesananState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PesananState>, PesananState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PesananState>, PesananState>,
              AsyncValue<PesananState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
