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

String _$pelangganNotifierHash() => r'fae7f94f518719173a2db9dfd334406a8e4dcb9b';

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
