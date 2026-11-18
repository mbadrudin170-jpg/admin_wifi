// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransaksiNotifier)
final transaksiProvider = TransaksiNotifierProvider._();

final class TransaksiNotifierProvider
    extends $AsyncNotifierProvider<TransaksiNotifier, TransaksiState> {
  TransaksiNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transaksiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transaksiNotifierHash();

  @$internal
  @override
  TransaksiNotifier create() => TransaksiNotifier();
}

String _$transaksiNotifierHash() => r'ae731dcdb8d5ac7c6ba4b151725003aa8883a499';

abstract class _$TransaksiNotifier extends $AsyncNotifier<TransaksiState> {
  FutureOr<TransaksiState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TransaksiState>, TransaksiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransaksiState>, TransaksiState>,
              AsyncValue<TransaksiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
