// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengguna_aktif_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PenggunaAktifNotifier)
final penggunaAktifProvider = PenggunaAktifNotifierProvider._();

final class PenggunaAktifNotifierProvider
    extends $AsyncNotifierProvider<PenggunaAktifNotifier, PelangganAktifState> {
  PenggunaAktifNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'penggunaAktifProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$penggunaAktifNotifierHash();

  @$internal
  @override
  PenggunaAktifNotifier create() => PenggunaAktifNotifier();
}

String _$penggunaAktifNotifierHash() =>
    r'8408eba1fc02b86c2f06dc78cca527fd92d3e01f';

abstract class _$PenggunaAktifNotifier
    extends $AsyncNotifier<PelangganAktifState> {
  FutureOr<PelangganAktifState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PelangganAktifState>, PelangganAktifState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PelangganAktifState>, PelangganAktifState>,
              AsyncValue<PelangganAktifState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
