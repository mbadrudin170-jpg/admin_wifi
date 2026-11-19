// path: lib/fitur/versi_apk_user/state/versi_apk_user_state.dart

import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'versi_apk_user_state.freezed.dart';

@freezed
abstract class VersiApkUserState with _$VersiApkUserState {
  const VersiApkUserState._();

  const factory VersiApkUserState({
    @Default([]) List<VersiApkUserModel> listVersiApkUser,
    @Default(0) int jumlahVersiApkUser,
  }) = _VersiApkUserState;
}
