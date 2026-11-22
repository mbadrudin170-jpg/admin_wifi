// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pelanggan_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PelangganNotifier)
final pelangganProvider = PelangganNotifierProvider._();

final class PelangganNotifierProvider
    extends $AsyncNotifierProvider<PelangganNotifier, PelangganState> {
  PelangganNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pelangganProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pelangganNotifierHash();

  @$internal
  @override
  PelangganNotifier create() => PelangganNotifier();
}

String _$pelangganNotifierHash() => r'903f1f7c94a8ccb5ac8c7a644d35c7a3c7f876ed';

abstract class _$PelangganNotifier extends $AsyncNotifier<PelangganState> {
  FutureOr<PelangganState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PelangganState>, PelangganState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PelangganState>, PelangganState>,
              AsyncValue<PelangganState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
