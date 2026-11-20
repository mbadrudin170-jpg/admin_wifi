// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kategori_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KategoriNotifier)
final kategoriProvider = KategoriNotifierProvider._();

final class KategoriNotifierProvider
    extends $AsyncNotifierProvider<KategoriNotifier, KategoriState> {
  KategoriNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kategoriProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kategoriNotifierHash();

  @$internal
  @override
  KategoriNotifier create() => KategoriNotifier();
}

String _$kategoriNotifierHash() => r'775b9bb5d456e61dc687fc58048f168d7b9ef46c';

abstract class _$KategoriNotifier extends $AsyncNotifier<KategoriState> {
  FutureOr<KategoriState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<KategoriState>, KategoriState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<KategoriState>, KategoriState>,
              AsyncValue<KategoriState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
