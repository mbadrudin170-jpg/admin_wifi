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
    extends $NotifierProvider<VoucherNotifier, String> {
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
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$voucherNotifierHash() => r'd407613c4673b75376321498155bf865ac15cc84';

abstract class _$VoucherNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
