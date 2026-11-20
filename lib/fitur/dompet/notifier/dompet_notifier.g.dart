// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dompet_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DompetNotifier)
final dompetProvider = DompetNotifierProvider._();

final class DompetNotifierProvider
    extends $AsyncNotifierProvider<DompetNotifier, DompetState> {
  DompetNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dompetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dompetNotifierHash();

  @$internal
  @override
  DompetNotifier create() => DompetNotifier();
}

String _$dompetNotifierHash() => r'1ff05707ac42683054a32da9de2ff3042c1acae0';

abstract class _$DompetNotifier extends $AsyncNotifier<DompetState> {
  FutureOr<DompetState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DompetState>, DompetState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DompetState>, DompetState>,
              AsyncValue<DompetState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
