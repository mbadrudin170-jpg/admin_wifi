// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'versi_apk_user_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VersiApkUserNotifier)
final versiApkUserProvider = VersiApkUserNotifierProvider._();

final class VersiApkUserNotifierProvider
    extends $AsyncNotifierProvider<VersiApkUserNotifier, VersiApkUserState> {
  VersiApkUserNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'versiApkUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$versiApkUserNotifierHash();

  @$internal
  @override
  VersiApkUserNotifier create() => VersiApkUserNotifier();
}

String _$versiApkUserNotifierHash() =>
    r'b2fc3f0abc2bd953cf00a9953f8ab7f6e4bd7bc6';

abstract class _$VersiApkUserNotifier
    extends $AsyncNotifier<VersiApkUserState> {
  FutureOr<VersiApkUserState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<VersiApkUserState>, VersiApkUserState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VersiApkUserState>, VersiApkUserState>,
              AsyncValue<VersiApkUserState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
