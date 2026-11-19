// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paket_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaketNotifier)
final paketProvider = PaketNotifierProvider._();

final class PaketNotifierProvider
    extends $AsyncNotifierProvider<PaketNotifier, PaketState> {
  PaketNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paketProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paketNotifierHash();

  @$internal
  @override
  PaketNotifier create() => PaketNotifier();
}

String _$paketNotifierHash() => r'83ba36c0593575b0b93ea506f92bb2aa902af9eb';

abstract class _$PaketNotifier extends $AsyncNotifier<PaketState> {
  FutureOr<PaketState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PaketState>, PaketState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaketState>, PaketState>,
              AsyncValue<PaketState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
