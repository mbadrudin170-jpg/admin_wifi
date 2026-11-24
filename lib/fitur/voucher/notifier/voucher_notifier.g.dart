// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VoucherNotifier)
final voucherProvider = VoucherNotifierProvider._();

final class VoucherNotifierProvider
    extends $AsyncNotifierProvider<VoucherNotifier, VoucherState> {
  VoucherNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voucherProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voucherNotifierHash();

  @$internal
  @override
  VoucherNotifier create() => VoucherNotifier();
}

String _$voucherNotifierHash() => r'ca61c25a95c315669925d9b28ed93e649168babb';

abstract class _$VoucherNotifier extends $AsyncNotifier<VoucherState> {
  FutureOr<VoucherState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<VoucherState>, VoucherState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VoucherState>, VoucherState>,
              AsyncValue<VoucherState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
