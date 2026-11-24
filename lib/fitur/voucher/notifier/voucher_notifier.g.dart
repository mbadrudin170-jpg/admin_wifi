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
    extends $NotifierProvider<VoucherNotifier, VoucherState> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoucherState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoucherState>(value),
    );
  }
}

String _$voucherNotifierHash() => r'5c20eee7672a306d9e44de201ae01b1ce988eb2f';

abstract class _$VoucherNotifier extends $Notifier<VoucherState> {
  VoucherState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VoucherState, VoucherState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoucherState, VoucherState>,
              VoucherState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
