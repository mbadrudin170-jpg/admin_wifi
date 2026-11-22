// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_kategori_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubKategoriNotifier)
final subKategoriProvider = SubKategoriNotifierProvider._();

final class SubKategoriNotifierProvider
    extends $AsyncNotifierProvider<SubKategoriNotifier, SubKategoriState> {
  SubKategoriNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subKategoriProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subKategoriNotifierHash();

  @$internal
  @override
  SubKategoriNotifier create() => SubKategoriNotifier();
}

String _$subKategoriNotifierHash() =>
    r'37c2c7f38c4de3f401c10c202c09adff2e05dcfb';

abstract class _$SubKategoriNotifier extends $AsyncNotifier<SubKategoriState> {
  FutureOr<SubKategoriState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SubKategoriState>, SubKategoriState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SubKategoriState>, SubKategoriState>,
              AsyncValue<SubKategoriState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
