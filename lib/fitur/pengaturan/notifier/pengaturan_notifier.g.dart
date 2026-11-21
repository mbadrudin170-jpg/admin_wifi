// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengaturan_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PengaturanNotifier)
final pengaturanProvider = PengaturanNotifierProvider._();

final class PengaturanNotifierProvider
    extends $AsyncNotifierProvider<PengaturanNotifier, PengaturanState> {
  PengaturanNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pengaturanProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pengaturanNotifierHash();

  @$internal
  @override
  PengaturanNotifier create() => PengaturanNotifier();
}

String _$pengaturanNotifierHash() =>
    r'4e896df9ea9c7f809592312f6ad3b5affee41405';

abstract class _$PengaturanNotifier extends $AsyncNotifier<PengaturanState> {
  FutureOr<PengaturanState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PengaturanState>, PengaturanState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PengaturanState>, PengaturanState>,
              AsyncValue<PengaturanState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
